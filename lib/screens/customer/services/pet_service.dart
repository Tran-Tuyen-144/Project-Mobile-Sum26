import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PetService {
  final String name;
  final String category;
  final String description;
  final String price;
  final String distance;
  final double rating;
  final IconData icon;
  final Color color;

  const PetService({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.distance,
    required this.rating,
    required this.icon,
    required this.color,
  });
}

const List<String> serviceCategories = [
  'Tất cả',
  'Spa',
  'Khách sạn',
  'Thú y',
  'Grooming',
];

const List<PetService> petServices = [
  PetService(
    name: 'Spa chó mèo trọn gói',
    category: 'Spa',
    description:
        'Tắm massage, vệ sinh tai/móng, sấy dưỡng lông và cắt tỉa theo yêu cầu.',
    price: 'Từ 120.000đ',
    distance: '1.4 km',
    rating: 4.8,
    icon: Icons.spa_rounded,
    color: AppColors.peach,
  ),
  PetService(
    name: 'Khách sạn thú cưng',
    category: 'Khách sạn',
    description: 'Gửi bé yêu qua đêm, có nhân viên chăm sóc và theo dõi.',
    price: 'Từ 180.000đ/ngày',
    distance: '2.1 km',
    rating: 4.7,
    icon: Icons.local_hotel_rounded,
    color: AppColors.mint,
  ),
  PetService(
    name: 'Bệnh viện thú cưng',
    category: 'Thú y',
    description: 'Khám sức khỏe, tiêm phòng và tư vấn chăm sóc thú cưng.',
    price: 'Từ 90.000đ',
    distance: '3.0 km',
    rating: 4.9,
    icon: Icons.medical_services_rounded,
    color: AppColors.sky,
  ),
];
