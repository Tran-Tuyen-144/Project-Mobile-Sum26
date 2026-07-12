import 'package:flutter/material.dart';

import '../../../services/pet_booking_store.dart' as booking_store;
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'profile_models.dart' as profile_models;

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            AppColors.primarySoft,
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
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trần Mộng Tuyền',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Khách hàng thân thiết của PetHub',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Pet Lover • Thành viên mới',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
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

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            value: '06',
            label: 'Lần đặt bàn',
            color: AppColors.peach,
            icon: Icons.event_available_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ProfileStatCard(
            value: '02',
            label: 'Bé pet',
            color: AppColors.mint,
            icon: Icons.pets_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ProfileStatCard(
            value: '14',
            label: 'Bài đã lưu',
            color: AppColors.lavender,
            icon: Icons.bookmark_rounded,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _ProfileStatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textDark,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PetProfileCard extends StatelessWidget {
  final profile_models.PetProfile pet;

  const PetProfileCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: SoftCard(
        color: pet.color,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(
                pet.icon,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pet.age,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePetProfileCard extends StatelessWidget {
  final booking_store.PetProfile pet;

  const ProfilePetProfileCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBooked = pet.bookingStatus == 'Đã được đặt';
    return SizedBox(
      width: 190,
      child: SoftCard(
        color: pet.isAvailable ? pet.color : Colors.grey.shade200,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(
                Icons.pets_rounded,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.age,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBooked ? 'Đã được đặt' : 'Có sẵn',
                    style: TextStyle(
                      color: isBooked ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final profile_models.ProfileMenuItem item;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.item,
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
            backgroundColor: item.color,
            child: Icon(
              item.icon,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFE1E1),
      onTap: onLogout,
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.logout_rounded,
              color: Color(0xFFD45A5A),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Đăng xuất về màn chọn chức vụ',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSoft,
          ),
        ],
      ),
    );
  }
}