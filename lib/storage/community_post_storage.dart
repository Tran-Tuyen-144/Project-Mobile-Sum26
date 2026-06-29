import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../screens/customer/community/community_post.dart';

class CommunityPostStorage {
  static const String _key = 'user_community_posts';

  static Future<void> savePosts(List<CommunityPost> posts) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> encodedPosts = posts.map((post) {
      return jsonEncode(post.toJson());
    }).toList();

    await prefs.setStringList(_key, encodedPosts);
  }

  static Future<List<CommunityPost>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> encodedPosts = prefs.getStringList(_key) ?? [];

    final List<CommunityPost> posts = [];

    for (final encodedPost in encodedPosts) {
      try {
        final decoded = jsonDecode(encodedPost) as Map<String, dynamic>;
        posts.add(CommunityPost.fromJson(decoded));
      } catch (_) {
        // Nếu dữ liệu cũ bị lỗi thì bỏ qua item đó để app không crash.
      }
    }

    return posts;
  }

  static Future<void> clearPosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}