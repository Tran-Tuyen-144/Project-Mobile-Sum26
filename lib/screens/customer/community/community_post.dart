import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PostComment {
  final int id;
  final String authorId;
  final String authorName;
  final bool isAnonymous;
  final String avatarIconKey;
  final String colorKey;
  final String content;
  final String timeAgo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostComment({
    required this.id,
    this.authorId = 'sample',
    required this.authorName,
    this.isAnonymous = true,
    this.avatarIconKey = 'anonymous',
    this.colorKey = 'peach',
    required this.content,
    required this.timeAgo,
    this.createdAt,
    this.updatedAt,
  });

  IconData get petIcon {
    return CommunityPost.iconFromKey(avatarIconKey);
  }

  Color get color {
    return CommunityPost.colorFromKey(colorKey);
  }

  bool get isEdited {
    return timeAgo.trim().toLowerCase() == 'vừa chỉnh sửa';
  }

  String get displayTimeAgo {
    final commentTime = createdAt;

    if (commentTime == null) {
      return timeAgo;
    }

    return _formatRelativeTime(commentTime);
  }

  String get displayTimeLabel {
    if (!isEdited) {
      return displayTimeAgo;
    }

    return '$displayTimeAgo • Đã chỉnh sửa';
  }

  PostComment copyWith({
    int? id,
    String? authorId,
    String? authorName,
    bool? isAnonymous,
    String? avatarIconKey,
    String? colorKey,
    String? content,
    String? timeAgo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool removeUpdatedAt = false,
  }) {
    return PostComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      avatarIconKey: avatarIconKey ?? this.avatarIconKey,
      colorKey: colorKey ?? this.colorKey,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: removeUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'isAnonymous': isAnonymous,
      'avatarIconKey': avatarIconKey,
      'colorKey': colorKey,
      'content': content,
      'timeAgo': timeAgo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final isAnonymous = json['isAnonymous'] as bool? ?? true;

    final avatarIconKey =
        json['avatarIconKey'] as String? ??
        (isAnonymous ? 'anonymous' : 'default_person');

    final colorKey =
        json['colorKey'] as String? ??
        CommunityPost.colorKeyFromIconKey(avatarIconKey);

    return PostComment(
      id:
          (json['id'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      authorId: json['authorId'] as String? ?? 'sample',
      authorName:
          json['authorName'] as String? ??
          (isAnonymous ? 'Ẩn danh PetHub' : 'Bạn PetHub'),
      isAnonymous: isAnonymous,
      avatarIconKey: avatarIconKey,
      colorKey: colorKey,
      content: json['content'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    try {
      final dynamic dynamicValue = value;
      final result = dynamicValue.toDate();

      if (result is DateTime) {
        return result;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

class CommunityPost {
  final int id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String avatarIconKey;
  final String colorKey;
  final bool isAnonymous;
  final String timeAgo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String content;
  final String category;
  final int likes;
  final List<String> likedBy;

  final String? imageUrl;
  final String? imagePublicId;
  final List<String> imageUrls;
  final List<String> imagePublicIds;

  // Trường cũ, giữ lại để không làm hỏng dữ liệu trước đây.
  final String? imagePath;
  final String? authorAvatarPath;

  // Số lượng bình luận được lưu trên document bài viết.
  final int commentCount;

  // Dữ liệu bình luận cũ trước khi chuyển sang subcollection.
  final List<PostComment> commentList;

  const CommunityPost({
    required this.id,
    this.authorId = 'sample',
    this.authorName = 'Ẩn danh PetHub',
    this.authorRole = 'Thành viên ẩn danh',
    bool? isAnonymous,
    required this.timeAgo,
    this.createdAt,
    this.updatedAt,
    required this.content,
    this.category = '',
    this.likes = 0,
    this.likedBy = const [],
    this.avatarIconKey = 'anonymous',
    this.colorKey = 'peach',
    this.imageUrl,
    this.imagePublicId,
    this.imageUrls = const [],
    this.imagePublicIds = const [],
    this.imagePath,
    this.authorAvatarPath,
    this.commentCount = 0,
    this.commentList = const [],
  }) : isAnonymous = isAnonymous ?? authorRole == 'Thành viên ẩn danh';
  int get totalComments {
    return commentCount;
  }

  bool get hasTag {
    return category.trim().isNotEmpty;
  }

  List<String> get allImageUrls {
    final values = imageUrls
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .take(5)
        .toList();

    if (values.isNotEmpty) {
      return values;
    }

    final legacyImageUrl = imageUrl?.trim() ?? '';

    if (legacyImageUrl.isEmpty) {
      return const [];
    }

    return [legacyImageUrl];
  }

  List<String> get allImagePublicIds {
    final values = imagePublicIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .take(5)
        .toList();

    if (values.isNotEmpty) {
      return values;
    }

    final legacyPublicId = imagePublicId?.trim() ?? '';

    if (legacyPublicId.isEmpty) {
      return const [];
    }

    return [legacyPublicId];
  }

  String? get primaryImageUrl {
    final values = allImageUrls;

    return values.isEmpty ? null : values.first;
  }

  String? get primaryImagePublicId {
    final values = allImagePublicIds;

    return values.isEmpty ? null : values.first;
  }

  bool get hasImage {
    return allImageUrls.isNotEmpty;
  }

  bool get isEdited {
    return timeAgo.trim().toLowerCase() == 'vừa chỉnh sửa';
  }

  String get displayTimeAgo {
    final createdTime = createdAt;

    if (createdTime == null) {
      return timeAgo;
    }

    return _formatRelativeTime(createdTime);
  }

  String get displayTimeLabel {
    if (!isEdited) {
      return displayTimeAgo;
    }

    return '$displayTimeAgo • Đã chỉnh sửa';
  }

  IconData get petIcon {
    return iconFromKey(avatarIconKey);
  }

  Color get color {
    return colorFromKey(colorKey);
  }

  CommunityPost copyWith({
    int? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    bool? isAnonymous,
    String? timeAgo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool removeUpdatedAt = false,
    String? content,
    String? category,
    int? likes,
    List<String>? likedBy,
    String? avatarIconKey,
    String? colorKey,
    IconData? petIcon,
    Color? color,
    String? imageUrl,
    String? imagePublicId,
    List<String>? imageUrls,
    List<String>? imagePublicIds,
    bool removeCloudinaryImage = false,
    String? imagePath,
    bool removeImage = false,
    String? authorAvatarPath,
    bool removeAvatar = false,
    int? commentCount,
    List<PostComment>? commentList,
  }) {
    final nextCommentList = commentList ?? this.commentList;

    final nextCommentCount =
        commentCount ??
        (commentList != null ? nextCommentList.length : this.commentCount);

    final nextImageUrls = removeCloudinaryImage
        ? <String>[]
        : imageUrls ?? this.imageUrls;

    final nextImagePublicIds = removeCloudinaryImage
        ? <String>[]
        : imagePublicIds ?? this.imagePublicIds;

    final nextImageUrl = removeCloudinaryImage
        ? null
        : imageUrl ??
              (imageUrls != null
                  ? (nextImageUrls.isEmpty ? null : nextImageUrls.first)
                  : this.imageUrl);

    final nextImagePublicId = removeCloudinaryImage
        ? null
        : imagePublicId ??
              (imagePublicIds != null
                  ? (nextImagePublicIds.isEmpty
                        ? null
                        : nextImagePublicIds.first)
                  : this.imagePublicId);

    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: removeUpdatedAt ? null : updatedAt ?? this.updatedAt,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      avatarIconKey:
          avatarIconKey ??
          (petIcon != null ? iconKeyFromIcon(petIcon) : this.avatarIconKey),
      colorKey:
          colorKey ??
          (color != null ? colorKeyFromColor(color) : this.colorKey),
      imageUrl: nextImageUrl,
      imagePublicId: nextImagePublicId,
      imageUrls: nextImageUrls,
      imagePublicIds: nextImagePublicIds,
      imagePath: removeImage ? null : imagePath ?? this.imagePath,
      authorAvatarPath: removeAvatar
          ? null
          : authorAvatarPath ?? this.authorAvatarPath,
      commentCount: nextCommentCount,
      commentList: nextCommentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'isAnonymous': isAnonymous,
      'timeAgo': timeAgo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'content': content,
      'category': category,
      'likes': likes,
      'likedBy': likedBy,
      'avatarIconKey': avatarIconKey,
      'colorKey': colorKey,
      'imageUrl': primaryImageUrl,
      'imagePublicId': primaryImagePublicId,
      'imageUrls': allImageUrls,
      'imagePublicIds': allImagePublicIds,
      'commentCount': commentCount,

      // Giữ trường cũ trong giai đoạn chuyển đổi dữ liệu.
      'commentList': commentList.map((comment) => comment.toJson()).toList(),

      'iconKey': avatarIconKey,
      'imagePath': imagePath,
      'authorAvatarPath': authorAvatarPath,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawComments = json['commentList'];
    final rawLikedBy = json['likedBy'];
    final rawImageUrls = json['imageUrls'];
    final rawImagePublicIds = json['imagePublicIds'];

    final legacyComments = rawComments is List
        ? rawComments
              .whereType<Map>()
              .map(
                (item) => PostComment.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <PostComment>[];

    final storedCommentCount = (json['commentCount'] as num?)?.toInt();

    final parsedImageUrls = rawImageUrls is List
        ? rawImageUrls
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .take(5)
              .toList()
        : <String>[];

    final parsedImagePublicIds = rawImagePublicIds is List
        ? rawImagePublicIds
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .take(5)
              .toList()
        : <String>[];

    final legacyImageUrl = json['imageUrl'] as String?;
    final legacyImagePublicId = json['imagePublicId'] as String?;

    final normalizedImageUrls = parsedImageUrls.isNotEmpty
        ? parsedImageUrls
        : legacyImageUrl != null && legacyImageUrl.trim().isNotEmpty
        ? [legacyImageUrl.trim()]
        : <String>[];

    final normalizedImagePublicIds = parsedImagePublicIds.isNotEmpty
        ? parsedImagePublicIds
        : legacyImagePublicId != null && legacyImagePublicId.trim().isNotEmpty
        ? [legacyImagePublicId.trim()]
        : <String>[];

    final authorRole = json['authorRole'] as String? ?? 'Thành viên ẩn danh';

    final isAnonymous =
        json['isAnonymous'] as bool? ??
        authorRole.toLowerCase().contains('ẩn danh');

    final avatarIconKey =
        json['avatarIconKey'] as String? ??
        json['iconKey'] as String? ??
        (isAnonymous ? 'anonymous' : 'default_person');

    final colorKey =
        json['colorKey'] as String? ?? colorKeyFromIconKey(avatarIconKey);

    return CommunityPost(
      id:
          (json['id'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      authorId: json['authorId'] as String? ?? 'sample',
      authorName:
          json['authorName'] as String? ??
          (isAnonymous ? 'Ẩn danh PetHub' : 'Bạn PetHub'),
      authorRole: authorRole,
      isAnonymous: isAnonymous,
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy: rawLikedBy is List
          ? rawLikedBy.map((item) => item.toString()).toList()
          : const [],
      avatarIconKey: avatarIconKey,
      colorKey: colorKey,
      imageUrl: normalizedImageUrls.isEmpty ? null : normalizedImageUrls.first,
      imagePublicId: normalizedImagePublicIds.isEmpty
          ? null
          : normalizedImagePublicIds.first,
      imageUrls: normalizedImageUrls,
      imagePublicIds: normalizedImagePublicIds,
      imagePath: json['imagePath'] as String?,
      authorAvatarPath: json['authorAvatarPath'] as String?,
      commentCount: storedCommentCount ?? legacyComments.length,
      commentList: legacyComments,
    );
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    try {
      final dynamic dynamicValue = value;
      final result = dynamicValue.toDate();

      if (result is DateTime) {
        return result;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String iconKeyFromIcon(IconData icon) {
    if (icon == Icons.person_rounded) {
      return 'default_person';
    }

    if (icon == Icons.face_rounded) {
      return 'anonymous';
    }

    if (icon == Icons.pets_rounded) {
      return 'cat';
    }

    if (icon == Icons.cruelty_free_rounded) {
      return 'dog';
    }

    if (icon == Icons.emoji_nature_rounded) {
      return 'rabbit';
    }

    if (icon == Icons.flutter_dash_rounded) {
      return 'bird';
    }

    if (icon == Icons.water_drop_rounded) {
      return 'fish';
    }

    if (icon == Icons.favorite_rounded) {
      return 'favorite';
    }

    if (icon == Icons.health_and_safety_rounded) {
      return 'health';
    }

    return 'cat';
  }

  static IconData iconFromKey(String key) {
    switch (key) {
      case 'default_person':
        return Icons.person_rounded;

      case 'anonymous':
        return Icons.face_rounded;

      case 'cat':
        return Icons.pets_rounded;

      case 'dog':
        return Icons.cruelty_free_rounded;

      case 'rabbit':
        return Icons.emoji_nature_rounded;

      case 'bird':
        return Icons.flutter_dash_rounded;

      case 'fish':
        return Icons.water_drop_rounded;

      case 'favorite':
        return Icons.favorite_rounded;

      case 'health':
        return Icons.health_and_safety_rounded;

      default:
        return Icons.person_rounded;
    }
  }

  static String colorKeyFromColor(Color color) {
    if (color == AppColors.mint) {
      return 'mint';
    }

    if (color == AppColors.sky) {
      return 'sky';
    }

    if (color == AppColors.lavender) {
      return 'lavender';
    }

    if (color == AppColors.primarySoft) {
      return 'primarySoft';
    }

    return 'peach';
  }

  static Color colorFromKey(String key) {
    switch (key) {
      case 'mint':
        return AppColors.mint;

      case 'sky':
        return AppColors.sky;

      case 'lavender':
        return AppColors.lavender;

      case 'primarySoft':
        return AppColors.primarySoft;

      case 'peach':
      default:
        return AppColors.peach;
    }
  }

  static String colorKeyFromIconKey(String iconKey) {
    switch (iconKey) {
      case 'default_person':
      case 'anonymous':
      case 'cat':
        return 'peach';

      case 'dog':
      case 'fish':
        return 'mint';

      case 'rabbit':
        return 'primarySoft';

      case 'bird':
      case 'health':
        return 'sky';

      case 'favorite':
        return 'lavender';

      default:
        return 'peach';
    }
  }
}

String _formatRelativeTime(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime.toLocal());

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Vừa xong';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} phút trước';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays} ngày trước';
  }

  if (difference.inDays < 30) {
    return '${difference.inDays ~/ 7} tuần trước';
  }

  if (difference.inDays < 365) {
    return '${difference.inDays ~/ 30} tháng trước';
  }

  return '${difference.inDays ~/ 365} năm trước';
}

const List<String> communityCategories = [
  'Tất cả',
  'Mèo',
  'Cún',
  'Chăm sóc',
  'Hỏi đáp',
  'Khoảnh khắc',
  'Tìm bạn chơi',
  'Kinh nghiệm',
];

const List<CommunityPost> communityPosts = [
  CommunityPost(
    id: 1,
    authorId: 'sample_1',
    authorName: 'Ẩn danh PetHub',
    authorRole: 'Thành viên ẩn danh',
    isAnonymous: true,
    timeAgo: '10 phút trước',
    content:
        'Hôm nay bé Miu rất ngoan, nằm cạnh cửa sổ cả buổi chiều. Ai ghé PetHub nhớ chào Miu một tiếng nha.',
    category: 'Mèo',
    likes: 128,
    avatarIconKey: 'cat',
    colorKey: 'peach',
    imageUrl:
        'https://res.cloudinary.com/kxkbvskv/image/upload/f_auto,q_auto/v1783879392/pethub_test/hant6rgjhl64yylsapnf.jpg',
    imagePublicId: 'pethub_test/hant6rgjhl64yylsapnf',
    commentList: [
      PostComment(
        id: 101,
        authorId: 'sample_comment_1',
        authorName: 'Ẩn danh PetHub',
        isAnonymous: true,
        avatarIconKey: 'anonymous',
        colorKey: 'peach',
        content: 'Miu dễ thương quá, cuối tuần mình ghé chơi.',
        timeAgo: '8 phút trước',
      ),
    ],
  ),
  CommunityPost(
    id: 2,
    authorId: 'sample_2',
    authorName: 'PetHub#A102BC',
    authorRole: 'Thành viên PetHub',
    isAnonymous: false,
    timeAgo: '25 phút trước',
    content:
        'Mọi người có kinh nghiệm chăm bé cún biếng ăn không ạ? Mình muốn xin thêm vài mẹo.',
    category: 'Cún',
    likes: 64,
    avatarIconKey: 'default_person',
    colorKey: 'peach',
  ),
];
