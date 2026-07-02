import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../storage/community_post_storage.dart';
import '../../../storage/profile_storage.dart';
import '../../../widgets/section_title.dart';
import '../community/community_post.dart';
import '../community/community_widgets.dart';
import 'profile_models.dart';
import 'profile_widgets.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  String? avatarPath;
  String displayName = 'Trần Mộng Tuyền';
  bool isLoadingProfile = true;

  final List<CommunityPost> myPosts = [];
  final Set<int> likedPostIds = {};
  final Set<int> savedPostIds = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final savedPath = await ProfileStorage.loadAvatarPath();
    final savedName = await ProfileStorage.loadDisplayName();
    final savedPosts = await CommunityPostStorage.loadPosts();

    if (!mounted) return;

    setState(() {
      avatarPath = savedPath;
      displayName = savedName;
      myPosts
        ..clear()
        ..addAll(savedPosts);
      isLoadingProfile = false;
    });
  }

  Future<void> _changeAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Chọn ảnh từ điện thoại'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatarFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Gỡ ảnh đại diện'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeAvatar();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarFromGallery() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );

      if (pickedImage == null) return;

      final copiedPath = await _copyAvatarToAppFolder(pickedImage);

      await ProfileStorage.saveAvatarPath(copiedPath);

      if (!mounted) return;

      setState(() {
        avatarPath = copiedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật ảnh đại diện.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không đổi được ảnh đại diện: $error'),
        ),
      );
    }
  }

  Future<String> _copyAvatarToAppFolder(XFile pickedImage) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/profile_avatar');

    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    final originalPath = pickedImage.path;
    final fileName = originalPath.split(Platform.pathSeparator).last;

    final newPath =
        '${avatarDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final copiedFile = await File(originalPath).copy(newPath);

    return copiedFile.path;
  }

  Future<void> _removeAvatar() async {
    await ProfileStorage.clearAvatarPath();

    if (!mounted) return;

    setState(() {
      avatarPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gỡ ảnh đại diện.'),
      ),
    );
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: displayName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Chỉnh sửa tên'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị',
              hintText: 'Nhập tên của bạn',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    final newName = result.trim();

    if (newName.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên không được để trống.'),
        ),
      );
      return;
    }

    await ProfileStorage.saveDisplayName(newName);

    if (!mounted) return;

    setState(() {
      displayName = newName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật tên hiển thị.'),
      ),
    );
  }

  Future<void> _editPost(CommunityPost post) async {
    final result = await context.push<CommunityPost>(
      '/community/create-post',
      extra: post,
    );

    if (result == null) return;

    final index = myPosts.indexWhere((item) => item.id == result.id);

    if (index == -1) return;

    setState(() {
      myPosts[index] = result;
    });

    await CommunityPostStorage.savePosts(myPosts);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật bài viết.'),
      ),
    );
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
            'Bài viết sẽ bị xóa khỏi danh sách bài đã đăng của bạn.',
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

    setState(() {
      myPosts.removeWhere((item) => item.id == post.id);
      likedPostIds.remove(post.id);
      savedPostIds.remove(post.id);
    });

    await CommunityPostStorage.savePosts(myPosts);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa bài viết.'),
      ),
    );
  }

  void _toggleLike(int postId) {
    setState(() {
      if (likedPostIds.contains(postId)) {
        likedPostIds.remove(postId);
      } else {
        likedPostIds.add(postId);
      }
    });
  }

  void _toggleSave(int postId) {
    setState(() {
      if (savedPostIds.contains(postId)) {
        savedPostIds.remove(postId);
      } else {
        savedPostIds.add(postId);
      }
    });
  }

  Future<void> _sharePost(CommunityPost post) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'Chia sẻ bài viết PetHub',
        text: '''
${post.authorName} chia sẻ trên PetHub:

${post.content}

#PetHub #Community
''',
      ),
    );
  }

  Future<void> _openPostDetail(CommunityPost post) async {
    await context.push(
      '/community/post-detail',
      extra: post,
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title sẽ được làm ở bước sau.'),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProfile) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            displayName: displayName,
            avatarPath: avatarPath,
            onChangeAvatar: _changeAvatar,
            onEditName: _editDisplayName,
          ),

          const SizedBox(height: 22),

          const ProfileStatsRow(),

          const SizedBox(height: 26),

          const SectionTitle(
            title: 'Pet của tôi',
            actionText: 'Thêm pet',
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myPets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return PetProfileCard(
                  pet: myPets[index],
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          SectionTitle(
            title: 'Bài viết đã đăng',
            actionText: '${myPosts.length} bài',
          ),

          const SizedBox(height: 12),

          if (myPosts.isEmpty)
            const Text(
              'Bạn chưa đăng bài nào trong cộng đồng.',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ListView.separated(
              itemCount: myPosts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = myPosts[index];

                return CommunityPostCard(
                  post: post,
                  isLiked: likedPostIds.contains(post.id),
                  isSaved: savedPostIds.contains(post.id),
                  onLike: () => _toggleLike(post.id),
                  onSave: () => _toggleSave(post.id),
                  onShare: () => _sharePost(post),
                  onOpenDetail: () => _openPostDetail(post),
                  canManage: true,
                  onEdit: () => _editPost(post),
                  onDelete: () => _deletePost(post),
                );
              },
            ),

          const SizedBox(height: 26),

          const SectionTitle(title: 'Tài khoản của tôi'),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: profileMenus.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = profileMenus[index];

              return ProfileMenuTile(
                item: item,
                onTap: () => _showComingSoon(context, item.title),
              );
            },
          ),

          const SizedBox(height: 18),

          LogoutCard(
            onLogout: () => _logout(context),
          ),
        ],
      ),
    );
  }
}