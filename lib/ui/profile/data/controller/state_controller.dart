import 'package:flutter/material.dart';

import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_provider.dart';
import '../../../auth/data/state_list_model.dart';



class StateController extends ChangeNotifier {
  // ===========================================================================
  // Controllers
  // ===========================================================================

  final TextEditingController stateController =
  TextEditingController(text: 'Select State');

  final TextEditingController stateSearchController =
  TextEditingController();

  // ===========================================================================
  // Loading
  // ===========================================================================

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
      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.stateListApi,
        requestBody: {
          "search":
          stateSearchController.text.trim(),
          "limit": showLoader
              ? stateList.length.toString()
              : "0",
        },
        isFormData: true,
      );

      if (response["error"] != null &&
          response["error"] == true) {
        final data =
        StateListModel.fromJson(response);

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
          stateList = [
            StateList(
              id: '',
              stateName: 'Select State',
            ),
          ];
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
  // Reset State
  // ===========================================================================

  void resetState() {
    stateController.text = 'Select State';

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

    stateListSearchResult.clear();

    isStateListLoading = false;
    isStateListLoadFail = false;
    isStateListLoadMore = false;

    notifyListeners();
  }

  // ===========================================================================
  // Dispose
  // ===========================================================================

  @override
  void dispose() {
    stateController.dispose();
    stateSearchController.dispose();

    super.dispose();
  }
}