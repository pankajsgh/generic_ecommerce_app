import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/view_full_image.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/Favourate/presentation/favourite_page.dart';
import 'package:flutter_ecom/ui/cart/presentation/cart_page.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/product_card.dart';
import 'package:flutter_ecom/ui/product_detail/data/controller/product_controller.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_ecom/ui/search_page/presentaion/product_search_page.dart';

final Color _pink = primaryButtonColor;

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String sizeId;
  final String colorId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.colorId,
    required this.sizeId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailController controller;
  late final ScrollController similarScrollController;
  late ProductData productData;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    productData = ProductData(
      id: widget.productId,
      sizeId: widget.sizeId,
      colorId: widget.colorId,
    );

    controller = ProductDetailController();
    controller.addProductId(productData);
    _pageController = PageController( initialPage: controller.selectedImageIndex, );

    similarScrollController = ScrollController();

    similarScrollController.addListener(() {
      if (!similarScrollController.hasClients) return;

      final position = similarScrollController.position;

      if (position.pixels >= position.maxScrollExtent - 300) {
        controller.loadMoreSimilarProducts(widget.productId);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    similarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (controller.productIdList.length > 1) {
          controller.removeLastProductId();
          return;
        }

        Navigator.of(context).pop();
      },
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.product == null) {
            return _buildErrorView();
          }

          final product = controller.product!;

          return Scaffold(
            appBar: AppBar(
              title:  Text(
                product.product,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              actions: [

                ValueListenableBuilder(
                    valueListenable: GlobalVars.totalFavourate,
                    builder: (context,_, __){
                      return _circleButton(
                        icon: Icons.favorite_border,
                        badge: GlobalVars.totalFavourate.value,
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavouriteScreen(

                              ),
                            ),
                          );
                        },
                      );
                    }),

                const SizedBox(width: 12),

                _circleButton(
                  icon: Icons.shopping_bag_outlined,
                  badge: product.totalCartCheck,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(isBack: true),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
              ],
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildProductSection(product)),

                  SliverToBoxAdapter(child: _buildSizeSection(product)),

                  SliverToBoxAdapter(child: _buildColorSection()),

                  SliverToBoxAdapter(child: _buildDescription(product)),

                  SliverToBoxAdapter(
                    child: _buildSimilarProducts(controller.similarProducts),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(product),
          );
        },
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
    Color iconColor = Colors.black87,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),

        if (badge != null && badge.isNotEmpty)
          Positioned(
            right: -3,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: _pink, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // PRODUCT SECTION
  // ============================================================

  Widget _buildProductSection(ProductDetailsModel product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildGallery()),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: _buildProductInfo(product)),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildGallery(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProductInfoMobile(product),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // IMAGE GALLERY
  // ============================================================

  Widget _buildGallery() {
    final size = controller.product!.sizeList.firstWhere((e) => e.isSelected);

    final color = size.colorList.firstWhere((e) => e.isSelected);

    final List<ImageListModel> images = color.imageList;

    final ImageListModel currentImage = images.isNotEmpty
        ? images[controller.selectedImageIndex]
        : ImageListModel(img: '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width / 0.8,
          width:MediaQuery.of(context).size.width-70 ,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              controller.selectImage(index);
            },
            itemBuilder: (context, index) {
              final currentImage = images[index];
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: currentImage.img.isEmpty
                          ? _imagePlaceholder()
                          : CachedNetworkImage(
                              imageUrl: currentImage.img,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              memCacheWidth: 600,
                              placeholder: (_, __) {
                                return _imagePlaceholder(loading: true);
                              },
                              errorWidget: (_, __, ___) {
                                return _imagePlaceholder();
                              },
                            ),
                    ),
                  ),
                  if (controller.selectedStock == '0')
                    Positioned(
                      left: 12,
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryRedButtonColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 20,
                    top: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: controller.toggleFavourite,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            controller.product!.favourate == '1'
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: primaryRedButtonColor,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 10,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: currentImage.img.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(
                                      imageUrl: currentImage.img,
                                    ),
                                  ),
                                );
                              },
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(Icons.fullscreen_rounded, size: 21),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(
            width: 60,
            height: MediaQuery.of(context).size.width / 0.8,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              scrollDirection: Axis.vertical,
              itemCount: images.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 6);
              },
              itemBuilder: (context, index) {
                final image = images[index];
                final selected = controller.selectedImageIndex == index;
                return GestureDetector(
                  onTap: () {
                    controller.selectImage(index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? _pink : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: _pink.withValues(alpha: .15),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: image.img.isEmpty
                          ? _imagePlaceholder()
                          : CachedNetworkImage(
                              imageUrl: image.img,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                              placeholder: (_, __) {
                                return _imagePlaceholder();
                              },
                              errorWidget: (_, __, ___) {
                                return _imagePlaceholder();
                              },
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 1.8),
              )
            : const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
      ),
    );
  }

  // ============================================================
  // PRODUCT INFO
  // ============================================================

  Widget _buildProductInfo(ProductDetailsModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.section,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _pink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          product.product,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        _infoRow(Icons.tag_outlined, 'HSN Code', product.hsnCode),

        const SizedBox(height: 7),

        Row(
          children: [
            const Icon(
              Icons.star_border_rounded,
              color: Color(0xffffb000),
              size: 20,
            ),
            const SizedBox(width: 4),
            const Text(
              '0.0',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            Text(
              '(0 Reviews)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          '₹${controller.selectedSalePrice}',
          style: TextStyle(
            color: _pink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        _infoRow(
          Icons.inventory_2_outlined,
          'Stock',
          controller.selectedStock == '0' ? 'Out of Stock' : 'In Stock',
          valueColor: controller.selectedStock == '0' ? _pink : Colors.green,
        ),

        const SizedBox(height: 7),

        _infoRow(
          Icons.calendar_month_outlined,
          'Preorder',
          product.allowPreorder == '1' ? 'Available' : 'Not Available',
          valueColor: product.allowPreorder == '1'
              ? Colors.green
              : Colors.grey.shade700,
        ),

        const SizedBox(height: 7),

        _infoRow(
          Icons.content_cut_rounded,
          'Custom Order',
          product.customiseOrder == '1' ? 'Available' : 'Not Available',
          valueColor: product.customiseOrder == '1'
              ? Colors.green
              : Colors.grey.shade700,
        ),

        const SizedBox(height: 7),

        _infoRow(Icons.sell_outlined, 'Section', product.section),
      ],
    );
  }

  Widget _buildProductInfoMobile(ProductDetailsModel product) {
    final bool inStock = controller.selectedStock != '0';
    final bool preorder = product.allowPreorder == '1';
    final bool customOrder = product.customiseOrder == '1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 3),

        // ─────────────────────────────────────
        // HEADER
        // ─────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.section,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _pink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  _ratingInfoRow(),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${controller.selectedSalePrice}',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 5),

                _stockBadge(inStock),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ─────────────────────────────────────
        // INFORMATION
        // ─────────────────────────────────────
        // Row(
        //   children: [
        //     Expanded(
        //       child: _productInfoCard(
        //         icon: Icons.tag_rounded,
        //         label: 'HSN Code',
        //         value: product.hsnCode.isEmpty
        //             ? 'N/A'
        //             : product.hsnCode,
        //       ),
        //     ),
        //
        //     const SizedBox(width: 9),
        //
        //     Expanded(
        //       child: _productInfoCard(
        //         icon: Icons.sell_outlined,
        //         label: 'Section',
        //         value: product.section.isEmpty
        //             ? 'N/A'
        //             : product.section,
        //       ),
        //     ),
        //   ],
        // ),
        //
        // const SizedBox(height: 9),

        Row(
          children: [
            Expanded(
              child: _productStatusCard(
                icon: Icons.calendar_month_rounded,
                label: 'Preorder',
                value: preorder
                    ? 'Available'
                    : 'Not Available',
                active: preorder,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: _productStatusCard(
                icon: Icons.content_cut_rounded,
                label: 'Custom Order',
                value: customOrder
                    ? 'Available'
                    : 'Not Available',
                active: customOrder,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stockBadge(bool inStock) {
    final color = inStock
        ? _pink
        : primaryRedButtonColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: .18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            inStock ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  Widget _productInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withValues(alpha: .26),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _pink.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: _pink,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _productStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required bool active,
  }) {
    final color = active
        ? Colors.green
        : Colors.grey.shade600;

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withValues(alpha: .045)
            : colorScheme.surfaceContainerHighest
            .withValues(alpha: .20),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: active
              ? Colors.green.withValues(alpha: .18)
              : colorScheme.outlineVariant
              .withValues(alpha: .30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            active
                ? Icons.check_circle_rounded
                : Icons.cancel_outlined,
            size: 15,
            color: color,
          ),
        ],
      ),
    );
  }
  Widget _ratingInfoRow() {
    return Row(
      children: [
        const Icon(
          Icons.star_border_rounded,
          color: Color(0xffffb000),
          size: 20,
        ),
        const SizedBox(width: 5),
        const Text(
          '0.0',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '(0 Reviews)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 7),
        Text(
          '$title: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _counterCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _pink, size: 20),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIZE
  // ============================================================

  Widget _buildSizeSection(ProductDetailsModel product) {
    if (product.sizeList.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Size',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: product.sizeList.map((size) {
              final selected = controller.selectedSize == size.size;

              return GestureDetector(
                onTap: () {
                  controller.selectSize(size.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 62,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xfffff7fa) : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selected ? _pink : const Color(0xffe2e2e7),
                      width: selected ? 1.3 : 1,
                    ),
                  ),
                  child: Text(
                    size.size,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? _pink : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLOR
  // ============================================================

  Widget _buildColorSection() {
    final colors = controller.colorList;

    if (colors.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text(
              'Select Color',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 10);
              },
              itemBuilder: (context, index) {
                return _buildColorCard(colors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(ColorListModel color) {
    final selected = controller.selectedColor == color.color;

    String image = color.images;

    if (image.isEmpty && color.imageList.isNotEmpty) {
      image = color.imageList.first.img;
    }

    final inStock = color.stock != '0';

    return GestureDetector(
      onTap: () {
        controller.selectColor(color.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 170,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xfffff8fa) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _pink : const Color(0xffe2e2e7),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 52,
                height: 52,
                child: image.isEmpty
                    ? _imagePlaceholder()
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        memCacheWidth: 200,
                        placeholder: (_, __) {
                          return _imagePlaceholder(loading: true);
                        },

                        errorWidget: (_, __, ___) {
                          return _imagePlaceholder();
                        },
                      ),
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    color.color.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),


                  Text(
                    '₹${color.salePrice}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),


                  Text(
                    inStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: inStock ? Colors.green : _pink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription(ProductDetailsModel product) {
    final description = product.description.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f9),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 5),

            Text(
              description.isEmpty
                  ? 'No description available for this product.'
                  : description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),

            if (description.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.only(top: 4, left: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    _showDescription(product.description);
                  },
                  child: Text(
                    'Read More ↓',
                    style: TextStyle(
                      fontSize: 12,
                      color: _pink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDescription(String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.loadProduct(productData);
            },

            child: Padding(
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),

                    const Divider(),

                    const SizedBox(height: 7),

                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SIMILAR PRODUCTS
  // ============================================================

  Widget _buildSimilarProducts(List<SimilarProductModel> similarProducts) {
    if (controller.similarProducts.isEmpty &&
        !controller.isSimilarProductLoading) {
      return const SizedBox();
    }

    final int itemCount =
        controller.similarProducts.length +
        (controller.isSimilarProductLoadingMore ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'Similar Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: controller.similarProducts.isEmpty
                      ? null
                      : () {
                          // View all
                        },
                  child: Text(
                    'View All →',
                    style: TextStyle(
                      fontSize: 12,
                      color: _pink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 12),

              itemCount: itemCount,

              separatorBuilder: (_, __) {
                return const SizedBox(width: 9);
              },

              itemBuilder: (context, index) {
                // ------------------------------------------------
                // Loading indicator at the end
                // ------------------------------------------------

                if (index >= controller.similarProducts.length) {
                  return const SizedBox(
                    width: 50,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final SimilarProductModel similarProduct = controller.similarProducts[index];

                return SizedBox(
                  width: 160,
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 14.0 : 0.0),
                    child: ProductCardWidget(
                        product: similarProduct,
                        callbackAction: (){
                          ProductData newProductData = ProductData(id: similarProduct.id, sizeId: similarProduct.sizeId, colorId: similarProduct.colorId);
                          controller.addProductId(newProductData);
                      },

                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductDetailsModel product) {
    return ListenableBuilder(
      listenable: controller.widgetUpdater,
      builder: (context, _) {
        final canAdd = controller.canProceedToCart;
        final isInCart = controller.isInCart;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Wishlist
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: controller.toggleFavourite,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _pink,
                        side: BorderSide(color: _pink, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      icon: Icon(
                        product.favourate == '1'
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 19,
                      ),
                      label: const Text(
                        'Wishlist',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Add to cart
                if (!isInCart) ...[
                  const SizedBox(width: 8),

                  ListenableBuilder(
                    listenable: controller.widgetUpdater,
                    builder: (context, _) {
                      print("this is good88");

                      return Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: canAdd
                                ? () async {
                                    await controller.addToCart(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pink,
                              disabledBackgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey.shade600,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            icon: controller.widgetUpdater.isLoading
                                ? SizedBox()
                                : const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 19,
                                  ),
                            label: controller.widgetUpdater.isLoading
                                ? Center(
                                    child: SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const SizedBox(width: 8),

                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pink.withValues(alpha: 0.7),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey.shade600,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        icon: const Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 19,
                        ),
                        label: const Text(
                          'Added in cart',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.grey),

              const SizedBox(height: 12),

              Text(
                controller.errorMessage.isEmpty
                    ? 'Unable to load product'
                    : controller.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    controller.loadProduct(productData);
                  },
                  child: const Text('Retry', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
