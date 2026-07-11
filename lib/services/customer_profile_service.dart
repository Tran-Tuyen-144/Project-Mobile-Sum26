import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/customer_profile.dart';

class CustomerProfileService {
  CustomerProfileService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User get _currentUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    return user;
  }

  static DocumentReference<Map<String, dynamic>> get _currentProfileRef {
    return _firestore.collection('users').doc(_currentUser.uid);
  }

  static String _generateRandomDisplayName() {
    const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();

    final code = List.generate(
      6,
          (_) => characters[random.nextInt(characters.length)],
    ).join();

    return 'PetHub#$code';
  }

  static Future<void> ensureCurrentProfile() async {
    final user = _currentUser;
    final reference = _firestore.collection('users').doc(user.uid);
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      await reference.set({
        'uid': user.uid,
        'role': 'customer',
        'fullName': user.displayName ?? 'Khách hàng PetHub',
        'displayName': _generateRandomDisplayName(),
        'email': user.email ?? '',
        'phoneNumber': user.phoneNumber,
        'avatarIconKey': 'default_person',
        'anonymousName': 'Ẩn danh PetHub',
        'anonymousAvatarIconKey': 'anonymous',
        'profileInitialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    final data = snapshot.data() ?? {};

    /*
     * Tài khoản cũ được tạo trước khi có profile mới sẽ được
     * chuyển sang tên mã ngẫu nhiên và avatar chân dung một lần.
     */
    if (data['profileInitialized'] != true) {
      final oldName = data['displayName'] as String? ??
          user.displayName ??
          'Khách hàng PetHub';

      await reference.set({
        'uid': user.uid,
        'role': data['role'] ?? 'customer',
        'fullName': data['fullName'] ?? oldName,
        'displayName': _generateRandomDisplayName(),
        'email': data['email'] ?? user.email ?? '',
        'phoneNumber': data['phoneNumber'] ?? user.phoneNumber,
        'avatarIconKey': 'default_person',
        'anonymousName': data['anonymousName'] ?? 'Ẩn danh PetHub',
        'anonymousAvatarIconKey':
        data['anonymousAvatarIconKey'] ?? 'anonymous',
        'profileInitialized': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Stream<CustomerProfile?> watchCurrentProfile() {
    return _currentProfileRef.snapshots().map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      return CustomerProfile.fromMap(data);
    });
  }

  static Future<void> updatePersonalInformation({
    required String fullName,
    required String displayName,
  }) async {
    final cleanFullName = fullName.trim();
    final cleanDisplayName = displayName.trim();

    if (cleanFullName.isEmpty) {
      throw Exception('Họ tên không được để trống.');
    }

    if (cleanDisplayName.isEmpty) {
      throw Exception('Tên hiển thị không được để trống.');
    }

    await _currentProfileRef.update({
      'fullName': cleanFullName,
      'displayName': cleanDisplayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateAvatarIcon(String iconKey) async {
    await _currentProfileRef.update({
      'avatarIconKey': iconKey,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}