import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'branch_location.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.sky, AppColors.peach, AppColors.cream],
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
              Icons.map_rounded,
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
                  'Tìm PetHub gần bạn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Xem chi nhánh, khoảng cách, giờ mở cửa và chọn nơi muốn ghé.',
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

class FakeMapPanel extends StatelessWidget {
  final BranchLocation? selectedLocation;

  const FakeMapPanel({super.key, required this.selectedLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 20,
            child: _MapBubble(
              label: 'Cafe',
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          Positioned(
            right: 20,
            top: 26,
            child: _MapBubble(
              label: 'Spa',
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          Positioned(
            left: 52,
            bottom: 28,
            child: _MapBubble(
              label: 'Park',
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          Positioned(
            right: 62,
            bottom: 34,
            child: _MapBubble(
              label: 'Pet',
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),

          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SoftCard(
              color: Colors.white.withValues(alpha: 0.88),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLocation == null
                          ? 'Chọn một chi nhánh bên dưới để xem nhanh.'
                          : '${selectedLocation!.name} • ${selectedLocation!.distance}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBubble extends StatelessWidget {
  final String label;
  final Color color;

  const _MapBubble({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class BranchCategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const BranchCategorySelector({
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
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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

class BranchLocationCard extends StatelessWidget {
  final BranchLocation location;
  final bool isSelected;
  final VoidCallback onTap;

  const BranchLocationCard({
    super.key,
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: isSelected ? AppColors.primarySoft : Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: location.color,
            child: Icon(location.icon, color: AppColors.textDark, size: 30),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  location.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location.rating.toString(),
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location.distance,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_ios_rounded,
            color: isSelected ? AppColors.primary : AppColors.textSoft,
            size: isSelected ? 22 : 16,
          ),
        ],
      ),
    );
  }
}

class BranchDetailSheet extends StatelessWidget {
  final BranchLocation location;

  const BranchDetailSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSoft.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 22),
            CircleAvatar(
              radius: 44,
              backgroundColor: location.color,
              child: Icon(location.icon, color: AppColors.textDark, size: 42),
            ),
            const SizedBox(height: 16),
            Text(
              location.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              location.address,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 18),
            SoftCard(
              color: Colors.white,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.category_rounded,
                    label: 'Loại chi nhánh',
                    value: location.category,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.near_me_rounded,
                    label: 'Khoảng cách',
                    value: location.distance,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Giờ mở cửa',
                    value: location.openTime,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.star_rounded,
                    label: 'Đánh giá',
                    value: '${location.rating}/5',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Chỉ đường'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã chọn ${location.name}.')),
                      );
                    },
                    icon: const Icon(Icons.event_seat_rounded),
                    label: const Text('Đặt bàn'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
