import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';

class DashboardBanner extends StatefulWidget {
  final List<BannerModel> banners;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const DashboardBanner({
    super.key,
    required this.banners,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<DashboardBanner> createState() => _DashboardBannerState();
}

class _DashboardBannerState extends State<DashboardBanner> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool hasMultiple = widget.banners.length > 1;

    return SizedBox(
      height: 230,
      child: GestureDetector(
        onTapDown: (_) {
          if (!mounted) return;

          setState(() {
            _pressed = true;
          });
        },
        onTapCancel: () {
          if (!mounted) return;

          setState(() {
            _pressed = false;
          });
        },
        onTapUp: (_) {
          if (!mounted) return;

          setState(() {
            _pressed = false;
          });
        },
        child: AnimatedScale(
          scale: _pressed ? .985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ==========================================================
              // BANNER PAGES
              // ==========================================================

              PageView.builder(
                controller: widget.controller,
                itemCount: widget.banners.length,
                onPageChanged: widget.onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _BannerItem(
                    banner: widget.banners[index],
                    index: index,
                    currentIndex: widget.currentIndex,
                    controller: widget.controller,
                  );
                },
              ),

              // ==========================================================
              // BOTTOM GRADIENT
              // ==========================================================

              if (hasMultiple)
                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 6,
                  height: 70,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x99000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ==========================================================
              // PAGE INDICATOR
              // ==========================================================

              if (hasMultiple)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: _BannerIndicator(
                    count: widget.banners.length,
                    currentIndex: widget.currentIndex,
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  void _nextPage() {
    if (!widget.controller.hasClients) {
      return;
    }

    final int nextIndex = widget.currentIndex + 1;

    widget.controller.animateToPage(
      nextIndex >= widget.banners.length ? 0 : nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  void _previousPage() {
    if (!widget.controller.hasClients) {
      return;
    }

    final int previousIndex = widget.currentIndex - 1;

    widget.controller.animateToPage(
      previousIndex < 0
          ? widget.banners.length - 1
          : previousIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}

// ============================================================================
// BANNER ITEM
// ============================================================================

class _BannerItem extends StatelessWidget {
  final BannerModel banner;
  final int index;
  final int currentIndex;
  final PageController controller;

  const _BannerItem({
    required this.banner,
    required this.index,
    required this.currentIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = currentIndex.toDouble();

        if (controller.hasClients &&
            controller.position.hasContentDimensions) {
          page = controller.page ?? currentIndex.toDouble();
        }

        final double difference = (page - index).abs();

        final double scale =
        (1 - (difference * .045)).clamp(.94, 1.0);

        final double opacity =
        (1 - (difference * .25)).clamp(.75, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },

      // ============================================================
      // BANNER CARD
      // ============================================================

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            // Strong black shadow
            boxShadow: [
              // BoxShadow(
              //   color: Colors.black.withValues(alpha: .30),
              //   blurRadius: 16,
              //   spreadRadius: 0,
              //   offset: const Offset(0, 6),
              // ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: banner.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: 1200,

              // Smooth image loading
              fadeInDuration: const Duration(
                milliseconds: 250,
              ),

              fadeOutDuration: const Duration(
                milliseconds: 150,
              ),

              placeholder: (_, __) {
                return const _BannerPlaceholder();
              },

              errorWidget: (_, __, ___) {
                return const _BannerError();
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BANNER PLACEHOLDER
// ============================================================================

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 34,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// ============================================================================
// BANNER ERROR
// ============================================================================

class _BannerError extends StatelessWidget {
  const _BannerError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// ============================================================================
// NAVIGATION BUTTON
// ============================================================================

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black.withValues(alpha: .28),
        shape: const CircleBorder(),

        elevation: 3,

        shadowColor: Colors.black.withValues(alpha: .35),

        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),

          child: const SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PAGE INDICATOR
// ============================================================================

class _BannerIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _BannerIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (index) {
          final bool selected = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,

            width: selected ? 24 : 7,
            height: selected ? 5 : 5,

            margin: const EdgeInsets.symmetric(
              horizontal: 3,
            ),

            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: .45),

              borderRadius: BorderRadius.circular(20),

              boxShadow: selected
                  ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
          );
        },
      ),
    );
  }
}