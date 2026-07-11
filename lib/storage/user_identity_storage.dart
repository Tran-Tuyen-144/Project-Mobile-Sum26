import 'package:shared_preferences/shared_preferences.dart';

class UserIdentityStorage {
  UserIdentityStorage._();

  static const String _userIdKey = 'local_user_id';

  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();

    final savedId = prefs.getString(_userIdKey);
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_userIdKey, newId);

    return newId;
  }
}