class BookingConfirmData {
  final String branch;
  final String day;
  final String time;
  final int guests;
  final String tableName;

  const BookingConfirmData({
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableName,
  });
}