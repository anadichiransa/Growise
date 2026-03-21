import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/dashboard');
        break;
      case 1:
        Get.toNamed('/growth');
        break;
      case 2:
        Get.toNamed('/meals');
        break;
      case 3:
        Get.toNamed('/vaccines');
        break;
      case 4:
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      backgroundColor: const Color(0xFF1B0B3B),
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