import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import 'community_post.dart';
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

  List<CommunityPost> get filteredPosts {
    return communityPosts.where((post) {
      final matchCategory =
          selectedCategory == 'Tất cả' || post.category == selectedCategory;

      final matchKeyword =
          post.authorName.toLowerCase().contains(keyword.toLowerCase()) ||
              post.content.toLowerCase().contains(keyword.toLowerCase());

      return matchCategory && matchKeyword;
    }).toList();
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

  void _openPostDetail(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return CommunityPostDetailSheet(post: post);
      },
    );
  }

  void _showCreatePostMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Màn đăng bài mình sẽ làm ở bước sau nha.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommunityHeader(),

          const SizedBox(height: 22),

          CreatePostCard(
            onTap: _showCreatePostMessage,
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
            actionText: '${filteredPosts.length} bài',
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
                onOpenDetail: () => _openPostDetail(post),
              );
            },
          ),
        ],
      ),
    );
  }
}