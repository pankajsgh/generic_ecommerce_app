import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';

class ProductData {
  final String id;
  final String sizeId;
  final String colorId;

  ProductData({
    required this.id,
    required this.sizeId,
    required this.colorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sizeId': sizeId,
      'colorId': colorId,
    };
  }
}

class ProductDetailController extends ChangeNotifier {
  ProductDetailsModel? product;

  List<ProductData> productIdList = [];

  bool isLoading = false;
  String errorMessage = '';

  int selectedImageIndex = 0;


// Selected Size
  String selectedSize = '';
  String selectedSizeId = '';

// Selected Color
  String selectedColor = '';
  String selectedColorId = '';

  bool _disposed = false;
  // String selectedSalePrice ='';
  WidgetUpdater widgetUpdater = WidgetUpdater();

  List<SimilarProductModel> similarProducts = [];

  bool isSimilarProductLoading = false;
  bool isSimilarProductLoadingMore = false;

  int similarProductLimit = 0;
  int similarProductTotal = 0;

  String similarProductError = '';

  bool get hasMoreSimilarProducts {
    return similarProducts.length < similarProductTotal;
  }

  Future<void> addToCart(BuildContext context) async {
    final currentProduct = product;

    if (currentProduct == null) return;

    if (!canAddToCart) {
      return;
    }

    // Already added
    if (currentProduct.cartCheck == '1') {
      return;
    }

    widgetUpdater.enableLoader();

    await Future.delayed(Duration(milliseconds: 200));

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
      'pid': currentProduct.id,
       'qty': '1',
      'CartType': 'Simple',
      'sizes': selectedSizeId,
      'colors': selectedColorId,
    };

    try {
      final data = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.addCartApi,
            requestBody: requestBody,
        isFormData: true
      );
      if(data["error"]!=null && data["error"] is bool && data["error"])
      {

        showItemAddedDialog(context);

         ProductData productData = ProductData(id: currentProduct.id, sizeId: selectedSizeId, colorId: selectedColorId);

        loadProduct(productData, isFormStart: false);

        _safeNotify();
      }

    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
    widgetUpdater.disableLoader();
  }

  void showItemAddedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 42,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Item Added Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'The item has been added to your cart.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void addProductId(ProductData productData){
    productIdList.add(productData);
    similarProductLimit = 0;
    similarProductTotal = 0;
    similarProducts.clear();
    loadProduct(productIdList.last);
  }

  void removeLastProductId(){
    productIdList.removeLast();
    similarProductLimit = 0;
    similarProductTotal = 0;
    similarProducts.clear();
    loadProduct(productIdList.last);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

// ============================================================
// LOAD PRODUCT
// ============================================================

  Future<void> loadProduct(ProductData productData, {bool isFormStart = true}) async {

    if(isFormStart){
      if (isLoading) return;

      isLoading = true;
      product = null;
    }


    errorMessage = '';


    selectedImageIndex = 0;
    selectedSize = '';
    selectedSizeId = '';

    selectedColor = '';
    selectedColorId = '';

    _safeNotify();

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
      'pid': productData.id,
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.productDetailsApi,
        requestBody: requestBody,
        isFormData: true
      );

      product = ProductDetailsModel.fromJson(
        Map<String, dynamic>.from(response),
      );


      debugPrint('PRODUCT LOADED');
      debugPrint('PRODUCT: ${product!.product}');

      if(product==null)
        {
          return;
        } else {
        GlobalVars.totalFavourate.value = product!.totalFavourate;
      }

      for (final size in product!.sizeList) {
        debugPrint(
          'SIZE: ${size.id} - ${size.size} '
              '| COLORS: ${size.colorList.length}',
        );

        for (final color in size.colorList) {
          debugPrint(
            '   COLOR: ${color.id} - ${color.color} '
                '| Stock: ${color.stock}',
          );
        }
      }

      if (product!.sizeList.isNotEmpty) {

        SizeListModel firstSize = product!.sizeList.first;

        if(productData.sizeId.isNotEmpty)
        {
          for(var x in product!.sizeList)
            {
              if(x.id== productData.sizeId) {
                firstSize = x;
              }
            }
        }

        selectSize(
          firstSize.id,
          notify: false,
        );

// ======================================================
// DEFAULT COLOR OF FIRST SIZE
// ======================================================

        if (firstSize.colorList.isNotEmpty) {
          ColorListModel firstColor = firstSize.colorList.first;

          if(productData.colorId.isNotEmpty)
          {
            for(var y in firstSize.colorList)
            {
              if(y.id== productData.colorId) {
                firstColor = y;
              }
            }
          }

          selectColor(
            firstColor.id,
            notify: false,
          );
        }
      }

      loadSimilarProducts(productData.id);
    } catch (e, stackTrace) {
      debugPrint('Product detail error: $e');
      debugPrintStack(stackTrace: stackTrace);

      product = null;
      errorMessage = e.toString();
    } finally {
      if( isFormStart)
        {
          isLoading = false;
        }
      _safeNotify();
    }
  }

  // ============================================================
// LOAD SIMILAR PRODUCTS
// ============================================================

  Future<void> loadSimilarProducts(
      String productId, {
        int limit = 0,
      }) async
  {
    if (isSimilarProductLoading) return;

    isSimilarProductLoading = true;
    isSimilarProductLoadingMore = false;
    similarProductError = '';

    similarProductLimit = limit;

    _safeNotify();

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
      'pid': productId,
      'limit': limit.toString(),
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.similarProductListApi,
        requestBody: requestBody,
      );

      if (response == null) {
        throw Exception('Empty response from server');
      }

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(response);

      similarProductTotal =
          int.tryParse(data['TotalData']?.toString() ?? '0') ?? 0;

      final List<dynamic> list =
          data['SimilarProduct'] as List<dynamic>? ?? [];

      similarProducts = list
          .map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();

      debugPrint('======================================');
      debugPrint('SIMILAR PRODUCTS LOADED');
      debugPrint('LIMIT: $similarProductLimit');
      debugPrint('TOTAL: $similarProductTotal');
      debugPrint('CURRENT: ${similarProducts.length}');
      debugPrint('HAS MORE: $hasMoreSimilarProducts');
      debugPrint('======================================');
    } catch (e, stackTrace) {
      debugPrint('Similar products error: $e');
      debugPrintStack(stackTrace: stackTrace);

      similarProducts = [];
      similarProductTotal = 0;
      similarProductError = e.toString();
    } finally {
      isSimilarProductLoading = false;
      _safeNotify();
    }
  }

  // ============================================================
// LOAD MORE SIMILAR PRODUCTS
// ============================================================

  Future<void> loadMoreSimilarProducts(String productId) async {
    if (isSimilarProductLoadingMore) return;

    if (!hasMoreSimilarProducts) {
      debugPrint('No more similar products');
      return;
    }

    isSimilarProductLoadingMore = true;
    _safeNotify();

    final int nextLimit = similarProductLimit + 20;

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
      'pid': productId,
      'limit': nextLimit.toString(),
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.similarProductListApi,
        requestBody: requestBody,
      );

      if (response == null) {
        throw Exception('Empty response from server');
      }

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(response);

      similarProductTotal =
          int.tryParse(data['TotalData']?.toString() ?? '0') ?? 0;

      final List<dynamic> list =
          data['SimilarProduct'] as List<dynamic>? ?? [];

      similarProducts = list
          .map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();

      similarProductLimit = nextLimit;

      debugPrint('======================================');
      debugPrint('SIMILAR PRODUCTS LOAD MORE');
      debugPrint('LIMIT: $similarProductLimit');
      debugPrint('TOTAL: $similarProductTotal');
      debugPrint('CURRENT: ${similarProducts.length}');
      debugPrint('HAS MORE: $hasMoreSimilarProducts');
      debugPrint('======================================');
    } catch (e, stackTrace) {
      debugPrint('Similar products load more error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isSimilarProductLoadingMore = false;
      _safeNotify();
    }
  }

// ============================================================
// IMAGE
// ============================================================

  void selectImage(int index) {
    final currentProduct = product;

    if (currentProduct == null) return;

/*
     * Your main model currently has:
     *
     * String images;
     *
     * So images is NOT a List.
     *
     * Therefore image index selection should only be used
     * if you later add a List<ImageListModel> to the product.
     */

    selectedImageIndex = index;

    _safeNotify();
  }

// ============================================================
// SIZE
// ============================================================

  void selectSize(
      String sizeId, {
        bool notify = true,
      }) {
    final currentProduct = product;

    if (currentProduct == null) return;

    final selectedSizeModel =
    _findSizeById(sizeId);

    if (selectedSizeModel == null) {
      return;
    }

    selectedSizeId = selectedSizeModel.id;
    selectedSize = selectedSizeModel.size;

// ----------------------------------------------------------
// Mark selected size
// ----------------------------------------------------------

    for (final item in currentProduct.sizeList) {
      item.isSelected = item.id == sizeId;
    }

// ----------------------------------------------------------
// Reset color when size changes
// ----------------------------------------------------------

    selectedColor = '';
    selectedColorId = '';

// Unselect all colors
    for (final size in currentProduct.sizeList) {
      for (final color in size.colorList) {
        color.isSelected = false;
      }
    }

// ----------------------------------------------------------
// Select first color of selected size
// ----------------------------------------------------------

    if (selectedSizeModel.colorList.isNotEmpty) {
      final firstColor =
          selectedSizeModel.colorList.first;

      selectedColorId = firstColor.id;
      selectedColor = firstColor.color;

      firstColor.isSelected = true;
    }

    if (notify) {
      _safeNotify();
    }
  }

// ============================================================
// COLOR
// ============================================================

  void selectColor(
      String colorId, {
        bool notify = true,
      }) {


    final currentProduct = product;

    if (currentProduct == null) return;

    final selectedSizeModel =
    _findSizeById(selectedSizeId);

    if (selectedSizeModel == null) return;

    ColorListModel? selectedColorModel;

// ----------------------------------------------------------
// Find color inside CURRENT SIZE
// ----------------------------------------------------------


    for (final color in selectedSizeModel.colorList) {
      if (color.id == colorId) {
        selectedColorModel = color;
        break;
      }
    }


    if (selectedColorModel == null) {
      return;
    }


    selectedColorId = selectedColorModel.id;
    selectedColor = selectedColorModel.color;



// ----------------------------------------------------------
// Select only current size's color
// ----------------------------------------------------------

    for (final color in selectedSizeModel.colorList) {
      color.isSelected = color.id == colorId;
    }

// ----------------------------------------------------------
// Select first image of selected color
// ----------------------------------------------------------

    if (selectedColorModel.imageList.isNotEmpty) {
      selectedImageIndex = 0;
    }

    if (notify) {
      _safeNotify();
    }
  }

// ============================================================
// FIND SIZE
// ============================================================

  SizeListModel? _findSizeById(String sizeId) {
    final currentProduct = product;

    if (currentProduct == null) return null;

    for (final size in currentProduct.sizeList) {
      if (size.id == sizeId) {
        return size;
      }
    }

    return null;
  }

// ============================================================
// GET SELECTED SIZE
// ============================================================

  SizeListModel? get selectedSizeModel {
    return _findSizeById(selectedSizeId);
  }

// ============================================================
// GET CURRENT COLOR LIST
// ============================================================

  List<ColorListModel> get colorList {
    final size = selectedSizeModel;

    if (size == null) {
      return [];
    }

    return size.colorList;
  }

// ============================================================
// GET SELECTED COLOR
// ============================================================

  ColorListModel? get selectedColorModel {
    for (final color in colorList) {
      if (color.id == selectedColorId) {
        return color;
      }
    }

    return null;
  }

// ============================================================
// WISHLIST
// ============================================================

  Future<void> toggleFavourite() async {
    ProductDetailsModel? currentProduct = product;

    if (currentProduct == null) return;

    final bool isFavourite = currentProduct.favourate == '1';

    final int count = int.tryParse(GlobalVars.totalFavourate.value,) ?? 0;

    Map<String, String> requestBody ={
      "uid": GlobalVars.userId,
      "Subuid": GlobalVars.subUserId,
      "pid": currentProduct.id,
      "SizeId": selectedSizeId,
      "ColorId": selectedColorId,
    };

    try {
      var data =  await ApiProvider.createServerRequest(apiUrl: ApiPath.addWishListApi,
          requestBody: requestBody
      );
      if(data["error"]!=null && data["error"] is bool && data["error"])
      {
        if (isFavourite) {
          currentProduct.favourate = '0';

          GlobalVars.totalFavourate.value = (count > 0 ? count - 1 : 0).toString();
        } else {
          currentProduct.favourate = '1';

          GlobalVars.totalFavourate.value = (count + 1).toString();
        }
      }

    } catch (e) {


    }


    _safeNotify();
  }

// ============================================================
// CART
// ============================================================

  bool get isInCart {
    final currentProduct = product;

    if (currentProduct == null) {
      return false;
    }

    print("this is good88");

    print(currentProduct.cartList.length);

    return currentProduct.cartList.any((item) {
        print(item.color);
        print(selectedColorId);
         return item.color == selectedColorId &&
          item.size == selectedSizeId;
    }
    );
  }

// ============================================================
// SELECTED COLOR STOCK
// ============================================================

  String? get selectedSalePrice {
    final color = selectedColorModel;
    if (color == null) {
      return product?.stock ?? '0';
    }

    return color.salePrice;
  }

  String get selectedStock {
    final color = selectedColorModel;

    if (color == null) {
      return product?.stock ?? '0';
    }

    return color.stock;
  }

// ============================================================
// CAN ADD TO CART
// ============================================================

  bool get canAddToCart {
    final currentProduct = product;

    if (currentProduct == null) {
      return false;
    }

// If sizes exist, size must be selected
    if (currentProduct.sizeList.isNotEmpty &&
        selectedSizeId.isEmpty) {
      return false;
    }

// If colors exist for selected size,
// color must be selected
    if (colorList.isNotEmpty &&
        selectedColorId.isEmpty) {
      return false;
    }

// Check stock
    final stock =
        int.tryParse(selectedStock) ?? 0;

    if (stock <= 0) {
      return false;
    }

    return true;
  }


// ============================================================
// REMOVE FROM CART
// ============================================================

  void removeFromCart() {
    final currentProduct = product;

    if (currentProduct == null) return;

    if (currentProduct.cartCheck != '1') {
      return;
    }

    currentProduct.cartCheck = '0';

    final int count =
        int.tryParse(
          currentProduct.totalCartCheck,
        ) ??
            0;

    currentProduct.totalCartCheck =
        (count > 0 ? count - 1 : 0).toString();

    _safeNotify();
  }

// ============================================================
// VALIDATION
// ============================================================

  bool get hasSize {
    final currentProduct = product;

    if (currentProduct == null) {
      return false;
    }

    return currentProduct.sizeList.isEmpty ||
        selectedSizeId.isNotEmpty;
  }

  bool get hasColor {
    return colorList.isEmpty ||
        selectedColorId.isNotEmpty;
  }

  bool get canProceedToCart {
    final currentProduct = product;

    if (currentProduct == null) {
      return false;
    }

    if (!hasSize) {
      return false;
    }

    if (!hasColor) {
      return false;
    }

    return canAddToCart;
  }

// ============================================================
// RETRY
// ============================================================

  Future<void> retry(ProductData productData) async {
    await loadProduct(productData);
  }

// ============================================================
// CLEAR PRODUCT
// ============================================================

  void clearProduct() {
    product = null;

    selectedImageIndex = 0;

    selectedSize = '';
    selectedSizeId = '';

    selectedColor = '';
    selectedColorId = '';

    errorMessage = '';

    _safeNotify();
  }
}
