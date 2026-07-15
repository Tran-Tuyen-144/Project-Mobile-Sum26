import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'cafe/admin_cafe_service_screen.dart';
import 'hotel/admin_hotel_service_screen.dart';
import 'spa/admin_spa_service_screen.dart';
import 'vet/admin_vet_service_screen.dart';
import 'widgets/service_card_item.dart';

class AdminServiceScreen extends StatelessWidget {
  const AdminServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách 4 dịch vụ cốt lõi
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Café',
        'subtitle': 'Order thức uống & quản lý tại bàn.',
        'icon': Icons.local_cafe_rounded,
        'color': AppColors.peach,
        'screen': const AdminCafeServiceScreen(),
      },
      {
        'title': 'Spa Thú Cưng',
        'subtitle': 'Lịch tắm, sấy & cắt tỉa lông.',
        'icon': Icons.content_cut_rounded,
        'color': AppColors.mint,
        'screen': const AdminSpaServiceScreen(),
      },
      {
        'title': 'Khách Sạn',
        'subtitle': 'Quản lý phòng lưu trú thú cưng.',
        'icon': Icons.hotel_rounded,
        'color': AppColors.lavender,
        'screen': const AdminHotelServiceScreen(),
      },
      {
        'title': 'Bệnh Viện Thú Y',
        'subtitle': 'Khám, chữa bệnh & theo dõi hồ sơ.',
        'icon': Icons.medical_services_rounded,
        'color': AppColors.sky,
        'screen': const AdminVetServiceScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt mà
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,       // Hiển thị 2 thẻ trên 1 hàng
            crossAxisSpacing: 16,    // Khoảng cách ngang giữa các thẻ
            mainAxisSpacing: 16,     // Khoảng cách dọc giữa các hàng
            childAspectRatio: 0.85,  // Tỷ lệ chiều rộng / chiều cao của thẻ (tùy chỉnh để thẻ vuông hay dài)
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final item = services[index];
            return ServiceCardItem(
              title: item['title'],
              subtitle: item['subtitle'],
              icon: item['icon'],
              color: item['color'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => item['screen'],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}