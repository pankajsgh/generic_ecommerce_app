
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/auth/data/state_list_model.dart';
import 'package:flutter_ecom/ui/auth/presentation/controllers/signupController.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = "/signup-screen";

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController controller;

  final _formKey = GlobalKey<FormState>();

  final nameFocus = FocusNode();
  final mobileFocus = FocusNode();
  final alternateMobileFocus = FocusNode();
  final emailFocus = FocusNode();
  final companyFocus = FocusNode();
  final addressFocus = FocusNode();
  final stateFocus = FocusNode();
  final cityFocus = FocusNode();
  final pincodeFocus = FocusNode();
  final gstFocus = FocusNode();
  final agentNameFocus = FocusNode();
  final agentMobileFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    controller = SignupController();

    controller.resetAll();
    controller.fetchStateList();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    mobileFocus.dispose();
    alternateMobileFocus.dispose();
    emailFocus.dispose();
    companyFocus.dispose();
    addressFocus.dispose();
    stateFocus.dispose();
    cityFocus.dispose();
    pincodeFocus.dispose();
    gstFocus.dispose();
    agentNameFocus.dispose();
    agentMobileFocus.dispose();

    controller.dispose();

    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _submit() async {
    _unfocus();

    debugPrint("========== SIGNUP VALIDATION START ==========");

    final isValid = _formKey.currentState?.validate() ?? false;

    debugPrint("FORM VALIDATION: $isValid");

    if (!isValid) {
      debugPrint("❌ SIGNUP VALIDATION FAILED");

      debugPrint("Please check the validation messages displayed below the fields.");

      // Print all field values for debugging
      debugPrint("========== ENTERED FIELD VALUES ==========");

      debugPrint("Full Name: ${controller.nameController.text}");
      debugPrint("Mobile: ${controller.mobileController.text}");
      debugPrint("Alternative Mobile: ${controller.alternateMobileController.text}");
      debugPrint("Email: ${controller.emailController.text}");
      debugPrint("Company: ${controller.companyNameController.text}");
      debugPrint("Address: ${controller.addressController.text}");
      debugPrint("City: ${controller.cityController.text}");
      debugPrint("Pincode: ${controller.pincodeController.text}");
      debugPrint("GST: ${controller.gstNoController.text}");

      debugPrint("==========================================");

      return;
    }

    debugPrint("✅ ALL FIELDS ARE VALID");

    Map<String, dynamic>? response = await controller.signupUser();

    if (!mounted || response == null) {
      return;
    }

    if (response['error'] == true) {
      response["logintype"] = "Register";

      controller.mobileController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['msg'] ?? "Unable to create account",
          ),
        ),
      );

      await Future.delayed(Duration(milliseconds: 500));

      Navigator.pop(context, response);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['msg'] ?? "Unable to create account",
        ),
      ),
    );
  }
  void _openStateSheet() {
    _unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return StateBottomSheet(
          controller: controller,
          onSelected: (state) {
            controller.setSelectedState(state);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  Future<void> _selectCountry() async {
    _unfocus();

    final country = await controller.getCountryCode(
      context: context,
    );

    if (country != null) {
      controller.setCountryCode(country);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xffF2F2F2),
      ),

      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 20,
              ),
              children: [
                const _Header(),

                const _Description(),

                _InputField(
                  controller: controller.nameController,
                  focusNode: nameFocus,
                  label: "Full Name*",
                  keyboardType: TextInputType.name,
                  validator: SignupValidators.name,
                ),

                _MobileField(
                  controller: controller,
                  focusNode: mobileFocus,
                  onCountryTap: _selectCountry,
                ),

                _InputField(
                  controller: controller.alternateMobileController,
                  focusNode: alternateMobileFocus,
                  label: "Alternative Number",
                  keyboardType: TextInputType.phone,
                  validator: SignupValidators.optionalMobile,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),

                _InputField(
                  controller: controller.emailController,
                  focusNode: emailFocus,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: SignupValidators.optionalEmail,
                ),

                _InputField(
                  controller: controller.companyNameController,
                  focusNode: companyFocus,
                  label: "Company Name",
                  keyboardType: TextInputType.name,
                  validator: SignupValidators.optionalCompany,
                ),

                _InputField(
                  controller: controller.addressController,
                  focusNode: addressFocus,
                  label: "Address",
                  keyboardType: TextInputType.streetAddress,
                  validator: SignupValidators.optionalAddress,
                ),

                _StateField(
                  controller: controller,
                  focusNode: stateFocus,
                  onTap: _openStateSheet,
                ),

                _InputField(
                  controller: controller.cityController,
                  focusNode: cityFocus,
                  label: "City",
                  keyboardType: TextInputType.name,
                  validator: SignupValidators.optionalCity,
                ),

                _InputField(
                  controller: controller.pincodeController,
                  focusNode: pincodeFocus,
                  label: "Pincode",
                  keyboardType: TextInputType.number,
                  validator: SignupValidators.optionalPincode,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),

                _InputField(
                  controller: controller.gstNoController,
                  focusNode: gstFocus,
                  label: "GST Number",
                  keyboardType: TextInputType.text,
                  validator: SignupValidators.optionalGst,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    const UpperCaseTextFormatter(),
                  ],
                ),

                _InputField(
                  controller: controller.agentnameController,
                  focusNode: agentNameFocus,
                  label: "Agent Name",
                  keyboardType: TextInputType.name,
                  validator: SignupValidators.optionalName,
                ),

                _AgentMobileField(
                  controller: controller,
                  focusNode: agentMobileFocus,
                ),

                const SizedBox(height: 18),

                _SignupButton(
                  loading: controller.isLoading,
                  onPressed: _submit,
                ),

                const SizedBox(height: 18),

                const _LoginRedirect(),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// UI CONSTANTS
// ============================================================

class _SignupUi {
  /// Actual visible input border height.
  static const double fieldHeight = 46;

  static const double horizontalPadding = 16;

  /// Space above/below each field.
  static const double fieldSpacing = 8;

  static const double radius = 8;

  static const Color borderColor = Color(0xffDBDBDB);
  static const Color textColor = Color(0xff3A3A3A);
  static const Color labelColor = Color(0xff555555);
  static const Color hintColor = Color(0xff9A9A9A);
}

// ============================================================
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        0,
      ),
      child: Text(
        "Create an Account",
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ============================================================
// DESCRIPTION
// ============================================================

class _Description extends StatelessWidget {
  const _Description();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        5,
        18,
        12,
      ),
      child: Text(
        "Please provide us with this information in order to create an account.",
        style: GoogleFonts.montserrat(
          fontSize: 11,
          color: const Color(0xff82828A),
        ),
      ),
    );
  }
}

// ============================================================
// COMMON INPUT FIELD
// ============================================================

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _SignupUi.horizontalPadding,
        vertical: _SignupUi.fieldSpacing,
      ),
      child: SizedBox(
        height: _SignupUi.fieldHeight,
        width: double.infinity,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,

          cursorColor: primaryButtonColor,

          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: _SignupUi.textColor,
          ),

          textAlignVertical: TextAlignVertical.center,

          decoration: _inputDecoration(
            label: label,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MOBILE FIELD
// ============================================================

class _MobileField extends StatelessWidget {
  final SignupController controller;
  final FocusNode focusNode;
  final VoidCallback onCountryTap;

  const _MobileField({
    required this.controller,
    required this.focusNode,
    required this.onCountryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _SignupUi.horizontalPadding,
        vertical: _SignupUi.fieldSpacing,
      ),
      child: SizedBox(
        height: _SignupUi.fieldHeight,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CountryButton(
              code: controller.selectedCountryCode,
              flag: controller.countryCode == null
                  ? Image.asset(
                "assets/images/icon_flag_india.png",
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              )
                  : controller.countryCode!.flagImage(
                fit: BoxFit.contain,
              ),
              onTap: onCountryTap,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: TextFormField(
                controller: controller.mobileController,
                focusNode: focusNode,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: SignupValidators.mobile,
                cursorColor: primaryButtonColor,

                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: _SignupUi.textColor,
                ),

                textAlignVertical: TextAlignVertical.center,

                decoration: _inputDecoration(
                  label: "Mobile Number",
                  hint: "Enter Mobile Number",
                ).copyWith(
                  counterText: "",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COUNTRY BUTTON
// ============================================================

class _CountryButton extends StatelessWidget {
  final String code;
  final Widget flag;
  final VoidCallback onTap;

  const _CountryButton({
    required this.code,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _SignupUi.fieldHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          _SignupUi.radius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            _SignupUi.radius,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _SignupUi.radius,
              ),
              border: Border.all(
                color: _SignupUi.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                flag,

                const SizedBox(width: 5),

                Text(
                  code,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AGENT MOBILE
// ============================================================

class _AgentMobileField extends StatelessWidget {
  final SignupController controller;
  final FocusNode focusNode;

  const _AgentMobileField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _SignupUi.horizontalPadding,
        vertical: _SignupUi.fieldSpacing,
      ),
      child: SizedBox(
        height: _SignupUi.fieldHeight,
        width: double.infinity,
        child: TextFormField(
          controller: controller.agentMobileController,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: SignupValidators.optionalMobile,
          cursorColor: primaryButtonColor,

          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: _SignupUi.textColor,
          ),

          textAlignVertical: TextAlignVertical.center,

          decoration: _inputDecoration(
            label: "Agent Mobile",
            hint: "Enter Agent Mobile",
          ).copyWith(
            counterText: "",
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATE FIELD
// ============================================================

class _StateField extends StatelessWidget {
  final SignupController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;

  const _StateField({
    required this.controller,
    required this.focusNode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _SignupUi.horizontalPadding,
        vertical: _SignupUi.fieldSpacing,
      ),
      child: SizedBox(
        height: _SignupUi.fieldHeight,
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            _SignupUi.radius,
          ),
          child: IgnorePointer(
            child: TextFormField(
              controller: controller.stateController,
              focusNode: focusNode,
              readOnly: true,
              validator: SignupValidators.optionalState,
              cursorColor: primaryButtonColor,

              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: _SignupUi.textColor,
              ),

              textAlignVertical: TextAlignVertical.center,

              decoration: _inputDecoration(
                label: "State",
                hint: "Select State",
              ).copyWith(
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _inputDecoration({
  required String label,
  String? hint,
}) {
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        _SignupUi.radius,
      ),
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,

    floatingLabelBehavior: FloatingLabelBehavior.always,

    labelStyle: GoogleFonts.montserrat(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: _SignupUi.labelColor,
    ),

    hintStyle: GoogleFonts.montserrat(
      fontSize: 12,
      color: _SignupUi.hintColor,
    ),

// Do NOT use isDense:true here.
    isDense: false,

    filled: true,
    fillColor: Colors.white,

// Controlled vertical position.
    contentPadding: const EdgeInsets.only(
      left: 12,
      right: 12,
      top: 16,
      bottom: 4,
    ),

    border: border(
      _SignupUi.borderColor,
    ),

    enabledBorder: border(
      _SignupUi.borderColor,
    ),

    focusedBorder: border(
      primaryButtonColor,
    ),

    errorBorder: border(
      Colors.red,
    ),

    focusedErrorBorder: border(
      Colors.red,
    ),

// Important:
// Error text must not increase the field height.
    errorStyle: const TextStyle(
      fontSize: 0,
      height: 0,
    ),
  );
}

// ============================================================
// SIGNUP BUTTON
// ============================================================

class _SignupButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _SignupButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: primaryRedButtonColor,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "SIGN UP",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN REDIRECT
// ============================================================

class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Already have an account? ",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: "Login Here",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: primaryButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STATE BOTTOM SHEET
// ============================================================

class StateBottomSheet extends StatelessWidget {
  final SignupController controller;
  final ValueChanged<StateList> onSelected;

  const StateBottomSheet({
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .70,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 16),

                _StateSearchField(
                  controller: controller,
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: _buildContent(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isStateListLoading &&
        controller.stateList.isEmpty) {
      return const Center(
        child: _Loader(),
      );
    }

    if (controller.isStateListLoadFail &&
        controller.stateList.isEmpty) {
      return _EmptyState(
        onRetry: controller.fetchStateList,
      );
    }

    if (controller.stateList.isEmpty) {
      return const Center(
        child: Text("No Data Found"),
      );
    }

    return _StateList(
      controller: controller,
      onSelected: onSelected,
    );
  }
}

// ============================================================
// STATE SEARCH
// ============================================================

class _StateSearchField extends StatelessWidget {
  final SignupController controller;

  const _StateSearchField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: controller.stateSearchController,
          onChanged: (value) {
            controller.setStateSearch(value);
            controller.fetchStateList();
          },
          textInputAction: TextInputAction.search,

          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.black,
          ),

          decoration: InputDecoration(
            hintText: "Search by State",

            hintStyle: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),

            prefixIcon: const Icon(
              Icons.search,
              size: 19,
              color: Colors.grey,
            ),

            suffixIcon:
            controller.stateSearchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                controller.stateSearchController.clear();
                controller.setStateSearch("");
                controller.fetchStateList();
              },
              icon: const Icon(
                Icons.close,
                size: 17,
                color: Colors.grey,
              ),
            )
                : null,

            filled: true,
            fillColor: Colors.grey.shade100,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: primaryButtonColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATE LIST
// ============================================================

class _StateList extends StatelessWidget {
  final SignupController controller;
  final ValueChanged<StateList> onSelected;

  const _StateList({
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = controller.stateList.length +
        (controller.isStateListLoadMore ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter == 0 &&
            !controller.isStateListLoadMore) {
          controller.fetchStateList(
            showLoader: true,
          );
        }

        return false;
      },
      child: ListView.separated(
        itemCount: itemCount,

        separatorBuilder: (_, __) {
          return const Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          );
        },

        itemBuilder: (context, index) {
          if (index >= controller.stateList.length) {
            return const SizedBox(
              height: 48,
              child: Center(
                child: _Loader(
                  size: 22,
                ),
              ),
            );
          }

          final state = controller.stateList[index];

          final selected =
              controller.selectedState.id == state.id;

          return _StateItem(
            state: state,
            selected: selected,
            onTap: () => onSelected(state),
          );
        },
      ),
    );
  }
}

// ============================================================
// STATE ITEM
// ============================================================

class _StateItem extends StatelessWidget {
  final StateList state;
  final bool selected;
  final VoidCallback onTap;

  const _StateItem({
    required this.state,
    required this.selected,
    required this.onTap,
  });

  static const double itemHeight = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.stateName ?? "Select State",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle,
                  size: 19,
                  color: primaryButtonColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 40,
            color: Colors.grey,
          ),

          const SizedBox(height: 10),

          Text(
            "No Data Found",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
              size: 17,
            ),
            label: Text(
              "Retry",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryButtonColor,
              side: BorderSide(
                color: primaryButtonColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADER
// ============================================================

class _Loader extends StatelessWidget {
  final double size;

  const _Loader({
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: primaryRedButtonColor,
      ),
    );
  }
}

// ============================================================
// UPPERCASE FORMATTER
// ============================================================

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// ============================================================
// VALIDATORS
// ============================================================

class SignupValidators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    final text = value.trim();

    if (text.length < 2) {
      return "Enter a valid name";
    }

    if (text.length > 50) {
      return "Name cannot exceed 50 characters";
    }

    if (!RegExp(
      r"^[a-zA-ZÀ-ÿ]+(?:[ '-][a-zA-ZÀ-ÿ]+)*$",
    ).hasMatch(text)) {
      return "Enter a valid name";
    }

    return null;
  }

  static String? optionalName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return name(value);
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Mobile number is required";
    }

    final mobile = value.trim();

    if (!RegExp(r"^[6-9][0-9]{9}$").hasMatch(mobile)) {
      return "Enter valid mobile number";
    }

    return null;
  }

  static String? optionalMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return mobile(value);
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final email = value.trim();

    if (email.length > 254) {
      return "Email is too long";
    }

    if (!RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    ).hasMatch(email)) {
      return "Enter a valid email address";
    }

    return null;
  }

  static String? optionalCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final company = value.trim();

    if (company.length < 2) {
      return "Enter a valid company name";
    }

    if (company.length > 100) {
      return "Company name cannot exceed 100 characters";
    }

    return null;
  }

  static String? optionalAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final address = value.trim();

    if (address.length < 5) {
      return "Enter a valid address";
    }

    if (address.length > 250) {
      return "Address cannot exceed 250 characters";
    }

    return null;
  }

  static String? optionalCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final city = value.trim();

    if (city.length < 2) {
      return "Enter a valid city";
    }

    if (city.length > 50) {
      return "City cannot exceed 50 characters";
    }

    if (!RegExp(
      r"^[a-zA-ZÀ-ÿ]+(?:[ .'-][a-zA-ZÀ-ÿ]+)*$",
    ).hasMatch(city)) {
      return "Enter a valid city";
    }

    return null;
  }

  static String? optionalPincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final pincode = value.trim();

    if (!RegExp(r"^[1-9][0-9]{5}$").hasMatch(pincode)) {
      return "Enter valid 6-digit pincode";
    }

    return null;
  }

  static String? optionalGst(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final gst = value.trim().toUpperCase();

    if (gst.length != 15) {
      return "GST number must be 15 characters";
    }

    if (!RegExp(
      r"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$",
    ).hasMatch(gst)) {
      return "Enter a valid GST number";
    }

    return null;
  }

  static String? optionalState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return null;
  }
}
