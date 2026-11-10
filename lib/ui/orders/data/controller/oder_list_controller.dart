import 'package:flutter/foundation.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/orders/data/model/order_list_model.dart';

class OrderListController extends ChangeNotifier {
  List<OrderListModel> orders = [];

  bool isLoading = false;
  String errorMessage = '';

  /// Currently selected status
  String selectedStatus = 'All';

  /// Available API status filters
  static const List<String> statuses = [
    'All',
    'Pending',
    'Confirm',
    'Dispatch',
    'Cancel',
  ];

  /// Load orders from API
  ///
  /// Status is sent to API.
  /// No local filtering is performed.
  Future<void> loadOrders({
    String status = 'All',
  }) async {
    isLoading = true;
    errorMessage = '';
    selectedStatus = status;

    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.orderListApi,
        requestBody: {
          'uid': GlobalVars.userId,
          'Subuid': GlobalVars.subUserId,

          // API will filter orders based on this value
          // All = empty status
          'status': status == 'All' ? '' : status,
        },
        isFormData: true,
      );

      if (response is Map<String, dynamic>) {
        final apiError = response['error'];

        if (apiError == true) {
          final list = response['OrderList'] as List? ?? [];

          orders = list
              .map(
                (e) => OrderListModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
              .toList();
        } else {
          orders = [];

          errorMessage = response['msg']?.toString() ??
              'Unable to load orders.';
        }
      } else {
        orders = [];
        errorMessage = 'Invalid server response.';
      }
    } catch (e) {
      orders = [];
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Called when user taps a status button
  Future<void> changeStatus(String status) async {
    if (selectedStatus == status && !isLoading) {
      return;
    }

    await loadOrders(status: status);
  }

  /// Refresh currently selected status
  Future<void> refreshOrders() async {
    await loadOrders(
      status: selectedStatus,
    );
  }
}