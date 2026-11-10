import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/ui/orders/data/controller/oder_list_controller.dart';
import 'package:flutter_ecom/ui/orders/data/model/order_list_model.dart';
import 'package:flutter_ecom/ui/orders/presentation/order_detail_page.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late final OrderListController controller;

  @override
  void initState() {
    super.initState();

    controller = OrderListController();

    controller.loadOrders();
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
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Column(
            children: [
              /// STATUS FILTER
              _StatusFilterBar(
                controller: controller,
              ),

              /// ORDERS
              Expanded(
                child: _buildOrderBody(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderBody() {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff249B5A),
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return _ErrorView(
        message: controller.errorMessage,
        onRetry: controller.refreshOrders,
      );
    }

    if (controller.orders.isEmpty) {
      return const _EmptyOrders();
    }

    return RefreshIndicator(
      color: const Color(0xff249B5A),
      onRefresh: controller.refreshOrders,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          20,
        ),
        itemCount: controller.orders.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final order = controller.orders[index];

          return _OrderCard(
            order: order,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(
                    orderId: order.id,
                    orderTrackId: order.orderId,
                    ordeDate: order.orderDate,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// STATUS FILTER BAR
/// ------------------------------------------------------------

class _StatusFilterBar extends StatelessWidget {
  final OrderListController controller;

  const _StatusFilterBar({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: OrderListController.statuses.map((status) {
            final bool selected =
                controller.selectedStatus == status;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _StatusButton(
                title: status,
                selected: selected,
                loading: selected && controller.isLoading,
                onTap: () {
                  controller.changeStatus(status);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// STATUS BUTTON
/// ------------------------------------------------------------

class _StatusButton extends StatelessWidget {
  final String title;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  const _StatusButton({
    required this.title,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xff249B5A)
                : const Color(0xffF3F5F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xff249B5A)
                  : const Color(0xffE1E5E9),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : const Color(0xff56616C),
                ),
              ),
              if (loading) ...[
                const SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.7,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// ORDER CARD
/// ------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  final OrderListModel order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xffE8ECF0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                /// HEADER
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.orderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1F2933),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xffB4BBC3),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              order.orderDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xff87919C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackground(order.status),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusColor(order.status),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(order.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                /// PRODUCT AREA
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// IMAGE
                    Container(
                      height: 58,
                      width: 58,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xffF6F7F8),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: CachedNetworkImage(
                          imageUrl: order.image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) {
                            return const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: Color(0xffA8B0B8),
                              ),
                            );
                          },
                          errorWidget: (_, __, ___) {
                            return const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: Color(0xffA8B0B8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 11),

                    /// ITEMS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${order.qty} Items',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff29313A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subtotal ₹${order.subtotal.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xff89929C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// PRICE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .5,
                            color: Color(0xff929BA5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${order.finalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff20262D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xffD97706);

      case 'confirmed':
      case 'confirm':
        return const Color(0xff2563EB);

      case 'dispatched':
      case 'dispatch':
        return const Color(0xff249B5A);

      case 'cancelled':
        return const Color(0xffD93025);

      default:
        return const Color(0xff68727D);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xffFFF7E8);

      case 'confirmed':
      case 'confirm':
        return const Color(0xffEEF4FF);

      case 'dispatched':
      case 'dispatch':
        return const Color(0xffEAF8F0);

      case 'cancelled':
        return const Color(0xffFFF0F0);

      default:
        return const Color(0xffF1F3F5);
    }
  }
}
/// ------------------------------------------------------------
/// EMPTY ORDERS
/// ------------------------------------------------------------

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xffF1F4F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: Color(0xff7A8490),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff7A8490),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// ERROR VIEW
/// ------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Color(0xffD93025),
            ),
            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff7A8490),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff249B5A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}