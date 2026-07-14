import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomerAuthService {
  CustomerAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _isGoogleInitialized = false;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  static Future<UserCredential> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Không tạo được tài khoản.');
    }

    await user.updateDisplayName(displayName.trim());

    await _createCustomerProfileIfNeeded(
      uid: user.uid,
      displayName: displayName.trim(),
      email: user.email ?? email.trim(),
      phoneNumber: user.phoneNumber,
    );

    return credential;
  }

  static Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user != null) {
      await _createCustomerProfileIfNeeded(
        uid: user.uid,
        displayName: user.displayName ?? 'Bạn PetHub',
        email: user.email ?? email.trim(),
        phoneNumber: user.phoneNumber,
      );
    }

    return credential;
  }

  static Future<UserCredential> loginWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception('Thiết bị này chưa hỗ trợ đăng nhập Google trực tiếp.');
    }

    final googleUser = await GoogleSignIn.instance.authenticate();

    final googleAuth = googleUser.authentication;

    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Không lấy được Google ID Token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      await _createCustomerProfileIfNeeded(
        uid: user.uid,
        displayName: user.displayName ?? googleUser.displayName ?? 'Bạn PetHub',
        email: user.email ?? googleUser.email,
        phoneNumber: user.phoneNumber,
      );
    }

    return userCredential;
  }

  static Future<void> sendForgotPasswordEmail(String email) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw Exception('Em nhập email trước nha.');
    }

    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  /// Changes an email/password account password after verifying the old one.
  /// Google-only accounts should use the password-reset flow instead.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
      throw Exception(
        'Tài khoản này không dùng mật khẩu. Hãy đặt lại mật khẩu qua email.',
      );
    }

    if (currentPassword.isEmpty) {
      throw Exception('Vui lòng nhập mật khẩu hiện tại.');
    }

    if (newPassword.length < 6) {
      throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  static Future<void> logout() async {
    // Firebase Authentication is the app's source of truth. Sign it out
    // first: Google Sign-In on web can take a long time or be unavailable,
    // and must never prevent the user from leaving their account.
    await _auth.signOut().timeout(const Duration(seconds: 8));

    try {
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;

    await GoogleSignIn.instance.initialize();

    _isGoogleInitialized = true;
  }

  static Future<void> _createCustomerProfileIfNeeded({
    required String uid,
    required String displayName,
    required String email,
    required String? phoneNumber,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      await userRef.update({
        'email': email,
        'phoneNumber': phoneNumber,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await userRef.set({
      'uid': uid,
      'role': 'customer',
      'displayName': displayName.isEmpty ? 'Bạn PetHub' : displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarIconKey': 'anonymous',
      'anonymousName': 'Ẩn danh PetHub',
      'anonymousAvatarIconKey': 'anonymous',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
}
