import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/community/community_post.dart';

class FirebaseCommunityService {
  FirebaseCommunityService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>> _posts = _firestore
      .collection('community_posts');

  static Stream<List<CommunityPost>> watchPosts() {
    return _posts.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((document) {
        final data = document.data();

        return CommunityPost.fromJson({
          ...data,
          'id': data['id'] ?? int.tryParse(document.id),
        });
      }).toList();
    });
  }

  static Stream<List<CommunityPost>> watchPostsByAuthor(String authorId) {
    return _posts.where('authorId', isEqualTo: authorId).snapshots().map((
      snapshot,
    ) {
      final posts = snapshot.docs.map((document) {
        final data = document.data();

        return CommunityPost.fromJson({
          ...data,
          'id': data['id'] ?? int.tryParse(document.id),
        });
      }).toList();

      posts.sort((first, second) {
        final firstTime = first.createdAt;
        final secondTime = second.createdAt;

        if (firstTime != null && secondTime != null) {
          return secondTime.compareTo(firstTime);
        }

        return second.id.compareTo(first.id);
      });

      return posts;
    });
  }

  static Stream<CommunityPost?> watchPost(int postId) {
    return _posts.doc(postId.toString()).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      return CommunityPost.fromJson({...data, 'id': data['id'] ?? postId});
    });
  }

  static Future<void> createPost(CommunityPost post) async {
    final cleanContent = post.content.trim();

    if (cleanContent.isEmpty) {
      throw Exception('Nội dung bài viết không được để trống.');
    }

    final imageUrls = post.allImageUrls;
    final imagePublicIds = post.allImagePublicIds;

    if (imageUrls.length > 5 || imagePublicIds.length > 5) {
      throw Exception('Mỗi bài viết chỉ được tối đa 5 ảnh.');
    }

    await _posts.doc(post.id.toString()).set({
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorRole': post.authorRole,
      'isAnonymous': post.isAnonymous,
      'avatarIconKey': post.avatarIconKey,
      'colorKey': post.colorKey,
      'timeAgo': 'Vừa xong',
      'content': cleanContent,
      'category': post.category.trim(),
      'imageUrl': imageUrls.isEmpty ? null : imageUrls.first,
      'imagePublicId': imagePublicIds.isEmpty ? null : imagePublicIds.first,
      'imageUrls': imageUrls,
      'imagePublicIds': imagePublicIds,
      'likes': 0,
      'likedBy': const <String>[],
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePost(CommunityPost post) async {
    final cleanContent = post.content.trim();

    if (cleanContent.isEmpty) {
      throw Exception('Nội dung bài viết không được để trống.');
    }

    final imageUrls = post.allImageUrls;
    final imagePublicIds = post.allImagePublicIds;

    if (imageUrls.length > 5 || imagePublicIds.length > 5) {
      throw Exception('Mỗi bài viết chỉ được tối đa 5 ảnh.');
    }

    final postReference = _posts.doc(post.id.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postReference);

      if (!snapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      transaction.update(postReference, {
        'authorId': post.authorId,
        'authorName': post.authorName,
        'authorRole': post.authorRole,
        'isAnonymous': post.isAnonymous,
        'avatarIconKey': post.avatarIconKey,
        'colorKey': post.colorKey,
        'timeAgo': 'Vừa chỉnh sửa',
        'content': cleanContent,
        'category': post.category.trim(),
        'imageUrl': imageUrls.isEmpty ? null : imageUrls.first,
        'imagePublicId': imagePublicIds.isEmpty ? null : imagePublicIds.first,
        'imageUrls': imageUrls,
        'imagePublicIds': imagePublicIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> deletePost(CommunityPost post) async {
    final postReference = _posts.doc(post.id.toString());

    await _deleteCommentsSubcollection(postReference);

    await _runWithRetry(() => postReference.delete());
  }

  static Future<void> toggleLike({
    required CommunityPost post,
    required String userId,
  }) async {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final postReference = _posts.doc(post.id.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postReference);

      if (!snapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      final rawLikedBy = data['likedBy'];

      final likedBy = rawLikedBy is List
          ? rawLikedBy.map((item) => item.toString()).toList()
          : <String>[];

      final currentLikes = (data['likes'] as num?)?.toInt() ?? 0;

      if (likedBy.contains(cleanUserId)) {
        likedBy.remove(cleanUserId);

        transaction.update(postReference, {
          'likedBy': likedBy,
          'likes': currentLikes > 0 ? currentLikes - 1 : 0,
        });

        return;
      }

      likedBy.add(cleanUserId);

      transaction.update(postReference, {
        'likedBy': likedBy,
        'likes': currentLikes + 1,
      });
    });
  }

  static Future<void> syncAuthorIdentity({
    required String authorId,
    required bool isAnonymous,
    required String authorName,
    required String avatarIconKey,
  }) async {
    final cleanAuthorId = authorId.trim();
    final cleanAuthorName = authorName.trim();
    final cleanAvatarIconKey = avatarIconKey.trim();

    if (cleanAuthorId.isEmpty) {
      return;
    }

    final resolvedAuthorName = cleanAuthorName.isEmpty
        ? isAnonymous
              ? 'Ẩn danh PetHub'
              : 'Bạn PetHub'
        : cleanAuthorName;

    final resolvedAvatarIconKey = cleanAvatarIconKey.isEmpty
        ? isAnonymous
              ? 'anonymous'
              : 'default_person'
        : cleanAvatarIconKey;

    final snapshot = await _posts
        .where('authorId', isEqualTo: cleanAuthorId)
        .get();

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
      final proposedEnd = start + maximumWritesPerBatch;

      final end = proposedEnd < matchingDocuments.length
          ? proposedEnd
          : matchingDocuments.length;

      final batch = _firestore.batch();

      for (var index = start; index < end; index++) {
        final document = matchingDocuments[index];

        batch.update(document.reference, {
          'authorName': resolvedAuthorName,
          'authorRole': isAnonymous
              ? 'Thành viên ẩn danh'
              : 'Thành viên PetHub',
          'isAnonymous': isAnonymous,
          'avatarIconKey': resolvedAvatarIconKey,
          'colorKey': CommunityPost.colorKeyFromIconKey(resolvedAvatarIconKey),
        });
      }

      await _runWithRetry(() => batch.commit());
    }
  }

  static Future<void> _deleteCommentsSubcollection(
    DocumentReference<Map<String, dynamic>> postReference,
  ) async {
    const batchSize = 400;

    while (true) {
      final snapshot = await postReference
          .collection('comments')
          .limit(batchSize)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await _runWithRetry(() => batch.commit());

      if (snapshot.docs.length < batchSize) {
        return;
      }
    }
  }

  static Future<void> _runWithRetry(Future<void> Function() operation) async {
    const maximumAttempts = 4;

    var retryDelay = const Duration(milliseconds: 700);

    for (var attempt = 1; attempt <= maximumAttempts; attempt++) {
      try {
        await operation();
        return;
      } on FirebaseException catch (error) {
        final canRetry =
            error.code == 'unavailable' ||
            error.code == 'deadline-exceeded' ||
            error.code == 'aborted';

        if (!canRetry || attempt == maximumAttempts) {
          rethrow;
        }

        await Future.delayed(retryDelay);

        retryDelay = Duration(milliseconds: retryDelay.inMilliseconds * 2);
      }
    }
  }
}
