import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/pet_booking_store.dart' as booking_store;
import '../../../widgets/section_title.dart';
import 'profile_models.dart' as profile_models;
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
            child: ValueListenableBuilder<List<booking_store.PetProfile>>(
              valueListenable: booking_store.PetBookingStore.instance.petsNotifier,
              builder: (context, pets, _) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return ProfilePetProfileCard(
                      pet: pet,
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          const SectionTitle(title: 'Tài khoản của tôi'),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: profile_models.profileMenus.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = profile_models.profileMenus[index];

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