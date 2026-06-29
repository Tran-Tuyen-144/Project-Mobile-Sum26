import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Danh sách nhân sự hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _buildStaffRow('Nguyễn Hải Yến', 'Phục vụ bàn', 'Lương: 3.200.000đ'),
        _buildStaffRow('Trần Mộng Tuyền', 'Pha chế chính', 'Lương: 4.500.000đ'),
        _buildStaffRow('Nguyễn Hoàng Ngọc Trân', 'Chăm sóc thú cưng', 'Lương: 4.000.000đ'),
      ],
    );
  }

  Widget _buildStaffRow(String name, String role, String salary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(role, style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
            ],
          ),
          Text(salary, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        ],
      ),
    );
  }
}