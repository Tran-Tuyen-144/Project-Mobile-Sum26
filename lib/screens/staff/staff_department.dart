import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum StaffDepartment {
  cafe,
  spa,
  hotel,
  hospital,
}

const List<StaffDepartment> selectableStaffDepartments = [
  StaffDepartment.cafe,
  StaffDepartment.spa,
  StaffDepartment.hotel,
  StaffDepartment.hospital,
];

extension StaffDepartmentExtension on StaffDepartment {
  String get key {
    switch (this) {
      case StaffDepartment.cafe:
        return 'cafe';
      case StaffDepartment.spa:
        return 'spa';
      case StaffDepartment.hotel:
        return 'hotel';
      case StaffDepartment.hospital:
        return 'hospital';
    }
  }

  String get title {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Nhân viên Café';
      case StaffDepartment.spa:
        return 'Nhân viên Spa';
      case StaffDepartment.hotel:
        return 'Nhân viên Khách sạn';
      case StaffDepartment.hospital:
        return 'Nhân viên Bệnh viện';
    }
  }

  String get shortTitle {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Café';
      case StaffDepartment.spa:
        return 'Spa';
      case StaffDepartment.hotel:
        return 'Khách sạn';
      case StaffDepartment.hospital:
        return 'Bệnh viện';
    }
  }

  String get description {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Tra cứu đặt bàn, chọn món, tính tiền và xuất Bill.';
      case StaffDepartment.spa:
        return 'Quản lý lịch tắm sấy, cắt tỉa lông và chăm sóc Pet.';
      case StaffDepartment.hotel:
        return 'Theo dõi phòng lưu trú, ăn uống và sức khỏe Pet.';
      case StaffDepartment.hospital:
        return 'Quản lý lịch khám, bệnh án, chi phí và xuất PDF.';
    }
  }

  IconData get icon {
    switch (this) {
      case StaffDepartment.cafe:
        return Icons.local_cafe_rounded;
      case StaffDepartment.spa:
        return Icons.spa_rounded;
      case StaffDepartment.hotel:
        return Icons.hotel_rounded;
      case StaffDepartment.hospital:
        return Icons.medical_services_rounded;
    }
  }

  Color get color {
    switch (this) {
      case StaffDepartment.cafe:
        return AppColors.peach;
      case StaffDepartment.spa:
        return AppColors.mint;
      case StaffDepartment.hotel:
        return AppColors.lavender;
      case StaffDepartment.hospital:
        return AppColors.sky;
    }
  }
}

StaffDepartment staffDepartmentFromKey(String? key) {
  switch (key) {
    case 'spa':
      return StaffDepartment.spa;
    case 'hotel':
      return StaffDepartment.hotel;
    case 'hospital':
      return StaffDepartment.hospital;
    case 'cafe':
    default:
      return StaffDepartment.cafe;
  }
}