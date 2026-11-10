import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/product_detail/presentation/product_details.dart';
import 'package:flutter_ecom/ui/search_page/data/controller/product_search_controller.dart';
import 'package:flutter_ecom/ui/search_page/data/model/product_model.dart';
import 'package:flutter_ecom/ui/search_page/presentaion/color_filter_view.dart';

class ProductSearchPage extends StatefulWidget {
  final String? short;
  final String? genderType;
  final SectionModel? section;
  const ProductSearchPage({
    super.key,
    this.short,
    this.genderType,
    this.section,

  });

  @override
  State<ProductSearchPage> createState() =>
      _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  late final ProductSearchController controller;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller = ProductSearchController();
    if(widget.short!=null && widget.short!.isNotEmpty)
    {
      controller.setType(widget.short!);
    }
    if(widget.genderType!=null && widget.genderType!.isNotEmpty)
      {
        controller.setGenderType(widget.genderType!);
      }

    if(widget.section!=null && widget.section!.id.isNotEmpty)
    {
      controller.addSection(widget.section!);
    }

    controller.initialize();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,

        title: const Text(
          'Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final count = controller.selectedFilterCount;


              return IconButton(
                tooltip: 'Filters',

                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },

                icon: Badge(
                  isLabelVisible: count > 0,

                  label: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  child: const Icon(
                    Icons.tune_rounded,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      // ========================================================
      // FILTER DRAWER
      // ========================================================

      endDrawer: _buildFilterDrawer(),

      // ========================================================
      // BODY
      // ========================================================

      body: ListenableBuilder(
        listenable: controller,

        builder: (
            context,
            child,
            ) {
          return Column(
            children: [
              // SEARCH
              _buildSearch(),

              // FILTER + SORT
              _buildFilterBar(),

              // SELECTED FILTERS
              _buildSelectedFilters(),

              const Divider(
                height: 1,
              ),

              // PRODUCTS
              Expanded(
                child: _buildProducts(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        6,
      ),

      child: SizedBox(
        height: 46,
        child: TextField(
          controller: searchController,
          focusNode: focusNode,

          onChanged: (value) {
            setState(() {});

            controller.onSearchChanged(
              value,
            );
          },

          textInputAction:
          TextInputAction.search,

          decoration: InputDecoration(
            hintText: 'Search products...',

            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),

            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 21,
            ),

            suffixIcon:
            searchController.text.isNotEmpty
                ? IconButton(
              tooltip: 'Clear',

              onPressed: () {
                searchController.clear();

                setState(() {});

                controller.onSearchChanged(
                  '',
                );
              },

              icon: const Icon(
                Icons.close_rounded,
                size: 19,
              ),
            )
                : null,

            filled: true,

            fillColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(.55),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),

              borderSide: BorderSide.none,
            ),

            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),

              borderSide: BorderSide.none,
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),

              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary,

                width: 1,
              ),
            ),

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER + SORT BAR
  // ============================================================

  Widget _buildFilterBar() {
    final filterCount = controller.selectedFilterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        5,
        12,
        6,
      ),

      child: Row(
        children: [
          // FILTER
          Expanded(
            child: _actionButton(
              icon: Icons.tune_rounded,

              title: filterCount > 0
                  ? 'Filters  •  $filterCount'
                  : 'Filters',

              active: filterCount > 0,

              onTap: () {
                focusNode.unfocus();
                _scaffoldKey.currentState
                    ?.openEndDrawer();
              },
            ),
          ),

          const SizedBox(width: 8),

          // SORT
          Expanded(
            child: _actionButton(
              icon: Icons.swap_vert_rounded,

              title: 'Sort',

              onTap: _openSortSheet,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Material(
      color: active
          ? primary.withValues(alpha: .09)
          : Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: .5),

      borderRadius:
      BorderRadius.circular(12),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),

        onTap: onTap,

        child: Container(
          height: 36,

          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(12),

            border: Border.all(
              color: active
                  ? primary.withOpacity(.35)
                  : Colors.transparent,
            ),
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 19,
                color: active
                    ? primary
                    : null,
              ),

              const SizedBox(width: 7),

              Text(
                title,

                style: TextStyle(
                  fontSize: 13,

                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w500,

                  color: active
                      ? primary
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED FILTERS
  // ============================================================

  Widget _buildSelectedFilters() {
    final hasFilters =
        controller.selectedSections.isNotEmpty ||
            controller.selectedColors.isNotEmpty ||
            controller.selectedSizes.isNotEmpty;

    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,

      child: ListView(
        scrollDirection:
        Axis.horizontal,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),

        children: [
          // SECTION
          ...controller.selectedSections.map(
                (section) {
              return _filterChip(
                section.section,

                    () {
                  controller.clearSection(
                    section,
                  );
                },
              );
            },
          ),

          // COLOR
          ...controller.selectedColors.map(
                (color) {
              return _filterChip(
                color.colorName,

                    () {
                  controller.clearColor(
                    color,
                  );
                },
              );
            },
          ),

          // SIZE
          ...controller.selectedSizes.map(
                (size) {
              return _filterChip(
                size.sizeName,

                    () {
                  controller.clearSize(
                    size,
                  );
                },
              );
            },
          ),

          Padding(
            padding:
            const EdgeInsets.only(
              left: 2,
            ),

            child: TextButton(
              onPressed:
              controller.clearAllFilters,

              style:
              TextButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),

              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _filterChip(
      String text,
      VoidCallback onDelete,
      ) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Chip(
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        deleteIcon: const Icon(
          Icons.close_rounded,
          size: 11,
        ),
        onDeleted: onDelete,

        // Smaller height
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(
          horizontal: -3,
          vertical: -4,
        ),

        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Widget _buildProducts() {
    if (controller.isLoading) {
      return _buildLoading();
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.products.isEmpty) {
      return _buildError();
    }

    if (controller.products.isEmpty) {
      return _buildEmpty();
    }

    return NotificationListener<
        ScrollNotification>(
      onNotification:
          (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent -
                300) {
          controller.loadProducts(
            loadMore: true,
          );
        }

        return false;
      },

      child: GridView.builder(
        padding:
        const EdgeInsets.fromLTRB(
          12,
          12,
          12,
          20,
        ),

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .6,
        ),

        itemCount:
        controller.products.length +
            (controller.isLoadingMore
                ? 2
                : 0),

        itemBuilder: (
            context,
            index,
            ) {
          if (index >=
              controller.products.length) {
            return _buildLoadingCard();
          }

          final product =
          controller.products[index];

          return _buildProductCard(
            product,
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
      ProductModel product,
      ) {
    final isInStock = product.status
        .toLowerCase()
        .contains('stock');

    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              productId: product.id,
              colorId: product.colorId,
              sizeId: product.sizeId,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior:
        Clip.antiAlias,

        elevation: 0,

        margin: EdgeInsets.zero,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(8),

          side: BorderSide(
            color:
            Colors.grey.withOpacity(.12),
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.image
                        .isEmpty
                        ? Container(
                      color:
                      Colors.grey.shade100,

                      child: Icon(
                        Icons
                            .image_not_supported_outlined,

                        size: 40,

                        color: Colors
                            .grey
                            .shade400,
                      ),
                    )
                        : CachedNetworkImage(
                      imageUrl:  product.image,
                      alignment: Alignment.topCenter,
                      width:
                      double.infinity,
                      memCacheWidth: 300,

                      fit: BoxFit.fitWidth,

                      errorWidget:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color:
                          Colors.grey.shade100,

                          child: Icon(
                            Icons
                                .broken_image_outlined,

                            color: Colors
                                .grey
                                .shade400,
                          ),
                        );
                      },
                    ),
                  ),

                  // =================================================
                  // STATUS
                  // =================================================

                  Positioned(
                    top: 8,
                    right: 8,

                    child: Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withOpacity(.92),

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Text(
                        product.status,

                        style: TextStyle(
                          fontSize: 10,

                          fontWeight:
                          FontWeight.w600,

                          color: isInStock
                              ? Colors.green
                              .shade700
                              : Colors.red
                              .shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // PRODUCT INFO
            // ======================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                9,
                4,
                9,
                6,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    product.product,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    const TextStyle(
                      fontSize: 14,

                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.colorName} • ${product.sizeName}',

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 11,

                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),

                      if (product
                          .salePrice
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 7,
                        ),

                        Text(
                          '₹${product.salePrice}',

                          style:
                          const TextStyle(
                            fontSize: 13,

                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ============================================================
  // LOADING CARD
  // ============================================================

  Widget _buildLoadingCard() {
    return const Card(
      elevation: 0,

      child: Center(
        child:
        CircularProgressIndicator(),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .cloud_off_rounded,

              size: 48,

              color:
              Colors.grey.shade400,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              controller.errorMessage,

              textAlign:
              TextAlign.center,

              style: TextStyle(
                fontSize: 13,

                color:
                Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            OutlinedButton.icon(
              onPressed: () {
                controller.loadProducts();
              },

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Container(
            width: 72,
            height: 72,

            decoration:
            BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons
                  .inventory_2_outlined,

              size: 36,

              color:
              Colors.grey.shade500,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'No products found',

            style: TextStyle(
              fontSize: 15,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Try changing your search or filters',

            style: TextStyle(
              fontSize: 12,

              color:
              Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER DRAWER
  // ============================================================

  Widget _buildFilterDrawer() {
    return Drawer(
      width:
      MediaQuery.of(context).size.width *
          .88,

      child: SafeArea(
        child: StatefulBuilder(
          builder: (
              context,
              setDrawerState,
              ) {
            return Column(
              children: [
                // HEADER
                _buildDrawerHeader(
                  setDrawerState,
                ),

                const Divider(
                  height: 1,
                ),

                // FILTER CONTENT
                Expanded(
                  child:
                  DefaultTabController(
                    length: 3,

                    child: Column(
                      children: [
                        _buildFilterTabs(),

                        Expanded(
                          child:
                          TabBarView(
                            children: [
                              // SECTION
                              _buildSectionFilter(
                                    () {
                                  setDrawerState(
                                        () {},
                                  );
                                },
                              ),

                              // COLOR
                              _buildColorFilter(
                                    () {
                                  setDrawerState(
                                        () {},
                                  );
                                },
                              ),

                              // SIZE
                              _buildSizeFilter(
                                    () {
                                  setDrawerState(
                                        () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM ACTIONS
                _buildDrawerBottomBar(
                  setDrawerState,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER HEADER
  // ============================================================

  Widget _buildDrawerHeader(
      StateSetter setDrawerState,
      ) {
    final count =
        controller.selectedFilterCount;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        14,
        10,
        12,
      ),

      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,

            decoration:
            BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: .10),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              Icons.tune_rounded,

              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  'Filter Products',

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 200,
                  ),

                  child: Text(
                    count == 0
                        ? 'Refine your product search'
                        : '$count filter${count == 1 ? '' : 's'} selected',

                    key: ValueKey(
                      count,
                    ),

                    style: TextStyle(
                      fontSize: 12,

                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Close',

            onPressed: () {
              Navigator.pop(
                context,
              );
            },

            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER TABS
  // ============================================================

  Widget _buildFilterTabs() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        8,
      ),

      child: Container(
        height: 44,

        decoration:
        BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: .55),

          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),

        child: TabBar(
          dividerColor:
          Colors.transparent,

          indicatorSize:
          TabBarIndicatorSize.tab,

          indicator:
          BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary,

            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),

          labelColor:
          Colors.white,

          unselectedLabelColor:
          Colors.grey.shade700,

          labelStyle:
          const TextStyle(
            fontSize: 12,

            fontWeight:
            FontWeight.w600,
          ),

          unselectedLabelStyle:
          const TextStyle(
            fontSize: 12,

            fontWeight:
            FontWeight.w500,
          ),

          padding:
          const EdgeInsets.all(
            3,
          ),

          tabs: const [
            Tab(
              text: 'Section',
            ),

            Tab(
              text: 'Color',
            ),

            Tab(
              text: 'Size',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION FILTER
  // ============================================================

  Widget _buildSectionFilter(
      VoidCallback refresh,
      ) {
    if (controller.sections.isEmpty) {
      return _emptyFilter(
        Icons.category_outlined,
        'No sections available',
      );
    }

    // Get available gender types from sections
    final genders = controller.sections
        .map((e) => e.genderType.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    // Default to first available gender
    controller.selectedGender ??= genders.isNotEmpty ? genders.first : null;

    print("this is good");
    print(controller.selectedGender);


    final filteredSections = controller.sections.where((section) {
      if (controller.selectedGender == null) {
        return true;
      }
      return section.genderType.trim().toLowerCase() == controller.selectedGender!.toLowerCase();}).toList();

    return Column(
      children: [
        // ─────────────────────────────
        // GENDER SELECTOR
        // ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            10,
          ),
          child: _buildGenderSelector(
            ["Men", 'Women'],
            refresh,
          ),
        ),

        // ─────────────────────────────
        // SECTION LIST
        // ─────────────────────────────
        Expanded(
          child: filteredSections.isEmpty
              ? _emptyFilter(
            Icons.category_outlined,
            'No sections available',
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              14,
              2,
              14,
              20,
            ),
            itemCount: filteredSections.length,
            separatorBuilder: (_, __) {
              return const SizedBox(height: 6);
            },
            itemBuilder: (context, index) {
              final section = filteredSections[index];

              final selected = controller.isSectionSelected(section);

              return _filterOptionTile(
                title: section.section,
                selected: selected,
                onTap: () {
                  controller.toggleSection(section);
                  refresh();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(
      List<String> genders,
      VoidCallback refresh,
      ) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: .45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _genderItem(
              title: 'Men',
              icon: Icons.man_rounded,
              value: 'men',
              primary: primary,
              refresh: refresh,
            ),
          ),

           const SizedBox(width: 20),

            Expanded(
              child: _genderItem(
                title: 'Women',
                icon: Icons.woman_rounded,
                value: 'women',
                primary: primary,
                refresh: refresh,
              ),
            ),

        ],
      ),
    );
  }

  Widget _genderItem({
    required String title,
    required IconData icon,
    required String value,
    required Color primary,
    required VoidCallback refresh,
  }) {
    final selected = controller.selectedGender?.toLowerCase() == value;

    return GestureDetector(
      onTap: () {
        controller.selectedGender = value;
        refresh();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   icon,
              //   size: 18,
              //   color: selected
              //       ? Colors.white
              //       : Theme.of(context)
              //       .colorScheme
              //       .onSurfaceVariant,
              // ),
              //
              // const SizedBox(width: 7),

              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildColorFilter(
      VoidCallback refresh,
      ) {
    return ColorFilterView(
      controller: controller,

      onChanged: refresh,
    );
  }

  // ============================================================
  // SIZE FILTER
  // ============================================================

  Widget _buildSizeFilter(
      VoidCallback refresh,
      ) {
    if (controller.sizes.isEmpty) {
      return _emptyFilter(
        Icons.straighten_outlined,
        'No sizes available',
      );
    }

    return ListView.separated(
      padding:
      const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        20,
      ),

      itemCount:
      controller.sizes.length,

      separatorBuilder:
          (_, __) {
        return const SizedBox(
          height: 6,
        );
      },

      itemBuilder: (
          context,
          index,
          ) {
        final size =
        controller.sizes[index];

        final selected =
        controller.isSizeSelected(
          size,
        );

        return _filterOptionTile(
          title: size.sizeName,

          selected: selected,

          onTap: () {
            controller.toggleSize(
              size,
            );

            refresh();
          },
        );
      },
    );
  }

  // ============================================================
  // FILTER OPTION
  // ============================================================

  Widget _filterOptionTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary =
        Theme.of(context)
            .colorScheme
            .primary;

    return Material(
      color: selected
          ? primary.withValues(alpha: .07)
          : Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: .35),

      borderRadius:
      BorderRadius.circular(
        12,
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          12,
        ),

        onTap: onTap,

        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 180,
          ),

          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),

          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              12,
            ),

            border: Border.all(
              color: selected
                  ? primary.withOpacity(
                .35,
              )
                  : Colors.transparent,
            ),
          ),

          child: Row(
            children: [
              // CHECK BOX
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 180,
                ),

                width: 22,
                height: 22,

                decoration:
                BoxDecoration(
                  color: selected
                      ? primary
                      : Colors.transparent,

                  borderRadius:
                  BorderRadius.circular(
                    6,
                  ),

                  border: Border.all(
                    color: selected
                        ? primary
                        : Colors
                        .grey
                        .shade400,

                    width: 1.4,
                  ),
                ),

                child: selected
                    ? const Icon(
                  Icons.check_rounded,

                  size: 16,

                  color:
                  Colors.white,
                )
                    : null,
              ),

              const SizedBox(
                width: 12,
              ),

              // TITLE
              Expanded(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),

              // SELECTED ICON
              if (selected)
                Icon(
                  Icons.done_rounded,

                  size: 17,

                  color: primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY FILTER
  // ============================================================

  Widget _emptyFilter(
      IconData icon,
      String message,
      ) {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Icon(
            icon,

            size: 42,

            color:
            Colors.grey.shade400,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            message,

            style: TextStyle(
              fontSize: 13,

              color:
              Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DRAWER BOTTOM BAR
  // ============================================================

  Widget _buildDrawerBottomBar(
      StateSetter setDrawerState,
      ) {
    final count =
        controller.selectedFilterCount;

    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        12,
      ),

      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor,

        boxShadow: [
          BoxShadow(
            blurRadius: 12,

            offset:
            const Offset(0, -3),

            color: Colors.black
                .withOpacity(.07),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [
            // CLEAR
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: count == 0
                    ? null
                    : () {
                  controller
                      .clearAllFilters();

                  setDrawerState(
                        () {},
                  );
                },

                style:
                OutlinedButton
                    .styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  minimumSize:
                  const Size(
                    0,
                    40,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),

                child: const Text(
                  'Clear All',
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            // APPLY
            Expanded(
              flex: 2,

              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(
                    context,
                  );

                  await controller
                      .applyFilters();
                },

                style:
                ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  minimumSize:
                  const Size(
                    0,
                    40,
                  ),

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),

                child:
                AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 200,
                  ),

                  child: Text(
                    count == 0
                        ? 'Show Products'
                        : 'Apply Filters ($count)',

                    key: ValueKey(
                      count,
                    ),

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  void _openSortSheet() {
    focusNode.unfocus();
    showModalBottomSheet(
      context: context,

      showDragHandle: true,

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Padding(
                  padding:
                  EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    12,
                  ),

                  child: Text(
                    'Sort Products',

                    style:
                    TextStyle(
                      fontSize: 18,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                ...controller.sortOptions
                    .map(
                      (option) {
                    final selected =
                        controller
                            .orderBy ==
                            option[
                            'value'];

                    return RadioListTile<
                        String>(
                      value:
                      option['value']!,

                      groupValue:
                      controller
                          .orderBy,

                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        controller
                            .setSort(
                          value,
                        );

                        Navigator.pop(
                          context,
                        );
                      },

                      title: Text(
                        option['title']!,

                        style:
                        const TextStyle(
                          fontSize: 14,

                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),

                      selected:
                      selected,

                      activeColor:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,

                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}