import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

// Các import này chuẩn bị cho việc bạn tạo các file trống trong thư mục con tương ứng
// import 'cafe/admin_cafe_screen.dart';
// import 'spa/admin_spa_screen.dart';
// import 'hotel/admin_hotel_screen.dart';
// import 'hospital/admin_hospital_screen.dart';

class AdminManageScreen extends StatelessWidget {
  const AdminManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Điều phối Dịch vụ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn bộ phận để trực tiếp vận hành hoặc kiểm tra trạng thái.',
            style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildManageCard(
                context,
                'PetHub Café',
                'Quản lý order, xuất bill',
                Icons.local_cafe_rounded,
                AppColors.peach,
                    () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCafeScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang mở trạm Café')));
                },
              ),
              _buildManageCard(
                context,
                'PetHub Spa',
                'Tạo lịch tắm sấy',
                Icons.shower_rounded,
                AppColors.mint,
                    () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSpaScreen()));
                },
              ),
              _buildManageCard(
                context,
                'Pet Hotel',
                'Check-in/out lưu trú',
                Icons.pets_rounded,
                AppColors.lavender,
                    () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHotelScreen()));
                },
              ),
              _buildManageCard(
                context,
                'Phòng khám',
                'Hồ sơ bệnh án',
                Icons.medical_services_rounded,
                AppColors.sky,
                    () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHospitalScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManageCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: color != AppColors.cream ? AppColors.textDark : AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}