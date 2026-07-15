// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get registerNow => 'Register';

  @override
  String get loginSubtitle => 'Welcome back to PetHub.';

  @override
  String get registerSubtitle =>
      'Create an account to save your profile and posts.';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get orText => 'or';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';
}
