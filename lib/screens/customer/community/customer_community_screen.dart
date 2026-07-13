import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/customer_saved_post_service.dart';
import '../../../services/firebase_community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import 'community_post.dart';
import 'community_post_detail_screen.dart';
import 'community_widgets.dart';

class CustomerCommunityScreen extends StatefulWidget {
  const CustomerCommunityScreen({super.key});

  @override
  State<CustomerCommunityScreen> createState() =>
      _CustomerCommunityScreenState();
}

class _CustomerCommunityScreenState extends State<CustomerCommunityScreen> {
  String selectedCategory = 'Tất cả';
  String keyword = '';

  String currentUserId = '';
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      setState(() {
        currentUserId = '';
        isLoadingUser = false;
      });

      return;
    }

    setState(() {
      currentUserId = user.uid;
      isLoadingUser = false;
    });
  }

  bool _isUserPost(CommunityPost post) {
    return post.authorId == currentUserId;
  }

  List<CommunityPost> _filterPosts(List<CommunityPost> posts) {
    return posts.where((post) {
      final matchCategory =
          selectedCategory == 'Tất cả' || post.category == selectedCategory;

      final lowerKeyword = keyword.toLowerCase();

      final matchKeyword =
          post.authorName.toLowerCase().contains(lowerKeyword) ||
          post.content.toLowerCase().contains(lowerKeyword) ||
          post.category.toLowerCase().contains(lowerKeyword);

      return matchCategory && matchKeyword;
    }).toList();
  }

  Stream<Set<int>> _watchSavedPostIds() {
    if (currentUserId.isEmpty) {
      return Stream.value(<int>{});
    }

    return CustomerSavedPostService.watchSavedPostIds(currentUserId);
  }

  Future<void> _openCreatePost() async {
    if (currentUserId.isEmpty) {
      context.go('/customer-auth');

      return;
    }

    final result = await context.push<CommunityPost>('/community/create-post');

    if (result == null) return;

    final post = result.copyWith(
      authorId: currentUserId,
      likes: 0,
      likedBy: const [],
    );

    try {
      await FirebaseCommunityService.createPost(post);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã đăng bài.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không đăng được bài: $error')));
    }
  }

  Future<void> _editPost(CommunityPost post) async {
    if (!_isUserPost(post)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ có thể chỉnh sửa bài viết của bạn.')),
      );

      return;
    }

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không sửa được bài: $error')));
    }
  }

  Future<void> _deletePost(CommunityPost post) async {
    if (!_isUserPost(post)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ có thể xóa bài viết của bạn.')),
      );

      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Xóa bài viết?'),
          content: const Text('Bài viết sẽ bị xóa khỏi cộng đồng.'),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không xóa được bài: $error')));
    }
  }

  Future<void> _toggleLike(CommunityPost post) async {
    if (currentUserId.isEmpty) {
      context.go('/customer-auth');

      return;
    }

    try {
      await FirebaseCommunityService.toggleLike(
        post: post,
        userId: currentUserId,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể thả tim: $error')));
    }
  }

  Future<void> _toggleSave(CommunityPost post) async {
    if (currentUserId.isEmpty) {
      context.go('/customer-auth');

      return;
    }

    try {
      final isSaved = await CustomerSavedPostService.toggleSavedPost(
        userId: currentUserId,
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
    Set<int> savedPostIds,
  ) async {
    final wasLiked = post.likedBy.contains(currentUserId);
    final wasSaved = savedPostIds.contains(post.id);

    final result = await context.push<PostDetailResult>(
      '/community/post-detail',
      extra: PostDetailArgs(post: post, isLiked: wasLiked, isSaved: wasSaved),
    );

    if (result == null) return;

    try {
      if (currentUserId.isNotEmpty && result.isLiked != wasLiked) {
        await FirebaseCommunityService.toggleLike(
          post: post,
          userId: currentUserId,
        );
      }

      if (currentUserId.isNotEmpty && result.isSaved != wasSaved) {
        await CustomerSavedPostService.setSavedPost(
          userId: currentUserId,
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<Set<int>>(
      stream: _watchSavedPostIds(),
      builder: (context, savedSnapshot) {
        final savedPostIds = savedSnapshot.data ?? <int>{};

        return StreamBuilder<List<CommunityPost>>(
          stream: FirebaseCommunityService.watchPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Không tải được cộng đồng:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final posts = snapshot.data ?? [];
            final filteredPosts = _filterPosts(posts);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommunityHeader(),

                  const SizedBox(height: 22),

                  CreatePostCard(onTap: _openCreatePost),

                  const SizedBox(height: 22),

                  TextField(
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm bài viết, tag, nội dung...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle(title: 'Tag cộng đồng'),

                  const SizedBox(height: 12),

                  CommunityCategorySelector(
                    categories: communityCategories,
                    selectedCategory: selectedCategory,
                    onSelected: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SectionTitle(
                    title: 'Bài viết mới',
                    actionText: '${filteredPosts.length} bài',
                  ),

                  const SizedBox(height: 12),

                  if (filteredPosts.isEmpty)
                    const Text(
                      'Chưa có bài viết nào.',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: filteredPosts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];

                        final isLiked = post.likedBy.contains(currentUserId);

                        final isSaved = savedPostIds.contains(post.id);

                        return CommunityPostCard(
                          post: post,
                          isLiked: isLiked,
                          isSaved: isSaved,
                          onLike: () => _toggleLike(post),
                          onSave: () => _toggleSave(post),
                          onShare: () => _sharePost(post),
                          onOpenDetail: () =>
                              _openPostDetail(post, savedPostIds),
                          canManage: _isUserPost(post),
                          onEdit: () => _editPost(post),
                          onDelete: () => _deletePost(post),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
