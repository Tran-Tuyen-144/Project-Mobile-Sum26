import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../storage/profile_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'community_post.dart';
import 'create_community_post_widgets.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  final CommunityPost? initialPost;

  const CreateCommunityPostScreen({
    super.key,
    this.initialPost,
  });

  bool get isEditMode => initialPost != null;

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final TextEditingController contentController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  String displayName = 'Bạn';
  String? authorAvatarPath;

  String selectedCategory = 'Mèo';
  int selectedIconIndex = 0;
  String? selectedImagePath;

  final List<String> postCategories = const [
    'Mèo',
    'Cún',
    'Chăm sóc',
    'Hỏi đáp',
  ];

  final List<PetIconOption> iconOptions = const [
    PetIconOption(
      label: 'Mèo',
      icon: Icons.pets_rounded,
      color: AppColors.peach,
    ),
    PetIconOption(
      label: 'Cún',
      icon: Icons.cruelty_free_rounded,
      color: AppColors.mint,
    ),
    PetIconOption(
      label: 'Yêu thích',
      icon: Icons.favorite_rounded,
      color: AppColors.lavender,
    ),
    PetIconOption(
      label: 'Sức khỏe',
      icon: Icons.health_and_safety_rounded,
      color: AppColors.sky,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final post = widget.initialPost;

    if (post != null) {
      contentController.text = post.content;
      selectedCategory = post.category;
      selectedImagePath = post.imagePath;

      displayName = post.authorName;
      authorAvatarPath = post.authorAvatarPath;

      final foundIndex = iconOptions.indexWhere(
            (item) => item.icon == post.petIcon,
      );

      if (foundIndex != -1) {
        selectedIconIndex = foundIndex;
      }
    } else {
      _loadAuthorProfile();
    }
  }

  Future<void> _loadAuthorProfile() async {
    final savedName = await ProfileStorage.loadDisplayName();
    final savedAvatarPath = await ProfileStorage.loadAvatarPath();

    if (!mounted) return;

    setState(() {
      displayName = savedName;
      authorAvatarPath = savedAvatarPath;
    });
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );

      if (pickedImage == null) return;

      final copiedPath = await _copyImageToAppFolder(pickedImage);

      if (!mounted) return;

      setState(() {
        selectedImagePath = copiedPath;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được ảnh: $error'),
        ),
      );
    }
  }

  Future<String> _copyImageToAppFolder(XFile pickedImage) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/community_images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final originalPath = pickedImage.path;
    final fileName = originalPath.split(Platform.pathSeparator).last;
    final newPath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final copiedFile = await File(originalPath).copy(newPath);

    return copiedFile.path;
  }

  void _removeImage() {
    setState(() {
      selectedImagePath = null;
    });
  }

  void _submitPost() {
    final content = contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Em nhập nội dung bài viết trước nha.'),
        ),
      );
      return;
    }

    final option = iconOptions[selectedIconIndex];
    final oldPost = widget.initialPost;

    final CommunityPost resultPost;

    if (oldPost == null) {
      resultPost = CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch,
        authorName: displayName,
        authorRole: 'Thành viên PetHub',
        timeAgo: 'Vừa xong',
        content: content,
        category: selectedCategory,
        likes: 0,
        petIcon: option.icon,
        color: option.color,
        imagePath: selectedImagePath,
        authorAvatarPath: authorAvatarPath,
        commentList: const [],
      );
    } else {
      resultPost = oldPost.copyWith(
        authorName: displayName,
        authorAvatarPath: authorAvatarPath,
        content: content,
        category: selectedCategory,
        petIcon: option.icon,
        color: option.color,
        imagePath: selectedImagePath,
        removeImage: selectedImagePath == null,
        timeAgo: 'Vừa chỉnh sửa',
      );
    }

    context.pop(resultPost);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = iconOptions[selectedIconIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreatePostHeader(
            title: widget.isEditMode ? 'Chỉnh sửa bài viết' : 'Tạo bài viết',
            subtitle: widget.isEditMode
                ? 'Cập nhật nội dung, chủ đề hoặc ảnh bài viết của bạn.'
                : 'Có thể đăng bài kèm ảnh hoặc không kèm ảnh đều được.',
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Nội dung bài viết'),

          const SizedBox(height: 12),

          SoftCard(
            color: Colors.white,
            child: TextField(
              controller: contentController,
              maxLines: 6,
              minLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText:
                'Ví dụ: Hôm nay bé Mochi đi PetHub rất ngoan, nằm cạnh cửa sổ cả buổi chiều...',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Ảnh bài viết'),

          const SizedBox(height: 12),

          PickImageCard(
            imagePath: selectedImagePath,
            onPickImage: _pickImage,
            onRemoveImage: _removeImage,
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn chủ đề'),

          const SizedBox(height: 12),

          PostCategorySelector(
            categories: postCategories,
            selectedCategory: selectedCategory,
            onSelected: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn hình minh họa'),

          const SizedBox(height: 12),

          PetIconSelector(
            options: iconOptions,
            selectedIndex: selectedIconIndex,
            onSelected: (index) {
              setState(() {
                selectedIconIndex = index;
              });
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Xem trước bài viết'),

          const SizedBox(height: 12),

          PostPreviewCard(
            content: contentController.text,
            category: selectedCategory,
            icon: selectedOption.icon,
            color: selectedOption.color,
            imagePath: selectedImagePath,
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitPost,
                  icon: Icon(
                    widget.isEditMode
                        ? Icons.save_rounded
                        : Icons.send_rounded,
                  ),
                  label: Text(
                    widget.isEditMode ? 'Lưu' : 'Đăng bài',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}