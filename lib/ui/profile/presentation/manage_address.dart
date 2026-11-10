import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/widget/loader.dart';
import 'package:flutter_ecom/ui/auth/data/state_list_model.dart';
import 'package:flutter_ecom/ui/profile/data/controller/address_controller.dart';
import 'package:flutter_ecom/ui/profile/data/controller/state_controller.dart';
import 'package:flutter_ecom/ui/profile/data/model/address_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/controller/profile_controller.dart';

class ManageAddressPage extends StatefulWidget {
  final bool? isOpenAddNew;
  const ManageAddressPage({super.key, this.isOpenAddNew});

  @override
  State<ManageAddressPage> createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  late AddressController controller;

  @override
  void initState() {
    super.initState();

    controller = AddressController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAddresses(

      );
      if(widget.isOpenAddNew!=null && widget.isOpenAddNew!)
      {
        controller.startAddAddress();
        _openAddressForm();
      }

    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Manage Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff202124),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.startAddAddress();
          _openAddressForm();
        },
        elevation: 2,
        backgroundColor: primaryButtonColor,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
          size: 19,
        ),
        label: const Text(
          'Add Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.isLoading) {
            return const Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                ),
              ),
            );
          }

          if (controller.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () {
              return controller.loadAddresses();
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                90,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.addresses.length,
              itemBuilder: (context, index) {
                final address = controller.addresses[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildAddressCard(address),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xffEDF4FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 32,
                color: primaryButtonColor,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'No Address Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xff25282C),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Add an address to make your checkout faster.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: Color(0xff7A8087),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.startAddAddress();
                  _openAddressForm();
                },
                icon: const Icon(
                  Icons.add_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Add Address',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primaryButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _openStateSheet() {
    StateController stateController = StateController();
    stateController.fetchStateList();
    _unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StateBottomPopUp(
          controller: stateController,
          onSelected: (StateList state) {
            controller.setState(state);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }


  // ============================================================
  // ADDRESS CARD
  // ============================================================

  Widget _buildAddressCard(AddressModel address) {
    final bool isDefault = address.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDefault
              ? const Color(0xffDCE9F7)
              : const Color(0xffE9EBEE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================================
            // NAME + PHONE + DELETE
            // ====================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PROFILE ICON
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xffEEF4FA),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: Color(0xff4F6478),
                  ),
                ),

                const SizedBox(width: 8),

                // NAME + PHONE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.fullName.trim().isEmpty
                                  ? 'No Name'
                                  : address.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff202124),
                              ),
                            ),
                          ),

                          if (isDefault) ...[
                            const SizedBox(width: 5),
                            _buildDefaultBadge(),
                          ],
                        ],
                      ),

                      if (address.mobile.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 11,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                address.mobile,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // DELETE
                Material(
                  color: const Color(0xffFFF4F4),
                  borderRadius: BorderRadius.circular(7),
                  child: InkWell(
                    onTap: () {
                      _showDeleteDialog(address);
                    },
                    borderRadius: BorderRadius.circular(7),
                    child: const SizedBox(
                      height: 29,
                      width: 29,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Color(0xffD85C5C),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // ====================================================
            // DIVIDER
            // ====================================================

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xffEEF0F2),
            ),

            const SizedBox(height: 6),

            // ====================================================
            // ADDRESS + EDIT
            // ====================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: primaryButtonColor,
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: Text(
                    address.address.isEmpty
                        ? 'Address not available'
                        : address.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xff626870),
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                // EDIT
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  backgroundColor: const Color(0xffF3F6FA),
                  iconColor: primaryButtonColor,
                  onTap: () {
                    controller.startEditAddress(address);
                    _openAddressForm();
                  },
                ),
              ],
            ),

            const SizedBox(height: 5),

            // ====================================================
            // CITY / STATE / PINCODE / COUNTRY
            // ====================================================

            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (address.city.isNotEmpty)
                  _buildAddressTag(
                    Icons.location_city_outlined,
                    address.city,
                  ),


                if (address.state.isNotEmpty)
                  _buildAddressTag(
                    Icons.map_outlined,
                    address.state,
                  ),

                if (address.pinCode.isNotEmpty)
                  _buildAddressTag(
                    Icons.pin_drop_outlined,
                    address.pinCode,
                  ),

                if (address.country.isNotEmpty)
                  _buildAddressTag(
                    Icons.public_outlined,
                    address.country,
                  ),
              ],
            ),

            // ====================================================
            // SET DEFAULT
            // ====================================================

            if (!isDefault) ...[
              const SizedBox(height: 7),

              SizedBox(
                height: 30,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.updater.isLoading
                      ? null
                      : () async {
                    await controller.setDefaultAddress(
                      address,
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 13,
                  ),
                  label: const Text(
                    'Set as Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryButtonColor,
                    disabledForegroundColor:
                    const Color(0xffAAB4C0),
                    side: const BorderSide(
                      color: Color(0xffC9DCF2),
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  // ============================================================
  // DEFAULT BADGE
  // ============================================================


  Widget _buildSelectFiled(ProfileField field) {
    // final editing = controller.isEditing;
    final editing = true;
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


  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffEEF7F1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 10,
            color: Color(0xff2E8B57),
          ),
          SizedBox(width: 3),
          Text(
            'Default',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E7D4F),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 32,
          width: 32,
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADDRESS TAG
  // ============================================================

  Widget _buildAddressTag(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF6F7F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xffECEEF1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: const Color(0xff7A828C),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xff666D75),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADDRESS ICON
  // ============================================================

  IconData _getAddressIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;

      case 'office':
      case 'work':
        return Icons.business_outlined;

      case 'shop':
        return Icons.storefront_outlined;

      default:
        return Icons.location_on_outlined;
    }
  }

  // ============================================================
  // ADDRESS FORM BOTTOM SHEET
  // ============================================================

  void _openAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.70,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  return _buildAddressForm(sheetContext);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ADDRESS FORM
  // ============================================================

  Widget _buildAddressForm(BuildContext sheetContext) {
    final bool editing = controller.isEditing;
    var profileFiled = ProfileField(title: 'State', hint: 'Select', icon: Icons.map_outlined, controller: controller.stateController, keyboardType: TextInputType.name, onTap: _openStateSheet);


    return Column(
      children: [
        // --------------------------------------------------------
        // HEADER
        // --------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            12,
            10,
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffEDF4FC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  editing
                      ? Icons.edit_location_alt_outlined
                      : Icons.add_location_alt_outlined,
                  size: 18,
                  color: primaryButtonColor,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editing
                          ? 'Edit Address'
                          : 'Add New Address',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff202124),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      editing
                          ? 'Update your address details'
                          : 'Enter your delivery address',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xff7A8087),
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: const Color(0xffF4F5F6),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    height: 32,
                    width: 32,
                    child: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: Color(0xff656B72),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
          color: Color(0xffECEEF1),
        ),

        // --------------------------------------------------------
        // FORM CONTENT
        // --------------------------------------------------------

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              20,
            ),
            child: Column(
              children: [
                _buildTextField(
                  controller: controller.fullNameController,
                  label: 'Full Name',
                  hint: 'Enter full name',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 10),

                // MOBILE
                _buildTextField(
                  controller: controller.mobileController,
                  label: 'Mobile Number',
                  hint: 'Enter mobile number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 10),

                // ADDRESS
                _buildTextField(
                  controller: controller.addressController,
                  label: 'Address',
                  hint: 'House no, street, area',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 10),

                // CITY + STATE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: controller.cityController,
                        label: 'City',
                        hint: 'City',
                        icon: Icons.location_city_outlined,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 9),

                    Expanded(
                      child: _buildSelectFiled(
                          profileFiled
                      ),
                    ),



                    // Expanded(
                    //   child: _buildTextField(
                    //     controller: controller.stateController,
                    //     label: 'State',
                    //     hint: 'State',
                    //     icon: Icons.map_outlined,
                    //     textInputAction: TextInputAction.next,
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 10),

                // PIN CODE
                _buildTextField(
                  controller: controller.pinCodeController,
                  label: 'PIN Code',
                  hint: 'Enter PIN code',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 18),

                ListenableBuilder(listenable: controller.updater,
                    builder: (context, _){

                      return SizedBox(
                        height: 42,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.updater.isLoading
                              ? null
                              : () async {
                            final success =
                            await controller.saveAddress();

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(sheetContext);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  behavior:
                                  SnackBarBehavior.floating,
                                  backgroundColor:
                                  const Color(0xff2E8B57),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(9),
                                  ),
                                  content: Text(
                                    editing
                                        ? 'Address updated successfully'
                                        : 'Address added successfully',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                            primaryButtonColor,
                            disabledBackgroundColor:
                            const Color(0xffB9C7D5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: controller.updater.isLoading
                              ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            editing
                                ? 'Update Address'
                                : 'Save Address',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );

                    })
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADDRESS TYPE BUTTON
  // ============================================================

  Widget _addressTypeButton(
      String type,
      IconData icon,
      ) {
    final bool selected =
        controller.selectedAddressType == type;

    return GestureDetector(
      onTap: () {
        controller.changeAddressType(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffEDF4FC)
              : const Color(0xffF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ?  primaryButtonColor
                : const Color(0xffE5E7EA),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ?  primaryButtonColor
                  : const Color(0xff727982),
            ),
            const SizedBox(width: 5),
            Text(
              type,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: selected
                    ?  primaryButtonColor
                    : const Color(0xff666D75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xff30343A),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xff737A83),
        ),
        hintStyle: const TextStyle(
          fontSize: 11.5,
          color: Color(0xffA5ABB2),
        ),
        prefixIcon: Icon(
          icon,
          size: 17,
          color: const Color(0xff7A828C),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
        ),
        filled: true,
        fillColor: const Color(0xffFAFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 11,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0xffE5E8EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide:  BorderSide(
            color: primaryButtonColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELETE DIALOG
  // ============================================================

  void _showDeleteDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            5,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            18,
            5,
            18,
            10,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            12,
          ),
          title: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffFEF1F1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Color(0xffD85C5C),
                ),
              ),

              const SizedBox(width: 9),

              const Text(
                'Delete Address',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff25282C),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the address of '
                '${address.fullName.isEmpty ? 'this user' : address.fullName}?',
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: Color(0xff6F767E),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff656B72),
                ),
              ),
            ),

            ListenableBuilder(listenable: controller.updater,
                builder: (context, _){
                  return ElevatedButton(
                    onPressed: controller.updater.isLoading? null: () async {

                      await controller.deleteAddress(address);

                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffD85C5C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(75, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: controller.updater.isLoading? SizedBox(
                        width: 60,
                        height: 30,
                        child:Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            ) )): const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                })
          ],
        );
      },
    );
  }
}

class StateBottomPopUp extends StatelessWidget {
  final StateController controller;
  final ValueChanged<StateList> onSelected;

  const StateBottomPopUp({
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
        child: Loader(),
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

class _StateSearchField extends StatelessWidget {
  final StateController controller;

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

class _StateList extends StatelessWidget {
  final StateController controller;
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
                child: Loader(
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