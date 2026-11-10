import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/session/session_manager.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';


class SplashController extends ChangeNotifier {

  bool isLoading = true;
  bool isLogin = false;


  Future<void> checkLogin() async {

    GlobalVars.userId = await SessionManager.getLoginId();
    GlobalVars.userName = await SessionManager.getName();
    GlobalVars.roleId = await SessionManager.getRoleId();

    await Future.delayed(
      const Duration(
        milliseconds: 600,
      ),
    );

    if(GlobalVars.userId.isNotEmpty)
    {
      isLogin = true;
    }

    isLoading = false;
    notifyListeners();
  }
}