import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// --- Import các màn hình con đã được tách file ---
import 'dashboard/admin_dashboard_screen.dart';
import 'reservations/admin_reservations_screen.dart';
import 'staff/admin_staff_screen.dart';
import 'manage/admin_manage_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  // Gọi trực tiếp các màn hình từ thư mục con
  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminReservationsScreen(),
    const AdminStaffScreen(),
    const AdminManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.peach.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'PetHub Admin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textDark,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Sử dụng IndexedStack để giữ nguyên trạng thái cuộn của từng tab
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSoft,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              activeIcon: Icon(Icons.analytics),
              label: 'Doanh thu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_restaurant_rounded),
              activeIcon: Icon(Icons.table_restaurant),
              label: 'Đặt bàn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_rounded),
              activeIcon: Icon(Icons.badge),
              label: 'Nhân viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category_rounded),
              label: 'Danh mục',
            ),
          ],
        ),
      ),
    );
  }
}
