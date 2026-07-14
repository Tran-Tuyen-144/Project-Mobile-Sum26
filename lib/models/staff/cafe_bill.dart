class CafeBill {
  final String id;
  final String customerName;
  final String staffName;
  final int totalPrice;
  final Map<String, int> items;
  final DateTime createdAt;

  const CafeBill({
    required this.id,
    this.customerName = '', // Khách có thể không để lại tên
    required this.staffName,
    required this.totalPrice,
    required this.items,
    required this.createdAt,
  });

  CafeBill copyWith({
    String? id,
    String? customerName,
    String? staffName,
    int? totalPrice,
    Map<String, int>? items,
    DateTime? createdAt,
  }) {
    return CafeBill(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      staffName: staffName ?? this.staffName,
      totalPrice: totalPrice ?? this.totalPrice,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==========================================
  // PHẦN TÍCH HỢP FIREBASE (JSON SERIALIZATION)
  // ==========================================

  factory CafeBill.fromJson(Map<String, dynamic> json, String documentId) {
    // Xử lý an toàn cho trường ngày tháng từ Firebase (Timestamp -> DateTime)
    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedDate = (json['createdAt'] as dynamic).toDate();
      } catch (e) {
        // Fallback nếu có lỗi ép kiểu
        parsedDate = DateTime.now();
      }
    }

    return CafeBill(
      id: documentId,
      customerName: json['customerName'] as String? ?? '',
      staffName: json['staffName'] as String? ?? 'Nhân viên',
      // Ép kiểu an toàn (num) để phòng trường hợp Firebase trả về double
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      items: Map<String, int>.from(json['items'] as Map? ?? {}),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'staffName': staffName,
      'totalPrice': totalPrice,
      'items': items,
      'createdAt': createdAt, // Firebase SDK sẽ tự động biến DateTime thành Timestamp
    };
  }
}