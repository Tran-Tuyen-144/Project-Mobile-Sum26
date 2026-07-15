import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/admin_notification_service.dart';
import '../services/crm_service.dart';

enum ServiceBookingStatus {
  sent('Đã gửi admin'),
  confirmed('Đã xác nhận');

  final String label;

  const ServiceBookingStatus(this.label);

  static ServiceBookingStatus fromName(String value) {
    return ServiceBookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ServiceBookingStatus.sent,
    );
  }
}

class ServiceBookingRequest {
  final String id;
  final String customerId;
  final DateTime createdAt;
  final String serviceName;
  final String serviceCategory;
  final String packageName;
  final String customerName;
  final String phone;
  final String petName;
  final String petType;
  final String startDay;
  final String endDay;
  final String time;
  final String note;
  final Map<String, String> details;
  final ServiceBookingStatus status;

  const ServiceBookingRequest({
    required this.id,
    this.customerId = '',
    required this.createdAt,
    required this.serviceName,
    required this.serviceCategory,
    required this.packageName,
    required this.customerName,
    required this.phone,
    required this.petName,
    required this.petType,
    required this.startDay,
    required this.endDay,
    required this.time,
    required this.note,
    this.details = const {},
    required this.status,
  });

  ServiceBookingRequest copyWith({
    String? customerId,
    ServiceBookingStatus? status,
  }) {
    return ServiceBookingRequest(
      id: id,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      packageName: packageName,
      customerName: customerName,
      phone: phone,
      petName: petName,
      petType: petType,
      startDay: startDay,
      endDay: endDay,
      time: time,
      note: note,
      details: details,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'packageName': packageName,
      'customerName': customerName,
      'phone': phone,
      'petName': petName,
      'petType': petType,
      'startDay': startDay,
      'endDay': endDay,
      'time': time,
      'note': note,
      'details': details,
      'status': status.name,
    };
  }

  factory ServiceBookingRequest.fromJson(Map<String, dynamic> json) {
    return ServiceBookingRequest(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      serviceName: json['serviceName'] as String? ?? '',
      serviceCategory: json['serviceCategory'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      petName: json['petName'] as String? ?? '',
      petType: json['petType'] as String? ?? '',
      startDay: json['startDay'] as String? ?? json['day'] as String? ?? '',
      endDay: json['endDay'] as String? ?? '',
      time: json['time'] as String? ?? '',
      note: json['note'] as String? ?? '',
      details: (json['details'] as Map<Object?, Object?>? ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      status: ServiceBookingStatus.fromName(json['status'] as String? ?? ''),
    );
  }
}

class ServiceBookingStorage {
  static final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('service_bookings');

  static Future<List<ServiceBookingRequest>> loadRequests() async {
    final snapshot = await _bookings
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((document) => ServiceBookingRequest.fromJson(document.data()))
        .toList();
  }

  static Future<List<ServiceBookingRequest>>
  loadCurrentCustomerRequests() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot = await _bookings
        .where('customerId', isEqualTo: user.uid)
        .get();

    final requests = snapshot.docs
        .map((document) => ServiceBookingRequest.fromJson(document.data()))
        .toList();

    requests.sort(
      (first, second) => second.createdAt.compareTo(first.createdAt),
    );

    return requests;
  }

  static Future<void> saveRequest(ServiceBookingRequest request) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập trước khi đặt dịch vụ.');
    }

    final ownedRequest = request.copyWith(customerId: user.uid);

    await _bookings.doc(ownedRequest.id).set(ownedRequest.toJson());

    try {
      await CrmService.upsertByPhone(
        name: ownedRequest.customerName,
        phone: ownedRequest.phone,
      );
    } catch (_) {}

    await AdminNotificationService.create(
      title: 'Yêu cầu dịch vụ mới',
      body:
          '${ownedRequest.customerName} • '
          '${ownedRequest.serviceName} • '
          '${ownedRequest.phone}',
      type: 'service',
    );
  }

  static Future<void> confirmRequest(String id) async {
    await _bookings.doc(id).update({
      'status': ServiceBookingStatus.confirmed.name,
    });
  }
}
