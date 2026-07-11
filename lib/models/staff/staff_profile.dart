import '../../screens/staff/staff_department.dart';

enum StaffWorkingStatus { working, breakTime, offDuty }

extension StaffWorkingStatusExtension on StaffWorkingStatus {
  String get label {
    switch (this) {
      case StaffWorkingStatus.working:
        return 'Đang làm việc';

      case StaffWorkingStatus.breakTime:
        return 'Đang nghỉ giữa ca';

      case StaffWorkingStatus.offDuty:
        return 'Đã kết thúc ca';
    }
  }
}

class StaffProfile {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;

  final StaffDepartment department;

  final String branchName;
  final String shiftName;
  final String shiftTime;

  final DateTime workDate;
  final StaffWorkingStatus workingStatus;

  const StaffProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.department,
    required this.branchName,
    required this.shiftName,
    required this.shiftTime,
    required this.workDate,
    this.workingStatus = StaffWorkingStatus.working,
  });

  StaffProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    StaffDepartment? department,
    String? branchName,
    String? shiftName,
    String? shiftTime,
    DateTime? workDate,
    StaffWorkingStatus? workingStatus,
  }) {
    return StaffProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      department: department ?? this.department,
      branchName: branchName ?? this.branchName,
      shiftName: shiftName ?? this.shiftName,
      shiftTime: shiftTime ?? this.shiftTime,
      workDate: workDate ?? this.workDate,
      workingStatus: workingStatus ?? this.workingStatus,
    );
  }
}
