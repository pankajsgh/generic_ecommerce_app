import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/search_page/data/model/color_model.dart';
import 'package:flutter_ecom/ui/search_page/data/model/product_model.dart';
import 'package:flutter_ecom/ui/search_page/data/model/size_model.dart';



class ProductSearchController extends ChangeNotifier {
  ProductSearchController();

  // ------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------

  List<ProductModel> products = [];
  List<SectionModel> sections = [];
  List<ColorModel> colors = [];
  List<SizeModel> sizes = [];
  String? selectedGender;

  String normalizeGender(String value) {
    switch (value.trim().toLowerCase()) {
      case 'male':
      case 'man':
      case 'men':
        return 'male';

      case 'female':
      case 'woman':
      case 'women':
        return 'female';

      default:
        return value.trim().toLowerCase();
    }
  }

  // ------------------------------------------------------------
  // SELECTED FILTERS
  // ------------------------------------------------------------

  final List<SectionModel> selectedSections = [];
  final List<ColorModel> selectedColors = [];
  final List<SizeModel> selectedSizes = [];

  // ------------------------------------------------------------
  // SEARCH / SORT
  // ------------------------------------------------------------

  String search = '';
  String orderBy = '';

  String type = '';
  String genderType = '';
  String subUid = '';

  // ------------------------------------------------------------
  // PAGINATION
  // ------------------------------------------------------------

  int limit = 0;
  int totalData = 0;

  bool get hasMore {
    return products.length < totalData;
  }

  // ------------------------------------------------------------
  // STATES
  // ------------------------------------------------------------

  bool isLoading = true;
  bool isLoadingMore = false;
  bool isFilterLoading = false;

  String errorMessage = '';

  Timer? _searchTimer;

  // ------------------------------------------------------------
  // SORT OPTIONS
  // ------------------------------------------------------------

  final List<Map<String, String>> sortOptions = [
    {
      'title': 'Default',
      'value': '',
    },
    {
      'title': 'New Arrival',
      'value': 'NewArrival',
    },
    {
      'title': 'Price: High to Low',
      'value': 'High-Low',
    },
    {
      'title': 'Price: Low to High',
      'value': 'Low-High',
    },

    {
      'title': 'Discount',
      'value': 'Discount',
    },
  ];

  // ------------------------------------------------------------
  // INITIAL LOAD
  // ------------------------------------------------------------

  Future<void> initialize() async {
    await Future.wait([
      loadSections(),
      loadColors(),
      loadSizes(),
    ]);

    await loadProducts();
  }

  // ------------------------------------------------------------
  // LOAD SECTIONS
  // ------------------------------------------------------------

  Future<void> loadSections() async {
    try {
      final response = await ApiProvider.createServerRequest(apiUrl: ApiPath.categoryListApi);

      final data = response;

      if (data['code'] == 1) {
        sections = (data['ColorList'] as List? ?? [])
            .map(
              (e) => SectionModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
            .toList();
      }
    } catch (e) {
      debugPrint('Section error: $e');
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // LOAD COLORS
  // ------------------------------------------------------------

  Future<void> loadColors() async {
    try {
      final response = await ApiProvider.createServerRequest(apiUrl: ApiPath.colorListApi);

      final data = Map<String, dynamic>.from(response);

      if (data['code'] == 1) {
        colors = (data['ColorList'] as List? ?? [])
            .map(
              (e) => ColorModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
            .toList();
      }
    } catch (e) {
      debugPrint('Color error: $e');
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // LOAD SIZES
  // ------------------------------------------------------------

  Future<void> loadSizes() async {
    try {
      final response = await ApiProvider.createServerRequest(apiUrl: ApiPath.sizesListApi);
      final data = Map<String, dynamic>.from(response);

      if (data['code'] == 1) {
        sizes = (data['SizeList'] as List? ?? [])
            .map(
              (e) => SizeModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
            .toList();
      }
    } catch (e) {
      debugPrint('Size error: $e');
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // PRODUCT API
  // ------------------------------------------------------------

  Future<void> loadProducts({
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMore || !hasMore) return;

      isLoadingMore = true;
      notifyListeners();
    } else {
      isLoading = true;
      errorMessage = '';
      limit = 0;

      notifyListeners();
    }

    try {
      final params = <String, dynamic>{
        'uid': GlobalVars.userId,
        'Type': type,
        'gender_type': genderType,
        'Subuid': subUid,

        'section[]': selectedSections
            .map((e) => e.id)
            .toList().join(','),

        'color[]': selectedColors
            .map((e) => e.id)
            .toList().join(','),

        'sizes[]': selectedSizes
            .map((e) => e.id)
            .toList().join(','),

        'Orderby': orderBy,
        'search': search,

        'limit': limit,
      };

      debugPrint('PRODUCT PARAMS: $params');

      final response = await ApiProvider.createServerRequest(apiUrl: ApiPath.productListApi, requestBody: params, isFormData: true);

      final data = Map<String, dynamic>.from(response);

      if (data['code'] == 1) {
        final result = (data['ProductList'] as List? ?? [])
            .map(
              (e) => ProductModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
            .toList();

        totalData =
            int.tryParse(
              data['TotalData']?.toString() ?? '',
            ) ??
                0;

        if (loadMore) {
          products.addAll(result);
        } else {
          products = result;
        }

        limit = products.length;
      } else {
        if (!loadMore) {
          products = [];
        }

        errorMessage =
            data['msg']?.toString() ?? 'Unable to load products';
      }
    } catch (e) {
      errorMessage = 'Something went wrong';

      debugPrint('Product API error: $e');
    } finally {
      isLoading = false;
      isLoadingMore = false;

      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  void onSearchChanged(String value) {
    search = value.trim();

    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 400),
          () {
        loadProducts();
      },
    );
  }

  // ------------------------------------------------------------
  // SECTION
  // ------------------------------------------------------------

  bool isSectionSelected(SectionModel section) {
    return selectedSections.any(
          (e) => e.id == section.id,
    );
  }

  void toggleSection(SectionModel section) {
    final index = selectedSections.indexWhere(
          (e) => e.id == section.id,
    );

    if (index >= 0) {
      selectedSections.removeAt(index);
    } else {
      selectedSections.add(section);
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // COLOR
  // ------------------------------------------------------------

  bool isColorSelected(ColorModel color) {
    return selectedColors.any(
          (e) => e.id == color.id,
    );
  }

  void toggleColor(ColorModel color) {
    final index = selectedColors.indexWhere(
          (e) => e.id == color.id,
    );

    if (index >= 0) {
      selectedColors.removeAt(index);
    } else {
      selectedColors.add(color);
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // SIZE
  // ------------------------------------------------------------

  bool isSizeSelected(SizeModel size) {
    return selectedSizes.any(
          (e) => e.id == size.id,
    );
  }

  void toggleSize(SizeModel size) {
    final index = selectedSizes.indexWhere(
          (e) => e.id == size.id,
    );

    if (index >= 0) {
      selectedSizes.removeAt(index);
    } else {
      selectedSizes.add(size);
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // SORT
  // ------------------------------------------------------------

  void setSort(String value) {
    orderBy = value;

    notifyListeners();

    loadProducts();
  }

  void setType(String value) {
    type = value;

  }

  void setGenderType(String value) {
    genderType = value;
  }

  void addSection(SectionModel value) {
    print("this is good");
    print(value);
    selectedSections.add(value);
  }

  // ------------------------------------------------------------
  // APPLY FILTER
  // ------------------------------------------------------------

  Future<void> applyFilters() async {
    await loadProducts();
  }

  // ------------------------------------------------------------
  // CLEAR ALL
  // ------------------------------------------------------------

  void clearAllFilters() {
    selectedSections.clear();
    selectedColors.clear();
    selectedSizes.clear();

    search = '';
    orderBy = '';

    notifyListeners();

    loadProducts();
  }

  // ------------------------------------------------------------
  // CLEAR SECTION
  // ------------------------------------------------------------

  void clearSection(SectionModel section) {
    selectedSections.removeWhere(
          (e) => e.id == section.id,
    );

    notifyListeners();

    loadProducts();
  }

  // ------------------------------------------------------------
  // CLEAR COLOR
  // ------------------------------------------------------------

  void clearColor(ColorModel color) {
    selectedColors.removeWhere(
          (e) => e.id == color.id,
    );

    notifyListeners();

    loadProducts();
  }

  // ------------------------------------------------------------
  // CLEAR SIZE
  // ------------------------------------------------------------

  void clearSize(SizeModel size) {
    selectedSizes.removeWhere(
          (e) => e.id == size.id,
    );

    notifyListeners();

    loadProducts();
  }

  // ------------------------------------------------------------
  // TOTAL SELECTED FILTERS
  // ------------------------------------------------------------

  int get selectedFilterCount {
    return selectedSections.length +
        selectedColors.length +
        selectedSizes.length;
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}