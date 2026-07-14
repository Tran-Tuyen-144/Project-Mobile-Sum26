import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../theme/app_colors.dart';

class OrderCardItem extends StatelessWidget {
  final String orderId;
  final String category;
  final Map<String, dynamic> data;

  const OrderCardItem({
    super.key,
    required this.orderId,
    required this.category,
    required this.data,
  });

  // Tự động lấy màu dựa theo Category
  Color _getCategoryColor() {
    switch (category) {
      case 'cafe':
        return AppColors.peach;
      case 'spa':
        return AppColors.mint;
      case 'hotel':
        return AppColors.lavender;
      case 'hospital':
        return AppColors.sky;
      default:
        return AppColors.cream;
    }
  }

  // Hàm xử lý cập nhật trạng thái lên Firebase
  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(orderId)
          .update({'status': newStatus});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã $newStatus đơn hàng thành công!'),
            backgroundColor: AppColors.textDark,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trích xuất dữ liệu từ Firebase (có dự phòng giá trị mặc định nếu null)
    final customerName = data['customerName'] ?? 'Khách lẻ';
    final phone = data['phone'] ?? 'Chưa cập nhật SĐT';
    final serviceName = data['serviceName'] ?? 'Dịch vụ tiêu chuẩn';
    final time = data['time'] ?? 'Chưa rõ thời gian';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getCategoryColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chờ duyệt',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_rounded, phone),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.category_rounded, serviceName),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.schedule_rounded, time),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateStatus(context, 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSoft,
                    side: const BorderSide(color: AppColors.textSoft),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Duyệt ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSoft),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}