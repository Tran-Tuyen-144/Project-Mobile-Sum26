import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/customer_profile.dart';
import '../../../services/cloudinary_upload_service.dart';
import '../../../services/customer_profile_service.dart';
import '../../../services/customer_saved_post_service.dart';
import '../../../services/firebase_community_comment_service.dart';
import '../../../services/firebase_community_service.dart';
import '../../../theme/app_colors.dart';
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

class _CommunityPostDetailScreenState
    extends State<CommunityPostDetailScreen> {
  late CommunityPost post;
  late bool isLiked;
  late bool isSaved;

  final TextEditingController commentController =
  TextEditingController();

  CustomerProfile? currentProfile;

  bool isLoadingProfile = true;
  bool isLoadingComments = true;
  bool isSendingComment = false;
  bool commentAsAnonymous = true;
  bool isUpdatingLike = false;
  bool isUpdatingSave = false;

  bool _allowPop = false;
  bool _isHandlingDeletedPost = false;

  StreamSubscription<CommunityPost?>? _postSubscription;
  StreamSubscription<List<PostComment>>? _commentSubscription;

  @override
  void initState() {
    super.initState();

    post = widget.args.post;
    isLiked = widget.args.isLiked;
    isSaved = widget.args.isSaved;

    _loadCurrentProfile();
    _listenToPost();
    _listenToComments();
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    _commentSubscription?.cancel();
    commentController.dispose();
    super.dispose();
  }

  void _listenToPost() {
    _postSubscription =
        FirebaseCommunityService.watchPost(post.id).listen(
              (latestPost) {
            if (!mounted) {
              return;
            }

            if (latestPost == null) {
              unawaited(_handleDeletedPost());
              return;
            }

            final userId = currentProfile?.uid ?? '';
            final currentComments = post.commentList;

            final currentCommentCount = isLoadingComments
                ? latestPost.commentCount
                : currentComments.length;

            setState(() {
              post = latestPost.copyWith(
                commentList: currentComments,
                commentCount: currentCommentCount,
              );

              if (userId.isNotEmpty) {
                isLiked = latestPost.likedBy.contains(userId);
              }
            });
          },
          onError: (Object error) {
            if (!mounted || _isHandlingDeletedPost) {
              return;
            }

            _showMessage(
              'Không cập nhật được bài viết: $error',
            );
          },
        );
  }

  void _listenToComments() {
    _commentSubscription =
        FirebaseCommunityCommentService.watchComments(
          post.id,
        ).listen(
              (comments) {
            if (!mounted || _isHandlingDeletedPost) {
              return;
            }

            setState(() {
              post = post.copyWith(
                commentList: comments,
                commentCount: comments.length,
              );

              isLoadingComments = false;
            });
          },
          onError: (Object error) {
            if (!mounted || _isHandlingDeletedPost) {
              return;
            }

            setState(() {
              isLoadingComments = false;
            });

            _showMessage(
              'Không tải được bình luận: $error',
            );
          },
        );
  }

  Future<void> _handleDeletedPost() async {
    if (_isHandlingDeletedPost) {
      return;
    }

    _isHandlingDeletedPost = true;

    await _postSubscription?.cancel();
    await _commentSubscription?.cancel();

    final userId =
        currentProfile?.uid ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';

    if (userId.isNotEmpty) {
      try {
        await CustomerSavedPostService.removeSavedPost(
          userId: userId,
          postId: post.id,
        );
      } catch (_) {
        // Vẫn đóng màn hình nếu xóa bookmark thất bại.
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isSaved = false;
      _allowPop = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Bài viết không còn tồn tại.',
          ),
        ),
      );

    context.pop();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile =
      await CustomerProfileService.getCurrentProfile();

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      setState(() {
        currentProfile = profile;
        isLiked = post.likedBy.contains(profile.uid);
        isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

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

  String _publicAvatarIconKey(
      CustomerProfile profile,
      ) {
    final iconKey = profile.avatarIconKey.trim();

    return iconKey.isEmpty
        ? 'default_person'
        : iconKey;
  }

  String _anonymousAvatarIconKey(
      CustomerProfile profile,
      ) {
    final iconKey =
    profile.anonymousAvatarIconKey.trim();

    return iconKey.isEmpty
        ? 'anonymous'
        : iconKey;
  }

  void _close() {
    if (!mounted || _isHandlingDeletedPost) {
      return;
    }

    setState(() {
      _allowPop = true;
    });

    context.pop(
      PostDetailResult(
        post: post,
        isLiked: isLiked,
        isSaved: isSaved,
      ),
    );
  }

  Future<void> _toggleLike() async {
    if (_isHandlingDeletedPost) {
      return;
    }

    final profile = currentProfile;

    if (profile == null) {
      _showMessage(
        'Không tìm thấy hồ sơ người dùng.',
      );
      return;
    }

    if (isUpdatingLike) {
      return;
    }

    final userId = profile.uid;
    final shouldLike =
    !post.likedBy.contains(userId);

    setState(() {
      isUpdatingLike = true;
    });

    try {
      await FirebaseCommunityService.toggleLike(
        post: post,
        userId: userId,
      );

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      setState(() {
        isLiked = shouldLike;
      });
    } catch (error) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Không cập nhật được lượt thích: $error',
      );
    } finally {
      if (mounted && !_isHandlingDeletedPost) {
        setState(() {
          isUpdatingLike = false;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    if (_isHandlingDeletedPost) {
      return;
    }

    final profile = currentProfile;

    if (profile == null) {
      _showMessage(
        'Không tìm thấy hồ sơ người dùng.',
      );
      return;
    }

    if (isUpdatingSave) {
      return;
    }

    final newSavedState = !isSaved;

    setState(() {
      isSaved = newSavedState;
      isUpdatingSave = true;
    });

    try {
      await CustomerSavedPostService.setSavedPost(
        userId: profile.uid,
        post: post,
        isSaved: newSavedState,
      );

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        newSavedState
            ? 'Đã lưu bài viết.'
            : 'Đã bỏ lưu bài viết.',
      );
    } catch (error) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      setState(() {
        isSaved = !newSavedState;
      });

      _showMessage(
        'Không cập nhật được bài viết đã lưu: $error',
      );
    } finally {
      if (mounted && !_isHandlingDeletedPost) {
        setState(() {
          isUpdatingSave = false;
        });
      }
    }
  }

  Future<void> _sendComment() async {
    if (_isHandlingDeletedPost) {
      return;
    }

    final profile = currentProfile;
    final text = commentController.text.trim();

    if (profile == null) {
      _showMessage(
        'Không tìm thấy hồ sơ người dùng.',
      );
      return;
    }

    if (text.isEmpty) {
      _showMessage(
        'Nhập bình luận trước nha.',
      );
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
      colorKey:
      CommunityPost.colorKeyFromIconKey(
        avatarIconKey,
      ),
      content: text,
      timeAgo: 'Vừa xong',
      createdAt: DateTime.now().toUtc(),
    );

    try {
      await FirebaseCommunityCommentService.addComment(
        postId: post.id,
        comment: comment,
      );

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      commentController.clear();

      _showMessage(
        'Đã gửi bình luận.',
      );
    } catch (error) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

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
      if (mounted && !_isHandlingDeletedPost) {
        setState(() {
          isSendingComment = false;
        });
      }
    }
  }

  Future<void> _editComment(
      PostComment comment,
      ) async {
    if (_isHandlingDeletedPost) {
      return;
    }

    final profile = currentProfile;

    if (profile == null ||
        comment.authorId != profile.uid) {
      _showMessage(
        'Bạn chỉ có thể sửa bình luận của mình.',
      );
      return;
    }

    var editedText = comment.content;

    final result = await showDialog<String>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          scrollable: true,
          insetPadding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
            side: const BorderSide(
              color: AppColors.peach,
            ),
          ),
          title: const Text(
            'Sửa bình luận',
          ),
          content: SizedBox(
            width:
            MediaQuery.sizeOf(
              dialogContext,
            ).width,
            child: TextFormField(
              initialValue: comment.content,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              keyboardType:
              TextInputType.multiline,
              textInputAction:
              TextInputAction.newline,
              onChanged: (value) {
                editedText = value;
              },
              decoration: InputDecoration(
                hintText:
                'Nhập nội dung bình luận mới...',
                filled: true,
                fillColor: AppColors.peach
                    .withValues(alpha: 0.25),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(
                    color: AppColors.peach,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(
                    color: AppColors.peach,
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding:
                const EdgeInsets.all(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text('Hủy'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                AppColors.primary,
              ),
              onPressed: () {
                final newText =
                editedText.trim();

                if (newText.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bình luận không được để trống.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(newText);
              },
              icon: const Icon(
                Icons.save_rounded,
              ),
              label: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        _isHandlingDeletedPost ||
        result == null) {
      return;
    }

    final newContent = result.trim();

    if (newContent.isEmpty) {
      _showMessage(
        'Bình luận không được để trống.',
      );
      return;
    }

    if (newContent == comment.content) {
      return;
    }

    final updatedComment = comment.copyWith(
      content: newContent,
      timeAgo: 'Vừa chỉnh sửa',
      updatedAt: DateTime.now().toUtc(),
    );

    try {
      await FirebaseCommunityCommentService
          .updateComment(
        postId: post.id,
        comment: updatedComment,
        currentUserId: profile.uid,
      );

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Đã sửa bình luận.',
      );
    } catch (error) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Không sửa được bình luận: $error',
      );
    }
  }

  Future<void> _deleteComment(
      PostComment comment,
      ) async {
    if (_isHandlingDeletedPost) {
      return;
    }

    final profile = currentProfile;

    if (profile == null ||
        comment.authorId != profile.uid) {
      _showMessage(
        'Bạn chỉ có thể xóa bình luận của mình.',
      );
      return;
    }

    final shouldDelete =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
            side: const BorderSide(
              color: AppColors.peach,
            ),
          ),
          title: const Text(
            'Xóa bình luận?',
          ),
          content: const Text(
            'Bình luận này sẽ bị xóa '
                'khỏi bài viết.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                Colors.redAccent,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              label: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        _isHandlingDeletedPost ||
        shouldDelete != true) {
      return;
    }

    try {
      await FirebaseCommunityCommentService
          .deleteComment(
        postId: post.id,
        commentId: comment.id,
        currentUserId: profile.uid,
      );

      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Đã xóa bình luận.',
      );
    } catch (error) {
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Không xóa được bình luận: $error',
      );
    }
  }

  Future<void> _sharePost() async {
    if (_isHandlingDeletedPost) {
      return;
    }

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
      if (!mounted || _isHandlingDeletedPost) {
        return;
      }

      _showMessage(
        'Không chia sẻ được: $error',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        currentProfile?.uid ?? '';

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (
          didPop,
          result,
          ) {
        if (didPop) {
          return;
        }

        _close();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor:
          AppColors.textDark,
          surfaceTintColor:
          Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          title: const Text(
            'Chi tiết bài viết',
          ),
          actions: [
            IconButton(
              tooltip: isSaved
                  ? 'Bỏ lưu bài viết'
                  : 'Lưu bài viết',
              onPressed: isUpdatingSave ||
                  _isHandlingDeletedPost
                  ? null
                  : _toggleSave,
              icon: isUpdatingSave
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
                  : Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons
                    .bookmark_border_rounded,
                color: isSaved
                    ? AppColors.primary
                    : AppColors.textSoft,
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
            _AuthorBlock(post: post),
            if (post.hasTag) ...[
              const SizedBox(height: 14),
              _TagChip(post: post),
            ],
            const SizedBox(height: 16),
            Text(
              post.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),
            if (post.hasImage) ...[
              const SizedBox(height: 16),
              _PostDetailImage(post: post),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _DetailActionButton(
                  icon: isLiked
                      ? Icons.favorite_rounded
                      : Icons
                      .favorite_border_rounded,
                  label: isUpdatingLike
                      ? '...'
                      : '$displayLikes',
                  active: isLiked,
                  onTap: isUpdatingLike ||
                      _isHandlingDeletedPost
                      ? () {}
                      : _toggleLike,
                ),
                const SizedBox(width: 10),
                _DetailActionButton(
                  icon: Icons
                      .chat_bubble_outline_rounded,
                  label:
                  '${post.totalComments}',
                  active: false,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _DetailActionButton(
                  icon: Icons.share_rounded,
                  label: 'Chia sẻ',
                  active: false,
                  onTap: _sharePost,
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Tất cả bình luận',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color:
                    AppColors.textDark,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoadingComments)
              const Center(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child:
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (post.commentList.isEmpty)
              const _EmptyCommentCard()
            else
              ...post.commentList.map(
                    (comment) {
                  final canManage =
                      currentUserId.isNotEmpty &&
                          comment.authorId ==
                              currentUserId;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
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
                },
              ),
          ],
        ),
        bottomNavigationBar:
        _CommentInputBar(
          controller: commentController,
          isLoadingProfile:
          isLoadingProfile,
          isSending: isSendingComment,
          commentAsAnonymous:
          commentAsAnonymous,
          isPostDeleted:
          _isHandlingDeletedPost,
          onToggleAnonymous: () {
            setState(() {
              commentAsAnonymous =
              !commentAsAnonymous;
            });
          },
          onSend: _sendComment,
        ),
      ),
    );
  }
}

class _PastelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const _PastelCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          borderRadius,
        ),
        side: const BorderSide(
          color: AppColors.peach,
          width: 1.3,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          borderRadius,
        ),
        child: Padding(
          padding: padding,
          child: child,
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
    return _PastelCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
            AppColors.peach,
            child: Icon(
              post.petIcon,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w900,
                    color:
                    AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.authorRole} • '
                      '${post.displayTimeLabel}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                    AppColors.textSoft,
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
        padding:
        const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.peach,
          borderRadius:
          BorderRadius.circular(99),
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
      ),
    );
  }
}

class _PostDetailImage
    extends StatefulWidget {
  final CommunityPost post;

  const _PostDetailImage({
    required this.post,
  });

  @override
  State<_PostDetailImage> createState() =>
      _PostDetailImageState();
}

class _PostDetailImageState
    extends State<_PostDetailImage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        widget.post.allImageUrls;

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(24),
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
              itemBuilder: (
                  context,
                  index,
                  ) {
                final imageUrl =
                CloudinaryUploadService
                    .optimizedImageUrl(
                  imageUrls[index],
                );

                return GestureDetector(
                  behavior:
                  HitTestBehavior.opaque,
                  onTap: () {
                    _openImageViewer(
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
                      if (loadingProgress ==
                          null) {
                        return child;
                      }

                      return Container(
                        color:
                        AppColors.peach,
                        alignment:
                        Alignment.center,
                        child: const
                        CircularProgressIndicator(
                          color:
                          AppColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        color:
                        AppColors.peach,
                        alignment:
                        Alignment.center,
                        child: const Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .broken_image_outlined,
                              color: AppColors
                                  .textSoft,
                              size: 34,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Không tải được ảnh.',
                              style: TextStyle(
                                color:
                                AppColors
                                    .textSoft,
                                fontWeight:
                                FontWeight
                                    .w700,
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
              left: 12,
              bottom: 12,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(
                      alpha: 0.92,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
            if (imageUrls.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors.primary
                        .withValues(
                      alpha: 0.92,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      99,
                    ),
                  ),
                  child: Text(
                    '${currentIndex + 1}'
                        '/${imageUrls.length}',
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w900,
                      fontSize: 12,
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

Future<void> _openImageViewer(
    BuildContext context, {
      required List<String> imageUrls,
      required int initialIndex,
    }) async {
  if (imageUrls.isEmpty) {
    return;
  }

  final safeIndex = initialIndex
      .clamp(0, imageUrls.length - 1)
      .toInt();

  await Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) {
        return _FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: safeIndex,
        );
      },
    ),
  );
}

class _FullScreenImageViewer
    extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer>
  createState() =>
      _FullScreenImageViewerState();
}

class _FullScreenImageViewerState
    extends State<_FullScreenImageViewer> {
  late final PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor:
        Colors.transparent,
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
          '${currentIndex + 1}'
              '/${widget.imageUrls.length}',
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
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (
            context,
            index,
            ) {
          final imageUrl =
          CloudinaryUploadService
              .optimizedImageUrl(
            widget.imageUrls[index],
          );

          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin:
            const EdgeInsets.all(100),
            child: Center(
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
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
                    child:
                    CircularProgressIndicator(
                      color:
                      AppColors.primary,
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
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Không tải được ảnh.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailActionButton
    extends StatelessWidget {
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
          padding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          icon,
          size: 20,
          color: active
              ? AppColors.primary
              : AppColors.textSoft,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active
                ? AppColors.primary
                : AppColors.textSoft,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _EmptyCommentCard
    extends StatelessWidget {
  const _EmptyCommentCard();

  @override
  Widget build(BuildContext context) {
    return const _PastelCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            AppColors.peach,
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chưa có bình luận nào. '
                  'Hãy là người đầu tiên bình luận.',
              style: TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile
    extends StatelessWidget {
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
    return _PastelCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
            AppColors.peach,
            child: Icon(
              comment.petIcon,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${comment.authorName} • '
                            '${comment.displayTimeLabel}',
                        style:
                        const TextStyle(
                          color:
                          AppColors.textDark,
                          fontWeight:
                          FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (canManage)
                      PopupMenuButton<String>(
                        color: Colors.white,
                        surfaceTintColor:
                        Colors.white,
                        icon: const Icon(
                          Icons
                              .more_horiz_rounded,
                          color: AppColors
                              .textSoft,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          side:
                          const BorderSide(
                            color:
                            AppColors.peach,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          }

                          if (value ==
                              'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (
                            context,
                            ) {
                          return const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .edit_rounded,
                                    color:
                                    AppColors
                                        .primary,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Sửa bình luận',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color: Colors
                                        .redAccent,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Xóa bình luận',
                                    style:
                                    TextStyle(
                                      color: Colors
                                          .redAccent,
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
                const SizedBox(height: 5),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: AppColors.textSoft,
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

class _CommentInputBar
    extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoadingProfile;
  final bool isSending;
  final bool commentAsAnonymous;
  final bool isPostDeleted;
  final VoidCallback onToggleAnonymous;
  final VoidCallback onSend;

  const _CommentInputBar({
    required this.controller,
    required this.isLoadingProfile,
    required this.isSending,
    required this.commentAsAnonymous,
    required this.isPostDeleted,
    required this.onToggleAnonymous,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final disabled =
        isLoadingProfile ||
            isSending ||
            isPostDeleted;

    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor:
      Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.peach,
              ),
            ),
          ),
          padding:
          const EdgeInsets.fromLTRB(
            12,
            9,
            12,
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
                style: IconButton.styleFrom(
                  backgroundColor:
                  AppColors.peach,
                  foregroundColor:
                  AppColors.primary,
                ),
                icon: Icon(
                  commentAsAnonymous
                      ? Icons.face_rounded
                      : Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !disabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction:
                  TextInputAction.newline,
                  decoration:
                  InputDecoration(
                    hintText: isPostDeleted
                        ? 'Bài viết đã bị xóa.'
                        : commentAsAnonymous
                        ? 'Viết bình luận ẩn danh...'
                        : 'Viết bình luận công khai...',
                    filled: true,
                    fillColor: AppColors.peach
                        .withValues(
                      alpha: 0.35,
                    ),
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                      borderSide:
                      const BorderSide(
                        color:
                        AppColors.peach,
                      ),
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                      borderSide:
                      const BorderSide(
                        color:
                        AppColors.peach,
                      ),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                      borderSide:
                      const BorderSide(
                        color:
                        AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                      borderSide:
                      const BorderSide(
                        color:
                        AppColors.peach,
                      ),
                    ),
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed:
                disabled ? null : onSend,
                style: IconButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor:
                  Colors.white,
                  disabledBackgroundColor:
                  AppColors.primarySoft,
                ),
                icon: isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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