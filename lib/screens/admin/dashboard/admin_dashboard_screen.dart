import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tổng quan hôm nay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryCard('Doanh thu', '2.450.000đ', Icons.attach_money_rounded, AppColors.mint),
              const SizedBox(width: 16),
              _buildSummaryCard('Đơn hàng mới', '18 đơn', Icons.shopping_bag_rounded, AppColors.peach),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Biểu đồ xu hướng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          // Khu vực vẽ biểu đồ (Sau này bạn có thể tích hợp thư viện fl_chart vào đây)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.peach.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                '🎨 Khu vực hiển thị biểu đồ doanh thu',
                style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Hoạt động dịch vụ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          _buildActivityRow('Café', '12 đơn hoàn thành', AppColors.peach),
          _buildActivityRow('Spa', '4 thú cưng đang tắm', AppColors.mint),
          _buildActivityRow('Khách sạn', '15 phòng đang sử dụng', AppColors.lavender),
          _buildActivityRow('Bệnh viện', '2 ca khám đang chờ', AppColors.sky),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.textDark, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String title, String subtitle, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark))),
          Text(subtitle, style: const TextStyle(color: AppColors.textSoft, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}