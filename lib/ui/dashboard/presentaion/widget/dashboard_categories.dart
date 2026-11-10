import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ecom/ui/dashboard/data/controller/dashboard_controller.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/search_page/presentaion/product_search_page.dart';

class DashboardCategories extends StatelessWidget {
  final List<SectionModel> sections;
  final DashboardController controller;
  final List<String> filterOptions;

  const DashboardCategories({
    super.key,
    required this.sections,
    required this.controller,
    this.filterOptions = const [
      'All',
      'Men',
      'Women',
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: controller.updateCategory,
      builder: (context, _) {
        final filteredSections = _filteredSections();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoriesHeader(
              selectedFilter: controller.selectedGender,
              filterOptions: filterOptions,
              onFilterChanged: controller.changeGender,
            ),
            const SizedBox(height: 2),
            _AnimatedCategoryList(
              sections: filteredSections,
              controller: controller,
            ),
          ],
        );
      },
    );
  }

  List<SectionModel> _filteredSections() {
    final selected = controller.selectedGender.trim();

    if (selected.isEmpty || selected.toLowerCase() == 'all') {
      return sections;
    }

    return sections
        .where(
          (section) =>
      section.genderType.trim().toLowerCase() ==
          selected.toLowerCase(),
    )
        .toList();
  }
}

// ============================================================
// HEADER
// ============================================================

class _CategoriesHeader extends StatelessWidget {
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onFilterChanged;

  const _CategoriesHeader({
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        4,
        14,
        6,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -.2,
              ),
            ),
          ),

          if (filterOptions.isNotEmpty)
            CategoryFilterSelector(
              selectedValue: selectedFilter,
              options: filterOptions,
              onChanged: onFilterChanged,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED CATEGORY LIST
// ============================================================

class _AnimatedCategoryList extends StatelessWidget {
  final List<SectionModel> sections;
  final DashboardController controller;

  const _AnimatedCategoryList({
    required this.sections,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(
          '${controller.selectedGender}_${sections.length}',
        ),
        height: 90,
        child: _CategoryList(
          sections: sections,
          controller: controller,
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY LIST
// ============================================================

class _CategoryList extends StatelessWidget {
  final List<SectionModel> sections;
  final DashboardController controller;

  const _CategoryList({
    required this.sections,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSections = sections
        .where(
          (section) =>
      !section.image.contains('no-images.png'),
    )
        .toList();

    if (visibleSections.isEmpty) {
      return const Center(
        child: Text(
          'No categories available',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: visibleSections.length,
      separatorBuilder: (_, __) {
        return const SizedBox(width: 12);
      },
      itemBuilder: (context, index) {
        final section = visibleSections[index];

        return _CategoryItem(
          section: section,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductSearchPage(
                  section: section,
                ),
              ),
            );

            controller.recheckCartCount();
          },
        );
      },
    );
  }
}

// ============================================================
// CATEGORY ITEM
// ============================================================

class _CategoryItem extends StatefulWidget {
  final SectionModel section;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.section,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 74,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTapDown: (_) {
          setState(() {
            _pressed = true;
          });
        },

        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },

        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });

          widget.onTap();
        },

        child: AnimatedScale(
          scale: _pressed ? .92 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Column(
            children: [
// ==================================================
// IMAGE
// ==================================================

              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.outline.withValues(
                      alpha: .10,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: .07,
                      ),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(
                        0,
                        3,
                      ),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.section.image,
                    width: 59,
                    height: 59,
                    memCacheWidth: 180,
                    fit: BoxFit.cover,

                    placeholder: (
                        context,
                        url,
                        ) {
                      return Container(
                        color: colorScheme
                            .surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: colorScheme
                              .onSurfaceVariant
                              .withValues(
                            alpha: .45,
                          ),
                        ),
                      );
                    },

                    errorWidget: (
                        context,
                        url,
                        error,
                        ) {
                      return Container(
                        color: colorScheme
                            .surfaceContainerHighest,
                        child: Icon(
                          Icons
                              .image_not_supported_outlined,
                          size: 20,
                          color: colorScheme
                              .onSurfaceVariant
                              .withValues(
                            alpha: .45,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 6),

// ==================================================
// CATEGORY NAME
// ==================================================

              Text(
                widget.section.section,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER SELECTOR
// ============================================================

class CategoryFilterSelector extends StatelessWidget {
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const CategoryFilterSelector({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: .45,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: .08,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map(
                (option) {
              return _CategoryFilterItem(
                title: option,
                value: option,
                selectedValue: selectedValue,
                onChanged: onChanged,
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER ITEM
// ============================================================

class _CategoryFilterItem extends StatelessWidget {
  final String title;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _CategoryFilterItem({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool selected =
        selectedValue.trim().toLowerCase() ==
            value.trim().toLowerCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!selected) {
          onChanged(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
