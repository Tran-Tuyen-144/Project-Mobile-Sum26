import 'package:firebase_auth/firebase_auth.dart';
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
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 18),
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              'Cafe thú cưng, dịch vụ chăm sóc Pet và cộng đồng dành cho người yêu động vật.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
            _RoleCard(
              title: 'Khách hàng',
              subtitle:
                  'Đặt bàn, tìm dịch vụ, xem bản đồ và tham gia cộng đồng.',
              icon: Icons.favorite_rounded,
              color: AppColors.primarySoft,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  context.push('/customer-auth');
                } else {
                  context.push('/customer');
                }
              },
            ),
            const SizedBox(height: 15),
            _RoleCard(
              title: 'Nhân viên',
              subtitle: 'Xử lý công việc, đơn hàng, Pet và Check-in.',
              icon: Icons.badge_rounded,
              color: AppColors.mint,
              onTap: () {
                context.push('/staff-role');
              },
            ),
            const SizedBox(height: 15),
            _RoleCard(
              title: 'Quản lý',
              subtitle: 'Quản lý đặt bàn, ca làm, nhân viên và doanh thu.',
              icon: Icons.admin_panel_settings_rounded,
              color: AppColors.sky,
              onTap: () {
                context.push('/admin');
              },
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                'Pet-friendly • Pastel UI • Flutter App',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
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
            backgroundColor: Colors.white.withValues(alpha: 0.75),
            child: Icon(icon, color: AppColors.textDark, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
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
