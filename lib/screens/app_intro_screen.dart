import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class AppIntroScreen extends StatelessWidget {
  const AppIntroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () => _pickLanguage(context),
                  icon: const Icon(Icons.language_rounded),
                  label: Text(text.language),
                ),
              ),
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: AppColors.primary,
                  size: 54,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                text.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text.welcomeSubtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.45,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 30),
              const _Feature(
                icon: Icons.local_cafe_rounded,
                vi: 'Cafe & đặt bàn',
                en: 'Cafe & reservations',
              ),
              const _Feature(
                icon: Icons.health_and_safety_rounded,
                vi: 'Spa, Hotel & chăm sóc sức khỏe',
                en: 'Spa, hotel & pet care',
              ),
              const _Feature(
                icon: Icons.groups_rounded,
                vi: 'Cộng đồng yêu thú cưng',
                en: 'Pet-loving community',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/role'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(text.getStarted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickLanguage(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Text('🇻🇳', style: TextStyle(fontSize: 22)),
            title: const Text('Tiếng Việt'),
            onTap: () async {
              await AppLocaleController.set(const Locale('vi'));
              if (sheetContext.mounted) Navigator.pop(sheetContext);
            },
          ),
          ListTile(
            leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
            title: const Text('English'),
            onTap: () async {
              await AppLocaleController.set(const Locale('en'));
              if (sheetContext.mounted) Navigator.pop(sheetContext);
            },
          ),
        ],
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String vi;
  final String en;
  const _Feature({required this.icon, required this.vi, required this.en});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          AppLocalizations.of(context).isVietnamese ? vi : en,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    ),
  );
}
