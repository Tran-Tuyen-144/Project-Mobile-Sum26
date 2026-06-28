import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BranchLocation {
  final String name;
  final String category;
  final String address;
  final String distance;
  final String openTime;
  final double rating;
  final IconData icon;
  final Color color;

  const BranchLocation({
    required this.name,
    required this.category,
    required this.address,
    required this.distance,
    required this.openTime,
    required this.rating,
    required this.icon,
    required this.color,
  });
}

const List<String> branchCategories = [
  'Tất cả',
  'Cafe mèo',
  'Cafe cún',
  'Pet spa',
];

const List<BranchLocation> branchLocations = [
  BranchLocation(
    name: 'PetHub Quận 1',
    category: 'Cafe mèo',
    address: '12 Nguyễn Huệ, Quận 1',
    distance: '1.2 km',
    openTime: '08:00 - 22:00',
    rating: 4.8,
    icon: Icons.pets_rounded,
    color: AppColors.mint,
  ),
  BranchLocation(
    name: 'PetHub Bình Thạnh',
    category: 'Cafe cún',
    address: '45 Xô Viết Nghệ Tĩnh, Bình Thạnh',
    distance: '2.8 km',
    openTime: '09:00 - 21:30',
    rating: 4.7,
    icon: Icons.cruelty_free_rounded,
    color: AppColors.sky,
  ),
  BranchLocation(
    name: 'PetHub Thủ Đức',
    category: 'Pet spa',
    address: '88 Võ Văn Ngân, Thủ Đức',
    distance: '5.4 km',
    openTime: '08:30 - 21:00',
    rating: 4.6,
    icon: Icons.spa_rounded,
    color: AppColors.lavender,
  ),
  BranchLocation(
    name: 'PetHub Quận 7',
    category: 'Cafe cún',
    address: '20 Nguyễn Thị Thập, Quận 7',
    distance: '6.1 km',
    openTime: '09:00 - 22:00',
    rating: 4.5,
    icon: Icons.local_cafe_rounded,
    color: AppColors.peach,
  ),
];