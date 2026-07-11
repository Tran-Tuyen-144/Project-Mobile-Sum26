import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum StaffDepartment {
  cafe,
  spa,
  hospital,

  // Giữ tạm để các file cũ không lỗi, nhưng không hiển thị nữa.
  petCare,
  reception,
}

const List<StaffDepartment> selectableStaffDepartments = [
  StaffDepartment.cafe,
  StaffDepartment.spa,
  StaffDepartment.hospital,
];

extension StaffDepartmentExtension on StaffDepartment {
  String get key {
    switch (this) {
      case StaffDepartment.cafe:
        return 'cafe';
      case StaffDepartment.spa:
        return 'spa-hotel';
      case StaffDepartment.hospital:
        return 'hospital';
      case StaffDepartment.petCare:
        return 'pet-care';
      case StaffDepartment.reception:
        return 'reception';
    }
  }

  String get title {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Nhân viên Café';
      case StaffDepartment.spa:
        return 'Nhân viên Spa / Khách sạn';
      case StaffDepartment.hospital:
        return 'Nhân viên Bệnh viện';
      case StaffDepartment.petCare:
        return 'Nhân viên chăm sóc Pet';
      case StaffDepartment.reception:
        return 'Lễ tân';
    }
  }

  String get shortTitle {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Café';
      case StaffDepartment.spa:
        return 'Spa / Khách sạn';
      case StaffDepartment.hospital:
        return 'Bệnh viện';
      case StaffDepartment.petCare:
        return 'Chăm sóc Pet';
      case StaffDepartment.reception:
        return 'Lễ tân';
    }
  }

  String get description {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Tra cứu đặt bàn, chọn món, tính tiền và xuất Bill.';
      case StaffDepartment.spa:
        return 'Quản lý Spa, khách sạn Pet, thời gian gửi nhận và chi phí.';
      case StaffDepartment.hospital:
        return 'Quản lý lịch khám, bệnh án, chi phí và xuất PDF.';
      case StaffDepartment.petCare:
        return 'Chức vụ cũ, tạm thời không sử dụng.';
      case StaffDepartment.reception:
        return 'Chức vụ cũ, tạm thời không sử dụng.';
    }
  }

  IconData get icon {
    switch (this) {
      case StaffDepartment.cafe:
        return Icons.local_cafe_rounded;
      case StaffDepartment.spa:
        return Icons.pets_rounded;
      case StaffDepartment.hospital:
        return Icons.medical_services_rounded;
      case StaffDepartment.petCare:
        return Icons.health_and_safety_rounded;
      case StaffDepartment.reception:
        return Icons.badge_rounded;
    }
  }

  Color get color {
    switch (this) {
      case StaffDepartment.cafe:
        return AppColors.peach;
      case StaffDepartment.spa:
        return AppColors.lavender;
      case StaffDepartment.hospital:
        return AppColors.sky;
      case StaffDepartment.petCare:
        return AppColors.mint;
      case StaffDepartment.reception:
        return AppColors.primarySoft;
    }
  }
}

StaffDepartment staffDepartmentFromKey(String? key) {
  switch (key) {
    case 'spa':
    case 'hotel':
    case 'spa-hotel':
      return StaffDepartment.spa;
    case 'hospital':
      return StaffDepartment.hospital;
    case 'pet-care':
      return StaffDepartment.petCare;
    case 'reception':
      return StaffDepartment.reception;
    case 'cafe':
    default:
      return StaffDepartment.cafe;
  }
}
