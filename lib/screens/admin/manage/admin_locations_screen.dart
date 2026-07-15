import 'package:flutter/material.dart';

import '../../customer/map/branch_location.dart';
import '../../../../theme/app_colors.dart';

class AdminLocationsScreen extends StatelessWidget {
  const AdminLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Địa điểm & chi nhánh'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Chi nhánh PetHub',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Theo dõi thông tin địa điểm đang hiển thị cho khách hàng.',
            style: TextStyle(color: AppColors.textSoft),
          ),
          const SizedBox(height: 18),
          ...branchLocations.map(
            (branch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdminBranchCard(branch: branch),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBranchCard extends StatelessWidget {
  final BranchLocation branch;

  const _AdminBranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: branch.kind.color,
            child: Icon(branch.kind.icon, color: AppColors.textDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branch.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSoft),
                ),
                const SizedBox(height: 8),
                Text(
                  '★ ${branch.rating}   •   ${branch.distance}   •   ${branch.travelTime}',
                  style: const TextStyle(color: AppColors.textSoft),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSoft),
        ],
      ),
    );
  }
}
