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

      posts.sort((first, second) => second.id.compareTo(first.id));

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

      return CommunityPost.fromJson({
        ...data,
        'id': data['id'] ?? postId,
      });
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

      // Ảnh lưu trên Cloudinary, Firestore chỉ lưu đường dẫn ảnh.
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

      // Không cập nhật commentList ở đây để tránh ghi đè bình luận mới.
      'imageUrl': post.imageUrl,
      'imagePublicId': post.imagePublicId,

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

  static Future<void> addComment({
    required int postId,
    required PostComment comment,
  }) async {
    final postRef = _posts.doc(postId.toString());

    await _runWithRetry(() async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception('Bài viết không còn tồn tại.');
        }

        final data = snapshot.data();

        if (data == null) {
          throw Exception('Không đọc được dữ liệu bài viết.');
        }

        final comments = _readComments(data['commentList']);

        final commentAlreadyExists = comments.any(
              (item) => item.id == comment.id,
        );

        if (commentAlreadyExists) {
          return;
        }

        comments.add(comment);

        transaction.update(postRef, {
          'commentList': comments
              .map((item) => item.toJson())
              .toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    });
  }
  static Future<void> updateComment({
    required int postId,
    required PostComment comment,
  }) async {
    final postRef = _posts.doc(postId.toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      final comments = _readComments(data['commentList']);

      final commentIndex = comments.indexWhere(
            (item) => item.id == comment.id,
      );

      if (commentIndex < 0) {
        throw Exception('Bình luận không còn tồn tại.');
      }

      comments[commentIndex] = comment;

      transaction.update(postRef, {
        'commentList': comments.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    final postRef = _posts.doc(postId.toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      final comments = _readComments(data['commentList']);

      final oldLength = comments.length;

      comments.removeWhere((item) => item.id == commentId);

      if (comments.length == oldLength) {
        throw Exception('Bình luận không còn tồn tại.');
      }

      transaction.update(postRef, {
        'commentList': comments.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> syncAuthorIdentity({
    required String authorId,
    required bool isAnonymous,
    required String authorName,
    required String avatarIconKey,
  }) async {
    final snapshot = await _posts
        .where('authorId', isEqualTo: authorId)
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
  static Future<void> _runWithRetry(
      Future<void> Function() operation,
      ) async {
    const maximumAttempts = 4;

    var retryDelay = const Duration(
      milliseconds: 700,
    );

    for (
    var attempt = 1;
    attempt <= maximumAttempts;
    attempt++
    ) {
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

        retryDelay = Duration(
          milliseconds: retryDelay.inMilliseconds * 2,
        );
      }
    }
  }


  static List<PostComment> _readComments(Object? rawComments) {
    if (rawComments is! List) {
      return <PostComment>[];
    }

    return rawComments
        .whereType<Map>()
        .map(
          (item) => PostComment.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}