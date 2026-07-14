class CafeBooking {
  final String id;
  final String customerName;
  final String phone;
  final String table;
  final String time;
  final String status;

  const CafeBooking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.table,
    required this.time,
    this.status = 'Chờ xác nhận',
  });

  CafeBooking copyWith({
    String? id,
    String? customerName,
    String? phone,
    String? table,
    String? time,
    String? status,
  }) {
    return CafeBooking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      table: table ?? this.table,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }

  // ==========================================
  // PHẦN TÍCH HỢP FIREBASE (JSON SERIALIZATION)
  // ==========================================

  factory CafeBooking.fromJson(Map<String, dynamic> json, String documentId) {
    return CafeBooking(
      id: documentId,
      customerName: json['customerName'] as String? ?? 'Khách vãng lai',
      phone: json['phone'] as String? ?? '',
      table: json['table'] as String? ?? 'Chưa xếp bàn',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'Chờ xác nhận',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phone': phone,
      'table': table,
      'time': time,
      'status': status,
    };
  }
}
