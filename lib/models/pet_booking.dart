import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingType { online, offline }

enum BookingStatus { active, completed, cancelled }

extension BookingTypeLabel on BookingType {
  String get value => name;
  String get label => this == BookingType.online ? 'Đặt Online' : 'Đặt tại chỗ';
}

extension BookingStatusLabel on BookingStatus {
  String get value => name;
  String get label {
    switch (this) {
      case BookingStatus.active:
        return 'Đang hoạt động';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class PetBooking {
  final String bookingId;
  final String customerId;
  final String customerName;
  final BookingType bookingType;
  final List<String> pets;
  final DateTime bookingDate;
  final String startTime;
  final String? address;
  final String? tableNumber;
  final String note;
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetBooking({
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.bookingType,
    required this.pets,
    required this.bookingDate,
    required this.startTime,
    this.address,
    this.tableNumber,
    required this.note,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == BookingStatus.active;

  factory PetBooking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final legacyPet = data['petName'] as String?;
    final rawPets = (data['pets'] as List<dynamic>?)
        ?.map((pet) => pet is Map ? (pet['name'] ?? '').toString() : pet.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    return PetBooking(
      bookingId: doc.id,
      customerId: (data['customerId'] ?? data['customerName'] ?? '').toString(),
      customerName: (data['customerName'] ?? '').toString(),
      bookingType: (data['bookingType'] ?? 'offline') == 'online'
          ? BookingType.online
          : BookingType.offline,
      pets: rawPets == null || rawPets.isEmpty
          ? (legacyPet == null ? [] : [legacyPet])
          : rawPets,
      bookingDate: _date(data['bookingDate']) ?? DateTime.now(),
      startTime: (data['startTime'] ?? data['requestedTime'] ?? '').toString(),
      address: data['address'] as String?,
      tableNumber: data['tableNumber'] as String?,
      note: (data['note'] ?? '').toString(),
      status: _status((data['status'] ?? 'active').toString()),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'bookingType': bookingType.value,
        'pets': pets.map((name) => {'name': name}).toList(),
        'bookingDate': Timestamp.fromDate(bookingDate),
        'startTime': startTime,
        'address': address,
        'tableNumber': tableNumber,
        'note': note,
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static DateTime? _date(dynamic value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
          ? value
          : null;

  static BookingStatus _status(String value) {
    switch (value) {
      case 'completed':
      case 'pending':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.active;
    }
  }
}
