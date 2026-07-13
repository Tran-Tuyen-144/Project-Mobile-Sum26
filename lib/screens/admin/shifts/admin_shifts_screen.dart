import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'admin_shift_assign_screen.dart';
class AdminShiftsScreen extends StatelessWidget {
  const AdminShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lịch làm việc hôm nay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () {
                  // Thêm lệnh này để mở màn hình Xếp ca
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminShiftAssignScreen()),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Xếp ca'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildShiftItem('Ca Sáng (07:00 - 12:00)', 'Trần Mộng Tuyền, Nguyễn Hải Yến'),
                _buildShiftItem('Ca Chiều (12:00 - 17:00)', 'Nguyễn Hoàng Ngọc Trân'),
                _buildShiftItem('Ca Tối (17:00 - 22:00)', 'Nguyễn Xuân Hiếu'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShiftItem(String time, String staffs) {
    return Card(
      elevation: 0,
      color: AppColors.peach.withOpacity(0.15),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent),
        title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Nhân viên: $staffs', style: const TextStyle(color: AppColors.textDark)),
      ),
    );
  }
}