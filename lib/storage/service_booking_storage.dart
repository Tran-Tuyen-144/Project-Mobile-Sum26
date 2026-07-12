import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  final ServiceBookingStatus status;

  const ServiceBookingRequest({
    required this.id,
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
    required this.status,
  });

  ServiceBookingRequest copyWith({ServiceBookingStatus? status}) {
    return ServiceBookingRequest(
      id: id,
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
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'status': status.name,
    };
  }

  factory ServiceBookingRequest.fromJson(Map<String, dynamic> json) {
    return ServiceBookingRequest(
      id: json['id'] as String? ?? '',
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
      status: ServiceBookingStatus.fromName(json['status'] as String? ?? ''),
    );
  }
}

class ServiceBookingStorage {
  static const String _key = 'service_booking_requests';

  static Future<List<ServiceBookingRequest>> loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = prefs.getStringList(_key) ?? [];
    final requests = <ServiceBookingRequest>[];

    for (final encoded in encodedItems) {
      try {
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        requests.add(ServiceBookingRequest.fromJson(decoded));
      } catch (_) {}
    }

    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  static Future<void> saveRequest(ServiceBookingRequest request) async {
    final requests = await loadRequests();
    requests.removeWhere((item) => item.id == request.id);
    requests.insert(0, request);
    await _saveRequests(requests);
  }

  static Future<void> confirmRequest(String id) async {
    final requests = await loadRequests();
    final updated = requests
        .map(
          (request) => request.id == id
              ? request.copyWith(status: ServiceBookingStatus.confirmed)
              : request,
        )
        .toList();
    await _saveRequests(updated);
  }

  static Future<void> _saveRequests(
    List<ServiceBookingRequest> requests,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      requests.map((request) => jsonEncode(request.toJson())).toList(),
    );
  }
}
