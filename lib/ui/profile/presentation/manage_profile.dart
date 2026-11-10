import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/auth/presentation/controllers/signupController.dart';
import 'package:flutter_ecom/ui/auth/presentation/pages/signupScreen.dart';
import 'package:flutter_ecom/ui/profile/data/controller/profile_controller.dart';

class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();

    controller = ProfileController(dio: Dio());

    controller.loadProfile();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _buildProfileHeader(),

              const SizedBox(height: 12),

              _buildPersonalInformation(),

              const SizedBox(height: 12),

              _buildAddressInformation(),

              const SizedBox(height: 12),

              _buildGstInformation(),

              const SizedBox(height: 12),

              _buildAgentInformation(),

              if (controller.isEditing) ...[
                const SizedBox(height: 14),
                _buildUpdateButton(),
              ],

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleSpacing: 16,

      title: const Text(
        'My Profile',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),

      actions: [
        ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return TextButton.icon(
              onPressed: controller.isUpdating
                  ? null
                  : () {
                      if (controller.isEditing) {
                        controller.cancelEditing();
                      } else {
                        controller.startEditing();
                      }
                    },

              icon: Icon(
                controller.isEditing
                    ? Icons.close_rounded
                    : Icons.edit_outlined,
                size: 18,
              ),

              label: Text(
                controller.isEditing ? 'Cancel' : 'Edit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final name = controller.fullNameController.text.trim();

    final company = controller.companyNameController.text.trim();

    final email = controller.emailController.text.trim();

    final mobile = controller.mobileController.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),

      child: Row(
        children: [
          // ======================================================
          // PROFILE PHOTO
          // ======================================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 68,
                width: 68,
                padding: const EdgeInsets.all(2),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffD9E6F5), width: 2),
                ),

                child: ClipOval(child: _buildUserPhoto()),
              ),

              if (controller.isEditing)
                Positioned(
                  right: -3,
                  bottom: -2,

                  child: Material(
                    color: Colors.transparent,

                    child: InkWell(
                      onTap: controller.pickProfileImage,

                      borderRadius: BorderRadius.circular(20),

                      child: Container(
                        height: 30,
                        width: 30,

                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),

                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // ======================================================
          // USER INFORMATION
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name.isEmpty ? 'Your Name' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff202124),
                  ),
                ),

                if (company.isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6F747C),
                    ),
                  ),
                ],

                if (email.isNotEmpty || mobile.isNotEmpty) ...[
                  const SizedBox(height: 7),

                  if (email.isNotEmpty)
                    _buildCompactInfo(icon: Icons.email_outlined, text: email),

                  if (email.isNotEmpty && mobile.isNotEmpty)
                    const SizedBox(height: 5),

                  if (mobile.isNotEmpty)
                    _buildCompactInfo(icon: Icons.phone_outlined, text: mobile),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER PHOTO
  // ============================================================

  Widget _buildUserPhoto() {
    // New selected image
    if (controller.profileImage != null) {
      return Image.file(
        controller.profileImage!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // Existing image
    final photo = GlobalVars.userAccountData.photo.trim();

    if (photo.isNotEmpty) {
      return Image.network(
        photo,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultProfileIcon();
        },
      );
    }

    return _buildDefaultProfileIcon();
  }

  // ============================================================
  // DEFAULT PROFILE ICON
  // ============================================================

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: const Color(0xffEEF4FC),

      child: const Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 34,
          color: Color(0xff6D819B),
        ),
      ),
    );
  }

  // ============================================================
  // COMPACT INFO
  // ============================================================

  Widget _buildCompactInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xff7A828C)),

        const SizedBox(width: 4),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(fontSize: 12, color: Color(0xff737982)),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      fields: [
        controller.fullNameController,
        controller.companyNameController,
        controller.alternateMobileController,
        controller.emailController,
      ],
    );
  }

  // ============================================================
  // ADDRESS INFORMATION
  // ============================================================

  Widget _buildAddressInformation() {
    return _buildSection(
      title: 'Address Information',
      icon: Icons.location_on_outlined,
      fields: [
        controller.addressController,
        controller.stateController,
        controller.cityController,
        controller.pinCodeController,
      ],
    );
  }

  // ============================================================
  // GST INFORMATION
  // ============================================================

  Widget _buildGstInformation() {
    return _buildSection(
      title: 'GST Information',
      icon: Icons.receipt_long_outlined,
      fields: [controller.gstTypeController, controller.gstNoController],
    );
  }

  // ============================================================
  // AGENT INFORMATION
  // ============================================================

  Widget _buildAgentInformation() {
    return _buildSection(
      title: 'Agent Information',
      icon: Icons.person_search_outlined,
      fields: [
        controller.agentnameController,
        controller.agentMobileController,
      ],
    );
  }

  // ============================================================
  // GENERIC SECTION
  // ============================================================

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _openStateSheet() {
    SignupController signupController = SignupController();
    signupController.fetchStateList();
    _unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StateBottomSheet(
          controller: signupController,
          onSelected: (state) {
            controller.setSelectedState(state);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  late final List<ProfileField> textFields = [
    ProfileField(
      title: 'Full Name',
      hint: 'Enter full name',
      icon: Icons.person_outline,
      controller: controller.fullNameController,
      keyboardType: TextInputType.name,
    ),

    ProfileField(
      title: 'Company Name',
      hint: 'Enter company name',
      icon: Icons.business_outlined,
      controller: controller.companyNameController,
      keyboardType: TextInputType.text,
    ),

    ProfileField(
      title: 'Alternate Mobile Number',
      hint: 'Enter mobile number',
      icon: Icons.phone_outlined,
      controller: controller.alternateMobileController,
      keyboardType: TextInputType.phone,
    ),

    ProfileField(
      title: 'Email Address',
      hint: 'Enter email address',
      icon: Icons.email_outlined,
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
    ),

    ProfileField(
      title: 'Address',
      hint: 'Enter address',
      icon: Icons.home_outlined,
      controller: controller.addressController,
      keyboardType: TextInputType.streetAddress,
      maxLines: 2,
    ),

    ProfileField(
      title: 'State',
      hint: 'Enter state',
      onTap: _openStateSheet,
      icon: Icons.location_on_outlined,
      controller: controller.stateController,
      keyboardType: TextInputType.text,
    ),

    ProfileField(
      title: 'City',
      hint: 'Enter city',
      icon: Icons.location_city_outlined,
      controller: controller.cityController,
      keyboardType: TextInputType.text,
    ),

    ProfileField(
      title: 'Pin Code',
      hint: 'Enter pin code',
      icon: Icons.pin_drop_outlined,
      controller: controller.pinCodeController,
      keyboardType: TextInputType.number,
    ),

    ProfileField(
      title: 'GST Type',
      hint: 'Enter GST type',
      icon: Icons.receipt_long_outlined,
      controller: controller.gstTypeController,
      keyboardType: TextInputType.text,
    ),

    ProfileField(
      title: 'GST Number',
      hint: 'Enter GST number',
      icon: Icons.receipt_outlined,
      controller: controller.gstNoController,
      keyboardType: TextInputType.text,
    ),

    ProfileField(
      title: 'Agent Name',
      hint: 'Enter agent name',
      icon: Icons.person_search_outlined,
      controller: controller.agentnameController,
      keyboardType: TextInputType.name,
    ),

    ProfileField(
      title: 'Agent Number',
      hint: 'Enter agent mobile number',
      icon: Icons.phone_callback_outlined,
      controller: controller.agentMobileController,
      keyboardType: TextInputType.phone,
    ),
  ];

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<TextEditingController> fields,
  }) {
    final profileFields = textFields
        .where((field) => fields.contains(field.controller))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 3),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ======================================================
          // SECTION TITLE
          // ======================================================
          Row(
            children: [
              Container(
                height: 30,
                width: 30,

                decoration: BoxDecoration(
                  color: const Color(0xffF1F6FC),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Icon(icon, size: 17, color: const Color(0xff56779D)),
              ),

              const SizedBox(width: 9),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff202124),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ======================================================
          // FIELDS
          // ======================================================
          ListView.builder(
            itemCount: profileFields.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemBuilder: (context, index) {
              final field = profileFields[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),

                child: _buildTextField(field),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField(ProfileField field) {
    final editing = controller.isEditing;
    final bool isSelectable = field.onTap != null;
    return TextField(
      controller: field.controller,
      enabled: editing || (editing && isSelectable),
      readOnly: !editing || isSelectable,
      onTap: editing? field.onTap:  null,
      keyboardType: field.keyboardType,
      maxLines: field.maxLines,
      style: TextStyle(
        fontSize: 13,
        color: editing ? const Color(0xff202124) : const Color(0xff62666D),
      ),
      decoration: InputDecoration(
        labelText: field.title,
        hintText: field.hint,
        suffixIcon: isSelectable
            ? const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xff707780),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 42,
        ),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xff62666D)),
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff9A9A9A)),
        prefixIcon: Icon(field.icon, size: 19, color: const Color(0xff707780)),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        filled: true,
        fillColor: editing ? Colors.white : const Color(0xffF7F8FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xffE1E4E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xffE1E4E8)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xffE1E4E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UPDATE BUTTON
  // ============================================================

  Widget _buildUpdateButton() {
    return SizedBox(
      height: 46,
      width: double.infinity,

      child: ElevatedButton(
        onPressed: controller.isUpdating
            ? null
            : () async {
                final success = await controller.updateProfile();

                if (!mounted) {
                  return;
                }

                if (success) {
                  _showSuccessDialog();
                } else {
                  _showErrorMessage();
                }
              },

        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: Theme.of(context).primaryColor,

          disabledBackgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.5),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),

        child: controller.isUpdating
            ? const SizedBox(
                height: 20,
                width: 20,

                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 18),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 52,
              ),

              const SizedBox(height: 12),

              const Text(
                'Profile Updated',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 7),

              Text(
                'Your profile has been updated successfully.',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 17),

              SizedBox(
                width: double.infinity,
                height: 42,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),

                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showErrorMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to update profile')));
  }
}
