import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum StaffDepartment {
  cafe,
  spa,
  hospital,
  petCare,
  reception,
}

extension StaffDepartmentExtension on StaffDepartment {
  String get key {
    switch (this) {
      case StaffDepartment.cafe:
        return 'cafe';
      case StaffDepartment.spa:
        return 'spa';
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
        return 'Nhân viên Spa';
      case StaffDepartment.hospital:
        return 'Nhân viên Bệnh viện thú y';
      case StaffDepartment.petCare:
        return 'Nhân viên chăm sóc Pet';
      case StaffDepartment.reception:
        return 'Lễ tân / Check-in';
    }
  }

  String get shortTitle {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Café';
      case StaffDepartment.spa:
        return 'Spa';
      case StaffDepartment.hospital:
        return 'Bệnh viện';
      case StaffDepartment.petCare:
        return 'Chăm sóc Pet';
      case StaffDepartment.reception:
        return 'Check-in';
    }
  }

  String get description {
    switch (this) {
      case StaffDepartment.cafe:
        return 'Xác nhận đơn gọi nước và cập nhật trạng thái món.';
      case StaffDepartment.spa:
        return 'Theo dõi dịch vụ spa, ghi chú và cập nhật ảnh sau spa.';
      case StaffDepartment.hospital:
        return 'Cập nhật tình trạng thú cưng và ghi chú bệnh án.';
      case StaffDepartment.petCare:
        return 'Theo dõi lịch làm việc, thời gian nghỉ và sức khỏe Pet.';
      case StaffDepartment.reception:
        return 'Quét mã QR và xác nhận khách đến quán.';
    }
  }

  IconData get icon {
    switch (this) {
      case StaffDepartment.cafe:
        return Icons.local_cafe_rounded;
      case StaffDepartment.spa:
        return Icons.bathtub_rounded;
      case StaffDepartment.hospital:
        return Icons.medical_services_rounded;
      case StaffDepartment.petCare:
        return Icons.pets_rounded;
      case StaffDepartment.reception:
        return Icons.qr_code_scanner_rounded;
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