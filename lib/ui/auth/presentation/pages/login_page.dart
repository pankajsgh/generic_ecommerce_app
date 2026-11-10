import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/constants/app_images.dart';
import 'package:flutter_ecom/ui/auth/presentation/pages/signupScreen.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widget/otp_box_widget.dart';
import '../controllers/auth_controller.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = AuthController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollToField(double height) {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }


  void getFinalOtp(String otp){
    print(otp);
    controller.setOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 10) {
      _scrollToField(keyboardHeight);
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F7FF),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            children: [
              /// TOP GRADIENT BACKGROUND
              Container(
                height: MediaQuery.of(context).size.height * .42,
                decoration: BoxDecoration(
                  color: primaryAppColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),

              /// CIRCLE EFFECTS
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                top: 60,
                left: -50,
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      /// LOGO
                      Container(
                        height: 240,
                        width: 240,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .2),
                          ),
                        ),
                        child: Image.asset(
                            AppImages.loginImage,
                          height: 240,
                        )
                      ),

                      const SizedBox(height: 18),
                      

                      Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(32),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),

                              blurRadius: 30,

                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            /// TITLE
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Welcome Back 👋",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff1E293B),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Login with mobile number",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// MOBILE FIELD
                            if (!controller.showOtp)
                              CustomTextField(
                                controller: controller.mobileController,

                                hintText: "Enter mobile number",

                                prefixIcon: Icons.phone_android,

                                keyboardType: TextInputType.phone,

                                maxLength: 10,

                                showCountryCode: true,
                              ),

                            /// OTP FIELD
                            if (controller.showOtp)
                              Column(
                                children: [

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                    children: [
                                      Text(
                                        "OTP sent to +91 ${controller.mobileController.text}",

                                        style: const TextStyle(
                                          fontSize: 12,

                                          color: Colors.grey,
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          controller.sendOtp(context);
                                        },

                                        child: Text(
                                          "Resend",

                                          style: TextStyle(
                                            color: primaryButtonColor,

                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),

                            if (controller.showOtp)
                              OtpBoxWidget(index: 4, callBack: getFinalOtp, otp: controller.otp),
                            const SizedBox(height: 12),
                            if (controller.showOtp)
                              Row(children: [
                              Icon(Icons.lock_outline, size: 18, color: Colors.grey,),
                              SizedBox(width: 8,),
                              Text("Enter OTP", style: TextStyle(fontSize: 12, color: Colors.grey),)
                            ],),

                            const SizedBox(height: 12),

                            /// BUTTON
                            SizedBox(
                              width: double.infinity,

                              height: 46,

                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () {
                                        controller.showOtp
                                            ? controller.verifyOtp(context)
                                            : controller.sendOtp(context);
                                      },

                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryButtonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                child: controller.isLoading
                                    ? const SizedBox(
                                        height: 22,

                                        width: 22,

                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,

                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        controller.showOtp
                                            ? "Verify OTP"
                                            : "Send OTP",

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 16,

                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// CHANGE MOBILE
                            if (controller.showOtp)
                              GestureDetector(
                                onTap: () {
                                  controller.changeNo();
                                },

                                child: Text(
                                  "Change Mobile Number",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ) else
                             Row(
                              children: [
                                Text(
                                  "Don't have an account",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: .85),
                                  ),
                                ),
                                SizedBox(width: 20,),
                                InkWell(
                                  onTap: () async {
                                   Map<String, dynamic>? value = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const SignupScreen(),
                                      ),
                                    );

                                   if(value!=null)
                                     {
                                      controller.setVerifyByRegister(value);
                                     }
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryButtonColor
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      SizedBox(),

                      const SizedBox(height: 26),
                      Text("Need help ?", style: TextStyle(fontWeight: FontWeight.w600),),
                      const SizedBox(height: 4),

                      Text("+91 8595633981", style: TextStyle(fontWeight: FontWeight.w600),)


                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hintText;

  final IconData prefixIcon;

  final Widget? suffixIcon;

  final bool obscureText;

  final int? maxLength;

  final bool showCountryCode;

  final TextInputType keyboardType;

  const CustomTextField({
    super.key,

    required this.controller,

    required this.hintText,

    required this.prefixIcon,

    this.suffixIcon,

    this.obscureText = false,

    this.maxLength,

    this.showCountryCode = false,

    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: TextField(
        controller: controller,

        obscureText: obscureText,

        maxLength: maxLength,

        keyboardType: keyboardType,

        decoration: InputDecoration(
          counterText: "",

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),

          /// PREFIX
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              const SizedBox(width: 14),

              Icon(prefixIcon, color: Colors.grey, size: 22),

              if (showCountryCode)
                Container(
                  margin: const EdgeInsets.only(left: 8),

                  child: const Text(
                    "+91",

                    style: TextStyle(
                      fontSize: 15,

                      fontWeight: FontWeight.w600,

                      color: Colors.black87,
                    ),
                  ),
                ),

              if (showCountryCode)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),

                  child: Text("|", style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),

          suffixIcon: suffixIcon,

          hintText: hintText,

          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

/// ------------------------------
/// CUSTOM TEXT FIELD
/// ------------------------------
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controllers;
//   final String hintText;
//   final IconData prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//
//   const CustomTextField({
//     super.key,
//     required this.controllers,
//     required this.hintText,
//     required this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       child: TextField(
//         controllers: controllers,
//         obscureText: obscureText,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 12),
//           prefixIcon: Icon(
//             prefixIcon,
//             color: Colors.grey,
//           ),
//           suffixIcon: suffixIcon,
//           hintText: hintText,
//           hintStyle: TextStyle(
//             color: Colors.grey.shade500,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }
// }
