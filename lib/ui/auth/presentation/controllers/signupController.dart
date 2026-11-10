import 'package:flutter/material.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/ui/auth/data/state_list_model.dart';
import 'package:google_fonts/google_fonts.dart';



class SignupController extends ChangeNotifier {

  // ===========================================================================
  // Controllers
  // ===========================================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController();

  final TextEditingController alternateMobileController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController companyNameController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController stateController =
  TextEditingController(text: 'Select State');

  final TextEditingController cityController =
  TextEditingController();

  final TextEditingController pincodeController =
  TextEditingController();

  final TextEditingController gstTypeController =
  TextEditingController();

  final TextEditingController gstNoController =
  TextEditingController();

  final TextEditingController agentnameController =
  TextEditingController();

  final TextEditingController agentMobileController =
  TextEditingController();

  final TextEditingController stateSearchController =
  TextEditingController();

  // ===========================================================================
  // Country Code
  // ===========================================================================

  CountryCode? countryCode;

  String get selectedCountryCode {
    return countryCode?.dialCode ?? '+91';
  }

  void setCountryCode(CountryCode code) {
    countryCode = code;
    notifyListeners();
  }

  Future<CountryCode?> getCountryCode({required BuildContext context}) async{
    FlCountryCodePicker countryPicker = FlCountryCodePicker(
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Select Country', style: GoogleFonts.montserrat(fontSize: 18.0, fontWeight: FontWeight.w700),),
        ),
        countryTextStyle: GoogleFonts.montserrat(fontSize: 12.0),
        dialCodeTextStyle: GoogleFonts.montserrat(fontSize: 12.0),
        searchBarTextStyle: GoogleFonts.montserrat(fontSize: 12.0)
    );

    CountryCode? countryCode = await countryPicker.showPicker(
      context: context,
      pickerMaxHeight: MediaQuery.of(context).size.height * 0.95,
    );
    return countryCode;
  }

  // ===========================================================================
  // Loading
  // ===========================================================================

  bool isLoading = false;

  bool isStateListLoading = false;

  bool isStateListLoadFail = false;

  bool isStateListLoadMore = false;

  // ===========================================================================
  // State List
  // ===========================================================================

  List<StateList> stateList = [
    StateList(
      id: '',
      stateName: 'Select State',
    ),
  ];

  List<StateList> stateListSearchResult = [];

  StateList selectedState = StateList(
    id: '',
    stateName: 'Select State',
  );

  // ===========================================================================
  // Select State
  // ===========================================================================

  void setSelectedState(StateList state) {
    selectedState = state;

    stateController.text =
        state.stateName ?? 'Select State';

    notifyListeners();
  }

  // ===========================================================================
  // State Search
  // ===========================================================================

  void setStateSearch(String value) {
    stateSearchController.text = value;
    notifyListeners();
  }

  // ===========================================================================
  // Fetch State List
  // ===========================================================================

  Future<void> fetchStateList({
    bool showLoader = false,
  }) async {
    if (showLoader) {
      isStateListLoadMore = true;
    } else {
      isStateListLoading = true;
    }

    isStateListLoadFail = false;

    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.stateListApi,
      requestBody: {
        "search": stateSearchController.text.trim(),
        "limit": showLoader
            ? stateList.length.toString()
            : "0",
      },
      isFormData: true
      );

      if (response["error"] !=null && response["error"] == true) {
        var data = StateListModel.fromJson(response);

        if (showLoader) {
          stateList.addAll(
            data.stateList ?? [],
          );
        } else {
          stateList = [
            StateList(
              id: '',
              stateName: 'Select State',
            ),
          ];

          stateList.addAll(
            data.stateList ?? [],
          );
        }

        isStateListLoadFail = false;
      } else {
        if (!showLoader) {
          stateList = [];
        }

        isStateListLoadFail = true;
      }
    } catch (e) {
      debugPrint(
        'fetchStateList error: $e',
      );

      isStateListLoadFail = true;
    }

    isStateListLoadMore = false;
    isStateListLoading = false;

    notifyListeners();
  }

  // ===========================================================================
  // Signup
  // ===========================================================================

  Future<Map<String, dynamic>?> signupUser({
    bool isFromDashboard = false,
  }) async {
    if (isLoading) return null;

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        "name": nameController.text.trim(),

        "mobile": mobileController.text.trim(),

        "mobile2": alternateMobileController.text.trim(),

        "email": emailController.text.trim(),

        "org_name": companyNameController.text.trim(),

        "address": addressController.text.trim(),

        "state_id": selectedState.id ?? "",

        "city": cityController.text.trim(),

        "pincode": pincodeController.text.trim(),

        "gst_type": gstNoController.text.trim().isNotEmpty? "Register": "",

        "gst_no": gstNoController.text.trim(),

        "agent_name": agentnameController.text.trim(),

        "agent_number": agentMobileController.text.trim(),

        "CountryCode": selectedCountryCode,
      };

      debugPrint(
        'Signup Request: $requestBody',
      );

      print("this is good");
      print(requestBody);

      final data =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.signupApi,
        requestBody: requestBody,
        isFormData: true,
      );

      print("this is good");
      print(data);
      return data;
    } catch (e) {
      debugPrint(
        'Signup Error: $e',
      );

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Reset
  // ===========================================================================

  void resetAll() {
    countryCode = null;

    nameController.clear();
    mobileController.clear();
    alternateMobileController.clear();
    emailController.clear();
    companyNameController.clear();
    addressController.clear();

    stateController.text = 'Select State';

    cityController.clear();
    pincodeController.clear();
    gstTypeController.clear();
    gstNoController.clear();
    agentnameController.clear();
    agentMobileController.clear();

    stateSearchController.clear();

    selectedState = StateList(
      id: '',
      stateName: 'Select State',
    );

    stateList = [
      StateList(
        id: '',
        stateName: 'Select State',
      ),
    ];

    notifyListeners();
  }

  // ===========================================================================
  // Dispose
  // ===========================================================================

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    gstTypeController.dispose();
    gstNoController.dispose();
    agentnameController.dispose();
    agentMobileController.dispose();
    stateSearchController.dispose();

    super.dispose();
  }
}