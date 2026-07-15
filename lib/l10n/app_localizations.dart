import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController {
  AppLocaleController._();
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('vi'));
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locale.value = Locale(prefs.getString('app_locale') ?? 'vi');
  }

  static Future<void> set(Locale value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', value.languageCode);
  }
}

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('vi'));
  bool get isVietnamese => locale.languageCode == 'vi';
  String get welcomeTitle =>
      isVietnamese ? 'Chào mừng đến PetHub' : 'Welcome to PetHub';
  String get welcomeSubtitle => isVietnamese
      ? 'Một hệ sinh thái thân thiện cho bạn và người bạn bốn chân.'
      : 'A friendly ecosystem for you and your four-legged companion.';
  String get getStarted => isVietnamese ? 'Khám phá PetHub' : 'Explore PetHub';
  String get language => isVietnamese ? 'Ngôn ngữ' : 'Language';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      const ['vi', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
