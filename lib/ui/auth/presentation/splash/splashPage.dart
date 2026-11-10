import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/constants/app_images.dart';
import 'package:flutter_ecom/core/routes/routes.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/auth/presentation/splash/splash_controller.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final controller = SplashController();



  @override
  void initState() {
    super.initState();
     startAnimation();
  }

  Future<void> startAnimation() async {

    await controller.checkLogin();

    if (!mounted) return;

    if (controller.isLogin) {
      Navigator.pushReplacementNamed(context, Routes.mainNavigation);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryAppColor,
          image: DecorationImage(
            image: AssetImage(
                AppImages.splashScreen,
            ),
            fit: BoxFit.fitHeight,
          ),
        ),

        // child: Stack(
        //   children: [
        //     /// TOP RIGHT CIRCLE
        //     Positioned(
        //       top: -80,
        //       right: -50,
        //       child: Container(
        //         height: 220,
        //         width: 220,
        //         decoration: BoxDecoration(
        //           color: Colors.white.withOpacity(.08),
        //           shape: BoxShape.circle,
        //         ),
        //       ),
        //     ),
        //
        //     /// BOTTOM LEFT CIRCLE
        //     Positioned(
        //       bottom: -100,
        //       left: -60,
        //       child: Container(
        //         height: 260,
        //         width: 260,
        //         decoration: BoxDecoration(
        //           color: Colors.white.withOpacity(.05),
        //           shape: BoxShape.circle,
        //         ),
        //       ),
        //     ),
        //
        //     /// CONTENT
        //     Center(
        //       child: ListenableBuilder(
        //         listenable: controller,
        //
        //         builder: (context, child) {
        //           return Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //
        //             children: [
        //               /// ANIMATED LOGO
        //               ScaleTransition(
        //                 scale: logoScale,
        //
        //                 child: AnimatedBuilder(
        //                   animation: pulseAnimation,
        //
        //                   builder: (context, child) {
        //                     return Transform.scale(
        //                       scale: pulseAnimation.value,
        //
        //                       child: Container(
        //                         height: 110,
        //                         width: 110,
        //
        //                         decoration: BoxDecoration(
        //                           color: Colors.white.withValues(alpha: .15),
        //
        //                           borderRadius: BorderRadius.circular(32),
        //
        //                           border: Border.all(
        //                             color: Colors.white.withValues(alpha: .2),
        //                           ),
        //
        //                           boxShadow: [
        //                             BoxShadow(
        //                               color: Colors.black.withOpacity(.12),
        //
        //                               blurRadius: 25,
        //
        //                               offset: const Offset(0, 10),
        //                             ),
        //                           ],
        //                         ),
        //
        //                         child:  Image.asset(
        //                         AppImages.appLogo,
        //                         height: 120,
        //                       )
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ),
        //
        //               const SizedBox(height: 30),
        //
        //               /// APP NAME
        //               FadeTransition(
        //                 opacity: textOpacity,
        //                 child: const Text(
        //                   appName,
        //                   style: TextStyle(
        //                     fontSize: 36,
        //                     fontWeight: FontWeight.bold,
        //                     color: Colors.white,
        //                     letterSpacing: 1,
        //                   ),
        //                 ),
        //               ),
        //
        //               const SizedBox(height: 10),
        //
        //               /// SUBTITLE
        //               FadeTransition(
        //                 opacity: textOpacity,
        //                 child: Text(
        //                   "Smart Task Management",
        //                   style: TextStyle(
        //                     fontSize: 16,
        //                     color: Colors.white.withOpacity(.85),
        //                     letterSpacing: .5,
        //                   ),
        //                 ),
        //               ),
        //
        //               const SizedBox(height: 60),
        //
        //             ],
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
