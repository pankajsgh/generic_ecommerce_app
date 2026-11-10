import 'package:flutter/material.dart';
import 'package:flutter_ecom/ui/search_page/data/controller/product_search_controller.dart';

class ColorFilterView extends StatefulWidget {
  final ProductSearchController controller;
  final VoidCallback onChanged;

  const ColorFilterView({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ColorFilterView> createState() => _ColorFilterViewState();
}

class _ColorFilterViewState extends State<ColorFilterView> {
  final TextEditingController searchController = TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = widget.controller.colors
        .where(
          (color) => color.colorName
          .toLowerCase()
          .contains(search.toLowerCase()),
    )
        .toList();

    final selectedCount = widget.controller.selectedColors.length;

    return Column(
      children: [
        _buildSearchField(theme),

        if (selectedCount > 0) _buildSelectedHeader(theme, selectedCount),

        Expanded(
          child: colors.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            physics: const BouncingScrollPhysics(),
            itemCount: colors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final color = colors[index];

              return _ColorTile(
                key: ValueKey(color.colorName),
                colorName: color.colorName,
                selected:
                widget.controller.isColorSelected(color),
                color: _getColorFromName(color.colorName),
                onTap: () {
                  widget.controller.toggleColor(color);

                  widget.onChanged();

                  // Only needed if this widget itself is responsible
                  // for refreshing the selected state.
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search colors',
          hintStyle: TextStyle(
            color: theme.hintColor,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
          ),
          suffixIcon: search.isEmpty
              ? null
              : IconButton(
            tooltip: 'Clear',
            onPressed: () {
              searchController.clear();

              setState(() {
                search = '';
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 19,
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.45),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedHeader(
      ThemeData theme,
      int selectedCount,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$selectedCount selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.controller.colors.length} colors',
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 42,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              search.isEmpty
                  ? 'No colors available'
                  : 'No matching colors',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (search.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Try a different color name',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase().trim()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'gold':
        return const Color(0xFFFFC107);
      case 'silver':
        return const Color(0xFFBDBDBD);
      default:
        return Colors.grey.shade400;
    }
  }
}

class _ColorTile extends StatelessWidget {
  final String colorName;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ColorTile({
    super.key,
    required this.colorName,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.07)
                : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: .35),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: selected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: selected
                    ? Container(
                  key: const ValueKey('selected'),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                )
                    : Container(
                  key: const ValueKey('unselected'),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(
                        alpha: 0.45,
                      ),
                      width: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                  child: Text(
                    colorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildColorCircle(ThemeData theme) {
    final isWhite = color == Colors.white;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: isWhite
              ? theme.dividerColor
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: selected ? 5 : 2,
            spreadRadius: 0,
            color: Colors.black.withValues(
              alpha: selected ? 0.12 : 0.05,
            ),
          ),
        ],
      ),
    );
  }
}