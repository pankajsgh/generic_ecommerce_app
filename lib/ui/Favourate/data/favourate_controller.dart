import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/ulitls/utility.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/toast.dart';
import 'package:flutter_ecom/ui/Favourate/data/favourate_model.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';

class FavouriteController extends ChangeNotifier {
  FavouriteModel? favourite;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  String errorMessage = '';

  bool _disposed = false;

  // API limit
  int limit = 0;

  // How many records API returns per request
  static const int pageSize = 20;

  // ============================================================
  // SAFE NOTIFY
  // ============================================================

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<SimilarProductModel> get products =>
      favourite?.productList ?? [];

  int get itemCount => products.length;

  int get totalFavourite =>
      int.tryParse(
        favourite?.totalFavourate ?? '0',
      ) ??
          0;

  int get totalCartCheck =>
      int.tryParse(
        favourite?.totalCartCheck ?? '0',
      ) ??
          0;

  bool get hasProducts => products.isNotEmpty;

  // ============================================================
  // FIRST LOAD
  // ============================================================

  Future<void> loadFavourites() async {
    if (isLoading) return;

    isLoading = true;
    isLoadingMore = false;

    errorMessage = '';

    // Start from 0
    limit = 0;
    hasMore = true;

    _safeNotify();

    try {
      final data = await _getFavouriteData(
        limit: limit,
      );

      if (data == null) {
        errorMessage =
        'Unable to connect to server.';
        return;
      }

      final code =
          int.tryParse(
            data['code']?.toString() ?? '0',
          ) ??
              0;

      if (code == 1) {
        favourite =
            FavouriteModel.fromJson(data);

        final count =
            favourite?.productList.length ?? 0;

        // If API returned less than 20,
        // there are no more products.
        if (count < pageSize) {
          hasMore = false;
        }
      } else {
        errorMessage =
            data['msg']?.toString() ??
                'Unable to load favourites.';
      }
    } catch (e) {
      debugPrint(
        'FavouriteController error: $e',
      );

      errorMessage =
      'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      _safeNotify();
    }
  }

  // ============================================================
  // LOAD NEXT 20
  // ============================================================

  Future<void> loadMoreFavourites() async {
    if (isLoading ||
        isLoadingMore ||
        !hasMore) {
      return;
    }

    isLoadingMore = true;
    _safeNotify();

    try {
      // 0 → 20 → 40 → 60
      final nextLimit = limit + pageSize;

      final data = await _getFavouriteData(
        limit: nextLimit,
      );

      if (data == null) {
        return;
      }

      final code =
          int.tryParse(
            data['code']?.toString() ?? '0',
          ) ??
              0;

      if (code == 1) {
        final nextFavourite =
        FavouriteModel.fromJson(data);

        final newProducts =
            nextFavourite.productList;

        if (newProducts.isEmpty) {
          hasMore = false;
          return;
        }

        // Add next 20 products
        favourite?.productList.addAll(
          newProducts,
        );

        // Move:
        // 0 → 20
        // 20 → 40
        // 40 → 60
        limit = nextLimit;

        // Less than 20 means last request
        if (newProducts.length < pageSize) {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      debugPrint(
        'FavouriteController loadMore error: $e',
      );
    } finally {
      isLoadingMore = false;
      _safeNotify();
    }
  }

  // ============================================================
  // API REQUEST
  // ============================================================

  Future<Map<String, dynamic>?> _getFavouriteData({
    required int limit,
  }) async {
    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,

      // IMPORTANT
      'limit': limit.toString(),
    };

    final response =
    await ApiProvider.createServerRequest(
      requestBody: requestBody,
      apiUrl: ApiPath.wishListApi,
    );

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshFavourites() async {
    await loadFavourites();
  }

  // ============================================================
  // REMOVE
  // ============================================================

  Future<void> removeFavourite(
      int index, {
        required String id,
      }) async {
    if (favourite == null) return;

    if (index < 0 ||
        index >= favourite!.productList.length) {
      return;
    }

    try {
      final requestBody = {
        'id': id,
      };

      final data =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.removeWishListApi,
        requestBody: requestBody,
      );

      if (data == null) return;

      if (data['error'] != null &&
          data['error'] is bool &&
          data['error'] == true) {
        favourite!.productList.removeAt(index);

        _safeNotify();
      }

      if (data['msg'] != null) {
        showMessage(
          data['msg'].toString(),
          ToastType.info,
        );
      }
    } catch (e) {
      debugPrint(
        'Remove favourite error: $e',
      );
    }
  }

  // ============================================================
  // FIND PRODUCT
  // ============================================================

  SimilarProductModel? findProduct(
      String productId,
      ) {
    try {
      return products.firstWhere(
            (e) => e.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}