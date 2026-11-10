import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/ulitls/utility.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/toast.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/cart/data/model.dart';
import 'package:flutter_ecom/ui/cart/data/product_stock_model.dart';
import 'package:path/path.dart';

class CartController extends ChangeNotifier {
  CartModel? cart;

  bool isLoading = false;
  String errorMessage = '';
  bool _disposed = false;
  String currentCartId = '';
  int stockAvailable = 0;

  WidgetUpdater widgetUpdater = WidgetUpdater();
  WidgetUpdater orderUpdater = WidgetUpdater();


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
  // LOAD CART
  // ============================================================

  Future<void> loadCart() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = '';

    _safeNotify();

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
    };

    try {
      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.cartListApi,
        requestBody: requestBody,
      );

      if (response == null) {
        throw Exception(
          'Empty response from server',
        );
      }

      cart = CartModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      debugPrint(
        'Cart loaded: '
            '${cart!.productCartList.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('Cart error: $e');
      debugPrintStack(
        stackTrace: stackTrace,
      );

      errorMessage = e.toString();
      cart = null;
    } finally {
      isLoading = false;
      _safeNotify();
    }
  }

  Future<void> removeFormCart(String cartId) async {

    currentCartId = cartId;
    widgetUpdater.enableLoader();

    await Future.delayed(Duration(milliseconds: 200));

    final Map<String, String> requestBody = {
      'uid': GlobalVars.userId,
      'cartid': cartId,
    };

    try {
      final data = await ApiProvider.createServerRequest(
          apiUrl: ApiPath.removeCartApi,
          requestBody: requestBody,
          isFormData: true
      );
      if(data["error"]!=null && data["error"] is bool && data["error"])
      {
        // currentProduct.cartCheck = '1';
        //
        // final count = int.tryParse(currentProduct.totalCartCheck) ?? 0;
        //
        // currentProduct.totalCartCheck = (count + 1).toString();
        refreshCart();
      }

    } catch (e) {
      debugPrint('Add to cart error: $e');
    }
    widgetUpdater.disableLoader();
    _safeNotify();
    widgetUpdater.disableLoader();
  }


  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCart() async {
    await loadCart();
  }

  // ============================================================
  // PRODUCT COUNT
  // ============================================================

  int get itemCount {
    return cart?.productCartList.length ?? 0;
  }

  // ============================================================
  // TOTAL QTY
  // ============================================================

  int get totalQty {
    int total = 0;

    for (final item
    in cart?.productCartList ?? []) {
      total += int.tryParse(item.qty) ?? 0;
    }

    return total;
  }

  // ============================================================
  // CHANGE QUANTITY LOCAL
  // ============================================================

  Future<void> increaseQty(int index) async {
    if (cart == null) return;

    if (index < 0 ||
        index >= cart!.productCartList.length) {
      return;
    }

    final item = cart!.productCartList[index];

    widgetUpdater.enableLoader();
    currentCartId = item.cartId;

    Map<String, String> requestBody = {
      "uid": GlobalVars.userId,
      "pid": item.pid,
      "sizeid": item.sizeId,
      "colorid": item.colorId,
    };


    var data = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.checkProductStockApi,
        requestBody: requestBody);

    if (data["error"]!=null && data["error"] is bool && data["error"]) {

      CheckProductStockModel stockModel = CheckProductStockModel.fromJson(data);


      if ((int.tryParse(stockModel.stockQty ?? '0') ?? 0) <= 0) {
        stockAvailable = 0;
      } else {
        stockAvailable = int.tryParse(stockModel.stockQty ?? '0')?? 0;
      }
    } else {
      stockAvailable = 0;
    }


    final int qty = int.tryParse(item.qty) ?? 0;

    // final int stock = int.tryParse(item.stock) ?? 0;
    final int stock =stockAvailable;

    if (qty >= stock) {
      return;
    }

    item.qty = (qty + 1).toString();

    Map<String, String> requestAdd = {
      "uid": GlobalVars.userId,
      "CartType":item.cartType,
      "crtid": item.cartId,
      "sizes": item.sizeId,
      "colors": item.colorId,
      "qty":item.qty

    };


    var value = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.updateCartProductApi,
        requestBody: requestAdd,
        isFormData: true,
    );

    if (value["error"]!=null && value["error"] is bool && value["error"])
      {
        loadCart();
      } else {
      item.qty = (qty -1).toString();
    }

    // item.qty = (qty + 1).toString();

    _safeNotify();
    widgetUpdater.disableLoader();
  }

  Future<void> decreaseQty(int index) async {
    if (cart == null) return;

    if (index < 0 ||
        index >= cart!.productCartList.length) {
      return;
    }

    final item = cart!.productCartList[index];
    currentCartId = item.cartId;

    final int qty =
        int.tryParse(item.qty) ?? 0;

    if (qty <= 1) {
      return;
    }

    item.qty = (qty - 1).toString();

    widgetUpdater.enableLoader();
    Map<String, String> requestAdd = {
      "uid": GlobalVars.userId,
      "CartType":item.cartType,
      "crtid": item.cartId,
      "sizes": item.sizeId,
      "colors": item.colorId,
      "qty":item.qty

    };


    var value = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.updateCartProductApi,
        requestBody: requestAdd,
      isFormData: true,);

    if (value["error"]!=null && value["error"] is bool && value["error"])
    {
     loadCart();
    } else {
      item.qty = (qty +1).toString();
    }

    widgetUpdater.disableLoader();
    _safeNotify();
  }

  Future<void> submitOrder(BuildContext context) async {

    orderUpdater.enableLoader();

    Map<String, String> requestBody = {
      "address_id": address!.id,
      "uid": GlobalVars.userId,
      "Subuid": GlobalVars.subUserId,
      "Subtotal": subtotal,
      "Gst": gst,
      "TotalAmount": finalAmount,
    };

    var value = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.submitOrderApi,
      requestBody: requestBody,
      isFormData: true
    );

    if (value["error"]!=null && value["error"] is bool && value["error"])
    {
      showMessage(value["msg"]?? "",ToastType.success);
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pop(context);
    } else {
      showMessage(value["msg"]?? "",ToastType.error);
    }

    orderUpdater.enableLoader();

  }

  // ============================================================
  // GETTERS
  // ============================================================

  String get subtotal {
    return cart?.grandTotals.subtotal ?? '0';
  }

  String get gst {
    return cart?.grandTotals.gst ?? '0';
  }

  String get finalAmount {
    return cart?.grandTotals.finalAmounts ?? '0';
  }

  UserAddressModel? get address {
    return cart?.userAddress;
  }

  void setCartAddress(UserAddressModel address){

    cart?.userAddress = address;
    widgetUpdater.update();
  }

  List<CartProductModel> get products {
    return cart?.productCartList ?? [];
  }
}