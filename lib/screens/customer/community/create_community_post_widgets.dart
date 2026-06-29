import 'dart:io';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';

class CreatePostHeader extends StatelessWidget {
  const CreatePostHeader({super.key});

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
              Icons.edit_note_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo bài viết',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Có thể đăng bài kèm ảnh hoặc không kèm ảnh đều được.',
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

class PostCategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const PostCategorySelector({
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

class PetIconSelector extends StatelessWidget {
  final List<PetIconOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PetIconSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onSelected(index),
            child: Container(
              width: 88,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySoft : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.peach,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: option.color,
                    child: Icon(
                      option.icon,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PickImageCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const PickImageCard({
    super.key,
    required this.imagePath,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.file(
                File(imagePath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(hasImage ? 'Đổi ảnh' : 'Tải ảnh lên'),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Không bắt buộc. Không chọn ảnh vẫn đăng bài bình thường.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class PostPreviewCard extends StatelessWidget {
  final String content;
  final String category;
  final IconData icon;
  final Color color;
  final String? imagePath;

  const PostPreviewCard({
    super.key,
    required this.content,
    required this.category,
    required this.icon,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final displayContent = content.trim().isEmpty
        ? 'Nội dung bài viết sẽ hiển thị ở đây...'
        : content.trim();

    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bạn • Vừa xong',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayContent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                File(imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 72,
                  color: AppColors.textDark.withOpacity(0.72),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PetIconOption {
  final String label;
  final IconData icon;
  final Color color;

  const PetIconOption({
    required this.label,
    required this.icon,
    required this.color,
  });
}