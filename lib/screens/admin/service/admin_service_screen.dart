import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../service_request_admin_screen.dart';
import 'cafe/admin_cafe_service_screen.dart';
import 'hotel/admin_hotel_service_screen.dart';
import 'spa/admin_spa_service_screen.dart';
import 'vet/admin_vet_service_screen.dart';
import 'widgets/service_card_item.dart';

class AdminServiceScreen extends StatelessWidget {
  const AdminServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ServiceRequestAdminScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yêu cầu đặt dịch vụ',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Xem lịch khách hàng đã gửi và xác nhận yêu cầu.',
                            style: TextStyle(
                              color: AppColors.textSoft,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final item = services[index];

                  return ServiceCardItem(
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => item['screen'] as Widget,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
