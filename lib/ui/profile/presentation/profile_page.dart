import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/constants/app_images.dart';
import 'package:flutter_ecom/core/network/api_path.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';
import 'package:flutter_ecom/ui/auth/presentation/pages/login_page.dart';
import 'package:flutter_ecom/ui/orders/presentation/order_list_page.dart';
import 'package:flutter_ecom/ui/profile/data/controller/profile_controller.dart';
import 'package:flutter_ecom/ui/profile/data/model/account_model.dart';
import 'package:flutter_ecom/ui/profile/presentation/OpenWebUrl.dart';
import 'package:flutter_ecom/ui/profile/presentation/manage_address.dart';
import 'package:flutter_ecom/ui/profile/presentation/manage_profile.dart';
import 'package:flutter_ecom/ui/profile/presentation/profile_page.dart' hide OpenWebUrl;
import 'package:shared_preferences/shared_preferences.dart';



class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static const Color textDark = Color(0xff20242A);
  static const Color textGrey = Color(0xff7B838D);
  static const Color border = Color(0xffE8EBEF);
  static const Color green = Color(0xff249B5A);
  static const Color red = Color(0xffD94758);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,

        title: const Text(
          'My Account',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          26,
        ),
        children: [
          _buildProfileCard(context),

          const SizedBox(height: 18),

          _sectionTitle(
            title: 'MY ACCOUNT',
            subtitle: 'Manage your account',
          ),

          const SizedBox(height: 10),

          _buildAccountMenu(context),

          const SizedBox(height: 18),

          _sectionTitle(
            title: 'SUPPORT',
            subtitle: 'Need help?',
          ),

          const SizedBox(height: 10),

          _buildSupportMenu(context),

          const SizedBox(height: 22),

          _buildLogoutButton(context),

          const SizedBox(height: 28),

          _buildFooter(),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard(BuildContext context) {
    final user = GlobalVars.userAccountData;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryButtonColor,
            primaryButtonColor.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryButtonColor.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                height: 52,
                width: 52,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                child: ClipOval(
                  child: user.photo.isEmpty
                      ? Container(
                    color: Colors.white.withValues(alpha: 0.18),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 27,
                      color: Colors.white,
                    ),
                  )
                      : Image.network(
                    user.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.white.withValues(alpha: 0.18),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 27,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? 'Welcome back!' : user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    if (user.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified Profile',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Edit
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageProfilePage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick stats
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
            child: Row(
              children: [
                _profileStat(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderListScreen(),
                      ),
                    );
                  },
                ),

                _statDivider(),

                _profileStat(
                  icon: Icons.location_on_outlined,
                  title: 'Addresses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageAddressPage(),
                      ),
                    );
                  },
                ),

                _statDivider(),

                _profileStat(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _profileStat({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: Color(0xff68717B),
          ),
        ),

        const Spacer(),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xff9AA1A9),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACCOUNT MENU
  // ============================================================

  Widget _buildAccountMenu(BuildContext context) {
    final items = [
      AccountMenuItem(
        title: 'Personal Information',
        subtitle: 'Manage your profile information',
        icon: Icons.person_outline_rounded,
        color: const Color(0xff2878D4),
        backgroundColor: const Color(0xffEAF3FF),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ManageProfilePage(),
            ),
          );
        },
      ),

      AccountMenuItem(
        title: 'My Orders',
        subtitle: 'View your orders and order history',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xff249B5A),
        backgroundColor: const Color(0xffEAF8F0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderListScreen(),
            ),
          );
        },
      ),

      AccountMenuItem(
        title: 'Manage Address',
        subtitle: 'Add or manage your delivery addresses',
        icon: Icons.location_on_outlined,
        color: const Color(0xffE07A26),
        backgroundColor: const Color(0xfffff3e8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ManageAddressPage(),
            ),
          );
        },
      ),
    ];

    return _menuCard(items);
  }

  // ============================================================
  // SUPPORT MENU
  // ============================================================

  Widget _buildSupportMenu(BuildContext context) {
    final items = [
      AccountMenuItem(
        title: 'About Us',
        subtitle: 'Know more about our company',
        icon: Icons.info_outline_rounded,
        color: const Color(0xff6C63C9),
        backgroundColor: const Color(0xffF0EEFF),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpenWebUrl(
                title: 'About Us',
                webUrl: GlobalVars.appWebUrl.aboutUsPage ?? '',
              ),
            ),
          );
        },
      ),

      AccountMenuItem(
        title: 'Contact Us',
        subtitle: 'Get in touch with our team',
        icon: Icons.support_agent_outlined,
        color: const Color(0xff1596A8),
        backgroundColor: const Color(0xffE8F8FA),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpenWebUrl(
                title: 'Contact Us',
                webUrl: GlobalVars.appWebUrl.contactUs ?? '',
              ),
            ),
          );
        },
      ),
    ];

    return _menuCard(items);
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _menuCard(List<AccountMenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) {
          return const Padding(
            padding: EdgeInsets.only(left: 58),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Color(0xffEEF0F2),
            ),
          );
        },
        itemBuilder: (context, index) {
          final item = items[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              splashColor: item.color.withValues(alpha: 0.06),
              highlightColor: item.color.withValues(alpha: 0.025),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    // ICON
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 17,
                        color: item.color,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // TEXT
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: textGrey,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ARROW
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xffF7F8FA),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: Color(0xff9299A2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xffffdfe3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          splashColor: red.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff0f1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: red,
                  ),
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: red,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sign out from your account',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 29,
                  width: 29,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff5f6),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xffD99AA2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff0f1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: red,
                    size: 29,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: textGrey,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff555C65),
                          side: const BorderSide(
                            color: border,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Powered by',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xff858B94),
              ),
            ),

            const SizedBox(width: 7),

            Image.asset(
              AppImages.logoPoweredImage,
              width: 65,
            ),
          ],
        ),

        const SizedBox(height: 7),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffEEF1F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Version ${GlobalVars.appVersion}',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xff858B94),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT ACTION
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }
}








