import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/constants/app_images.dart';

import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/core/vars/global_vars.dart';

import 'package:flutter_ecom/ui/Favourate/presentation/favourite_page.dart';
import 'package:flutter_ecom/ui/cart/presentation/cart_page.dart';
import 'package:flutter_ecom/ui/dashboard/data/controller/dashboard_controller.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/search_page/presentaion/product_search_page.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardModel data;
  final DashboardController controller;

  const DashboardHeader({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        6,
      ),
      child: Row(
        children: [
          // _menuButton(context),
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(AppImages.appLogo, width: 44, )),
          const SizedBox(width: 8),
          Expanded(
            child: _greeting(),
          ),

          _searchButton(context),

          const SizedBox(width: 6),

          _favouriteButton(context),

          const SizedBox(width: 6),

          _cartButton(context),
        ],
      ),
    );
  }

  Widget _greeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${data.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _menuButton(BuildContext context) {
    return _circleButton(
      icon: Icons.menu_rounded,
      onTap: () {
        // Open drawer/menu
      },
    );
  }

  Widget _searchButton(BuildContext context) {
    return _circleButton(
      icon: Icons.search_rounded,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductSearchPage(),
          ),
        );

        controller.loadDashboard();
      },
    );
  }

  Widget _favouriteButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GlobalVars.totalFavourate,
      builder: (context, value, _) {
        return _circleButton(
          icon: Icons.favorite_border_rounded,
          count: value.toString(),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavouriteScreen(),
              ),
            );

            controller.recheckCartCount();
          },
        );
      },
    );
  }

  Widget _cartButton(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.updateCartCount,
      builder: (context, _) {
        return _circleButton(
          icon: Icons.shopping_bag_outlined,
          count: data.totalCartCheck,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );

            controller.recheckCartCount();
          },
        );
      },
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    String count = '',
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 23,
              ),

              if (count.isNotEmpty && count != '0')
                Positioned(
                  right: -7,
                  top: -7,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryButtonColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}