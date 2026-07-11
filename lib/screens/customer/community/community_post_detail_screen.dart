import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'community_post.dart';

class PostDetailArgs {
  final CommunityPost post;
  final bool isLiked;
  final bool isSaved;

  const PostDetailArgs({
    required this.post,
    required this.isLiked,
    required this.isSaved,
  });

  factory PostDetailArgs.fallback() {
    return PostDetailArgs(
      post: communityPosts.first,
      isLiked: false,
      isSaved: false,
    );
  }
}

class PostDetailResult {
  final CommunityPost post;
  final bool isLiked;
  final bool isSaved;

  const PostDetailResult({
    required this.post,
    required this.isLiked,
    required this.isSaved,
  });
}

class CommunityPostDetailScreen extends StatefulWidget {
  final PostDetailArgs args;

  const CommunityPostDetailScreen({
    super.key,
    required this.args,
  });

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  late CommunityPost post;
  late bool isLiked;
  late bool originalIsLiked;
  late bool isSaved;

  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    post = widget.args.post;
    isLiked = widget.args.isLiked;
    originalIsLiked = widget.args.isLiked;
    isSaved = widget.args.isSaved;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  int get displayLikes {
    if (isLiked == originalIsLiked) {
      return post.likes;
    }

    if (isLiked) {
      return post.likes + 1;
    }
    return post.likes > 0 ? post.likes - 1 : 0;
  }

  void _close() {
    context.pop(
      PostDetailResult(
        post: post,
        isLiked: isLiked,
        isSaved: isSaved,
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  void _sendComment() {
    final text = commentController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhập bình luận trước nha.'),
        ),
      );
      return;
    }

    final comment = PostComment(
      id: DateTime.now().millisecondsSinceEpoch,
      authorName: 'Ẩn danh PetHub',
      content: text,
      timeAgo: 'Vừa xong',
    );

    setState(() {
      post = post.copyWith(
        commentList: [
          ...post.commentList,
          comment,
        ],
      );
      commentController.clear();
    });
  }

  Future<void> _sharePost() async {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('Chi tiết bài viết'),
          actions: [
            IconButton(
              onPressed: _toggleSave,
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSaved ? AppColors.primary : null,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                children: [
                  _AuthorBlock(post: post),

                  if (post.hasTag) ...[
                    const SizedBox(height: 14),
                    _TagChip(post: post),
                  ],

                  const SizedBox(height: 16),

                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: AppColors.textDark,
                    ),
                  ),

                  Row(
                    children: [
                      _DetailActionButton(
                        icon: isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: '$displayLikes',
                        active: isLiked,
                        onTap: _toggleLike,
                      ),
                      const SizedBox(width: 12),
                      _DetailActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: '${post.totalComments}',
                        active: false,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _DetailActionButton(
                        icon: Icons.share_rounded,
                        label: 'Chia sẻ',
                        active: false,
                        onTap: _sharePost,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tất cả bình luận',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  if (post.commentList.isEmpty)
                    const SoftCard(
                      color: Colors.white,
                      child: Text(
                        'Chưa có bình luận nào. Hãy là người đầu tiên bình luận.',
                        style: TextStyle(
                          color: AppColors.textSoft,
                        ),
                      ),
                    )
                  else
                    ...post.commentList.map(
                          (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CommentTile(comment: comment),
                      ),
                    ),
                ],
              ),
            ),

            _CommentInputBar(
              controller: commentController,
              onSend: _sendComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorBlock extends StatelessWidget {
  final CommunityPost post;

  const _AuthorBlock({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: post.color,
            child: Icon(
              post.petIcon,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.authorRole} • ${post.timeAgo}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final CommunityPost post;

  const _TagChip({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: post.color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          '#${post.category}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: active ? AppColors.primary : AppColors.textSoft,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textSoft,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostComment comment;

  const _CommentTile({
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.peach,
            child: Icon(
              Icons.face_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${comment.authorName} • ${comment.timeAgo}',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _CommentInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEFE1D3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Viết bình luận ẩn danh...',
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}