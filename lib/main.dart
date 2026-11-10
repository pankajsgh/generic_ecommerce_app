import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecom/core/routes/routes.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/mainNavbar.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor:  const Color(0xff93a175),
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      onGenerateRoute: Routes.generateRoute,
      // home: MainNavigationPage(),
    );
  }
}


