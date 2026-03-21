import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growise/core/config/routes.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  void _defaultNavigate(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.dashboard);
        break;
      case 1:
        Get.offNamed(AppRoutes.growth);
        break;
      case 2:
        Get.offNamed(AppRoutes.meals);
        break;
      case 3:
        Get.offNamed(AppRoutes.vaccines);
        break;
      case 4:
        Get.offNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? _defaultNavigate,
      backgroundColor: const Color(0xFF210F37),
      selectedItemColor: const Color(0xFFD9A577),
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Growth'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Meals'),
        BottomNavigationBarItem(icon: Icon(Icons.vaccines), label: 'Vaccines'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}