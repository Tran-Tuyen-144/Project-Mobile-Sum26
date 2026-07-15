import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/community/community_post.dart';

class FirebaseCommunityCommentService {
  FirebaseCommunityCommentService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _postReference(int postId) {
    return _firestore.collection('community_posts').doc(postId.toString());
  }

  static CollectionReference<Map<String, dynamic>> _commentsReference(
    int postId,
  ) {
    return _postReference(postId).collection('comments');
  }

  static Stream<List<PostComment>> watchComments(int postId) {
    return _commentsReference(postId).orderBy('createdAt').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((document) {
        final data = document.data();

        return PostComment.fromJson({
          ...data,
          'id':
              data['id'] ??
              int.tryParse(document.id) ??
              DateTime.now().millisecondsSinceEpoch,
        });
      }).toList();
    });
  }

  /// Chuyển các bình luận cũ đang nằm trong commentList
  /// sang subcollection comments.
  ///
  /// Hàm này có thể gọi nhiều lần vì chỉ tạo các document
  /// chưa tồn tại.
  static Future<void> migrateLegacyComments({required int postId}) async {
    final postReference = _postReference(postId);

    final postSnapshot = await postReference.get();

    if (!postSnapshot.exists) {
      throw Exception('Bài viết không còn tồn tại.');
    }

    final postData = postSnapshot.data();

    if (postData == null) {
      throw Exception('Không đọc được dữ liệu bài viết.');
    }

    final legacyComments = _readLegacyComments(postData['commentList']);

    final existingSnapshot = await _commentsReference(postId).get();

    final existingCommentIds = existingSnapshot.docs
        .map((document) => document.id)
        .toSet();

    final missingComments = legacyComments.where((comment) {
      return !existingCommentIds.contains(comment.id.toString());
    }).toList();

    const maximumWritesPerBatch = 400;

    for (
      var start = 0;
      start < missingComments.length;
      start += maximumWritesPerBatch
    ) {
      final proposedEnd = start + maximumWritesPerBatch;

      final end = proposedEnd < missingComments.length
          ? proposedEnd
          : missingComments.length;

      final batch = _firestore.batch();

      for (var index = start; index < end; index++) {
        final comment = missingComments[index];

        final commentReference = _commentsReference(
          postId,
        ).doc(comment.id.toString());

        batch.set(
          commentReference,
          _commentDataForMigration(comment),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    }

    final migratedCommentIds = <String>{
      ...existingCommentIds,
      ...legacyComments.map((comment) => comment.id.toString()),
    };

    await _firestore.runTransaction((transaction) async {
      final latestPostSnapshot = await transaction.get(postReference);

      if (!latestPostSnapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final latestPostData = latestPostSnapshot.data();

      if (latestPostData == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      final currentCommentCount = _readCommentCount(latestPostData);

      final migratedCommentCount = migratedCommentIds.length;

      final nextCommentCount = currentCommentCount > migratedCommentCount
          ? currentCommentCount
          : migratedCommentCount;

      transaction.update(postReference, {'commentCount': nextCommentCount});
    });
  }

  static Future<void> addComment({
    required int postId,
    required PostComment comment,
  }) async {
    final cleanContent = comment.content.trim();

    if (cleanContent.isEmpty) {
      throw Exception('Bình luận không được để trống.');
    }

    final postReference = _postReference(postId);

    final commentReference = _commentsReference(
      postId,
    ).doc(comment.id.toString());

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postReference);

      final commentSnapshot = await transaction.get(commentReference);

      if (!postSnapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final postData = postSnapshot.data();

      if (postData == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      if (commentSnapshot.exists) {
        return;
      }

      final currentCommentCount = _readCommentCount(postData);

      transaction.set(commentReference, {
        'id': comment.id,
        'authorId': comment.authorId,
        'authorName': comment.authorName,
        'isAnonymous': comment.isAnonymous,
        'avatarIconKey': comment.avatarIconKey,
        'colorKey': comment.colorKey,
        'content': cleanContent,
        'timeAgo': 'Vừa xong',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      transaction.update(postReference, {
        'commentCount': currentCommentCount + 1,
      });
    });
  }

  static Future<void> updateComment({
    required int postId,
    required PostComment comment,
    required String currentUserId,
  }) async {
    final cleanUserId = currentUserId.trim();
    final cleanContent = comment.content.trim();

    if (cleanUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    if (cleanContent.isEmpty) {
      throw Exception('Bình luận không được để trống.');
    }

    final postReference = _postReference(postId);

    final commentReference = _commentsReference(
      postId,
    ).doc(comment.id.toString());

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postReference);

      final commentSnapshot = await transaction.get(commentReference);

      if (!postSnapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      if (!commentSnapshot.exists) {
        throw Exception('Bình luận không còn tồn tại.');
      }

      final commentData = commentSnapshot.data();

      if (commentData == null) {
        throw Exception('Không đọc được dữ liệu bình luận.');
      }

      final storedAuthorId = commentData['authorId'] as String? ?? '';

      if (storedAuthorId != cleanUserId) {
        throw Exception('Bạn chỉ có thể sửa bình luận của mình.');
      }

      transaction.update(commentReference, {
        'content': cleanContent,
        'timeAgo': 'Vừa chỉnh sửa',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> deleteComment({
    required int postId,
    required int commentId,
    required String currentUserId,
  }) async {
    final cleanUserId = currentUserId.trim();

    if (cleanUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final postReference = _postReference(postId);

    final commentReference = _commentsReference(
      postId,
    ).doc(commentId.toString());

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postReference);

      final commentSnapshot = await transaction.get(commentReference);

      if (!postSnapshot.exists) {
        throw Exception('Bài viết không còn tồn tại.');
      }

      final postData = postSnapshot.data();

      if (postData == null) {
        throw Exception('Không đọc được dữ liệu bài viết.');
      }

      if (!commentSnapshot.exists) {
        throw Exception('Bình luận không còn tồn tại.');
      }

      final commentData = commentSnapshot.data();

      if (commentData == null) {
        throw Exception('Không đọc được dữ liệu bình luận.');
      }

      final storedAuthorId = commentData['authorId'] as String? ?? '';

      if (storedAuthorId != cleanUserId) {
        throw Exception('Bạn chỉ có thể xóa bình luận của mình.');
      }

      final currentCommentCount = _readCommentCount(postData);

      transaction.delete(commentReference);

      transaction.update(postReference, {
        'commentCount': currentCommentCount > 0 ? currentCommentCount - 1 : 0,
      });
    });
  }

  static Map<String, dynamic> _commentDataForMigration(PostComment comment) {
    final createdAt = comment.createdAt;
    final updatedAt = comment.updatedAt;

    return {
      'id': comment.id,
      'authorId': comment.authorId,
      'authorName': comment.authorName,
      'isAnonymous': comment.isAnonymous,
      'avatarIconKey': comment.avatarIconKey,
      'colorKey': comment.colorKey,
      'content': comment.content,
      'timeAgo': comment.timeAgo,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt.toUtc()),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  static List<PostComment> _readLegacyComments(Object? rawComments) {
    if (rawComments is! List) {
      return <PostComment>[];
    }

    return rawComments
        .whereType<Map>()
        .map((item) => PostComment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static int _readCommentCount(Map<String, dynamic> postData) {
    final storedCommentCount = (postData['commentCount'] as num?)?.toInt();

    if (storedCommentCount != null && storedCommentCount >= 0) {
      return storedCommentCount;
    }

    final legacyComments = postData['commentList'];

    if (legacyComments is List) {
      return legacyComments.length;
    }

    return 0;
  }
}
