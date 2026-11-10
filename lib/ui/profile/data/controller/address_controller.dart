import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/ulitls/utility.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/toast.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/profile/data/model/address_model.dart';

import '../../../auth/data/state_list_model.dart';


class AddressController extends ChangeNotifier {
  // =====================================================
  // State
  // =====================================================
  bool isLoading = false;
  WidgetUpdater updater = WidgetUpdater();

  // =====================================================
  // Address List
  // =====================================================

  List<AddressModel> addresses = [];

  StateList? selectedState;
  // =====================================================
  // Form Controllers
  // =====================================================

  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final pinCodeController = TextEditingController();

  void setState(StateList value){
    selectedState = value;
    stateController.text = value.stateName?? '';
  }

  // =====================================================
  // Form State
  // =====================================================

  String selectedAddressType = 'Home';

  bool isEditing = false;

  String? editingAddressId;

  // =====================================================
  // Load Addresses
  // =====================================================

  Future<void> loadAddresses() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.addressListApi,
        requestBody: {
          'uid': GlobalVars.userId,
          'Subuid': GlobalVars.subUserId,
        },
      );

      debugPrint('Address Response: ${response}');

      final result = AddressListResponse.fromJson(
        response,
      );

      if (result.code == 1) {
        addresses = result.addressList;
      } else {
        addresses = [];
        debugPrint('Address API Error: ${result.msg}');
      }
    } catch (e) {
      debugPrint('Load address error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // =====================================================
  // Start Add
  // =====================================================
  void startAddAddress() {
    isEditing = false;
    editingAddressId = null;

    clearForm();

    notifyListeners();
  }

  Future<bool> addUpdateAddressApi(String? pageType, {String? addressId}) async {

    Map<String, String> parameters = {};
    parameters["uid"] = GlobalVars.userId;
    parameters["name"] = fullNameController.text;
    parameters["mobile"] = mobileController.text;
    parameters["address"] = addressController.text;
    parameters["state"] = selectedState?.stateName ?? '';
    parameters["city"] = cityController.text;
    parameters["pincode"] = pinCodeController.text;
    if (pageType == "Update") {
      parameters["id"] = addressId!;
    }

    var data =  await ApiProvider.createServerRequest(apiUrl: pageType == "Update"? ApiPath.updateAddressApi: ApiPath.addAddressApi,
      requestBody: parameters,
      isFormData: true,
    );

    if(data["error"]!=null && data["error"] is bool && data["error"])
    {
      loadAddresses();

      return true;
    }
    if(data["msg"]!=null) {
      showMessage(data["msg"], ToastType.info);
    }

    return false;
  }

  Future<bool> deleteAddressApi({required String addressId}) async {

    Map<String, String> parameters =
    {"id": addressId};

    var data =  await ApiProvider.createServerRequest(apiUrl: ApiPath.removeAddressApi,
      requestBody: parameters,
      isFormData: true,
    );

    if(data["error"]!=null && data["error"] is bool && data["error"])
    {
      loadAddresses();

      return true;
    }
    if(data["msg"]!=null) {
      showMessage(data["msg"], ToastType.info);
    }

    return false;
  }


  // =====================================================
  // Start Edit
  // =====================================================

  void startEditAddress(AddressModel address) {
    isEditing = true;
    editingAddressId = address.id;

    fullNameController.text = address.fullName;
    mobileController.text = address.mobile;
    addressController.text = address.address;
    stateController.text = address.state;
    cityController.text = address.city;
    pinCodeController.text = address.pinCode;

    selectedAddressType = address.addressType;

    notifyListeners();
  }

  // =====================================================
  // Clear Form
  // =====================================================

  void clearForm() {
    fullNameController.clear();
    mobileController.clear();
    addressController.clear();
    stateController.clear();
    cityController.clear();
    pinCodeController.clear();

    selectedAddressType = 'Home';
  }

  // =====================================================
  // Address Type
  // =====================================================

  void changeAddressType(String type) {
    selectedAddressType = type;
    notifyListeners();
  }

  // =====================================================
  // Save Address
  // =====================================================

  Future<bool> saveAddress() async {

    var returnValue = false;

    if (!_validate()) {
      if(fullNameController.text.trim().isEmpty) {
        showMessage("Name is empty", ToastType.info);
      }
      if(mobileController.text.trim().isEmpty) {
        showMessage("Mobile no is empty", ToastType.info);
      }
      if(addressController.text.trim().isEmpty) {
        showMessage("Address is empty", ToastType.info);
      }
      if(cityController.text.trim().isEmpty) {
        showMessage("City is empty", ToastType.info);
      }
      if(stateController.text.trim().isEmpty) {
        showMessage("State is empty", ToastType.info);
      }
      if(pinCodeController.text.trim().isEmpty) {
        showMessage("Pincode is empty", ToastType.info);
      }
      return false;
    }

    updater.enableLoader();

    if (isEditing) {

      final index = addresses.indexWhere(
            (element) =>
        element.id == editingAddressId,
      );

      returnValue = await addUpdateAddressApi("Update", addressId: editingAddressId);
    } else {
      returnValue = await addUpdateAddressApi("New");
    }
    updater.disableLoader();

    clearForm();
    isEditing = false;
    editingAddressId = null;
    return returnValue;
  }

  // =====================================================
  // Delete Address
  // =====================================================

  Future<bool> deleteAddress(AddressModel address) async {
    try {
      // =============================================
      // Call Delete API here
      // =============================================

      updater.enableLoader();
      var resultValue = await deleteAddressApi(addressId: address.id);

      if(resultValue)
      {
        final wasDefault = address.isDefault;

        addresses.removeWhere(
              (item) => item.id == address.id,
        );

        // If default address was deleted,
        // make first address default.
        if (wasDefault && addresses.isNotEmpty) {
          addresses.first.isDefault = true;
        }
      }

      updater.disableLoader();


      return false;

    } catch (e) {
      debugPrint('Delete address error: $e');
      return false;
    }
  }

  // =====================================================
  // Set Default
  // =====================================================

  Future<void> setDefaultAddress(
      AddressModel address,
      ) async {
    try {
      for (final item in addresses) {
        item.isDefault = item.id == address.id;
      }

      // =============================================
      // Call Set Default API here
      // =============================================

      notifyListeners();
    } catch (e) {
      debugPrint('Set default address error: $e');
    }
  }

  // =====================================================
  // Validation
  // =====================================================

  bool _validate() {
    if (fullNameController.text
        .trim()
        .isEmpty) {
      return false;
    }

    if (mobileController.text
        .trim()
        .isEmpty) {
      return false;
    }

    if (addressController.text
        .trim()
        .isEmpty) {
      return false;
    }

    if (stateController.text
        .trim()
        .isEmpty) {
      return false;
    }

    if (cityController.text
        .trim()
        .isEmpty) {
      return false;
    }

    if (pinCodeController.text
        .trim()
        .isEmpty) {
      return false;
    }

    return true;
  }

  // =====================================================
  // Dispose
  // =====================================================

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }
}