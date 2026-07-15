class CustomerProfile {
  final String uid;
  final String role;
  final String fullName;
  final String displayName;
  final String email;
  final String avatarIconKey;
  final String? avatarUrl;
  final String? avatarPublicId;
  final String anonymousName;
  final String anonymousAvatarIconKey;

  const CustomerProfile({
    required this.uid,
    required this.role,
    required this.fullName,
    required this.displayName,
    required this.email,
    required this.avatarIconKey,
    this.avatarUrl,
    this.avatarPublicId,
    required this.anonymousName,
    required this.anonymousAvatarIconKey,
  });

  factory CustomerProfile.fromMap(Map<String, dynamic> data) {
    return CustomerProfile(
      uid: data['uid'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      fullName: data['fullName'] as String? ?? 'Khách hàng PetHub',
      displayName: data['displayName'] as String? ?? 'PetHub User',
      email: data['email'] as String? ?? '',
      avatarIconKey: data['avatarIconKey'] as String? ?? 'default_person',
      avatarUrl: data['avatarUrl'] as String?,
      avatarPublicId: data['avatarPublicId'] as String?,
      anonymousName: data['anonymousName'] as String? ?? 'Ẩn danh PetHub',
      anonymousAvatarIconKey:
          data['anonymousAvatarIconKey'] as String? ?? 'anonymous',
    );
  }
}
