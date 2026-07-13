class BookingConfirmData {
  final List<String> petNames;
  final String petStatus;
  final String customerName;
  final String branch;
  final String day;
  final String time;
  final int guests;
  final String tableName;

  const BookingConfirmData({
    this.petNames = const [],
    this.petStatus = '',
    this.customerName = 'Khách vãng lai',
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableName,
  });

  String get petName {
    if (petNames.isEmpty) {
      return 'Thú cưng của bạn';
    }

    return petNames.join(', ');
  }

  String get customerId {
    final normalized = customerName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (normalized.isEmpty) {
      return 'khach-vang-lai';
    }

    return normalized;
  }

  bool get canAddPet => petNames.length < 3;

  BookingConfirmData addPet(String newPetName, String newPetStatus) {
    if (!canAddPet || petNames.contains(newPetName)) {
      return this;
    }

    return BookingConfirmData(
      petNames: [...petNames, newPetName],
      petStatus: newPetStatus,
      customerName: customerName,
      branch: branch,
      day: day,
      time: time,
      guests: guests,
      tableName: tableName,
    );
  }

  BookingConfirmData copyWith({
    List<String>? petNames,
    String? petStatus,
    String? customerName,
    String? branch,
    String? day,
    String? time,
    int? guests,
    String? tableName,
  }) {
    return BookingConfirmData(
      petNames: petNames ?? this.petNames,
      petStatus: petStatus ?? this.petStatus,
      customerName: customerName ?? this.customerName,
      branch: branch ?? this.branch,
      day: day ?? this.day,
      time: time ?? this.time,
      guests: guests ?? this.guests,
      tableName: tableName ?? this.tableName,
    );
  }
}
