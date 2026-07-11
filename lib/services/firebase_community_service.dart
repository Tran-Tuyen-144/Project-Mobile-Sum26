import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/community/community_post.dart';

class FirebaseCommunityService {
  FirebaseCommunityService._();

  static final CollectionReference<Map<String, dynamic>> _posts =
  FirebaseFirestore.instance.collection('community_posts');

  static Stream<List<CommunityPost>> watchPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return CommunityPost.fromJson({
          ...data,
          'id': data['id'] ?? int.tryParse(doc.id),
        });
      }).toList();
    });
  }

  static Stream<List<CommunityPost>> watchPostsByAuthor(String authorId) {
    return _posts
        .where('authorId', isEqualTo: authorId)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();

        return CommunityPost.fromJson({
          ...data,
          'id': data['id'] ?? int.tryParse(doc.id),
        });
      }).toList();

      posts.sort((a, b) => b.id.compareTo(a.id));

      return posts;
    });
  }


  static Future<void> createPost(CommunityPost post) async {
    await _posts.doc(post.id.toString()).set({
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'avatarIconKey': post.avatarIconKey,
      'colorKey': post.colorKey,
      'timeAgo': post.timeAgo,
      'content': post.content,
      'category': post.category,
      'likes': post.likes,
      'likedBy': post.likedBy,
      'commentList': post.commentList.map((comment) => comment.toJson()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePost(CommunityPost post) async {
    await _posts.doc(post.id.toString()).update({
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'avatarIconKey': post.avatarIconKey,
      'colorKey': post.colorKey,
      'timeAgo': post.timeAgo,
      'content': post.content,
      'category': post.category,
      'commentList': post.commentList.map((comment) => comment.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deletePost(CommunityPost post) async {
    await _posts.doc(post.id.toString()).delete();
  }

  static Future<void> toggleLike({
    required CommunityPost post,
    required String userId,
  }) async {
    final postRef = _posts.doc(post.id.toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final rawLikedBy = data['likedBy'];

      final likedBy = rawLikedBy is List
          ? rawLikedBy.map((item) => item.toString()).toList()
          : <String>[];

      final currentLikes = (data['likes'] as num?)?.toInt() ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);

        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes > 0 ? currentLikes - 1 : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        likedBy.add(userId);

        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}