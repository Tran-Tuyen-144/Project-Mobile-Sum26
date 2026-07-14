import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/customer_profile.dart';
import '../../../services/cloudinary_upload_service.dart';
import '../../../services/customer_profile_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'community_post.dart';
import 'create_community_post_widgets.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  final CommunityPost? initialPost;

  const CreateCommunityPostScreen({super.key, this.initialPost});

  bool get isEditMode => initialPost != null;

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final TextEditingController contentController = TextEditingController();

  CustomerProfile? currentProfile;

  bool isLoadingProfile = true;
  bool isSavingIdentity = false;
  bool isUploadingPost = false;

  String? loadingError;

  bool isAnonymous = false;

  String anonymousName = 'Ẩn danh PetHub';
  String anonymousAvatarIconKey = 'anonymous';

  String selectedCategory = '';

  XFile? selectedImageFile;
  String? currentImageUrl;
  String? currentImagePublicId;
  bool removeCurrentImage = false;

  final List<String> postCategories = const [
    'Mèo',
    'Cún',
    'Chăm sóc',
    'Hỏi đáp',
    'Khoảnh khắc',
    'Tìm bạn chơi',
    'Kinh nghiệm',
  ];

  final List<PetIconOption> iconOptions = const [
    PetIconOption(
      label: 'Chân dung',
      iconKey: 'default_person',
      icon: Icons.person_rounded,
      color: AppColors.peach,
    ),
    PetIconOption(
      label: 'Ẩn danh',
      iconKey: 'anonymous',
      icon: Icons.face_rounded,
      color: AppColors.peach,
    ),
    PetIconOption(
      label: 'Mèo',
      iconKey: 'cat',
      icon: Icons.pets_rounded,
      color: AppColors.primarySoft,
    ),
    PetIconOption(
      label: 'Cún',
      iconKey: 'dog',
      icon: Icons.cruelty_free_rounded,
      color: AppColors.mint,
    ),
    PetIconOption(
      label: 'Thỏ',
      iconKey: 'rabbit',
      icon: Icons.emoji_nature_rounded,
      color: AppColors.lavender,
    ),
    PetIconOption(
      label: 'Chim',
      iconKey: 'bird',
      icon: Icons.flutter_dash_rounded,
      color: AppColors.sky,
    ),
    PetIconOption(
      label: 'Cá',
      iconKey: 'fish',
      icon: Icons.water_drop_rounded,
      color: AppColors.mint,
    ),
    PetIconOption(
      label: 'Yêu thích',
      iconKey: 'favorite',
      icon: Icons.favorite_rounded,
      color: AppColors.lavender,
    ),
    PetIconOption(
      label: 'Sức khỏe',
      iconKey: 'health',
      icon: Icons.health_and_safety_rounded,
      color: AppColors.sky,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final oldPost = widget.initialPost;

    if (oldPost != null) {
      contentController.text = oldPost.content;
      selectedCategory = oldPost.category;
      isAnonymous = oldPost.isAnonymous;
      currentImageUrl = oldPost.imageUrl;
      currentImagePublicId = oldPost.imagePublicId;
    }

    _loadCurrentProfile();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await CustomerProfileService.getCurrentProfile();

      if (!mounted) return;

      setState(() {
        currentProfile = profile;

        anonymousName = profile.anonymousName.trim().isEmpty
            ? 'Ẩn danh PetHub'
            : profile.anonymousName.trim();

        anonymousAvatarIconKey = profile.anonymousAvatarIconKey.trim().isEmpty
            ? 'anonymous'
            : profile.anonymousAvatarIconKey.trim();

        loadingError = null;
        isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadingError = error.toString().replaceFirst('Exception: ', '');
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _retryLoadProfile() async {
    setState(() {
      isLoadingProfile = true;
      loadingError = null;
    });

    await _loadCurrentProfile();
  }

  PetIconOption _findIconOption(String iconKey) {
    return iconOptions.firstWhere(
      (option) => option.iconKey == iconKey,
      orElse: () => iconOptions.first,
    );
  }

  String _publicDisplayName(CustomerProfile profile) {
    final name = profile.displayName.trim();

    return name.isEmpty ? 'Bạn PetHub' : name;
  }

  String _publicAvatarIconKey(CustomerProfile profile) {
    final iconKey = profile.avatarIconKey.trim();

    return iconKey.isEmpty ? 'default_person' : iconKey;
  }

  String _currentAuthorName(CustomerProfile profile) {
    if (isAnonymous) {
      return anonymousName.trim().isEmpty
          ? 'Ẩn danh PetHub'
          : anonymousName.trim();
    }

    return _publicDisplayName(profile);
  }

  String _currentAvatarIconKey(CustomerProfile profile) {
    if (isAnonymous) {
      return anonymousAvatarIconKey.trim().isEmpty
          ? 'anonymous'
          : anonymousAvatarIconKey.trim();
    }

    return _publicAvatarIconKey(profile);
  }

  void _toggleAnonymous(bool value) {
    if (isSavingIdentity || isUploadingPost) return;

    setState(() {
      isAnonymous = value;
    });
  }

  Future<void> _changeAnonymousName() async {
    if (!isAnonymous || isSavingIdentity || isUploadingPost) {
      return;
    }

    final controller = TextEditingController(text: anonymousName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Đổi tên ẩn danh'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Tên ẩn danh',
              hintText: 'Ví dụ: Mèo Cam 152',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
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

    final cleanName = result.trim();

    if (cleanName.isEmpty) {
      _showMessage('Tên ẩn danh không được để trống.');
      return;
    }

    if (cleanName == anonymousName) return;

    setState(() {
      isSavingIdentity = true;
    });

    try {
      await CustomerProfileService.updateAnonymousName(cleanName);

      if (!mounted) return;

      setState(() {
        anonymousName = cleanName;
      });

      _showMessage('Đã cập nhật tên ẩn danh.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSavingIdentity = false;
        });
      }
    }
  }

  Future<void> _showAnonymousAvatarPicker() async {
    if (!isAnonymous || isSavingIdentity || isUploadingPost) {
      return;
    }

    final selectedOption = await showModalBottomSheet<PetIconOption>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
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
                  'Chọn avatar ẩn danh',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  itemCount: iconOptions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final option = iconOptions[index];

                    final isSelected = option.iconKey == anonymousAvatarIconKey;

                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop(option);
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

    if (selectedOption == null) return;

    if (selectedOption.iconKey == anonymousAvatarIconKey) {
      return;
    }

    setState(() {
      isSavingIdentity = true;
    });

    try {
      await CustomerProfileService.updateAnonymousAvatarIcon(
        selectedOption.iconKey,
      );

      if (!mounted) return;

      setState(() {
        anonymousAvatarIconKey = selectedOption.iconKey;
      });

      _showMessage('Đã cập nhật avatar ẩn danh.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSavingIdentity = false;
        });
      }
    }
  }

  void _showTagPicker() {
    if (isUploadingPost) return;

    showModalBottomSheet<void>(
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
                  'Chọn tag bài viết',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: postCategories.map((category) {
                    final selected = selectedCategory == category;

                    return ChoiceChip(
                      label: Text('#$category'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });

                        Navigator.of(bottomSheetContext).pop();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCategory = '';
                      });

                      Navigator.of(bottomSheetContext).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Không gắn tag'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (isUploadingPost) {
      return;
    }

    try {
      final image =
      await CloudinaryUploadService.pickImageFromGallery();

      if (!mounted || image == null) {
        return;
      }

      setState(() {
        selectedImageFile = image;
        removeCurrentImage = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Không chọn được ảnh: $error');
    }
  }

  void _removeSelectedImage() {
    if (isUploadingPost) return;

    setState(() {
      selectedImageFile = null;
      removeCurrentImage = true;
    });
  }

  Future<void> _submitPost() async {
    final profile = currentProfile;

    if (profile == null) {
      _showMessage('Không tìm thấy hồ sơ người dùng.');
      return;
    }

    if (isSavingIdentity) {
      _showMessage('Đang lưu danh tính, vui lòng đợi.');
      return;
    }

    if (isUploadingPost) {
      return;
    }

    final content = contentController.text.trim();

    if (content.isEmpty) {
      _showMessage('Em nhập nội dung bài viết trước nha.');
      return;
    }

    setState(() {
      isUploadingPost = true;
    });

    CommunityPost? resultPost;

    try {
      final authorName = _currentAuthorName(profile);
      final avatarIconKey = _currentAvatarIconKey(profile);

      final authorRole = isAnonymous
          ? 'Thành viên ẩn danh'
          : 'Thành viên PetHub';

      final colorKey = CommunityPost.colorKeyFromIconKey(
        avatarIconKey,
      );

      final oldPost = widget.initialPost;

      String? finalImageUrl = currentImageUrl;
      String? finalImagePublicId = currentImagePublicId;

      if (removeCurrentImage) {
        finalImageUrl = null;
        finalImagePublicId = null;
      }

      final imageFile = selectedImageFile;

      if (imageFile != null) {
        final uploadResult =
        await CloudinaryUploadService.uploadImageFile(
          imageFile,
        );

        if (!mounted) {
          return;
        }

        finalImageUrl =
            CloudinaryUploadService.optimizedImageUrl(
              uploadResult.imageUrl,
            );

        finalImagePublicId = uploadResult.publicId;
      }

      if (oldPost == null) {
        resultPost = CommunityPost(
          id: DateTime.now().millisecondsSinceEpoch,
          authorId: profile.uid,
          authorName: authorName,
          authorRole: authorRole,
          isAnonymous: isAnonymous,
          timeAgo: 'Vừa xong',
          createdAt: DateTime.now(),
          content: content,
          category: selectedCategory,
          likes: 0,
          likedBy: const [],
          avatarIconKey: avatarIconKey,
          colorKey: colorKey,
          imageUrl: finalImageUrl,
          imagePublicId: finalImagePublicId,
          commentList: const [],
        );
      } else {
        resultPost = oldPost.copyWith(
          authorId: profile.uid,
          authorName: authorName,
          authorRole: authorRole,
          isAnonymous: isAnonymous,
          content: content,
          category: selectedCategory,
          avatarIconKey: avatarIconKey,
          colorKey: colorKey,
          imageUrl: finalImageUrl,
          imagePublicId: finalImagePublicId,
          removeCloudinaryImage:
          finalImageUrl == null &&
              finalImagePublicId == null,
          timeAgo: 'Vừa chỉnh sửa',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isUploadingPost = false;
      });

      _showMessage(
        'Không đăng được ảnh/bài viết: $error',
      );

      return;
    }

    if (!mounted || resultPost == null) {
      return;
    }

    setState(() {
      isUploadingPost = false;
    });

    context.pop(resultPost);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildImagePickerSection() {
    final hasSelectedImage = selectedImageFile != null;
    final hasOldImage =
        currentImageUrl != null &&
        currentImageUrl!.trim().isNotEmpty &&
        !removeCurrentImage;

    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.peach,
                child: Icon(Icons.image_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ảnh bài viết',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ảnh sẽ được lưu trên Cloudinary.',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: isUploadingPost ? null : _pickImageFromGallery,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: Text(
                  hasSelectedImage || hasOldImage ? 'Đổi ảnh' : 'Chọn ảnh',
                ),
              ),
            ],
          ),
          if (hasSelectedImage || hasOldImage) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: hasSelectedImage
                    ? Image.file(
                        File(selectedImageFile!.path),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        currentImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
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
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: isUploadingPost ? null : _removeSelectedImage,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'Gỡ ảnh khỏi bài viết',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadingError != null || currentProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 14),
              Text(
                loadingError ?? 'Không tìm thấy hồ sơ người dùng.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _retryLoadProfile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = currentProfile!;

    final authorName = _currentAuthorName(profile);
    final avatarIconKey = _currentAvatarIconKey(profile);
    final selectedOption = _findIconOption(avatarIconKey);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreatePostHeader(
                title: widget.isEditMode
                    ? 'Chỉnh sửa bài viết'
                    : 'Tạo bài viết',
                subtitle: isAnonymous
                    ? 'Bạn đang đăng bằng danh tính ẩn danh.'
                    : 'Bài viết đang sử dụng tên và avatar trong trang cá nhân.',
              ),

              const SizedBox(height: 20),

              SoftCard(
                color: Colors.white,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isAnonymous,
                  onChanged: isUploadingPost ? null : _toggleAnonymous,
                  title: const Text(
                    'Đăng ẩn danh',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    isAnonymous
                        ? 'Người khác sẽ thấy tên và avatar ẩn danh.'
                        : 'Người khác sẽ thấy tên hiển thị trong trang cá nhân.',
                  ),
                  activeThumbColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              _AuthorIdentityCard(
                authorName: authorName,
                selectedOption: selectedOption,
                isAnonymous: isAnonymous,
                isSaving: isSavingIdentity || isUploadingPost,
                onAvatarTap: isAnonymous ? _showAnonymousAvatarPicker : null,
                onNameTap: isAnonymous ? _changeAnonymousName : null,
              ),

              if (isSavingIdentity) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],

              const SizedBox(height: 24),

              const SectionTitle(title: 'Nội dung bài viết'),

              const SizedBox(height: 12),

              SoftCard(
                color: Colors.white,
                child: TextField(
                  controller: contentController,
                  enabled: !isUploadingPost,
                  maxLines: 6,
                  minLines: 4,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText:
                        'Ví dụ: Hôm nay bé mèo nhà mình hơi lười ăn, mọi người có kinh nghiệm gì không?',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: 'Ảnh minh họa'),

              const SizedBox(height: 12),

              _buildImagePickerSection(),

              const SizedBox(height: 24),

              const SectionTitle(title: 'Tag bài viết'),

              const SizedBox(height: 12),

              TagPickerCard(
                selectedCategory: selectedCategory,
                onTap: _showTagPicker,
                onClear: () {
                  setState(() {
                    selectedCategory = '';
                  });
                },
              ),

              const SizedBox(height: 24),

              const SectionTitle(title: 'Xem trước bài viết'),

              const SizedBox(height: 12),

              PostPreviewCard(
                authorName: authorName,
                content: contentController.text,
                category: selectedCategory,
                icon: selectedOption.icon,
                color: selectedOption.color,
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUploadingPost ? null : () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUploadingPost ? null : _submitPost,
                      icon: Icon(
                        widget.isEditMode
                            ? Icons.save_rounded
                            : Icons.send_rounded,
                      ),
                      label: Text(
                        isUploadingPost
                            ? 'Đang đăng...'
                            : widget.isEditMode
                            ? 'Lưu'
                            : 'Đăng bài',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (isUploadingPost)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.08),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 14),
                        Text(
                          'Đang upload ảnh và lưu bài viết...',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AuthorIdentityCard extends StatelessWidget {
  final String authorName;
  final PetIconOption selectedOption;
  final bool isAnonymous;
  final bool isSaving;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNameTap;

  const _AuthorIdentityCard({
    required this.authorName,
    required this.selectedOption,
    required this.isAnonymous,
    required this.isSaving,
    required this.onAvatarTap,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: isAnonymous && !isSaving ? onAvatarTap : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: selectedOption.color,
                  child: Icon(
                    selectedOption.icon,
                    color: AppColors.textDark,
                    size: 32,
                  ),
                ),
                if (isAnonymous)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 23,
                      height: 23,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isAnonymous && !isSaving ? onNameTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAnonymous
                          ? 'Bấm để đổi tên hoặc avatar ẩn danh'
                          : 'Tên và avatar lấy từ trang cá nhân',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Icon(
            isAnonymous ? Icons.edit_rounded : Icons.lock_outline_rounded,
            color: isAnonymous ? AppColors.primary : AppColors.textSoft,
          ),
        ],
      ),
    );
  }
}
