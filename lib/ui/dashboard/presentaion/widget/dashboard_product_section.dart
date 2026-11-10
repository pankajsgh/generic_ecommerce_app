import 'package:flutter/material.dart';

import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/dashboard/data/controller/dashboard_controller.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/product_card.dart';
import 'package:flutter_ecom/ui/product_detail/presentation/product_details.dart';
import 'package:flutter_ecom/ui/search_page/presentaion/product_search_page.dart';

class DashboardProductSection extends StatelessWidget {
  final String title;
  final List<SimilarProductModel> products;
  final DashboardController controller;
  final String? sort;

  const DashboardProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.controller,
    this.sort,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return ListenableBuilder(
      listenable: controller.updateCartCount,
      builder: (context, _) {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: title,
                onViewAll: sort == null
                    ? null
                    : () => _openAll(context),
              ),

              _ProductList(
                products: products,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAll(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          short: sort!,
        ),
      ),
    );

    controller.recheckCartCount();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        10,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          if (onViewAll != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onViewAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 3,
                ),
                child: Text(
                  'View All  ›',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryButtonColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<SimilarProductModel> products;
  final DashboardController controller;

  const _ProductList({
    required this.products,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final product = products[index];

          return SizedBox(
            width: 150,
            child: ProductCardWidget(
              product: product,
              callbackAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      productId: product.id,
                      colorId: product.colorId,
                      sizeId: product.sizeId,
                    ),
                  ),
                );

                controller.recheckCartCount();
              },
            ),
          );
        },
      ),
    );
  }
}