import '../../screens/staff/staff_department.dart';

class StaffTask {
  final String id;
  final StaffDepartment department;
  final String title;
  final String description;
  final String timeSlot;
  final String note;
  final bool isRequired;
  final bool isCompleted;

  const StaffTask({
    required this.id,
    required this.department,
    required this.title,
    required this.description,
    required this.timeSlot,
    this.note = '',
    this.isRequired = true,
    this.isCompleted = false,
  });

  StaffTask copyWith({
    String? id,
    StaffDepartment? department,
    String? title,
    String? description,
    String? timeSlot,
    String? note,
    bool? isRequired,
    bool? isCompleted,
  }) {
    return StaffTask(
      id: id ?? this.id,
      department: department ?? this.department,
      title: title ?? this.title,
      description: description ?? this.description,
      timeSlot: timeSlot ?? this.timeSlot,
      note: note ?? this.note,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // ==========================================
  // PHẦN TÍCH HỢP FIREBASE (JSON SERIALIZATION)
  // ==========================================

  /// Chuyển đổi dữ liệu từ Firebase (Map) thành Object StaffTask
  factory StaffTask.fromJson(Map<String, dynamic> json, String documentId) {
    // 1. Chuyển đổi String từ Firebase ngược lại thành Enum StaffDepartment
    final deptString = json['department'] as String? ?? 'cafe';
    final deptEnum = StaffDepartment.values.firstWhere(
          (e) => e.name == deptString,
      orElse: () => StaffDepartment.cafe, // Giá trị mặc định nếu lỗi
    );

    return StaffTask(
      id: documentId,
      department: deptEnum,
      title: json['title'] ?? 'Chưa có tiêu đề',
      description: json['description'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      note: json['note'] ?? '',
      isRequired: json['isRequired'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  /// Chuyển đổi Object StaffTask thành Map để đẩy lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'department': department.name, // Lưu Enum dưới dạng String (ví dụ: 'cafe', 'spa')
      'title': title,
      'description': description,
      'timeSlot': timeSlot,
      'note': note,
      'isRequired': isRequired,
      'isCompleted': isCompleted,
    };
  }
}