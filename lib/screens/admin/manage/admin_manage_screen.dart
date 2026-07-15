import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
// Import các màn hình chức năng
import '../pet/admin_pet_list_screen.dart';
import '../menu/admin_menu_list_screen.dart';
import '../table/admin_table_list_screen.dart';
import '../customer/admin_customer_list_screen.dart';

class AdminManageScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const AdminManageScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý dữ liệu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildManageCard(
                context,
                'Khách hàng',
                'CRM & thú cưng',
                Icons.people_alt_rounded,
                AppColors.sky,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCustomerListScreen(),
                  ),
                ),
              ),
              _buildManageCard(
                context,
                'Nhân viên',
                'Hồ sơ, chức vụ',
                Icons.badge_rounded,
                AppColors.mint,
                () => onNavigateToTab?.call(3),
              ),
              _buildManageCard(
                context,
                'Thú cưng',
                'Thêm, sửa pet',
                Icons.pets_rounded,
                AppColors.peach,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPetListScreen()),
                ),
              ),
              _buildManageCard(
                context,
                'Thực đơn',
                'Nước & Thức ăn',
                Icons.local_cafe_rounded,
                AppColors.primarySoft,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminMenuListScreen(),
                  ),
                ),
              ),
              _buildManageCard(
                context,
                'Sơ đồ Bàn',
                'Thêm bàn, khu vực',
                Icons.table_restaurant_rounded,
                Colors.purple.shade100,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminTableListScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManageCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              sub,
              style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
