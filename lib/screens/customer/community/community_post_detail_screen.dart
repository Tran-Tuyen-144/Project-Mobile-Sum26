import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/customer_profile.dart';
import '../../../services/cloudinary_upload_service.dart';
import '../../../services/customer_profile_service.dart';
import '../../../services/firebase_community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'community_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class _CommunityPostDetailScreenState
    extends State<CommunityPostDetailScreen> {
  late CommunityPost post;
  late bool isLiked;
  late bool isSaved;

  final TextEditingController commentController = TextEditingController();

  CustomerProfile? currentProfile;

  bool isLoadingProfile = true;
  bool isSendingComment = false;
  bool commentAsAnonymous = true;
  bool isUpdatingLike = false;

  StreamSubscription<CommunityPost?>? _postSubscription;

  @override
  void initState() {
    super.initState();

    post = widget.args.post;
    isLiked = widget.args.isLiked;
    isSaved = widget.args.isSaved;

    _loadCurrentProfile();
    _listenToPost();
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    commentController.dispose();
    super.dispose();
  }

  void _listenToPost() {
    _postSubscription =
        FirebaseCommunityService.watchPost(post.id).listen(
              (latestPost) {
            if (!mounted || latestPost == null) {
              return;
            }

            final userId = currentProfile?.uid ?? '';

            setState(() {
              post = latestPost;

              if (userId.isNotEmpty) {
                isLiked = latestPost.likedBy.contains(userId);
              }
            });
          },
          onError: (Object error) {
            if (!mounted) {
              return;
            }

            _showMessage(
              'Không cập nhật được bài viết: $error',
            );
          },
        );
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await CustomerProfileService.getCurrentProfile();

      if (!mounted) return;

      setState(() {
        currentProfile = profile;
        isLiked = post.likedBy.contains(profile.uid);
        isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        currentProfile = null;
        isLoadingProfile = false;
      });
    }
  }

  int get displayLikes => post.likes;

  String _publicName(CustomerProfile profile) {
    final displayName = profile.displayName.trim();

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final fullName = profile.fullName.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return 'Bạn PetHub';
  }

  String _anonymousName(CustomerProfile profile) {
    final name = profile.anonymousName.trim();

    return name.isEmpty ? 'Ẩn danh PetHub' : name;
  }

  String _publicAvatarIconKey(CustomerProfile profile) {
    final iconKey = profile.avatarIconKey.trim();

    return iconKey.isEmpty ? 'default_person' : iconKey;
  }

  String _anonymousAvatarIconKey(CustomerProfile profile) {
    final iconKey = profile.anonymousAvatarIconKey.trim();

    return iconKey.isEmpty ? 'anonymous' : iconKey;
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

  Future<void> _toggleLike() async {
    final profile = currentProfile;

    if (profile == null) {
      _showMessage('Không tìm thấy hồ sơ người dùng.');
      return;
    }

    if (isUpdatingLike) {
      return;
    }

    final userId = profile.uid;

    final shouldLike = !post.likedBy.contains(userId);

    setState(() {
      isUpdatingLike = true;
    });

    try {
      await FirebaseCommunityService.toggleLike(
        post: post,
        userId: userId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLiked = shouldLike;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Không cập nhật được lượt thích: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingLike = false;
        });
      }
    }
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  Future<void> _sendComment() async {
    final profile = currentProfile;
    final text = commentController.text.trim();

    if (profile == null) {
      _showMessage('Không tìm thấy hồ sơ người dùng.');
      return;
    }

    if (text.isEmpty) {
      _showMessage('Nhập bình luận trước nha.');
      return;
    }

    if (isSendingComment) {
      return;
    }

    setState(() {
      isSendingComment = true;
    });

    final avatarIconKey = commentAsAnonymous
        ? _anonymousAvatarIconKey(profile)
        : _publicAvatarIconKey(profile);

    final comment = PostComment(
      id: DateTime.now().millisecondsSinceEpoch,
      authorId: profile.uid,
      authorName: commentAsAnonymous
          ? _anonymousName(profile)
          : _publicName(profile),
      isAnonymous: commentAsAnonymous,
      avatarIconKey: avatarIconKey,
      colorKey: CommunityPost.colorKeyFromIconKey(avatarIconKey),
      content: text,
      timeAgo: 'Vừa xong',
      createdAt: DateTime.now(),
    );

    final oldPost = post;

    setState(() {
      post = post.copyWith(
        commentList: [
          ...post.commentList,
          comment,
        ],
      );

      commentController.clear();
    });

    try {
      await FirebaseCommunityService.addComment(
        postId: post.id,
        comment: comment,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        post = oldPost;
      });

      if (error is FirebaseException &&
          error.code == 'unavailable') {
        _showMessage(
          'Không kết nối được Firestore. '
              'Kiểm tra mạng rồi thử lại nha.',
        );
      } else {
        _showMessage(
          'Không gửi được bình luận: $error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSendingComment = false;
        });
      }
    }
  }

  Future<void> _editComment(PostComment comment) async {
    final profile = currentProfile;

    if (profile == null || comment.authorId != profile.uid) {
      _showMessage('Bạn chỉ có thể sửa bình luận của mình.');
      return;
    }

    var editedText = comment.content;

    final result = await showDialog<String>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Sửa bình luận'),
          content: SizedBox(
            width: MediaQuery.sizeOf(dialogContext).width,
            child: TextFormField(
              initialValue: comment.content,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (value) {
                editedText = value;
              },
              decoration: InputDecoration(
                hintText: 'Nhập nội dung bình luận mới...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
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
                final newText = editedText.trim();

                if (newText.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bình luận không được để trống.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(newText);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final newContent = result.trim();

    if (newContent.isEmpty) {
      _showMessage('Bình luận không được để trống.');
      return;
    }

    if (newContent == comment.content) {
      return;
    }

    final oldPost = post;

    final updatedComment = PostComment(
      id: comment.id,
      authorId: comment.authorId,
      authorName: comment.authorName,
      isAnonymous: comment.isAnonymous,
      avatarIconKey: comment.avatarIconKey,
      colorKey: comment.colorKey,
      content: newContent,
      timeAgo: 'Vừa chỉnh sửa',
      createdAt: comment.createdAt,
    );

    setState(() {
      post = post.copyWith(
        commentList: post.commentList.map((item) {
          if (item.id == comment.id) {
            return updatedComment;
          }

          return item;
        }).toList(),
      );
    });

    try {
      await FirebaseCommunityService.updateComment(
        postId: post.id,
        comment: updatedComment,
      );

      if (!mounted) return;

      _showMessage('Đã sửa bình luận.');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        post = oldPost;
      });

      _showMessage('Không sửa được bình luận: $error');
    }
  }

  Future<void> _deleteComment(PostComment comment) async {
    final profile = currentProfile;

    if (profile == null || comment.authorId != profile.uid) {
      _showMessage('Bạn chỉ có thể xóa bình luận của mình.');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Xóa bình luận?'),
          content: const Text(
            'Bình luận này sẽ bị xóa khỏi bài viết.',
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

    if (shouldDelete != true) {
      return;
    }

    final oldPost = post;

    setState(() {
      post = post.copyWith(
        commentList: post.commentList
            .where((item) => item.id != comment.id)
            .toList(),
      );
    });

    try {
      await FirebaseCommunityService.deleteComment(
        postId: post.id,
        commentId: comment.id,
      );

      if (!mounted) return;

      _showMessage('Đã xóa bình luận.');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        post = oldPost;
      });

      _showMessage('Không xóa được bình luận: $error');
    }
  }

  Future<void> _sharePost() async {
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

      _showMessage('Không chia sẻ được: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = currentProfile?.uid ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _close();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
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
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            20,
          ),
          children: [
            _AuthorBlock(
              post: post,
            ),

            if (post.hasTag) ...[
              const SizedBox(height: 14),
              _TagChip(
                post: post,
              ),
            ],

            const SizedBox(height: 16),

            Text(
              post.content,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),

            if (post.hasImage) ...[
              const SizedBox(height: 16),
              _PostDetailImage(
                post: post,
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                _DetailActionButton(
                  icon: isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: isUpdatingLike
                      ? '...'
                      : '$displayLikes',
                  active: isLiked,
                  onTap: isUpdatingLike
                      ? () {}
                      : _toggleLike,
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            if (post.commentList.isEmpty)
              const SoftCard(
                color: Colors.white,
                child: Text(
                  'Chưa có bình luận nào. '
                      'Hãy là người đầu tiên bình luận.',
                  style: TextStyle(
                    color: AppColors.textSoft,
                  ),
                ),
              )
            else
              ...post.commentList.map((comment) {
                final canManage =
                    currentUserId.isNotEmpty &&
                        comment.authorId == currentUserId;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _CommentTile(
                    comment: comment,
                    canManage: canManage,
                    onEdit: () {
                      _editComment(comment);
                    },
                    onDelete: () {
                      _deleteComment(comment);
                    },
                  ),
                );
              }),
          ],
        ),
        bottomNavigationBar: _CommentInputBar(
          controller: commentController,
          isLoadingProfile: isLoadingProfile,
          isSending: isSendingComment,
          commentAsAnonymous: commentAsAnonymous,
          onToggleAnonymous: () {
            setState(() {
              commentAsAnonymous = !commentAsAnonymous;
            });
          },
          onSend: _sendComment,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.authorRole} • ${post.displayTimeAgo}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium,
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
          color: post.color.withValues(
            alpha: 0.85,
          ),
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

class _PostDetailImage extends StatelessWidget {
  final CommunityPost post;

  const _PostDetailImage({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.imageUrl ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          CloudinaryUploadService.optimizedImageUrl(
            imageUrl,
          ),
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
              color: AppColors.cream,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return Container(
              color: AppColors.cream,
              alignment: Alignment.center,
              child: const Text(
                'Không tải được ảnh.',
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
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
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostComment comment;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: comment.color,
            child: Icon(
              comment.petIcon,
              size: 18,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${comment.authorName} • '
                            '${comment.displayTimeAgo}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (canManage)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textSoft,
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
                                  ),
                                  SizedBox(width: 8),
                                  Text('Sửa bình luận'),
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
                                  SizedBox(width: 8),
                                  Text(
                                    'Xóa bình luận',
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
  final bool isLoadingProfile;
  final bool isSending;
  final bool commentAsAnonymous;
  final VoidCallback onToggleAnonymous;
  final VoidCallback onSend;

  const _CommentInputBar({
    required this.controller,
    required this.isLoadingProfile,
    required this.isSending,
    required this.commentAsAnonymous,
    required this.onToggleAnonymous,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoadingProfile || isSending;

    return Material(
      color: AppColors.cream,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            10,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: commentAsAnonymous
                    ? 'Đổi sang công khai'
                    : 'Đổi sang ẩn danh',
                onPressed: disabled
                    ? null
                    : onToggleAnonymous,
                icon: Icon(
                  commentAsAnonymous
                      ? Icons.face_rounded
                      : Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !disabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: commentAsAnonymous
                        ? 'Viết bình luận ẩn danh...'
                        : 'Viết bình luận công khai...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: disabled ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}