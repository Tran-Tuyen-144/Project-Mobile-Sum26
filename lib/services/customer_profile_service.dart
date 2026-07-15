import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/customer_profile.dart';
import 'crm_service.dart';
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

  /// Minimal profile used by the UI when Firestore is temporarily unavailable.
  /// It keeps the profile route usable for an authenticated customer.
  static CustomerProfile? get localFallbackProfile {
    final user = _auth.currentUser;
    if (user == null) return null;
    return CustomerProfile(
      uid: user.uid,
      role: 'customer',
      fullName: user.displayName ?? 'Khách hàng PetHub',
      displayName: user.displayName ?? 'PetHub User',
      email: user.email ?? '',
      avatarIconKey: 'default_person',
      anonymousName: 'Ẩn danh PetHub',
      anonymousAvatarIconKey: 'anonymous',
    );
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
        'avatarUrl': null,
        'avatarPublicId': null,
        'anonymousName': 'Ẩn danh PetHub',
        'anonymousAvatarIconKey': 'anonymous',
        'profileInitialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

    // The CRM uses a dedicated collection so staff can query customers without
    // exposing the complete authentication profile.  The Firebase UID is the
    // stable customer id in both collections.
    // CRM is an admin enhancement.  A missing Firestore rule for `customers`
    // must never prevent a customer from opening their own profile.
    try {
      await CrmService.syncCustomer(
        id: user.uid,
        name:
            (data['fullName'] as String?) ??
            user.displayName ??
            'Khách hàng PetHub',
        phone: (data['phoneNumber'] as String?) ?? user.phoneNumber ?? '',
      );
    } catch (error, stackTrace) {
      debugPrint('CRM customer sync skipped: $error\n$stackTrace');
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

    try {
      await CrmService.syncCustomer(
        id: _currentUser.uid,
        name: cleanFullName,
        phone:
            (data['phoneNumber'] as String?) ?? _currentUser.phoneNumber ?? '',
      );
    } catch (error, stackTrace) {
      debugPrint('CRM customer sync skipped: $error\n$stackTrace');
    }

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

  /// Lưu link ảnh đại diện trên Cloudinary; Firestore chỉ giữ URL và public id.
  static Future<void> updateAvatarImage({
    required String imageUrl,
    required String publicId,
  }) async {
    if (imageUrl.trim().isEmpty || publicId.trim().isEmpty) {
      throw Exception('Ảnh đại diện không hợp lệ.');
    }

    // set + merge also works for an account whose profile document has not
    // reached Firestore yet.  Other devices receive this URL from the same
    // `users/{uid}` document through watchCurrentProfile().
    await _currentProfileRef.set({
      'uid': _currentUser.uid,
      'avatarUrl': imageUrl.trim(),
      'avatarPublicId': publicId.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
