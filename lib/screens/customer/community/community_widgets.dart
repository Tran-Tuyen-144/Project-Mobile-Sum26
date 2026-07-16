import 'package:flutter/material.dart';

import '../../../services/cloudinary_upload_service.dart';
import '../../../theme/app_colors.dart';
import 'community_post.dart';

Future<void> showCommunityImageViewer(
    BuildContext context, {
      required List<String> imageUrls,
      required int initialIndex,
    }) async {
  if (imageUrls.isEmpty) {
    return;
  }

  final safeInitialIndex = initialIndex
      .clamp(0, imageUrls.length - 1)
      .toInt();

  await Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) {
        return _CommunityFullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: safeInitialIndex,
        );
      },
    ),
  );
}

class _CommunityFullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _CommunityFullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_CommunityFullScreenImageViewer> createState() =>
      _CommunityFullScreenImageViewerState();
}

class _CommunityFullScreenImageViewerState
    extends State<_CommunityFullScreenImageViewer> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        title: Text(
          '${currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đóng',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl =
          CloudinaryUploadService.optimizedImageUrl(
            widget.imageUrls[index],
          );

          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin: const EdgeInsets.all(100),
            child: Center(
              child: SizedBox.expand(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                      ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  },
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Không tải được ảnh.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.peach,
          width: 1.2,
        ),
        gradient: const LinearGradient(
          colors: [
            AppColors.primarySoft,
            AppColors.peach,
            Colors.white,
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
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.peach,
              ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chia sẻ khoảnh khắc, hỏi đáp chăm sóc '
                      'và kết nối với những người yêu pet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: AppColors.textSoft,
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
        separatorBuilder: (_, _) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              onSelected(category);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.peach,
                  width: 1.2,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textDark,
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
    return _CommunityCard(
      onTap: onTap,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.peach,
            child: Icon(
              Icons.face_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bạn muốn chia sẻ điều gì về '
                  'bé pet hôm nay?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
            ),
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
    final totalLikes = post.likes;

    return _CommunityCard(
      onTap: onOpenDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PostAvatar(post: post),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${post.authorRole} • '
                          '${post.displayTimeLabel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isSaved
                    ? 'Bỏ lưu bài viết'
                    : 'Lưu bài viết',
                onPressed: onSave,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? AppColors.primary
                      : AppColors.textSoft,
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSoft,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(
                      color: AppColors.peach,
                    ),
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
                            Text(
                              'Xóa bài viết',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),
          if (post.hasTag) ...[
            const SizedBox(height: 12),
            _TagChip(post: post),
          ],
          const SizedBox(height: 14),
          Text(
            post.content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: AppColors.textDark,
            ),
          ),
          if (post.hasImage) ...[
            const SizedBox(height: 14),
            _PostImage(post: post),
          ],
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
            ],
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CommunityCard({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: AppColors.peach,
          width: 1.4,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _PostAvatar extends StatelessWidget {
  final CommunityPost post;

  const _PostAvatar({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.peach,
      child: Icon(
        post.petIcon,
        color: AppColors.primary,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.primarySoft,
        ),
      ),
      child: Text(
        '#${post.category}',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PostImage extends StatefulWidget {
  final CommunityPost post;

  const _PostImage({
    required this.post,
  });

  @override
  State<_PostImage> createState() =>
      _PostImageState();
}

class _PostImageState extends State<_PostImage> {
  int currentIndex = 0;

  @override
  void didUpdateWidget(
      covariant _PostImage oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    final imageCount =
        widget.post.allImageUrls.length;

    if (imageCount == 0) {
      currentIndex = 0;
      return;
    }

    if (currentIndex >= imageCount) {
      currentIndex = imageCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        widget.post.allImageUrls;

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl =
                CloudinaryUploadService
                    .optimizedImageUrl(
                  imageUrls[index],
                );

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showCommunityImageViewer(
                      context,
                      imageUrls: imageUrls,
                      initialIndex: index,
                    );
                  },
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                        ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: AppColors.peach,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        color: AppColors.peach,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textSoft,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Không tải được ảnh.',
                              style: TextStyle(
                                color: AppColors.textSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: IgnorePointer(
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
            if (imageUrls.length > 1)
              Positioned(
                top: 10,
                right: 10,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.92,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${currentIndex + 1}/${imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
      style: OutlinedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: active
            ? AppColors.peach
            : Colors.white,
        foregroundColor: active
            ? AppColors.primary
            : AppColors.textSoft,
        side: BorderSide(
          color: active
              ? AppColors.primary
              : AppColors.peach,
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: Icon(
        icon,
        size: 18,
        color: active
            ? AppColors.primary
            : AppColors.textSoft,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active
              ? AppColors.primary
              : AppColors.textSoft,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}