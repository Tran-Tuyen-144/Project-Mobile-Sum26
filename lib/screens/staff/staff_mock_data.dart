import '../../models/staff/staff_profile.dart';
import '../../models/staff/staff_task.dart';
import 'staff_department.dart';

class StaffMockData {
  StaffMockData._();

  static StaffProfile profileFor(StaffDepartment department) {
    switch (department) {
      case StaffDepartment.cafe:
        return StaffProfile(
          id: 'NV-CF-001',
          fullName: 'Nguyễn Minh An',
          phoneNumber: '0901234567',
          email: 'minhan@pethub.vn',
          department: StaffDepartment.cafe,
          branchName: 'PetHub Quận 1',
          shiftName: 'Ca sáng',
          shiftTime: '07:30 - 15:30',
          workDate: DateTime.now(),
        );

      case StaffDepartment.spa:
        return StaffProfile(
          id: 'NV-SP-002',
          fullName: 'Trần Ngọc Mai',
          phoneNumber: '0912345678',
          email: 'ngocmai@pethub.vn',
          department: StaffDepartment.spa,
          branchName: 'PetHub Quận 1',
          shiftName: 'Ca hành chính',
          shiftTime: '08:00 - 17:00',
          workDate: DateTime.now(),
        );

      case StaffDepartment.hospital:
        return StaffProfile(
          id: 'NV-BV-003',
          fullName: 'Lê Hoàng Nam',
          phoneNumber: '0987654321',
          email: 'hoangnam@pethub.vn',
          department: StaffDepartment.hospital,
          branchName: 'PetHub Veterinary',
          shiftName: 'Ca sáng',
          shiftTime: '08:00 - 16:00',
          workDate: DateTime.now(),
        );

      case StaffDepartment.petCare:
        return profileFor(StaffDepartment.spa);

      case StaffDepartment.reception:
        return profileFor(StaffDepartment.cafe);
    }
  }

  static List<StaffTask> tasksFor(StaffDepartment department) {
    switch (department) {
      case StaffDepartment.cafe:
        return const [
          StaffTask(
            id: 'CF-T01',
            department: StaffDepartment.cafe,
            title: 'Kiểm tra khu vực Café',
            description: 'Kiểm tra bàn ghế, quầy pha chế và vệ sinh đầu ca.',
            timeSlot: '07:30 - 08:00',
          ),
          StaffTask(
            id: 'CF-T02',
            department: StaffDepartment.cafe,
            title: 'Kiểm tra đơn đặt bàn',
            description:
                'Kiểm tra các đơn đặt bàn và khách dự kiến đến trong ca.',
            timeSlot: '08:00 - 08:30',
          ),
          StaffTask(
            id: 'CF-T03',
            department: StaffDepartment.cafe,
            title: 'Kiểm tra Menu',
            description: 'Kiểm tra món còn phục vụ và món đã hết trong ngày.',
            timeSlot: '08:30 - 09:00',
          ),
          StaffTask(
            id: 'CF-T04',
            department: StaffDepartment.cafe,
            title: 'Kiểm kê cuối ca',
            description: 'Kiểm tra nguyên liệu và bàn giao lại cho ca sau.',
            timeSlot: '15:00 - 15:30',
          ),
        ];

      case StaffDepartment.spa:
        return const [
          StaffTask(
            id: 'SP-T01',
            department: StaffDepartment.spa,
            title: 'Chuẩn bị khu vực Spa',
            description: 'Kiểm tra dụng cụ, khăn, phòng Spa và khu lưu trú.',
            timeSlot: '08:00 - 08:30',
          ),
          StaffTask(
            id: 'SP-T02',
            department: StaffDepartment.spa,
            title: 'Kiểm tra lịch dịch vụ',
            description: 'Kiểm tra khách Spa và Pet gửi khách sạn trong ngày.',
            timeSlot: '08:30 - 09:00',
          ),
          StaffTask(
            id: 'SP-T03',
            department: StaffDepartment.spa,
            title: 'Kiểm tra Pet lưu trú',
            description: 'Theo dõi ăn uống, sức khỏe và thời gian trả Pet.',
            timeSlot: '11:00 - 11:30',
          ),
          StaffTask(
            id: 'SP-T04',
            department: StaffDepartment.spa,
            title: 'Cập nhật hồ sơ dịch vụ',
            description: 'Ghi chú kết quả Spa và tình trạng Pet cuối ca.',
            timeSlot: '16:30 - 17:00',
          ),
        ];

      case StaffDepartment.hospital:
        return const [
          StaffTask(
            id: 'BV-T01',
            department: StaffDepartment.hospital,
            title: 'Kiểm tra lịch khám',
            description: 'Kiểm tra danh sách khách và Pet đã đặt lịch khám.',
            timeSlot: '08:00 - 08:30',
          ),
          StaffTask(
            id: 'BV-T02',
            department: StaffDepartment.hospital,
            title: 'Chuẩn bị phòng khám',
            description: 'Kiểm tra dụng cụ, thuốc và thiết bị khám bệnh.',
            timeSlot: '08:30 - 09:00',
          ),
          StaffTask(
            id: 'BV-T03',
            department: StaffDepartment.hospital,
            title: 'Cập nhật bệnh án',
            description: 'Hoàn thiện hồ sơ bệnh án sau mỗi lượt khám.',
            timeSlot: 'Trong ca',
          ),
          StaffTask(
            id: 'BV-T04',
            department: StaffDepartment.hospital,
            title: 'Kiểm tra lịch tái khám',
            description: 'Kiểm tra và xác nhận các lịch tái khám sắp tới.',
            timeSlot: '15:30 - 16:00',
          ),
        ];

      case StaffDepartment.petCare:
        return tasksFor(StaffDepartment.spa);

      case StaffDepartment.reception:
        return tasksFor(StaffDepartment.cafe);
    }
  }
}
