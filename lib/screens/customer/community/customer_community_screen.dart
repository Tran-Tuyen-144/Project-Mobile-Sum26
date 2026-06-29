import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../storage/community_post_storage.dart';
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

  final Set<int> likedPostIds = {};
  final Set<int> savedPostIds = {};

  final List<CommunityPost> userPosts = [];
  final Map<int, CommunityPost> editedPosts = {};

  bool isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    final savedPosts = await CommunityPostStorage.loadPosts();

    if (!mounted) return;

    setState(() {
      userPosts
        ..clear()
        ..addAll(savedPosts);

      isLoadingPosts = false;
    });
  }

  Future<void> _saveUserPosts() async {
    await CommunityPostStorage.savePosts(userPosts);
  }

  List<CommunityPost> get allPosts {
    final staticPosts = communityPosts.map((post) {
      return editedPosts[post.id] ?? post;
    }).toList();

    return [
      ...userPosts,
      ...staticPosts,
    ];
  }

  List<CommunityPost> get filteredPosts {
    return allPosts.where((post) {
      final matchCategory =
          selectedCategory == 'Tất cả' || post.category == selectedCategory;

      final matchKeyword =
          post.authorName.toLowerCase().contains(keyword.toLowerCase()) ||
              post.content.toLowerCase().contains(keyword.toLowerCase());

      return matchCategory && matchKeyword;
    }).toList();
  }

  Future<void> _replacePost(CommunityPost updatedPost) async {
    final userIndex = userPosts.indexWhere((post) => post.id == updatedPost.id);

    setState(() {
      if (userIndex != -1) {
        userPosts[userIndex] = updatedPost;
      } else {
        editedPosts[updatedPost.id] = updatedPost;
      }
    });

    if (userIndex != -1) {
      await _saveUserPosts();
    }
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
    try {
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
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không chia sẻ được: $error'),
        ),
      );
    }
  }

  Future<void> _openPostDetail(CommunityPost post) async {
    final result = await context.push<PostDetailResult>(
      '/community/post-detail',
      extra: PostDetailArgs(
        post: post,
        isLiked: likedPostIds.contains(post.id),
        isSaved: savedPostIds.contains(post.id),
      ),
    );

    if (result == null) return;

    await _replacePost(result.post);

    setState(() {
      if (result.isLiked) {
        likedPostIds.add(result.post.id);
      } else {
        likedPostIds.remove(result.post.id);
      }

      if (result.isSaved) {
        savedPostIds.add(result.post.id);
      } else {
        savedPostIds.remove(result.post.id);
      }
    });
  }

  Future<void> _openCreatePost() async {
    final result = await context.push<CommunityPost>('/community/create-post');

    if (result == null) return;

    setState(() {
      userPosts.insert(0, result);
    });

    await _saveUserPosts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đăng và lưu bài viết vào máy.'),
      ),
    );
  }

  Future<void> _clearUserPosts() async {
    if (userPosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có bài viết tự đăng để xóa.'),
        ),
      );
      return;
    }

    setState(() {
      userPosts.clear();
    });

    await CommunityPostStorage.clearPosts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa các bài viết tự đăng trong bộ nhớ local.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPosts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommunityHeader(),
          const SizedBox(height: 22),
          CreatePostCard(
            onTap: _openCreatePost,
          ),
          const SizedBox(height: 22),
          TextField(
            onChanged: (value) {
              setState(() {
                keyword = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Tìm bài viết, chủ đề, cộng đồng...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Chủ đề cộng đồng'),
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
            actionText:
            userPosts.isEmpty ? '${filteredPosts.length} bài' : 'Xóa bài local',
            onActionTap: userPosts.isEmpty ? null : _clearUserPosts,
          ),
          const SizedBox(height: 12),
          ListView.separated(
            itemCount: filteredPosts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = filteredPosts[index];

              return CommunityPostCard(
                post: post,
                isLiked: likedPostIds.contains(post.id),
                isSaved: savedPostIds.contains(post.id),
                onLike: () => _toggleLike(post.id),
                onSave: () => _toggleSave(post.id),
                onShare: () => _sharePost(post),
                onOpenDetail: () => _openPostDetail(post),
              );
            },
          ),
        ],
      ),
    );
  }
}