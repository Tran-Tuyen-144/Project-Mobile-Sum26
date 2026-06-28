import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PetProfile {
  final String name;
  final String type;
  final String age;
  final IconData icon;
  final Color color;

  const PetProfile({
    required this.name,
    required this.type,
    required this.age,
    required this.icon,
    required this.color,
  });
}

class ProfileMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const List<PetProfile> myPets = [
  PetProfile(
    name: 'Mochi',
    type: 'Mèo Anh lông ngắn',
    age: '2 tuổi',
    icon: Icons.pets_rounded,
    color: AppColors.peach,
  ),
  PetProfile(
    name: 'Bông',
    type: 'Cún Poodle',
    age: '1 tuổi',
    icon: Icons.cruelty_free_rounded,
    color: AppColors.mint,
  ),
];

const List<ProfileMenuItem> profileMenus = [
  ProfileMenuItem(
    title: 'Lịch sử đặt bàn',
    subtitle: 'Xem lại các lần đặt bàn tại PetHub.',
    icon: Icons.event_seat_rounded,
    color: AppColors.peach,
  ),
  ProfileMenuItem(
    title: 'Đơn gọi món',
    subtitle: 'Theo dõi nước và bánh đã gọi trước.',
    icon: Icons.local_cafe_rounded,
    color: AppColors.sky,
  ),
  ProfileMenuItem(
    title: 'Dịch vụ đã đặt',
    subtitle: 'Spa, khách sạn thú cưng, thú y và grooming.',
    icon: Icons.spa_rounded,
    color: AppColors.mint,
  ),
  ProfileMenuItem(
    title: 'Bài viết đã lưu',
    subtitle: 'Những bài cộng đồng bạn muốn xem lại.',
    icon: Icons.bookmark_rounded,
    color: AppColors.lavender,
  ),
  ProfileMenuItem(
    title: 'Cài đặt tài khoản',
    subtitle: 'Thông tin cá nhân, giao diện và quyền riêng tư.',
    icon: Icons.settings_rounded,
    color: AppColors.primarySoft,
  ),
];