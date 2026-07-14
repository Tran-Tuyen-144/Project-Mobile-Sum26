import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class AdminSpaScreen extends StatelessWidget {
  const AdminSpaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tiến độ Spa', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSpaTaskCard('Bé Miu (Mèo Anh)', 'Tắm & Sấy', 'Đang thực hiện', 0.6),
          _buildSpaTaskCard('Bé Corgi', 'Cắt tỉa lông', 'Chờ xử lý', 0.1),
          _buildSpaTaskCard('Bé Poodle', 'Gói Full Spa', 'Hoàn thành', 1.0),
        ],
      ),
    );
  }

  Widget _buildSpaTaskCard(String petName, String service, String status, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(petName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              Icon(Icons.pets_rounded, color: AppColors.mint.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Dịch vụ: $service', style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cream,
                  color: status == 'Hoàn thành' ? AppColors.primary : AppColors.mint,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          )
        ],
      ),
    );
  }
}