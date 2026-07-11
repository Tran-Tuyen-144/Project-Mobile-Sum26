import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  bool isAnonymous = true;
  String authorName = 'Ẩn danh PetHub';

  String selectedCategory = '';
  int selectedIconIndex = 0;

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
      label: 'Ẩn danh',
      iconKey: 'anonymous',
      icon: Icons.face_rounded,
      color: AppColors.peach,
    ),
    PetIconOption(
      label: 'Mèo',
      iconKey: 'cat',
      icon: Icons.pets_rounded,
      color: AppColors.peach,
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
      color: AppColors.primarySoft,
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

    final post = widget.initialPost;

    if (post != null) {
      contentController.text = post.content;
      selectedCategory = post.category;
      authorName = post.authorName;
      isAnonymous = post.authorRole.contains('ẩn danh');

      final foundIndex = iconOptions.indexWhere(
            (item) => item.iconKey == post.avatarIconKey,
      );

      if (foundIndex != -1) {
        selectedIconIndex = foundIndex;
      }
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  void _toggleAnonymous(bool value) {
    setState(() {
      isAnonymous = value;

      if (isAnonymous && authorName == 'Bạn PetHub') {
        authorName = 'Ẩn danh PetHub';
      }

      if (!isAnonymous && authorName == 'Ẩn danh PetHub') {
        authorName = 'Bạn PetHub';
      }
    });
  }

  Future<void> _changeAuthorName() async {
    final controller = TextEditingController(text: authorName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isAnonymous ? 'Đổi tên ẩn danh' : 'Đổi tên hiển thị',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập tên hiển thị...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      authorName = result.isEmpty
          ? (isAnonymous ? 'Ẩn danh PetHub' : 'Bạn PetHub')
          : result;
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
                  'Chọn avatar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  itemCount: iconOptions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final option = iconOptions[index];
                    final isSelected = selectedIconIndex == index;

                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          selectedIconIndex = index;
                        });

                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
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
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: Icon(
                                option.icon,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
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
  }

  void _showTagPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
                    final isSelected = selectedCategory == category;

                    return ChoiceChip(
                      label: Text('#$category'),
                      selected: isSelected,
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
        authorId: '',
        authorName: authorName,
        authorRole: isAnonymous ? 'Thành viên ẩn danh' : 'Thành viên PetHub',
        timeAgo: 'Vừa xong',
        content: content,
        category: selectedCategory,
        likes: 0,
        likedBy: const [],
        avatarIconKey: option.iconKey,
        colorKey: CommunityPost.colorKeyFromColor(option.color),
        commentList: const [],
      );
    } else {
      resultPost = oldPost.copyWith(
        authorName: authorName,
        authorRole: isAnonymous ? 'Thành viên ẩn danh' : 'Thành viên PetHub',
        content: content,
        category: selectedCategory,
        avatarIconKey: option.iconKey,
        colorKey: CommunityPost.colorKeyFromColor(option.color),
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
            subtitle: 'Bật/tắt ẩn danh, bấm avatar để đổi icon, bấm tên để đổi tên.',
          ),

          const SizedBox(height: 20),

          SoftCard(
            color: Colors.white,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isAnonymous,
              onChanged: _toggleAnonymous,
              title: const Text(
                'Đăng ẩn danh',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                isAnonymous
                    ? 'Người khác sẽ thấy bạn dưới tên ẩn danh.'
                    : 'Bài viết sẽ dùng tên hiển thị bạn đặt.',
              ),
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 20),

          _AuthorPickerCard(
            authorName: authorName,
            selectedOption: selectedOption,
            onAvatarTap: _showAvatarPicker,
            onNameTap: _changeAuthorName,
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
                'Ví dụ: Hôm nay bé mèo nhà mình hơi lười ăn, mọi người có kinh nghiệm gì không?',
                border: InputBorder.none,
              ),
            ),
          ),

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

class _AuthorPickerCard extends StatelessWidget {
  final String authorName;
  final PetIconOption selectedOption;
  final VoidCallback onAvatarTap;
  final VoidCallback onNameTap;

  const _AuthorPickerCard({
    required this.authorName,
    required this.selectedOption,
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
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: selectedOption.color,
              child: Icon(
                selectedOption.icon,
                color: AppColors.textDark,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onNameTap,
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
                    const Text(
                      'Bấm để đổi tên',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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