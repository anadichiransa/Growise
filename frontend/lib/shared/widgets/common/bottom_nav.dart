import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? (_) {},
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
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
