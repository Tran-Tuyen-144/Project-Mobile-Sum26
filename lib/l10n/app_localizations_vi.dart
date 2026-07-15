// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get registerNow => 'Đăng ký';

  @override
  String get loginSubtitle => 'Chào mừng bạn quay lại PetHub.';

  @override
  String get registerSubtitle =>
      'Tạo tài khoản khách hàng để lưu hồ sơ và bài viết.';

  @override
  String get fullName => 'Họ tên';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get confirmPassword => 'Nhập lại mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginGoogle => 'Tiếp tục với Google';

  @override
  String get orText => 'hoặc';

  @override
  String get noAccount => 'Chưa có tài khoản? ';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';
}
