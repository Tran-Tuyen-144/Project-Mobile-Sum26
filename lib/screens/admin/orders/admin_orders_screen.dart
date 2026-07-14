import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import 'widgets/order_card_item.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề của trang (Được thiết kế giống các trang Dashboard, Manage)
            const SizedBox(height: 8),

            // Thanh chọn dịch vụ (TabBar)
            const TabBar(
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSoft,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              dividerColor: AppColors.cream, // Đường viền mờ bên dưới
              tabs: [
                Tab(text: 'Café'),
                Tab(text: 'Spa'),
                Tab(text: 'Khách sạn'),
                Tab(text: 'Bệnh viện'),
              ],
            ),

            // Khu vực hiển thị danh sách đơn hàng
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderList('cafe'),
                  _buildOrderList('spa'),
                  _buildOrderList('hotel'),
                  _buildOrderList('hospital'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo danh sách theo từng loại category (Giữ nguyên)
  Widget _buildOrderList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có đơn đặt lịch mới nào.',
              style: TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data() as Map<String, dynamic>;

            return OrderCardItem(
              orderId: doc.id,
              category: category,
              data: data,
            );
          },
        );
      },
    );
  }
}
