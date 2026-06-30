import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan hôm nay', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Doanh thu',
                  value: '2.450.000đ',
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Đơn hàng mới',
                  value: '18 đơn',
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.peach,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Biểu đồ xu hướng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '🎨 Khu vực hiển thị biểu đồ doanh thu',
                style: TextStyle(color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.6),
            child: Icon(icon, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}