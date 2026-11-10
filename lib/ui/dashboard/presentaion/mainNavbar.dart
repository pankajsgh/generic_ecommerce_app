import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/Favourate/presentation/favourite_page.dart';
import 'package:flutter_ecom/ui/cart/presentation/cart_page.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/dashboard.dart';
import 'package:flutter_ecom/ui/dashboard/presentaion/mainNavbar.dart';
import 'package:flutter_ecom/ui/profile/presentation/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    FavouriteScreen(),
    CartScreen(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:pages[selectedIndex] ,
      // body: IndexedStack(
      //   index: selectedIndex,
      //   children: pages,
      // ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, -2),
                color: Colors.black12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              _bottomItem(
                index: 1,
                icon: Icons.favorite_border,
                selectedIcon: Icons.favorite,
                label: 'Favourite',
              ),
              _bottomItem(
                index: 2,
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag_outlined,
                label: 'Cart',
              ),

              _bottomItem(
                index: 3,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              top: selected ? -30 : 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: selected ? 46 : 30,
                height: selected ? 46 : 30,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryButtonColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? Colors.white
                      : Colors.grey,
                  size: 24,
                ),
              ),
            ),

            if (selected)
              Positioned(
                bottom: 20,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryButtonColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



