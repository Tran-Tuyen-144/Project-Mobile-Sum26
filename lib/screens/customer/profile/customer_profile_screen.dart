import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/section_title.dart';
import 'profile_models.dart';
import 'profile_widgets.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title sẽ được làm ở bước sau.'),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileHeader(),

          const SizedBox(height: 22),

          const ProfileStatsRow(),

          const SizedBox(height: 26),

          const SectionTitle(
            title: 'Pet của tôi',
            actionText: 'Thêm pet',
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myPets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return PetProfileCard(
                  pet: myPets[index],
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          const SectionTitle(title: 'Tài khoản của tôi'),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: profileMenus.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = profileMenus[index];

              return ProfileMenuTile(
                item: item,
                onTap: () => _showComingSoon(context, item.title),
              );
            },
          ),

          const SizedBox(height: 18),

          LogoutCard(
            onLogout: () => _logout(context),
          ),
        ],
      ),
    );
  }
}