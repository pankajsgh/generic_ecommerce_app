

import 'package:flutter/cupertino.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/profile/data/model/account_model.dart';
import 'package:flutter_ecom/ui/profile/presentation/OpenWebUrl.dart';

class GlobalVars{
  static bool fromDrawer=false;
  static bool hadIntro = false;
  static String userId = '';
  static String subUserId = '';
  static String roleName ='';
  static String roleId = '';
  static String userName = '';
  static String appVersion = '22.01.26';
  static String accessKey = '';
  static bool isAdmin = true;
  static String localIp = '192.168.1.15';
  static String totalTask = "0";
  static AccountModel userAccountData = AccountModel();
  static AppWebUrl appWebUrl = AppWebUrl();
  static ValueNotifier<String> totalFavourate = ValueNotifier('');

}

class AppWebUrl {
  String? aboutUsPage;
  String? termCondition;
  String? privacyPolicy;
  String? contactUs;
AppWebUrl({this.aboutUsPage, this.termCondition, this.privacyPolicy, this.contactUs});

}