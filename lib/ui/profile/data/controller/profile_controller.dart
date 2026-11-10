import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/ulitls/utility.dart';
import 'package:flutter_ecom/core/widget/toast.dart';
import 'package:flutter_ecom/ui/auth/data/state_list_model.dart';
import 'package:flutter_ecom/ui/profile/data/model/account_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';

class ProfileController extends ChangeNotifier {
  final Dio dio;
  AccountModel? accountModel;

  ProfileController({
    required this.dio,
  });

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = false;
  bool isUpdating = false;
  bool isEditing = false;
  StateList? selectedState;

  void setSelectedState(StateList state){
    selectedState = state;
    stateController.text = selectedState?.stateName ?? '';
  }

  File? profileImage;

  // Existing image coming from API
  String? profileImageUrl;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController fullNameController =
  TextEditingController(
    text: GlobalVars.userAccountData.name ?? '',
  );

  final TextEditingController companyNameController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController(
    text: GlobalVars.userAccountData.mobile ?? '',
  );

  final TextEditingController alternateMobileController = TextEditingController();

  final TextEditingController emailController =
  TextEditingController(
    text: GlobalVars.userAccountData.email ?? '',
  );

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController stateController =
  TextEditingController();

  final TextEditingController cityController =
  TextEditingController();

  final TextEditingController pinCodeController =
  TextEditingController();

  final TextEditingController gstTypeController =
  TextEditingController();

  final TextEditingController gstNoController =
  TextEditingController();

  final TextEditingController agentnameController =
  TextEditingController();

  final TextEditingController agentMobileController =
  TextEditingController();

  // ============================================================
  // PROFILE FIELDS
  // ============================================================

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    final Map<String, String> requestBody = {
      'id': GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
    };

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.myProfileApi,
        requestBody: requestBody,
      );

      if(response["error"]!=null && response["error"] is bool && response["error"])
      {
        accountModel = AccountModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }


      if (accountModel != null) {
        // Update GlobalVars
        GlobalVars.userAccountData = accountModel!;

        // Autofill all text fields
        _fillTextFields(accountModel!);

        // Existing profile image
        profileImageUrl = accountModel!.photo;

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Profile Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _fillTextFields(AccountModel model) {
    fullNameController.text = model.name;
    companyNameController.text = model.orgName;

    mobileController.text = model.mobile;
    emailController.text = model.email;

    addressController.text = model.address;
    if(model.stateId.isNotEmpty) {
      setSelectedState(StateList(id: model.stateId, stateName: model.stateName));
    }
    cityController.text = model.city;
    pinCodeController.text = model.pincode;

    gstTypeController.text = model.gstType;
    gstNoController.text = model.gstNo;

    agentnameController.text = model.agentName;
    agentMobileController.text = model.agentNo;
  }



  // ============================================================
  // EDIT
  // ============================================================

  void startEditing() {
    isEditing = true;
    notifyListeners();
  }

  // ============================================================
  // CANCEL EDITING
  // ============================================================

  void cancelEditing() {
    isEditing = false;

    // Remove newly selected image
    profileImage = null;

    notifyListeners();
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> pickProfileImage() async {
    try {
      final XFile? pickedFile =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      profileImage = File(pickedFile.path);

      notifyListeners();
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile() async {
    if (!_validate()) {
      return false;
    }

    isUpdating = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        "id": GlobalVars.userId,
        "Subuid": GlobalVars.subUserId,

        // Personal
        "name": fullNameController.text.trim(),
        "org_name": companyNameController.text.trim(),
        "mobile2": alternateMobileController.text.trim(),
        "email": emailController.text.trim(),

        // Address
        "address": addressController.text.trim(),
        "state": selectedState?.id ?? '',
        "city": cityController.text.trim(),
        "pincode": pinCodeController.text.trim(),

        // GST
        "gst_type": gstTypeController.text.trim(),
        "gst_no": gstNoController.text.trim(),

        // Agent
        "agent_name": agentnameController.text.trim(),
        "agent_number": agentMobileController.text.trim(),
      };

      // ----------------------------------------------------------
      // ADD IMAGE ONLY IF NEW IMAGE SELECTED
      // ----------------------------------------------------------

      // if (profileImage != null) {
      //   data["Image"] = await MultipartFile.fromFile(
      //     profileImage!.path,
      //     filename: "profile.jpg",
      //   );
      // }


      // ----------------------------------------------------------
      // API
      // ----------------------------------------------------------

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.updateProfileApi,
        requestBody: requestBody,
      );

      debugPrint(
        'Update profile response: ${response}',
      );

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if(response["error"]!=null && response["error"] is bool && response["error"])
      {
        isEditing = false;
        profileImage = null;


        notifyListeners();

        return true;
      }

      if(response["msg"]!=null) {
        showMessage(response["msg"], ToastType.info);
      }


      return false;
    } on DioException catch (e) {
      debugPrint(
        'Update profile Dio error: ${e.message}',
      );

      debugPrint(
        'Response: ${e.response?.data}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Update profile error: $e',
      );

      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validate() {
    if (fullNameController.text.trim().isEmpty) {
      return false;
    }


    if (emailController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    fullNameController.dispose();
    companyNameController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();

    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();

    gstTypeController.dispose();
    gstNoController.dispose();

    agentnameController.dispose();
    agentMobileController.dispose();

    super.dispose();
  }
}

// =====================================================
// Profile Field Model
// =====================================================

class ProfileField {
  final String title;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  int maxLines;
  final GestureTapCallback? onTap;


  ProfileField({
    required this.title,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.keyboardType,
     this.maxLines = 1,
    this.onTap,
  });
}