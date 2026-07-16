import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/section_title.dart';
import '../../widgets/soft_card.dart';

class CustomerHomeScreen extends StatelessWidget {
  final VoidCallback onOpenBooking;
  final VoidCallback onOpenOrder;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenCommunity;
  final VoidCallback onOpenPetProfile;

  const CustomerHomeScreen({
    super.key,
    required this.onOpenBooking,
    required this.onOpenOrder,
    required this.onOpenServices,
    required this.onOpenCommunity,
    required this.onOpenPetProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeBanner(onExplore: onOpenBooking),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Bạn muốn làm gì hôm nay?'),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.event_seat_rounded,
                  title: 'Đặt bàn',
                  color: AppColors.peach,
                  onTap: onOpenBooking,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.local_cafe_rounded,
                  title: 'Gọi món',
                  color: AppColors.primarySoft,
                  onTap: onOpenOrder,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.forum_rounded,
                  title: 'Cộng đồng',
                  color: AppColors.lavender,
                  onTap: onOpenCommunity,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.pets_rounded,
                  title: 'Đào',
                  color: AppColors.mint,
                  onTap: onOpenPetProfile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.spa_rounded,
                  title: 'Dịch vụ',
                  color: AppColors.peach,
                  onTap: onOpenServices,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          SectionTitle(
            title: 'Dịch vụ nổi bật',
            actionText: 'Tất cả',
            onActionTap: onOpenServices,
          ),

          const SizedBox(height: 12),

          _ServicePreview(onOpenServices: onOpenServices),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final VoidCallback onExplore;

  const _WelcomeBanner({required this.onExplore});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cafe thú cưng\nấm áp gần bạn',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(height: 1.15),
                ),
                const SizedBox(height: 10),
                Text(
                  'Đặt bàn trước, chọn món nhẹ nhàng và ghé chơi cùng các bé pet đáng yêu.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.pets_rounded),
                  label: const Text('Khám phá ngay'),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textDark, size: 30),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ServicePreview extends StatelessWidget {
  final VoidCallback onOpenServices;

  const _ServicePreview({required this.onOpenServices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ServiceTile(
          icon: Icons.spa_rounded,
          title: 'Spa thú cưng',
          subtitle: 'Tắm, massage, chăm sóc lông nhẹ nhàng.',
          color: AppColors.peach,
          onTap: onOpenServices,
        ),
        const SizedBox(height: 12),
        _ServiceTile(
          icon: Icons.local_hotel_rounded,
          title: 'Khách sạn thú cưng',
          subtitle: 'Gửi bé yêu khi bạn bận đi học, đi làm.',
          color: AppColors.mint,
          onTap: onOpenServices,
        ),
        const SizedBox(height: 12),
        _ServiceTile(
          icon: Icons.medical_services_rounded,
          title: 'Bệnh viện thú y',
          subtitle: 'Tra cứu phòng khám và dịch vụ gần nhất.',
          color: AppColors.sky,
          onTap: onOpenServices,
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: AppColors.textDark),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSoft,
          ),
        ],
      ),
    );
  }
}
