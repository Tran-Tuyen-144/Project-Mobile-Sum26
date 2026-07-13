import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/customer_profile.dart';
import 'firebase_community_service.dart';

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
     * Tài khoản được tạo trước khi có Profile mới
     * sẽ được nâng cấp đúng một lần.
     */
    if (data['profileInitialized'] != true) {
      final oldName =
          data['displayName'] as String? ??
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
        'anonymousAvatarIconKey': data['anonymousAvatarIconKey'] ?? 'anonymous',
        'profileInitialized': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Future<CustomerProfile> getCurrentProfile() async {
    await ensureCurrentProfile();

    final snapshot = await _currentProfileRef.get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw Exception('Không tìm thấy hồ sơ khách hàng.');
    }

    return CustomerProfile.fromMap(data);
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

    final snapshot = await _currentProfileRef.get();

    final data = snapshot.data() ?? {};

    final avatarIconKey = data['avatarIconKey'] as String? ?? 'default_person';

    await _currentProfileRef.update({
      'fullName': cleanFullName,
      'displayName': cleanDisplayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /*
     * Cập nhật luôn Firebase Auth displayName.
     */
    await _currentUser.updateDisplayName(cleanDisplayName);

    /*
     * Đồng bộ tên mới sang tất cả bài
     * không ẩn danh của người dùng.
     */
    await FirebaseCommunityService.syncAuthorIdentity(
      authorId: _currentUser.uid,
      isAnonymous: false,
      authorName: cleanDisplayName,
      avatarIconKey: avatarIconKey,
    );
  }

  static Future<void> updateAvatarIcon(String iconKey) async {
    final cleanIconKey = iconKey.trim();

    if (cleanIconKey.isEmpty) {
      throw Exception('Avatar không hợp lệ.');
    }

    final snapshot = await _currentProfileRef.get();

    final data = snapshot.data() ?? {};

    final displayName = data['displayName'] as String? ?? 'Bạn PetHub';

    await _currentProfileRef.update({
      'avatarIconKey': cleanIconKey,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /*
     * Đồng bộ avatar mới sang các bài
     * không ẩn danh.
     */
    await FirebaseCommunityService.syncAuthorIdentity(
      authorId: _currentUser.uid,
      isAnonymous: false,
      authorName: displayName,
      avatarIconKey: cleanIconKey,
    );
  }

  static Future<void> updateAnonymousIdentity({
    required String anonymousName,
    required String anonymousAvatarIconKey,
  }) async {
    final cleanAnonymousName = anonymousName.trim();

    final cleanAnonymousAvatar = anonymousAvatarIconKey.trim();

    if (cleanAnonymousName.isEmpty) {
      throw Exception('Tên ẩn danh không được để trống.');
    }

    if (cleanAnonymousAvatar.isEmpty) {
      throw Exception('Avatar ẩn danh không hợp lệ.');
    }

    await _currentProfileRef.update({
      'anonymousName': cleanAnonymousName,
      'anonymousAvatarIconKey': cleanAnonymousAvatar,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /*
     * Đồng bộ danh tính mới sang tất cả
     * bài ẩn danh của tài khoản.
     */
    await FirebaseCommunityService.syncAuthorIdentity(
      authorId: _currentUser.uid,
      isAnonymous: true,
      authorName: cleanAnonymousName,
      avatarIconKey: cleanAnonymousAvatar,
    );
  }

  static Future<void> updateAnonymousName(String anonymousName) async {
    final profile = await getCurrentProfile();

    await updateAnonymousIdentity(
      anonymousName: anonymousName,
      anonymousAvatarIconKey: profile.anonymousAvatarIconKey,
    );
  }

  static Future<void> updateAnonymousAvatarIcon(String iconKey) async {
    final profile = await getCurrentProfile();

    await updateAnonymousIdentity(
      anonymousName: profile.anonymousName,
      anonymousAvatarIconKey: iconKey,
    );
  }
}
