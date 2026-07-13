import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/community/community_post.dart';

class FirebaseCommunityService {
  FirebaseCommunityService._();

  static final CollectionReference<Map<String, dynamic>> _posts =
      FirebaseFirestore.instance.collection('community_posts');

  static Stream<List<CommunityPost>> watchPosts() {
    return _posts.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
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
    return _posts.where('authorId', isEqualTo: authorId).snapshots().map((
      snapshot,
    ) {
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();

        return CommunityPost.fromJson({
          ...data,
          'id': data['id'] ?? int.tryParse(doc.id),
        });
      }).toList();

      posts.sort((first, second) => second.id.compareTo(first.id));

      return posts;
    });
  }

  static Future<void> createPost(CommunityPost post) async {
    await _posts.doc(post.id.toString()).set({
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'isAnonymous': post.isAnonymous,
      'avatarIconKey': post.avatarIconKey,
      'colorKey': post.colorKey,
      'timeAgo': post.timeAgo,
      'content': post.content,
      'category': post.category,

      // Ảnh lưu trên Cloudinary, Firestore chỉ lưu link.
      'imageUrl': post.imageUrl,
      'imagePublicId': post.imagePublicId,

      'likes': post.likes,
      'likedBy': post.likedBy,
      'commentList': post.commentList
          .map((comment) => comment.toJson())
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePost(CommunityPost post) async {
    await _posts.doc(post.id.toString()).update({
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'isAnonymous': post.isAnonymous,
      'avatarIconKey': post.avatarIconKey,
      'colorKey': post.colorKey,
      'timeAgo': post.timeAgo,
      'content': post.content,
      'category': post.category,

      // Cập nhật ảnh khi sửa bài viết.
      'imageUrl': post.imageUrl,
      'imagePublicId': post.imagePublicId,

      'commentList': post.commentList
          .map((comment) => comment.toJson())
          .toList(),
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

  static Future<void> syncAuthorIdentity({
    required String authorId,
    required bool isAnonymous,
    required String authorName,
    required String avatarIconKey,
  }) async {
    final snapshot = await _posts.where('authorId', isEqualTo: authorId).get();

    final matchingDocuments = snapshot.docs.where((document) {
      final data = document.data();

      final storedRole = data['authorRole'] as String? ?? '';

      final storedAnonymous =
          data['isAnonymous'] as bool? ??
          storedRole.toLowerCase().contains('ẩn danh');

      return storedAnonymous == isAnonymous;
    }).toList();

    if (matchingDocuments.isEmpty) {
      return;
    }

    const maximumWritesPerBatch = 450;

    for (
      var start = 0;
      start < matchingDocuments.length;
      start += maximumWritesPerBatch
    ) {
      final end = start + maximumWritesPerBatch < matchingDocuments.length
          ? start + maximumWritesPerBatch
          : matchingDocuments.length;

      final batch = FirebaseFirestore.instance.batch();

      for (var index = start; index < end; index++) {
        final document = matchingDocuments[index];

        batch.update(document.reference, {
          'authorName': authorName,
          'authorRole': isAnonymous
              ? 'Thành viên ẩn danh'
              : 'Thành viên PetHub',
          'isAnonymous': isAnonymous,
          'avatarIconKey': avatarIconKey,
          'colorKey': CommunityPost.colorKeyFromIconKey(avatarIconKey),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }
  }
}
