import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/customer_profile.dart';
import '../../../services/customer_auth_service.dart';
import '../../../services/customer_profile_service.dart';
import '../../../services/customer_saved_post_service.dart';
import '../../../services/firebase_community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import '../community/community_post.dart';
import '../community/community_post_detail_screen.dart';
import '../community/community_widgets.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final Future<void> profileInitialization;

  final List<_ProfileAvatarOption> avatarOptions = const [
    _ProfileAvatarOption(
      keyName: 'default_person',
      label: 'Mặc định',
      icon: Icons.person_rounded,
      color: AppColors.peach,
    ),
    _ProfileAvatarOption(
      keyName: 'cat',
      label: 'Mèo',
      icon: Icons.pets_rounded,
      color: AppColors.primarySoft,
    ),
    _ProfileAvatarOption(
      keyName: 'dog',
      label: 'Cún',
      icon: Icons.cruelty_free_rounded,
      color: AppColors.mint,
    ),
    _ProfileAvatarOption(
      keyName: 'rabbit',
      label: 'Thỏ',
      icon: Icons.emoji_nature_rounded,
      color: AppColors.lavender,
    ),
    _ProfileAvatarOption(
      keyName: 'bird',
      label: 'Chim',
      icon: Icons.flutter_dash_rounded,
      color: AppColors.sky,
    ),
    _ProfileAvatarOption(
      keyName: 'favorite',
      label: 'Yêu thích',
      icon: Icons.favorite_rounded,
      color: AppColors.peach,
    ),
    _ProfileAvatarOption(
      keyName: 'health',
      label: 'Sức khỏe',
      icon: Icons.health_and_safety_rounded,
      color: AppColors.sky,
    ),
  ];

  @override
  void initState() {
    super.initState();
    profileInitialization = CustomerProfileService.ensureCurrentProfile();
  }

  _ProfileAvatarOption _avatarFromKey(String key) {
    return avatarOptions.firstWhere(
      (option) => option.keyName == key,
      orElse: () => avatarOptions.first,
    );
  }

  Future<void> _showAvatarPicker(CustomerProfile profile) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn ảnh đại diện',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  itemCount: avatarOptions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    final option = avatarOptions[index];
                    final isSelected = option.keyName == profile.avatarIconKey;

                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () async {
                        Navigator.of(bottomSheetContext).pop();

                        await CustomerProfileService.updateAvatarIcon(
                          option.keyName,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? option.color : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : option.color,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.85,
                              ),
                              child: Icon(
                                option.icon,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfile(CustomerProfile profile) async {
    final fullNameController = TextEditingController(text: profile.fullName);
    final displayNameController = TextEditingController(
      text: profile.displayName,
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Chỉnh sửa thông tin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: displayNameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
            ],
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
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      try {
        await CustomerProfileService.updatePersonalInformation(
          fullName: fullNameController.text,
          displayName: displayNameController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin cá nhân.')),
        );
      } catch (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }

    fullNameController.dispose();
    displayNameController.dispose();
  }

  Future<void> _createPost(CustomerProfile profile) async {
    final result = await context.push<CommunityPost>('/community/create-post');

    if (result == null) return;

    final post = result.copyWith(
      authorId: profile.uid,
      likes: 0,
      likedBy: const [],
    );

    try {
      await FirebaseCommunityService.createPost(post);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đăng bài lên cộng đồng.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không đăng được bài: $error')));
    }
  }

  Future<void> _editPost(CommunityPost post) async {
    final result = await context.push<CommunityPost>(
      '/community/create-post',
      extra: post,
    );

    if (result == null) return;

    final updatedPost = result.copyWith(
      authorId: post.authorId,
      likes: post.likes,
      likedBy: post.likedBy,
      commentList: post.commentList,
    );

    try {
      await FirebaseCommunityService.updatePost(updatedPost);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật bài viết.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không sửa được bài viết: $error')),
      );
    }
  }

  Future<void> _deletePost(CommunityPost post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Xóa bài viết?'),
          content: const Text(
            'Bài viết sẽ bị xóa khỏi trang cá nhân và cộng đồng.',
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
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await FirebaseCommunityService.deletePost(post);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa bài viết.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không xóa được bài viết: $error')),
      );
    }
  }

  Future<void> _toggleLike(CommunityPost post, String userId) async {
    try {
      await FirebaseCommunityService.toggleLike(post: post, userId: userId);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể thả tim: $error')));
    }
  }

  Future<void> _toggleSave(CommunityPost post, String userId) async {
    try {
      final isSaved = await CustomerSavedPostService.toggleSavedPost(
        userId: userId,
        post: post,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Đã lưu bài viết.' : 'Đã bỏ lưu bài viết.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lưu được bài viết: $error')),
      );
    }
  }

  Future<void> _sharePost(CommunityPost post) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Chia sẻ bài viết PetHub',
          text:
              '''
${post.authorName} chia sẻ trên PetHub:

${post.content}

#PetHub #Community
''',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không chia sẻ được: $error')));
    }
  }

  Future<void> _openPostDetail(
    CommunityPost post,
    String userId,
    Set<int> savedPostIds,
  ) async {
    final wasLiked = post.likedBy.contains(userId);
    final wasSaved = savedPostIds.contains(post.id);

    final result = await context.push<PostDetailResult>(
      '/community/post-detail',
      extra: PostDetailArgs(post: post, isLiked: wasLiked, isSaved: wasSaved),
    );

    if (result == null) return;

    try {
      if (result.isLiked != wasLiked) {
        await FirebaseCommunityService.toggleLike(post: post, userId: userId);
      }

      if (result.isSaved != wasSaved) {
        await CustomerSavedPostService.setSavedPost(
          userId: userId,
          post: post,
          isSaved: result.isSaved,
        );
      }

      final updatedPost = result.post.copyWith(
        authorId: post.authorId,
        authorName: post.authorName,
        authorRole: post.authorRole,
        isAnonymous: post.isAnonymous,
        avatarIconKey: post.avatarIconKey,
        colorKey: post.colorKey,
        likes: post.likes,
        likedBy: post.likedBy,
        imageUrl: post.imageUrl,
        imagePublicId: post.imagePublicId,
      );

      await FirebaseCommunityService.updatePost(updatedPost);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không cập nhật bài viết: $error')),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
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
    );

    if (shouldLogout != true) return;

    try {
      await CustomerAuthService.logout();

      if (!mounted) return;

      context.go('/customer-auth');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không đăng xuất được: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: profileInitialization,
      builder: (context, initializationSnapshot) {
        if (initializationSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (initializationSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Không khởi tạo được hồ sơ:\n'
                '${initializationSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return StreamBuilder<CustomerProfile?>(
          stream: CustomerProfileService.watchCurrentProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = profileSnapshot.data;

            if (profile == null) {
              return const Center(
                child: Text('Không tìm thấy hồ sơ khách hàng.'),
              );
            }

            final avatar = _avatarFromKey(profile.avatarIconKey);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    profile: profile,
                    avatar: avatar,
                    onAvatarTap: () => _showAvatarPicker(profile),
                    onEditTap: () => _editProfile(profile),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _createPost(profile),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Đăng bài mới'),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const SectionTitle(title: 'Thông tin cá nhân'),
                  const SizedBox(height: 12),
                  _PersonalInformationCard(profile: profile),
                  const SizedBox(height: 26),
                  _ProfileCommunitySections(
                    profile: profile,
                    onLike: (post) => _toggleLike(post, profile.uid),
                    onSave: (post) => _toggleSave(post, profile.uid),
                    onShare: _sharePost,
                    onOpenDetail: (post, savedPostIds) =>
                        _openPostDetail(post, profile.uid, savedPostIds),
                    onEdit: _editPost,
                    onDelete: _deletePost,
                  ),
                  const SizedBox(height: 30),
                  const SectionTitle(title: 'Tài khoản'),
                  const SizedBox(height: 12),
                  _LogoutCard(onLogout: _logout),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileCommunitySections extends StatelessWidget {
  final CustomerProfile profile;
  final ValueChanged<CommunityPost> onLike;
  final ValueChanged<CommunityPost> onSave;
  final ValueChanged<CommunityPost> onShare;
  final void Function(CommunityPost post, Set<int> savedPostIds) onOpenDetail;
  final ValueChanged<CommunityPost> onEdit;
  final ValueChanged<CommunityPost> onDelete;

  const _ProfileCommunitySections({
    required this.profile,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<int>>(
      stream: CustomerSavedPostService.watchSavedPostIds(profile.uid),
      builder: (context, savedSnapshot) {
        final savedPostIds = savedSnapshot.data ?? <int>{};

        return StreamBuilder<List<CommunityPost>>(
          stream: FirebaseCommunityService.watchPosts(),
          builder: (context, postsSnapshot) {
            if (postsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (postsSnapshot.hasError) {
              return Text('Không tải được bài viết: ${postsSnapshot.error}');
            }

            final allPosts = postsSnapshot.data ?? [];

            final myPosts = allPosts
                .where((post) => post.authorId == profile.uid)
                .toList();

            final savedPosts = allPosts
                .where((post) => savedPostIds.contains(post.id))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfilePostSection(
                  title: 'Bài viết của tôi',
                  emptyText: 'Bạn chưa đăng bài viết nào.',
                  posts: myPosts,
                  savedPostIds: savedPostIds,
                  profile: profile,
                  allowManageOwnPost: true,
                  onLike: onLike,
                  onSave: onSave,
                  onShare: onShare,
                  onOpenDetail: onOpenDetail,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
                const SizedBox(height: 28),
                _ProfilePostSection(
                  title: 'Bài viết đã lưu',
                  emptyText: 'Bạn chưa lưu bài viết nào.',
                  posts: savedPosts,
                  savedPostIds: savedPostIds,
                  profile: profile,
                  allowManageOwnPost: false,
                  onLike: onLike,
                  onSave: onSave,
                  onShare: onShare,
                  onOpenDetail: onOpenDetail,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfilePostSection extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<CommunityPost> posts;
  final Set<int> savedPostIds;
  final CustomerProfile profile;
  final bool allowManageOwnPost;
  final ValueChanged<CommunityPost> onLike;
  final ValueChanged<CommunityPost> onSave;
  final ValueChanged<CommunityPost> onShare;
  final void Function(CommunityPost post, Set<int> savedPostIds) onOpenDetail;
  final ValueChanged<CommunityPost> onEdit;
  final ValueChanged<CommunityPost> onDelete;

  const _ProfilePostSection({
    required this.title,
    required this.emptyText,
    required this.posts,
    required this.savedPostIds,
    required this.profile,
    required this.allowManageOwnPost,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, actionText: '${posts.length} bài'),
        const SizedBox(height: 12),
        if (posts.isEmpty)
          SoftCard(
            color: Colors.white,
            child: Text(
              emptyText,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ListView.separated(
            itemCount: posts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];

              final isLiked = post.likedBy.contains(profile.uid);
              final isSaved = savedPostIds.contains(post.id);

              final canManage =
                  allowManageOwnPost && post.authorId == profile.uid;

              return CommunityPostCard(
                post: post,
                isLiked: isLiked,
                isSaved: isSaved,
                onLike: () => onLike(post),
                onSave: () => onSave(post),
                onShare: () => onShare(post),
                onOpenDetail: () => onOpenDetail(post, savedPostIds),
                canManage: canManage,
                onEdit: () => onEdit(post),
                onDelete: () => onDelete(post),
              );
            },
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final CustomerProfile profile;
  final _ProfileAvatarOption avatar;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditTap;

  const _ProfileHeader({
    required this.profile,
    required this.avatar,
    required this.onAvatarTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.peach, AppColors.cream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: avatar.color,
                  child: Icon(avatar.icon, size: 44, color: AppColors.textDark),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 21),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditTap,
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PersonalInformationCard extends StatelessWidget {
  final CustomerProfile profile;

  const _PersonalInformationCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.badge_rounded,
            label: 'Họ tên',
            value: profile.fullName,
          ),
          const Divider(height: 24),
          _InformationRow(
            icon: Icons.alternate_email_rounded,
            label: 'Tên hiển thị',
            value: profile.displayName,
          ),
          const Divider(height: 24),
          _InformationRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: profile.email,
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.primarySoft,
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? 'Chưa cập nhật' : value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onLogout,
      child: const Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFFFE2E2),
            child: Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Đăng xuất tài khoản',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 17,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarOption {
  final String keyName;
  final String label;
  final IconData icon;
  final Color color;

  const _ProfileAvatarOption({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.color,
  });
}
