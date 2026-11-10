
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/auth/presentation/splash/splashPage.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/mainNavbar.dart';
import '../../ui/dashboard/presentaion/dashboard.dart';
import '../../ui/auth/presentation/pages/login_page.dart';



class Routes {
  static const String login = '/login';
  static const String intro = '/';
  static const String mainNavigation = '/mainNavigation';
  static const String dashboard = '/dashboard';
  static const String addExpense = '/addExpense';
  static const String expense = '/expense';
  static const String report = '/report';
  static const String taskDetail = '/taskDetail';
  static const String profile = '/profile';
  static const String vendor = '/vendor';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == login) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }
    if (settings.name == intro) {
      return MaterialPageRoute(builder: (context) => SplashPage());
    }
    if (settings.name == dashboard) {
      return MaterialPageRoute(builder: (context) => DashboardPage());
    }
    if (settings.name == mainNavigation) {
      return MaterialPageRoute(builder: (context) => MainNavigationPage());
    }
    else {
      return MaterialPageRoute(builder: (context) => SplashPage());
    }
  }
}