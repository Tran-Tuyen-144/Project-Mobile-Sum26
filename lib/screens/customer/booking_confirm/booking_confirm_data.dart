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
    required this.petNames,
    required this.petStatus,
    required this.customerName,
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableName,
  });

  String get petName => petNames.join(', ');
  String get customerId =>
      customerName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  bool get canAddPet => petNames.length < 3;

  BookingConfirmData addPet(String petName, String status) {
    if (!canAddPet || petNames.contains(petName)) return this;
    return BookingConfirmData(
      petNames: [...petNames, petName],
      petStatus: status,
      customerName: customerName,
      branch: branch,
      day: day,
      time: time,
      guests: guests,
      tableName: tableName,
    );
  }
}
