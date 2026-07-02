import 'dart:io';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'community_post.dart';

class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            AppColors.lavender,
            AppColors.peach,
            AppColors.cream,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cộng đồng PetHub',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Chia sẻ khoảnh khắc, hỏi đáp chăm sóc và kết nối với những người yêu pet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
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

class CommunityCategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CommunityCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.peach,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CreatePostCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreatePostCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.peach,
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bạn muốn chia sẻ điều gì về bé pet hôm nay?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Icon(
            Icons.edit_rounded,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onOpenDetail;

  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onOpenDetail,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalLikes = isLiked ? post.likes + 1 : post.likes;

    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PostAuthorAvatar(post: post),

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
                    const SizedBox(height: 3),
                    Text(
                      '${post.authorRole} • ${post.timeAgo}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onSave,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.textSoft,
                ),
              ),

              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSoft,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    }

                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text('Xóa bài viết'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          _PostMedia(post: post),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _PostAction(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '$totalLikes',
                active: isLiked,
                onTap: onLike,
              ),
              _PostAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.totalComments}',
                active: false,
                onTap: onOpenDetail,
              ),
              _PostAction(
                icon: Icons.share_rounded,
                label: 'Chia sẻ',
                active: false,
                onTap: onShare,
              ),
              _PostAction(
                icon: Icons.open_in_full_rounded,
                label: 'Chi tiết',
                active: false,
                onTap: onOpenDetail,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAuthorAvatar extends StatelessWidget {
  final CommunityPost post;

  const _PostAuthorAvatar({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final avatarPath = post.authorAvatarPath;
    final hasAvatar = avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync();

    if (hasAvatar) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: post.color,
        backgroundImage: FileImage(File(avatarPath)),
      );
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: post.color,
      child: Icon(
        post.petIcon,
        color: AppColors.textDark,
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final CommunityPost post;

  const _PostMedia({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imagePath != null &&
        post.imagePath!.isNotEmpty &&
        File(post.imagePath!).existsSync();

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(post.imagePath!),
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: post.color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          post.petIcon,
          size: 74,
          color: AppColors.textDark.withOpacity(0.72),
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: active ? AppColors.primary : AppColors.textSoft,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primary : AppColors.textSoft,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}