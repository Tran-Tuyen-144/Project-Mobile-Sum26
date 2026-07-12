import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';

class CreatePostHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CreatePostHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.peach, AppColors.cream],
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
              color: Colors.white.withValues(alpha: 0.82),
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
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PetIconOption {
  final String label;
  final String iconKey;
  final IconData icon;
  final Color color;

  const PetIconOption({
    required this.label,
    required this.iconKey,
    required this.icon,
    required this.color,
  });
}

class SelectedAvatarCard extends StatelessWidget {
  final PetIconOption selectedOption;
  final VoidCallback onTap;

  const SelectedAvatarCard({
    super.key,
    required this.selectedOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avatar ẩn danh',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedOption.label,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class TagPickerCard extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const TagPickerCard({
    super.key,
    required this.selectedCategory,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasTag = selectedCategory.trim().isNotEmpty;

    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: hasTag ? AppColors.primarySoft : AppColors.peach,
            child: Icon(
              hasTag ? Icons.tag_rounded : Icons.sell_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tag bài viết',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasTag ? '#$selectedCategory' : 'Không gắn tag',
                  style: TextStyle(
                    color: hasTag ? AppColors.primary : AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (hasTag)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: AppColors.textSoft),
            )
          else
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}

class PostPreviewCard extends StatelessWidget {
  final String authorName;
  final String content;
  final String category;
  final IconData icon;
  final Color color;

  const PostPreviewCard({
    super.key,
    required this.authorName,
    required this.content,
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final previewContent = content.trim().isEmpty
        ? 'Nội dung bài viết của bạn sẽ hiển thị ở đây...'
        : content.trim();

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
                child: Icon(icon, color: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  authorName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
              ),
              if (category.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '#$category',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            previewContent,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
