import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminManageScreen extends StatelessWidget {
  const AdminManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý dữ liệu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thêm, xoá và cập nhật thông tin các hạng mục trong hệ thống PetHub.',
            style: TextStyle(color: AppColors.textSoft, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Dùng GridView để tạo các thẻ chức năng dạng lưới
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của Grid vì đã có SingleChildScrollView
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildManageCard(
                context,
                title: 'Nhân viên',
                subtitle: 'Hồ sơ, chức vụ',
                icon: Icons.badge_rounded,
                color: AppColors.mint,
                onTap: () {
                  // TODO: Điều hướng sang màn hình CRUD Nhân viên
                },
              ),
              _buildManageCard(
                context,
                title: 'Thú cưng',
                subtitle: 'Thêm, sửa pet',
                icon: Icons.pets_rounded,
                color: AppColors.peach,
                onTap: () {
                  // TODO: Điều hướng sang màn hình CRUD Thú cưng
                },
              ),
              _buildManageCard(
                context,
                title: 'Thực đơn',
                subtitle: 'Nước & Thức ăn',
                icon: Icons.local_cafe_rounded,
                color: AppColors.primarySoft,
                onTap: () {
                  // TODO: Điều hướng sang màn hình CRUD Nước/Thức ăn
                },
              ),
              _buildManageCard(
                context,
                title: 'Sơ đồ Bàn',
                subtitle: 'Thêm bàn, khu vực',
                icon: Icons.table_restaurant_rounded,
                color: Colors.purple.shade100, // Thêm một chút màu tím pastel
                onTap: () {
                  // TODO: Điều hướng sang màn hình CRUD Bàn
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget tái sử dụng để vẽ các thẻ bo góc
  Widget _buildManageCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}