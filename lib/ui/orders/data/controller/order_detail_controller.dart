import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/orders/data/model/order_list_model.dart';

class OrderDetailController extends ChangeNotifier {

  OrderDetailModel? order;

  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadOrderDetail(String orderId) async {
    isLoading = true;
    errorMessage = '';
    order = null;

    notifyListeners();

    try {
      // final response = await dio.get(
      //   'YOUR_ORDER_DETAIL_API',
      //   queryParameters: {
      //     'uid': GlobalVars.userId,
      //     'Subuid': GlobalVars.subUserId,
      //     'id': orderId,
      //   },
      // );
      //
      // final data = response.data;
      //
      // if (data is Map<String, dynamic>) {
      //   order = OrderDetailModel.fromJson(data);
      // }

      final response = await ApiProvider.createServerRequest(
          apiUrl: ApiPath.orderDetailsApi,
          requestBody: {
            'uid': GlobalVars.userId,
            'Subuid': GlobalVars.subUserId,
            'oid': orderId,
          },
          isFormData: true
      );

      if (response["error"]!=null && response["error"] is bool && response["error"])
      {
        order = OrderDetailModel.fromJson(response);
      } else {

      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}