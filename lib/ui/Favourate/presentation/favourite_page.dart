import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/Favourate/data/favourate_controller.dart';
import 'package:flutter_ecom/ui/Favourate/data/favourate_model.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/product_card.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  late final FavouriteController controller;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = FavouriteController();

    _scrollController.addListener(_onScroll);

    controller.loadFavourites();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // Load next page when user is close to bottom.
    if (position.pixels >= position.maxScrollExtent - 500) {
      controller.loadMoreFavourites();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    controller.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                  'My Favourites',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (controller.products.isNotEmpty) ...[
                  const SizedBox(width: 7),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.itemCount}',
                      style: TextStyle(
                        fontSize: 10,
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
          // ======================================================
          // INITIAL LOADING
          // ======================================================

          if (controller.isLoading &&
              controller.favourite == null) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (controller.errorMessage.isNotEmpty &&
              controller.favourite == null) {
            return _buildError();
          }

          // ======================================================
          // EMPTY
          // ======================================================

          if (controller.products.isEmpty) {
            return _buildEmpty();
          }

          // ======================================================
          // GRID
          // ======================================================

          return RefreshIndicator(
            color: primaryButtonColor,
            onRefresh: controller.refreshFavourites,

            child: GridView.builder(
              controller: _scrollController,

              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                10,
                12,
                10,
                25,
              ),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Card height
                childAspectRatio: 0.6,
              ),

              itemCount:
              controller.products.length +
                  (controller.isLoadingMore ? 1 : 0),

              itemBuilder: (context, index) {
                // ==================================================
                // PAGINATION LOADER
                // ==================================================

                if (index >= controller.products.length) {
                  return _buildPaginationLoader();
                }

                final item = controller.products[index];

                return ProductCardWidget(
                  product: item,
                );
              },
            ),
          );
        },
      ),
    );
  }


  // ============================================================
  // PAGINATION LOADER
  // ============================================================

  Widget _buildPaginationLoader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,

          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: primaryButtonColor,

      onRefresh: controller.refreshFavourites,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),

          Icon(
            Icons.favorite_border_rounded,
            size: 65,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'No favourites yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Save your favourite products here.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
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
              onPressed: controller.loadFavourites,

              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }


}