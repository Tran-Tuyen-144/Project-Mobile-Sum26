import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  ProfileStorage._();

  static const String _avatarPathKey = 'profile_avatar_path';
  static const String _displayNameKey = 'profile_display_name';

  static Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPathKey, path);
  }

  static Future<String?> loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarPathKey);
  }

  static Future<void> clearAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarPathKey);
  }

  static Future<void> saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
  }

  static Future<String> loadDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey) ?? 'Trần Mộng Tuyền';
  }
}