import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/cart/data/cart_controller.dart';
import 'package:flutter_ecom/ui/cart/data/model.dart';
import 'package:flutter_ecom/ui/cart/presentation/checkout_page.dart';


class CartScreen extends StatefulWidget {
  final bool? isBack;
  const CartScreen({super.key, this.isBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartController controller;

  @override
  void initState() {
    super.initState();

    controller = CartController();
    controller.loadCart();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Row(
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (controller.products.isNotEmpty) ...[
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.itemCount}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),

      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading && controller.cart == null) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty &&
              controller.cart == null) {
            return _buildError();
          }

          if (controller.products.isEmpty) {
            return _buildEmptyCart();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshCart,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                170,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                // // Address
                // if (index == 0) {
                //   return _buildAddress();
                // }

                // // Section title
                // if (index == 1) {
                //   return Padding(
                //     padding: const EdgeInsets.only(
                //       top: 4,
                //       bottom: 10,
                //     ),
                //     child: Text(
                //       'Cart Items',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w700,
                //         color: Colors.grey.shade800,
                //       ),
                //     ),
                //   );
                // }
                //
                // final itemIndex = index - 2;
                final item = controller.products[index];

                return _buildCartItem(
                  item,
                  index,
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.products.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildBottomTotal();
        },
      ),
    );
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _buildAddress() {
    final address = controller.address;

    if (address == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 19,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Change address
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 25),
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  address.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${address.address}, ${address.city}, '
                      '${address.state}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),

                if (address.mobile.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    address.mobile,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem(
      CartProductModel item,
      int index,
      ) {
    final int qty = int.tryParse(item.qty) ?? 0;
    final int stock = int.tryParse(item.stock) ?? 0;

    final double rate = double.tryParse(item.rate) ?? 0;
    final double discountPrice =
        double.tryParse(item.discountPrice) ?? 0;

    final bool hasDiscount = discountPrice > 0;
    final double finalPrice =
    hasDiscount ? discountPrice : rate;

    final double itemTotal = finalPrice * qty;

    final bool canIncrease = qty < stock;

    final bool isOutOfStock =
        item.status.toLowerCase() == 'out-stock' ||
            stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // ========================================================
          // PRODUCT
          // ========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 68,
                  height: 82,
                  child: item.images.isEmpty
                      ? _imagePlaceholder()
                      : CachedNetworkImage(
                    imageUrl: item.images,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    memCacheWidth: 300,
                    placeholder: (_, __) {
                      return _imagePlaceholder(
                        loading: true,
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return _imagePlaceholder();
                    },
                  ),
                ),
              ),

              const SizedBox(width: 9),

              // DETAILS
              Expanded(
                child: SizedBox(
                  height: 82,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // NAME + DELETE
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.item,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          ListenableBuilder(
                            listenable:
                            controller.widgetUpdater,
                            builder: (context, _) {
                              final bool deleting =
                                  controller.widgetUpdater
                                      .isLoading &&
                                      controller.currentCartId ==
                                          item.cartId;

                              return InkWell(
                                onTap: deleting
                                    ? null
                                    : () {
                                  controller
                                      .removeFormCart(
                                    item.cartId,
                                  );
                                },
                                borderRadius:
                                BorderRadius.circular(7),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: primaryButtonColor
                                        .withValues(alpha: 0.08),
                                    borderRadius:
                                    BorderRadius.circular(7),
                                  ),
                                  child: deleting
                                      ? Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        6),
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 1.7,
                                      color:
                                      primaryButtonColor,
                                    ),
                                  )
                                      : Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    size: 16,
                                    color:
                                    primaryButtonColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // SECTION
                      Text(
                        item.section,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // COLOR + SIZE
                      Row(
                        children: [
                          _compactAttribute(
                            Icons.palette_outlined,
                            item.color,
                          ),
                          const SizedBox(width: 8),
                          _compactAttribute(
                            Icons.straighten_outlined,
                            item.size,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // PRICE + TOTAL
                      Row(
                        children: [
                          Text(
                            '₹${finalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          if (hasDiscount) ...[
                            const SizedBox(width: 5),
                            Text(
                              '₹${rate.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                                decoration:
                                TextDecoration.lineThrough,
                              ),
                            ),
                          ],

                          const Spacer(),

                          Text(
                            '₹${itemTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 6),

          // ========================================================
          // STOCK + QUANTITY
          // ========================================================

          Row(
            children: [
              // STOCK
              if (isOutOfStock)
                _stockText(
                  'Out of stock',
                  isError: true,
                )
              else
                _stockText(
                  stock <= 3
                      ? 'Only $stock left'
                      : 'In stock',
                ),

              const Spacer(),

              // ======================================================
              // QUANTITY
              // ======================================================

              ListenableBuilder(
                listenable: controller.widgetUpdater,
                builder: (context, _) {
                  final bool updating =
                      controller.widgetUpdater.isLoading &&
                          controller.currentCartId ==
                              item.cartId;

                  return Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                      BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // DECREASE
                        _quantityButton(
                          icon: Icons.remove,
                          onTap: qty > 1 && !updating
                              ? () {
                            controller.decreaseQty(
                              index,
                            );
                          }
                              : null,
                        ),

                        // QTY
                        SizedBox(
                          width: 28,
                          child: Center(
                            child: updating
                                ? SizedBox(
                              width: 13,
                              height: 13,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color:
                                primaryButtonColor,
                              ),
                            )
                                : Text(
                              item.qty,
                              style:
                              const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        // INCREASE
                        _quantityButton(
                          icon: Icons.add,
                          onTap: canIncrease && !updating
                              ? () {
                            controller.increaseQty(
                              index,
                            );
                          }
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactAttribute(
      IconData icon,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 27,
        height: 27,
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: onTap == null
                ? Colors.grey.shade300
                : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _smallAttribute(
      String title,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _stockText(
      String text, {
        bool isError = false,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isError
              ? Icons.error_outline
              : Icons.check_circle_outline,
          size: 14,
          color: isError
              ? Colors.red.shade400
              : Colors.green.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isError
                ? Colors.red.shade500
                : Colors.green.shade600,
          ),
        ),
      ],
    );
  }



  // ============================================================
  // BOTTOM TOTAL
  // ============================================================

  Widget _buildBottomTotal() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, -2),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: ListenableBuilder(listenable: controller.widgetUpdater,
            builder: (context, _){
          return Row(
            children: [
              // ----------------------------------------------------
              // TOTAL
              // ----------------------------------------------------

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.totalQty} item${controller.totalQty == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        const Text(
                          'Total ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${controller.finalAmount}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Incl. GST ₹${controller.gst}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ----------------------------------------------------
              // CHECKOUT BUTTON
              // ----------------------------------------------------

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: controller.products.isEmpty
                      ? null
                      : () async {
                   await  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(),
                      ),
                    );
                   controller.loadCart();
                    // Navigate to Checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
            })
      ),
    );
  }

  Widget _bottomPrice(
      String title,
      String value, {
        bool alignEnd = false,
      }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _buildEmptyCart() {
    return RefreshIndicator(
      onRefresh: controller.refreshCart,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),

          Icon(
            Icons.shopping_cart_outlined,
            size: 65,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Add products to your cart to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Center(
          //   child: OutlinedButton(
          //     onPressed: () {
          //       if(widget.isBack!=null)
          //         {
          //           Navigator.pop(context);
          //         }
          //       // Continue shopping
          //     },
          //     style: OutlinedButton.styleFrom(
          //       minimumSize: const Size(150, 40),
          //     ),
          //     child: const Text(
          //       'Continue Shopping',
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 12),

            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: controller.loadCart,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder({
    bool loading = false,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: loading
            ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade400,
          ),
        )
            : Icon(
          Icons.image_outlined,
          size: 30,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}




