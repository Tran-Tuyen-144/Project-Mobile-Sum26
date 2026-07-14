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

      case StaffDepartment.hotel:
        return StaffProfile(
          id: 'NV-HT-003',
          fullName: 'Lê Hoàng Nam',
          phoneNumber: '0987654321',
          email: 'hoangnam@pethub.vn',
          department: StaffDepartment.hotel,
          branchName: 'PetHub Quận 1',
          shiftName: 'Ca hành chính',
          shiftTime: '08:00 - 17:00',
          workDate: DateTime.now(),
        );

      case StaffDepartment.hospital:
        return StaffProfile(
          id: 'NV-BV-004',
          fullName: 'Phạm Thị Thúy',
          phoneNumber: '0966666888',
          email: 'thuypham@pethub.vn',
          department: StaffDepartment.hospital,
          branchName: 'PetHub Veterinary',
          shiftName: 'Ca sáng',
          shiftTime: '08:00 - 16:00',
          workDate: DateTime.now(),
        );
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
            description: 'Kiểm tra các đơn đặt bàn và khách dự kiến đến trong ca.',
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
            description: 'Kiểm tra dụng cụ, khăn và phòng Spa.',
            timeSlot: '08:00 - 08:30',
          ),
          StaffTask(
            id: 'SP-T02',
            department: StaffDepartment.spa,
            title: 'Kiểm tra lịch dịch vụ',
            description: 'Kiểm tra khách Spa trong ngày.',
            timeSlot: '08:30 - 09:00',
          ),
        ];

      case StaffDepartment.hotel:
        return const [
          StaffTask(
            id: 'HT-T01',
            department: StaffDepartment.hotel,
            title: 'Kiểm tra phòng lưu trú',
            description: 'Dọn dẹp phòng, kiểm tra nước uống và vệ sinh khu vực.',
            timeSlot: '08:30 - 09:00',
          ),
          StaffTask(
            id: 'HT-T02',
            department: StaffDepartment.hotel,
            title: 'Theo dõi sức khỏe Pet',
            description: 'Kiểm tra ăn uống và tình trạng Pet nội trú.',
            timeSlot: '11:00 - 11:30',
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
        ];
    }
  }
}