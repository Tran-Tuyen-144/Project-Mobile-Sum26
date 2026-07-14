import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.peach,
              child: Icon(Icons.admin_panel_settings_rounded, size: 50, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Column(
              children: [
                Text('Quản trị viên', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('admin.pethub@gmail.com', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 36),

          const Text('Quản trị hệ thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSoft)),
          const SizedBox(height: 12),

          _buildSettingsCard([
            _buildListTile(Icons.people_alt_rounded, 'Quản lý tài khoản nhân viên', AppColors.primary),
            const Divider(height: 1, color: AppColors.cream),
            _buildListTile(Icons.category_rounded, 'Cấu hình Danh mục & Bảng giá', AppColors.mint),
            const Divider(height: 1, color: AppColors.cream),
            _buildListTile(Icons.bar_chart_rounded, 'Báo cáo doanh thu chi tiết', AppColors.sky),
          ]),

          const SizedBox(height: 36),
          OutlinedButton.icon(
            onPressed: () {
              // Xử lý đăng xuất Firebase Auth và điều hướng về trang Login
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: AppColors.textSoft, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.cream, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSoft),
      onTap: () {
        // Điều hướng đến các trang chức năng
      },
    );
  }
}