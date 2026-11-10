import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';

class ProductCartController extends ChangeNotifier {
  SimilarProductModel? product;
  ProductCartController(this.product);

  bool isLoading = false;
  String errorMessage = '';
  bool _disposed = false;


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
// WISHLIST
// ============================================================

  Future<void> toggleFavourite() async {
    SimilarProductModel? currentProduct = product;

    if (currentProduct == null) return;
    final bool isFavourite = currentProduct.isFavourite;
    final int count = int.tryParse(GlobalVars.totalFavourate.value) ?? 0;

    isLoading = true;
    _safeNotify();

    Map<String, String> requestBody ={
      "uid": GlobalVars.userId,
      "Subuid": GlobalVars.subUserId,
      "pid": currentProduct.id,
      "SizeId": currentProduct.sizeId,
      "ColorId": currentProduct.colorId,
    };

    try {
      var data =  await ApiProvider.createServerRequest(apiUrl: ApiPath.addWishListApi,
          requestBody: requestBody
      );

      if(data["error"]!=null && data["error"] is bool && data["error"])
      {

      }
      if (isFavourite) {
        currentProduct.isFavourite = false;

        GlobalVars.totalFavourate.value = (count > 0 ? count - 1 : 0).toString();
      } else {
        currentProduct.isFavourite = true;

        GlobalVars.totalFavourate.value = (count + 1).toString();
      }
    } catch (e) {

    }

    isLoading = false;
    _safeNotify();
  }


}

