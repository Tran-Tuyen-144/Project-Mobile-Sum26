import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'tabs/cafe_home_tab.dart';
import 'tabs/cafe_booking_tab.dart';
import 'tabs/cafe_menu_tab.dart';
import 'tabs/cafe_profile_tab.dart';

class StaffCafeScreen extends StatefulWidget {
  const StaffCafeScreen({super.key});

  @override
  State<StaffCafeScreen> createState() => _StaffCafeScreenState();
}

class _StaffCafeScreenState extends State<StaffCafeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    CafeHomeTab(),
    CafeBookingTab(),
    CafeMenuTab(),
    CafeProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.peach, // Màu theme của Café
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textSoft),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.textDark),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined, color: AppColors.textSoft),
            selectedIcon: Icon(Icons.table_restaurant_rounded, color: AppColors.textDark),
            label: 'Đặt bàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined, color: AppColors.textSoft),
            selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.textDark),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: AppColors.textSoft),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.textDark),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}