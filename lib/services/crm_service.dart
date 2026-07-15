import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/crm_customer.dart';
import '../models/crm_pet.dart';

/// Firestore gateway for the admin CRM.
/// `customers/{id}` owns the relationship; pets reference it through `ownerId`.
class CrmService {
  CrmService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<CrmCustomer>> watchCustomers({String phone = ''}) {
    final cleanPhone = phone.trim();
    Query<Map<String, dynamic>> query = _db.collection('customers');
    if (cleanPhone.isNotEmpty) {
      query = query.where('phone', isEqualTo: cleanPhone);
    }
    return query.snapshots().map((snapshot) {
      final customers = snapshot.docs.map(CrmCustomer.fromSnapshot).toList();
      customers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return customers;
    });
  }

  static Stream<CrmCustomer?> watchCustomer(String customerId) => _db
      .collection('customers')
      .doc(customerId)
      .snapshots()
      .map((doc) => doc.exists ? CrmCustomer.fromSnapshot(doc) : null);

  static Stream<List<CrmPet>> watchPets(String ownerId) => _db
      .collection('pets')
      .where('ownerId', isEqualTo: ownerId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(CrmPet.fromSnapshot).toList());

  static Future<String> saveCustomer({
    String? id,
    required String name,
    required String phone,
  }) async {
    final reference = id == null
        ? _db.collection('customers').doc()
        : _db.collection('customers').doc(id);
    await reference.set({
      'name': name.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (id == null) 'points': 0,
      if (id == null) 'tier': 'Đồng',
      if (id == null) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return reference.id;
  }

  /// Finds the existing CRM record by phone before creating one.  This makes
  /// bookings, service requests and walk-in orders share one customer record.
  static Future<String> upsertByPhone({
    required String name,
    required String phone,
  }) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) return saveCustomer(name: name, phone: cleanPhone);
    final existing = await _db
        .collection('customers')
        .where('phone', isEqualTo: cleanPhone)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final id = existing.docs.first.id;
      await saveCustomer(
        id: id,
        name: name.isEmpty
            ? (existing.docs.first.data()['name'] as String? ??
                  'Khách hàng PetHub')
            : name,
        phone: cleanPhone,
      );
      return id;
    }
    return saveCustomer(
      name: name.isEmpty ? 'Khách hàng PetHub' : name,
      phone: cleanPhone,
    );
  }

  /// Creates the CRM mirror for an authenticated customer without resetting
  /// points that staff may already have granted.
  static Future<void> syncCustomer({
    required String id,
    required String name,
    required String phone,
  }) async {
    final ref = _db.collection('customers').doc(id);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      transaction.set(ref, {
        'name': name.trim(),
        'phone': phone.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'points': 0,
        if (!snapshot.exists) 'tier': 'Đồng',
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static Future<void> savePet({
    String? id,
    required String ownerId,
    required String name,
    required String species,
    required String breed,
    required List<DateTime> vaccinationDates,
    required String dietaryNotes,
    required String medicalHistory,
  }) =>
      (id == null
              ? _db.collection('pets').doc()
              : _db.collection('pets').doc(id))
          .set({
            'ownerId': ownerId,
            'name': name.trim(),
            'species': species.trim(),
            'breed': breed.trim(),
            'vaccinationDates': vaccinationDates
                .map(Timestamp.fromDate)
                .toList(),
            'dietaryNotes': dietaryNotes.trim(),
            'medicalHistory': medicalHistory.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
            if (id == null) 'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

  /// Every 10,000 VND gives one point.  The transaction keeps point/tier aligned.
  static Future<void> addPoints({
    required String customerId,
    required int totalAmount,
  }) async {
    final earned = totalAmount ~/ 10000;
    if (earned <= 0) return;
    final ref = _db.collection('customers').doc(customerId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final current = (snapshot.data()?['points'] as num?)?.toInt() ?? 0;
      final updated = current + earned;
      transaction.set(ref, {
        'points': updated,
        'tier': CrmCustomer.tierForPoints(updated),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
