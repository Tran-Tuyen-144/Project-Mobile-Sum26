import 'package:cloud_firestore/cloud_firestore.dart';

class CrmCustomer {
  final String id;
  final String name;
  final String phone;
  final int points;
  final String tier;
  final DateTime? createdAt;

  const CrmCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.points,
    required this.tier,
    this.createdAt,
  });

  factory CrmCustomer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];
    return CrmCustomer(
      id: doc.id,
      name: data['name'] as String? ?? 'Khách hàng PetHub',
      phone: data['phone'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      tier: data['tier'] as String? ?? 'Đồng',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  static String tierForPoints(int points) {
    if (points >= 1000) return 'Vàng';
    if (points >= 300) return 'Bạc';
    return 'Đồng';
  }
}
