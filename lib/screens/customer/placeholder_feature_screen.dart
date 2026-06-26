import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_card.dart';

class PlaceholderFeatureScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderFeatureScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SoftCard(
          color: AppColors.peach,
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white.withOpacity(0.8),
                child: Icon(
                  icon,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}