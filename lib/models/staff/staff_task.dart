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
}
