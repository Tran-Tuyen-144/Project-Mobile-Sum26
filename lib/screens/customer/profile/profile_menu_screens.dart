import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/customer_profile.dart';
import '../../../services/cloudinary_upload_service.dart';
import '../../../services/customer_auth_service.dart';
import '../../../services/customer_profile_service.dart';
import '../../../services/customer_saved_post_service.dart';
import '../../../services/firebase_community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import '../community/community_post.dart';
import '../community/community_post_detail_screen.dart';
import '../community/community_widgets.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerProfile?>(
      stream: CustomerProfileService.watchCurrentProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<Set<int>>(
          stream: CustomerSavedPostService.watchSavedPostIds(profile.uid),
          builder: (context, savedSnapshot) {
            final savedIds = savedSnapshot.data ?? <int>{};
            return StreamBuilder<List<CommunityPost>>(
              stream: FirebaseCommunityService.watchPosts(),
              builder: (context, postsSnapshot) {
                if (postsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (postsSnapshot.hasError) {
                  return Center(child: Text('Không tải được bài viết đã lưu.'));
                }

                final posts = (postsSnapshot.data ?? [])
                    .where((post) => savedIds.contains(post.id))
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  itemCount: posts.isEmpty ? 2 : posts.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _SavedIntro(count: posts.length);
                    }
                    if (posts.isEmpty) {
                      return const _EmptySavedPosts();
                    }
                    final post = posts[index - 1];
                    return CommunityPostCard(
                      post: post,
                      isLiked: post.likedBy.contains(profile.uid),
                      isSaved: true,
                      canManage: false,
                      onEdit: () {},
                      onDelete: () {},
                      onLike: () => FirebaseCommunityService.toggleLike(
                        post: post,
                        userId: profile.uid,
                      ),
                      onSave: () => CustomerSavedPostService.setSavedPost(
                        userId: profile.uid,
                        post: post,
                        isSaved: false,
                      ),
                      onShare: () {},
                      onOpenDetail: () => context.push(
                        '/community/post-detail',
                        extra: PostDetailArgs(
                          post: post,
                          isLiked: post.likedBy.contains(profile.uid),
                          isSaved: true,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class AccountCenterScreen extends StatelessWidget {
  const AccountCenterScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Đăng xuất tài khoản?'),
              content: const Text(
                'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng PetHub.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Đăng xuất'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) {
      return;
    }

    try {
      await CustomerAuthService.logout();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể đăng xuất: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );

      return;
    }

    if (context.mounted) {
      context.go('/customer-auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerProfile?>(
      stream: CustomerProfileService.watchCurrentProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _AccountHero(profile: profile),
            const SizedBox(height: 22),
            const Text(
              'Quản lý tài khoản',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            const SizedBox(height: 12),
            _AccountTile(
              icon: Icons.person_outline_rounded,
              color: AppColors.sky,
              title: 'Thông tin cá nhân',
              subtitle: 'Họ tên, tên hiển thị và email',
              onTap: () {
                context.push('/profile/personal-information');
              },
            ),
            const SizedBox(height: 10),
            _AccountTile(
              icon: Icons.lock_outline_rounded,
              color: AppColors.lavender,
              title: 'Mật khẩu và bảo mật',
              subtitle: 'Đổi mật khẩu hoặc gửi email đặt lại',
              onTap: () {
                context.push('/profile/password-security');
              },
            ),
            const SizedBox(height: 22),
            const Text(
              'Phiên đăng nhập',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            const SizedBox(height: 12),
            _AccountTile(
              icon: Icons.logout_rounded,
              color: AppColors.peach,
              title: 'Đăng xuất',
              subtitle: 'Thoát khỏi tài khoản hiện tại',
              onTap: () {
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class _SavedIntro extends StatelessWidget {
  final int count;
  const _SavedIntro({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF314A7E), Color(0xFF5975B9)],
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0x33FFFFFF),
          child: Icon(Icons.bookmark_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '$count bài viết đã lưu\nLưu lại điều bạn yêu thích để xem bất cứ lúc nào.',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
        ),
      ],
    ),
  );
}

class _EmptySavedPosts extends StatelessWidget {
  const _EmptySavedPosts();
  @override
  Widget build(BuildContext context) => SoftCard(
    color: Colors.white,
    child: const Column(
      children: [
        Icon(Icons.bookmark_add_outlined, size: 42, color: AppColors.primary),
        SizedBox(height: 10),
        Text(
          'Chưa có bài viết nào được lưu',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          'Chạm biểu tượng đánh dấu trên một bài cộng đồng để lưu.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _AccountHero extends StatelessWidget {
  final CustomerProfile profile;
  const _AccountHero({required this.profile});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF273B67), Color(0xFF4A78A8)],
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0x33FFFFFF),
          child: Icon(Icons.verified_user_outlined, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trung tâm tài khoản',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email.isEmpty
                    ? 'Hoàn thiện hồ sơ để bảo vệ tài khoản.'
                    : profile.email,
                style: const TextStyle(color: Color(0xFFE3ECFF)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AccountTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => SoftCard(
    color: Colors.white,
    onTap: onTap,
    child: Row(
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: color,
          child: Icon(icon, color: AppColors.textDark),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft),
      ],
    ),
  );
}

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<CustomerProfile?>(
    stream: CustomerProfileService.watchCurrentProfile(),
    builder: (context, snapshot) {
      final profile = snapshot.data;
      if (profile == null)
        return const Center(child: CircularProgressIndicator());
      return _PersonalInformationForm(profile: profile);
    },
  );
}

class _PersonalInformationForm extends StatefulWidget {
  final CustomerProfile profile;
  const _PersonalInformationForm({required this.profile});

  @override
  State<_PersonalInformationForm> createState() =>
      _PersonalInformationFormState();
}

class _PersonalInformationFormState extends State<_PersonalInformationForm> {
  late final TextEditingController _fullName;
  late final TextEditingController _displayName;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.profile.fullName);
    _displayName = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatar() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cập nhật ảnh đại diện',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Navigator.pop(sheetContext, 'camera'),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    setState(() => _isUploadingAvatar = true);
    try {
      final image = source == 'gallery'
          ? await CloudinaryUploadService.pickImageFromGallery()
          : await CloudinaryUploadService.pickImageFromCamera();
      if (image == null) return;
      final upload = await CloudinaryUploadService.uploadImageFile(
        image,
        folder: CloudinaryUploadService.profileFolder(
          CustomerAuthService.currentUser?.uid ?? 'anonymous',
        ),
      );
      await CustomerProfileService.updateAvatarImage(
        imageUrl: upload.imageUrl,
        publicId: upload.publicId,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật ảnh đại diện.')),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không tải được ảnh: $error')));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await CustomerProfileService.updatePersonalInformation(
        fullName: _fullName.text,
        displayName: _displayName.text,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thông tin cá nhân.')),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final avatarUrl = profile.avatarUrl?.trim();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: const Color(0xFFE2EDFF),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(
                              CloudinaryUploadService.optimizedImageUrl(
                                avatarUrl,
                              ),
                            )
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              size: 58,
                              color: Color(0xFF315F93),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: FilledButton(
                        onPressed: _isUploadingAvatar ? null : _chooseAvatar,
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: const Color(0xFF315F93),
                        ),
                        child: _isUploadingAvatar
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Ảnh đại diện',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _fullName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _displayName,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                color: const Color(0xFFF1F5FC),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Color(0xFF315F93)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email đăng nhập',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile.email.isEmpty
                                ? 'Chưa cập nhật'
                                : profile.email,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});
  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (next.text != confirm.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu mới chưa khớp.')));
      return;
    }
    setState(() => isSaving = true);
    try {
      await CustomerAuthService.changePassword(
        currentPassword: current.text,
        newPassword: next.text,
      );
      if (mounted) {
        current.clear();
        next.clear();
        confirm.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật mật khẩu.')));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _sendResetEmail() async {
    try {
      final profile = await CustomerProfileService.getCurrentProfile();
      await CustomerAuthService.sendForgotPasswordEmail(profile.email);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi email đặt lại mật khẩu.')),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFE9E0FF),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF6949A5),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mật khẩu được lưu và quản lý trực tiếp bởi Firebase Authentication.',
              style: TextStyle(color: AppColors.textSoft),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nhập lại mật khẩu mới',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSaving ? null : _changePassword,
                child: Text(isSaving ? 'Đang lưu...' : 'Lưu mật khẩu mới'),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: _sendResetEmail,
                icon: const Icon(Icons.mail_outline_rounded),
                label: const Text('Gửi email đặt lại mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
