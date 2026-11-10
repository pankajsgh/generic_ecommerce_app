import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ecom/ui/orders/data/controller/order_detail_controller.dart';
import 'package:flutter_ecom/ui/orders/data/model/order_list_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String orderTrackId;
  final String ordeDate;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.ordeDate,
    required this.orderTrackId,
  });

  @override
  State<OrderDetailScreen> createState() =>
      _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderDetailController controller;

  @override
  void initState() {
    super.initState();

    controller = OrderDetailController();
    controller.loadOrderDetail(widget.orderId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leadingWidth: 40,

        titleSpacing: 4,

        title: Text(
          widget.orderTrackId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          Text(
            widget.ordeDate,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xff68727D),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          // LOADING
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          // ERROR
          if (controller.errorMessage.isNotEmpty) {
            return _buildError();
          }

          final order = controller.order;

          // EMPTY
          if (order == null) {
            return const Center(
              child: Text(
                'Order not found',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff68727D),
                ),
              ),
            );
          }

          // CONTENT
          return RefreshIndicator(
            onRefresh: () =>
                controller.loadOrderDetail(widget.orderId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                16,
              ),
              children: [
                // STATUS
                _buildOrderHeader(order),

                const SizedBox(height: 8),

                // PRODUCTS
                _buildProducts(order),

                const SizedBox(height: 8),

                // PAYMENT
                _buildTotals(order),

                // SHIPPING
                if (order.shippingAddress != null) ...[
                  const SizedBox(height: 8),
                  _buildShippingAddress(
                    order.shippingAddress!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 8),

            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xff68727D),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed:(){
                  controller.loadOrderDetail(
                    widget.orderId,
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ORDER HEADER
  // ==========================================================

  Widget _buildOrderHeader(OrderDetailModel order) {
    return _SectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      child: OrderStatusTracker(
        status: order.orderStatus,
      ),
    );
  }

  // ==========================================================
  // PRODUCTS
  // ==========================================================

  Widget _buildProducts(OrderDetailModel order) {
    return _SectionCard(
      title: 'Order Items (${order.products.length})',
      child: Column(
        children: [
          ...order.products.map(
                (product) => _ProductItem(
              product: product,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAYMENT SUMMARY
  // ==========================================================

  Widget _buildTotals(OrderDetailModel order) {
    final totals = order.totals;

    return _SectionCard(
      title: 'Payment Summary',
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            '₹${totals.subtotal.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 6),

          _summaryRow(
            'GST',
            '₹${totals.gst.toStringAsFixed(0)}',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Divider(
              height: 1,
            ),
          ),

          _summaryRow(
            'Grand Total',
            '₹${totals.finalAmount.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: bold ? 12 : 11,
            fontWeight:
            bold ? FontWeight.w700 : FontWeight.w400,
            color: bold
                ? Colors.black
                : const Color(0xff68727D),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 14 : 11.5,
            fontWeight:
            bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SHIPPING ADDRESS
  // ==========================================================

  Widget _buildShippingAddress(
      ShippingAddressModel address,
      ) {
    return _SectionCard(
      title: 'Shipping Address',
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // NAME + MOBILE
          Row(
            children: [
              Expanded(
                child: Text(
                  address.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (address.mobile.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.phone_outlined,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 3),
                Text(
                  address.mobile,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff68727D),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // ADDRESS
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Color(0xff68727D),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  [
                    address.address,
                    address.city,
                    address.state,
                    address.pincode,
                  ]
                      .where(
                        (e) => e.trim().isNotEmpty,
                  )
                      .join(', '),
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: Color(0xff4D5660),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PRODUCT ITEM
// ==================================================================

class _ProductItem extends StatelessWidget {
  final OrderProductModel product;

  const _ProductItem({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 7,
      ),
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffEEF0F2),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ========================================================
          // IMAGE
          // ========================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: product.image,
              height: 68,
              width: 60,
              fit: BoxFit.cover,
              memCacheWidth: 250,
              placeholder: (_, __) {
                return _imagePlaceholder();
              },
              errorWidget: (_, __, ___) {
                return _imagePlaceholder();
              },
            ),
          ),

          const SizedBox(width: 8),

          // ========================================================
          // DETAILS
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // NAME + PRICE
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.product,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      '₹${product.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // SECTION
                Text(
                  product.section,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xff7A8490),
                  ),
                ),

                const SizedBox(height: 5),

                // ATTRIBUTES
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: [
                    _InfoChip(
                      label:
                      'Color: ${product.color}',
                    ),
                    _InfoChip(
                      label:
                      'Size: ${product.size}',
                    ),
                    _InfoChip(
                      label:
                      'Qty: ${product.qty}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 68,
      width: 60,
      color: const Color(0xffF1F3F5),
      child: const Icon(
        Icons.image_outlined,
        size: 21,
        color: Color(0xffAAB1B8),
      ),
    );
  }
}

// ==================================================================
// INFO CHIP
// ==================================================================

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6F8),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xff68727D),
        ),
      ),
    );
  }
}

// ==================================================================
// SECTION CARD
// ==================================================================

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffE9EDF2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),
          ],

          child,
        ],
      ),
    );
  }
}

// ==================================================================
// ORDER STATUS TRACKER
// ==================================================================



class OrderStatusTracker extends StatelessWidget {
  final String status;

  const OrderStatusTracker({
    super.key,
    required this.status,
  });

  // ==========================================================
  // CURRENT STATUS
  // ==========================================================

  int get currentIndex {
    final value = status.trim().toLowerCase();

    if (value == 'pending') {
      return 0;
    }

    if (value == 'confirm' || value == 'confirmed') {
      return 1;
    }

    if (value == 'dispatch' || value == 'dispatched') {
      return 2;
    }

    return 0;
  }

  // ==========================================================
  // CANCELLED
  // ==========================================================

  bool get isCancelled {
    return status.trim().toLowerCase() == 'cancelled';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (isCancelled) {
      return _cancelledView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      child: SizedBox(
        height: 34,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double circleSize = 17;
            const double lineHeight = 2;

            final double stepWidth = constraints.maxWidth / 3;

            // Circle center positions
            final double firstCenter = stepWidth / 2;
            final double secondCenter = stepWidth * 1.5;
            final double thirdCenter = stepWidth * 2.5;

            // Start after first circle
            final double lineStart =
                firstCenter + (circleSize / 2);

            // End before last circle
            final double lineEnd =
                thirdCenter - (circleSize / 2);

            return Stack(
              children: [
                // ==================================================
                // CONNECTING LINE
                // ==================================================

                Positioned(
                  left: lineStart,
                  right: constraints.maxWidth - lineEnd,
                  top: (circleSize - lineHeight) / 2,
                  child: Row(
                    children: [
                      // Pending -> Confirmed
                      Expanded(
                        child: Container(
                          height: lineHeight,
                          color: currentIndex >= 1
                              ? const Color(0xff249B5A)
                              : const Color(0xffD9DEE5),
                        ),
                      ),

                      // Confirmed -> Dispatched
                      Expanded(
                        child: Container(
                          height: lineHeight,
                          color: currentIndex >= 2
                              ? const Color(0xff249B5A)
                              : const Color(0xffD9DEE5),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // STEPS
                // ==================================================

                Row(
                  children: [
                    _step(
                      index: 0,
                      title: 'Pending',
                    ),
                    _step(
                      index: 1,
                      title: 'Confirmed',
                    ),
                    _step(
                      index: 2,
                      title: 'Dispatched',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // STEP
  // ==========================================================

  Widget _step({
    required int index,
    required String title,
  }) {
    final bool completed = currentIndex >= index;
    final bool active = currentIndex == index;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ====================================================
          // CIRCLE
          // ====================================================

          SizedBox(
            height: 17,
            child: Center(
              child: _circle(
                index: index,
                completed: completed,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // ====================================================
          // TITLE
          // ====================================================

          SizedBox(
            height: 12,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1,
                fontWeight: active || completed
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: active || completed
                    ? const Color(0xff249B5A)
                    : const Color(0xff7A8490),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CIRCLE
  // ==========================================================

  Widget _circle({
    required int index,
    required bool completed,
  }) {
    final bool isCurrent = currentIndex == index;

    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? const Color(0xff249B5A)
            : const Color(0xffE8ECF1),
        border: isCurrent
            ? Border.all(
          color: const Color(0xff249B5A),
          width: 1.5,
        )
            : null,
      ),
      child: isCurrent
          ? const Icon(
        Icons.check,
        size: 10,
        color: Colors.white,
      )
          : null,
    );
  }

  // ==========================================================
  // CANCELLED
  // ==========================================================

  Widget _cancelledView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFFF1F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffffdddd),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Color(0xffD93025),
            size: 18,
          ),
          SizedBox(width: 7),
          Text(
            'Order Cancelled',
            style: TextStyle(
              color: Color(0xffD93025),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
