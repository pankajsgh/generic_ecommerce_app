import 'package:flutter/foundation.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/network/api_provider.dart';
import 'package:flutter_ecom/core/ulitls/utility.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/core/widget/toast.dart';
import 'package:flutter_ecom/core/widget/widget_updater.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/profile/data/model/account_model.dart';

class DashboardController extends ChangeNotifier {
  DashboardModel? dashboard;

  bool isLoading = false;
  String? errorMessage;
  String selectedGender = '';
  int currentBanner = 0;
  WidgetUpdater updateCategory = WidgetUpdater();
  WidgetUpdater updateCartCount = WidgetUpdater();

  void changeGender(String gender) {
    selectedGender = gender;
    updateCategory.update();
  }

  Future<void> recheckCartCount() async {

    Map<String, String> requestBody ={
      'id':  GlobalVars.userId,
      'Subuid': GlobalVars.subUserId,
    };

    try {
      final response = await ApiProvider.createServerRequest( apiUrl: ApiPath.dashboardApi, requestBody:requestBody );

      var dataDashboard = DashboardModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if(dashboard!=null){
        dashboard!.totalCartCheck =  dataDashboard.totalCartCheck;
        // dashboard!.newArrival =dataDashboard.newArrival;
        // dashboard!.topCollection =dataDashboard.topCollection;
        // dashboard!.recentlyViewed =dataDashboard.recentlyViewed;
        updateCartCount.update();
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');

      errorMessage = 'Something went wrong';
    }
  }


  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    Map<String, String> requestBody ={
      'id':  GlobalVars.userId,
       'Subuid': GlobalVars.subUserId,
    };

    try {
      final response = await ApiProvider.createServerRequest( apiUrl: ApiPath.dashboardApi, requestBody:requestBody );

      dashboard = DashboardModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if(dashboard!=null){
        GlobalVars.appWebUrl = AppWebUrl(
          aboutUsPage: dashboard!.aboutUs,
          termCondition: dashboard!.termCondition,
          contactUs: dashboard!.contactUs,
          privacyPolicy: dashboard!.privacyPolicy,
        );
        GlobalVars.totalFavourate.value = dashboard!.totalFavourate;
        if(GlobalVars.userAccountData.id.isEmpty || GlobalVars.userAccountData.name.isEmpty)
        {
          GlobalVars.userAccountData = AccountModel(name: dashboard!.name, id: dashboard!.id, photo:dashboard!.photo);
        }
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');

      errorMessage = 'Something went wrong';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeBanner(int index) {
    currentBanner = index;
    notifyListeners();
  }


  @override
  void dispose() {
    super.dispose();
  }
}