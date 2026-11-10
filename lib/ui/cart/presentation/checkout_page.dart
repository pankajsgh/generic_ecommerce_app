import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/cart/data/cart_controller.dart';
import 'package:flutter_ecom/ui/cart/data/model.dart';
import 'package:flutter_ecom/ui/profile/data/controller/address_controller.dart';
import 'package:flutter_ecom/ui/profile/presentation/manage_address.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CartController controller;
  late final AddressController addressController;

  @override
  void initState() {
    super.initState();

    controller = CartController();
    addressController = AddressController();
    addressController.loadAddresses();
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
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
            return _buildEmpty();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              110,
            ),
            children: [
              ListenableBuilder(listenable: controller.widgetUpdater,
                  builder: (context, _){
                    return _buildAddressSection();
                  }),

              const SizedBox(height: 6),

              _buildSectionTitle(
                'Order Items',
                '${controller.totalQty} item${controller.totalQty == 1 ? '' : 's'}',
              ),

              const SizedBox(height: 8),

              ...List.generate(
                controller.products.length,
                    (index) {
                  return _buildCheckoutItem(
                    controller.products[index],
                  );
                },
              ),

              const SizedBox(height: 4),

              _buildOrderSummary(),
            ],
          );
        },
      ),

      bottomNavigationBar: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.products.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildSubmitButton();
        },
      ),
    );
  }

// ============================================================
// ADDRESS
// ============================================================

  Widget _buildAddressSection() {
    final address = controller.address;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryButtonColor.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 19,
                  color: primaryButtonColor,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              TextButton(
                onPressed: _showAddressSelector,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  minimumSize: const Size(50, 32),
                  tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryButtonColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          if (address != null) ...[
            Text(
              address.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              '${address.address}, ${address.city}, ${address.state}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            if (address.mobile.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    address.mobile,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ] else
            Text(
              'Please select delivery address',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.shade400,
              ),
            ),
        ],
      ),
    );
  }

// ============================================================
// ADDRESS SELECTOR
// ============================================================

  Future<bool?> _showAddressSelector() async {

    WidgetUpdater updater = WidgetUpdater();

    bool? value =  await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Select Delivery Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ListenableBuilder(listenable:updater,
                    builder: (context, _){
                  return  ListView.builder(
                    shrinkWrap: true,
                    itemCount: addressController.addresses.length,
                    itemBuilder: (context, index) {
                      final address = addressController.addresses[index];

                      return _addressOption(
                        name: address.fullName,
                        address:
                        '${address.address}, '
                            '${address.city}, '
                            '${address.state}',
                        mobile: address.mobile,
                        selected: controller.address?.id== address.id,
                        onTap: () {
                          controller.setCartAddress(
                              UserAddressModel(
                                  id: address.id,
                                  name: address.fullName,
                                  mobile: address.mobile,
                                  address: address.address,
                                  state: address.state,
                                  city: address.city,
                                  country: address.country,
                                  pincode: address.pinCode
                              )
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                    }),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageAddressPage(
                            isOpenAddNew: true,
                          ),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: const Text(
                      'Add New Address',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryButtonColor,
                      side: BorderSide(
                        color: primaryButtonColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if(value!=null && value)
      {
        addressController.loadAddresses();
      }

    return value;
  }

  Widget _addressOption({
    required String name,
    required String address,
    required String mobile,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? primaryButtonColor.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? primaryButtonColor
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
                color: selected
                    ? primaryButtonColor
                    : Colors.grey.shade400,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),

                    if (mobile.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        mobile,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ============================================================
// SECTION TITLE
// ============================================================

  Widget _buildSectionTitle(
      String title,
      String trailing,
      ) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

// ============================================================
// CHECKOUT ITEM
// ============================================================

  Widget _buildCheckoutItem(
      CartProductModel item,
      ) {
    final int qty = int.tryParse(item.qty) ?? 0;

    final double rate =
        double.tryParse(item.rate) ?? 0;

    final double discountPrice =
        double.tryParse(item.discountPrice) ?? 0;

    final bool hasDiscount = discountPrice > 0;

    final double finalPrice =
    hasDiscount ? discountPrice : rate;

    final double itemTotal =
        finalPrice * qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 88,
              child: item.images.isEmpty
                  ? _imagePlaceholder()
                  : CachedNetworkImage(
                imageUrl: item.images,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                placeholder: (_, __) =>
                    _imagePlaceholder(
                      loading: true,
                    ),
                errorWidget: (_, __, ___) =>
                    _imagePlaceholder(),
              ),
            ),
          ),

          const SizedBox(width: 10),

// DETAILS
          Expanded(
            child: SizedBox(
              height: 88,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.section,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      _attribute(
                        'Color',
                        item.color,
                      ),
                      const SizedBox(width: 10),
                      _attribute(
                        'Size',
                        item.size,
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
                        'Qty: $qty',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        '₹${itemTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _attribute(
      String title,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

// ============================================================
// ORDER SUMMARY
// ============================================================

  Widget _buildOrderSummary() {
    final double subtotal = _calculateSubtotal();

    final double gst =
        double.tryParse(
          controller.gst.toString(),
        ) ??
            0;

    final double total =
        double.tryParse(
          controller.finalAmount.toString(),
        ) ??
            subtotal;

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 13),

          _summaryRow(
            'Items',
            '${controller.totalQty}',
          ),

          const SizedBox(height: 9),

          _summaryRow(
            'Subtotal',
            '₹${subtotal.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 9),

          _summaryRow(
            'GST',
            '₹${gst.toStringAsFixed(2)}',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 11,
            ),
            child: Divider(height: 1),
          ),

          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              Text(
                '₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: primaryButtonColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    double total = 0;

    for (final item in controller.products) {
      final int qty = int.tryParse(item.qty) ?? 0;

      final double rate =
          double.tryParse(item.rate) ?? 0;

      final double discount =
          double.tryParse(item.discountPrice) ?? 0;

      final double price =
      discount > 0 ? discount : rate;

      total += price * qty;
    }

    return total;
  }

  Widget _summaryRow(
      String title,
      String value,
      ) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

// ============================================================
// SUBMIT BUTTON
// ============================================================

  Widget _buildSubmitButton() {
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
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
            ),
          ],
        ),
        child: SizedBox(
          height: 45,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child:  Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: controller.orderUpdater.isLoading? [
                Center(
                  child: SizedBox(
                    height: 20,
                      width: 20,
                    child: CircularProgressIndicator(),
                  ),
                )
              ]: [
                Text(
                  'Submit Order',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitOrder() {
    if (controller.address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select delivery address',
          ),
        ),
      );
      return;
    }

    controller.submitOrder(context);




    debugPrint('Submit Order');
  }

// ============================================================
// EMPTY
// ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 55,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          const Text(
            'No items to checkout',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
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
              size: 48,
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
              child: const Text('Retry'),
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
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : Icon(
          Icons.image_outlined,
          size: 28,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
