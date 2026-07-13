import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/community/community_post.dart';

class CustomerSavedPostService {
  CustomerSavedPostService._();

  static CollectionReference<Map<String, dynamic>> _savedPostsRef(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedCommunityPosts');
  }

  static Stream<Set<int>> watchSavedPostIds(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(<int>{});
    }

    return _savedPostsRef(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((document) {
            final data = document.data();

            return (data['postId'] as num?)?.toInt() ??
                int.tryParse(document.id);
          })
          .whereType<int>()
          .toSet();
    });
  }

  static Future<bool> toggleSavedPost({
    required String userId,
    required CommunityPost post,
  }) async {
    final reference = _savedPostsRef(userId).doc(post.id.toString());

    final snapshot = await reference.get();

    if (snapshot.exists) {
      await reference.delete();
      return false;
    }

    await _savePost(userId: userId, post: post);

    return true;
  }

  static Future<void> setSavedPost({
    required String userId,
    required CommunityPost post,
    required bool isSaved,
  }) async {
    final reference = _savedPostsRef(userId).doc(post.id.toString());

    if (!isSaved) {
      await reference.delete();
      return;
    }

    await _savePost(userId: userId, post: post);
  }

  static Future<void> _savePost({
    required String userId,
    required CommunityPost post,
  }) async {
    final cleanContent = post.content.trim();

    final contentPreview = cleanContent.length > 120
        ? '${cleanContent.substring(0, 120)}...'
        : cleanContent;

    await _savedPostsRef(userId).doc(post.id.toString()).set({
      'postId': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'category': post.category,
      'contentPreview': contentPreview,
      'imageUrl': post.imageUrl,
      'imagePublicId': post.imagePublicId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
}
