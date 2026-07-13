import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminStaffDetailScreen extends StatelessWidget {
  final Map<String, dynamic> staff;

  const AdminStaffDetailScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.mint.withValues(alpha: 0.3),
                child: Icon(Icons.person, size: 50, color: AppColors.mint),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              staff['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              staff['role'],
              style: const TextStyle(fontSize: 16, color: AppColors.textSoft),
            ),
            const SizedBox(height: 32),
            _buildDetailRow('Mã nhân viên', staff['id']),
            _buildDetailRow('Ngày sinh', staff['dob']),
            _buildDetailRow('Liên lạc', staff['contact']),
            _buildDetailRow('Ghi chú', staff['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
