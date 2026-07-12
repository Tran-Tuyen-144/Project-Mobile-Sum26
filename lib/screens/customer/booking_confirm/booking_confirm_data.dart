class BookingConfirmData {
  final String petName;
  final String petStatus;
  final String branch;
  final String day;
  final String time;
  final int guests;
  final String tableName;

  const BookingConfirmData({
    required this.petName,
    required this.petStatus,
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableName,
  });

  BookingConfirmData copyWith({String? petName, String? petStatus}) {
    return BookingConfirmData(
      petName: petName ?? this.petName,
      petStatus: petStatus ?? this.petStatus,
      branch: branch,
      day: day,
      time: time,
      guests: guests,
      tableName: tableName,
    );
  }
}
