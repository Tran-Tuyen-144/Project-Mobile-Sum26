import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../customer/admin_customer_list_screen.dart';
import '../staff/admin_staff_screen.dart';
import 'admin_locations_screen.dart';
import 'hotel/admin_manage_hotel_screen.dart';
import 'menu/admin_manage_menu_screen.dart';
import 'pets/admin_manage_pet_screen.dart';
import 'spa/admin_manage_spa_screen.dart';
import 'table/admin_manage_table_screen.dart';
import 'vet/admin_manage_vet_screen.dart';

class AdminManageScreen extends StatelessWidget {
  const AdminManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> manageItems = [
      {
        'title': 'Khách hàng CRM',
        'subtitle': 'CRM, điểm thành viên và thú cưng',
        'icon': Icons.people_alt_rounded,
        'color': AppColors.sky,
        'screen': const AdminCustomerListScreen(),
      },
      {
        'title': 'Quản lý nhân viên',
        'subtitle': 'Thêm, sửa, xóa và xem hồ sơ nhân sự',
        'icon': Icons.badge_rounded,
        'color': AppColors.mint,
        'screen': const AdminStaffScreen(),
      },
      {
        'title': 'Quản lý Pet',
        'subtitle': 'Hồ sơ và thông tin thú cưng',
        'icon': Icons.pets_rounded,
        'color': AppColors.peach,
        'screen': const AdminManagePetScreen(),
      },
      {
        'title': 'Quản lý Menu',
        'subtitle': 'Thực đơn đồ uống & bánh',
        'icon': Icons.menu_book_rounded,
        'color': AppColors.mint,
        'screen': const AdminManageMenuScreen(),
      },
      {
        'title': 'Quản lý Bàn',
        'subtitle': 'Sơ đồ vị trí không gian',
        'icon': Icons.table_bar_rounded,
        'color': AppColors.sky,
        'screen': const AdminManageTableScreen(),
      },
      {
        'title': 'Dịch vụ Spa',
        'subtitle': 'Lịch trình tắm, sấy, cắt tỉa',
        'icon': Icons.shower_rounded,
        'color': AppColors.lavender,
        'screen': const AdminManageSpaScreen(),
      },
      {
        'title': 'Khách sạn',
        'subtitle': 'Quản lý phòng lưu trú',
        'icon': Icons.hotel_rounded,
        'color': AppColors.peach,
        'screen': const AdminManageHotelScreen(),
      },
      {
        'title': 'Bệnh viện thú y',
        'subtitle': 'Khám chữa bệnh & hồ sơ y tế',
        'icon': Icons.medical_services_rounded,
        'color': AppColors.mint,
        'screen': const AdminManageVetScreen(),
      },
      {
        'title': 'Địa điểm & chi nhánh',
        'subtitle': 'Quản lý các cơ sở PetHub',
        'icon': Icons.location_on_rounded,
        'color': AppColors.sky,
        'screen': const AdminLocationsScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Điều phối Dịch vụ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn bộ phận để trực tiếp vận hành hoặc kiểm tra trạng thái.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ...manageItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildManageListTile(
                context,
                item['title'] as String,
                item['subtitle'] as String,
                item['icon'] as IconData,
                item['color'] as Color,
                () {
                  final screen = item['screen'] as Widget?;

                  if (screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tính năng ${item['title']} đang được phát triển!',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color != AppColors.cream
                    ? AppColors.textDark
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSoft.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
