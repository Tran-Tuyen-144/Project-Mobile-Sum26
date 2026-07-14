import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';

class CafeProfileTab extends StatelessWidget {
  const CafeProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Hồ sơ của Tôi', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textDark,
          elevation: 0
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.peach,
                child: Icon(Icons.local_cafe_rounded, size: 55, color: AppColors.primary)
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Column(
              children: [
                Text('Nguyễn Minh An', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('Nhân viên Café • PetHub Quận 1', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 36),

          Card(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.cream, width: 2),
                borderRadius: BorderRadius.circular(24)
            ),
            child: const Column(
              children: [
                ListTile(
                    leading: Icon(Icons.badge_rounded, color: AppColors.primary),
                    title: Text('Mã nhân viên', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                    trailing: Text('NV-CF-001', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark))
                ),
                Divider(height: 1, color: AppColors.cream),
                ListTile(
                    leading: Icon(Icons.schedule_rounded, color: AppColors.primary),
                    title: Text('Ca làm việc hiện tại', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                    trailing: Text('Ca Sáng', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark))
                ),
                Divider(height: 1, color: AppColors.cream),
                ListTile(
                    leading: Icon(Icons.phone_rounded, color: AppColors.primary),
                    title: Text('Số điện thoại', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                    trailing: Text('0901 234 567', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark))
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
          OutlinedButton.icon(
            onPressed: () => context.go('/'), // Điều hướng về màn hình chọn vai trò / đăng nhập ban đầu
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark, // Dùng TextDark thay vì màu đỏ quá gắt
                side: const BorderSide(color: AppColors.textSoft, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
          )
        ],
      ),
    );
  }
}