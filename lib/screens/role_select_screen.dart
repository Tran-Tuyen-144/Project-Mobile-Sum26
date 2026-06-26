import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'PetHub',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 34,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Một chiếc app nhỏ xinh cho cafe thú cưng, đặt bàn, tìm dịch vụ và kết nối cộng đồng yêu pet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              _RoleCard(
                title: 'Khách hàng',
                subtitle: 'Đặt bàn, tìm dịch vụ, xem bản đồ và lướt cộng đồng.',
                icon: Icons.favorite_rounded,
                color: AppColors.primarySoft,
                onTap: () {
                  context.push('/customer');
                },
              ),

              const SizedBox(height: 18),

              _RoleCard(
                title: 'Quản lý / Nhân viên',
                subtitle: 'Quản lý đơn đặt bàn, thú cưng, ca làm và doanh thu.',
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.mint,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phần Admin mình sẽ làm sau nha.'),
                    ),
                  );
                },
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Pet-friendly • Pastel UI • Flutter App',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.75),
            child: Icon(
              icon,
              color: AppColors.textDark,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: AppColors.textSoft,
          ),
        ],
      ),
    );
  }
}