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
  });

  IconData get petIcon {
    return CommunityPost.iconFromKey(avatarIconKey);
  }

  Color get color {
    return CommunityPost.colorFromKey(colorKey);
  }
  String get displayTimeAgo {
    final commentTime = createdAt;

    if (commentTime == null) {
      return timeAgo;
    }

    final difference = DateTime.now().difference(commentTime.toLocal());

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
  final String content;
  final String category;
  final int likes;
  final List<String> likedBy;

  // Ảnh Cloudinary.
  final String? imageUrl;
  final String? imagePublicId;

  // Trường cũ, giữ lại để không vỡ dữ liệu trước đây.
  final String? imagePath;
  final String? authorAvatarPath;

  final List<PostComment> commentList;

  const CommunityPost({
    required this.id,
    this.authorId = 'sample',
    this.authorName = 'Ẩn danh PetHub',
    this.authorRole = 'Thành viên ẩn danh',
    bool? isAnonymous,
    required this.timeAgo,
    this.createdAt,
    required this.content,
    this.category = '',
    this.likes = 0,
    this.likedBy = const [],
    this.avatarIconKey = 'anonymous',
    this.colorKey = 'peach',
    this.imageUrl,
    this.imagePublicId,
    this.imagePath,
    this.authorAvatarPath,
    this.commentList = const [],
  }) : isAnonymous = isAnonymous ?? authorRole == 'Thành viên ẩn danh';

  int get totalComments => commentList.length;

  bool get hasTag => category.trim().isNotEmpty;

  bool get hasImage {
    return imageUrl != null && imageUrl!.trim().isNotEmpty;
  }
  String get displayTimeAgo {
    final createdTime = createdAt;

    if (createdTime == null) {
      return timeAgo;
    }

    final difference = DateTime.now().difference(createdTime.toLocal());

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

  IconData get petIcon => iconFromKey(avatarIconKey);

  Color get color => colorFromKey(colorKey);

  CommunityPost copyWith({
    int? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    bool? isAnonymous,
    String? timeAgo,
    DateTime? createdAt,
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
    bool removeCloudinaryImage = false,
    String? imagePath,
    bool removeImage = false,
    String? authorAvatarPath,
    bool removeAvatar = false,
    List<PostComment>? commentList,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
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
      imageUrl: removeCloudinaryImage ? null : imageUrl ?? this.imageUrl,
      imagePublicId: removeCloudinaryImage
          ? null
          : imagePublicId ?? this.imagePublicId,
      imagePath: removeImage ? null : imagePath ?? this.imagePath,
      authorAvatarPath: removeAvatar
          ? null
          : authorAvatarPath ?? this.authorAvatarPath,
      commentList: commentList ?? this.commentList,
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
      'content': content,
      'category': category,
      'likes': likes,
      'likedBy': likedBy,
      'avatarIconKey': avatarIconKey,
      'colorKey': colorKey,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'commentList': commentList.map((comment) => comment.toJson()).toList(),

      // Trường cũ.
      'iconKey': avatarIconKey,
      'imagePath': imagePath,
      'authorAvatarPath': authorAvatarPath,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawComments = json['commentList'];
    final rawLikedBy = json['likedBy'];

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
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy: rawLikedBy is List
          ? rawLikedBy.map((item) => item.toString()).toList()
          : const [],
      avatarIconKey: avatarIconKey,
      colorKey: colorKey,
      imageUrl: json['imageUrl'] as String?,
      imagePublicId: json['imagePublicId'] as String?,
      imagePath: json['imagePath'] as String?,
      authorAvatarPath: json['authorAvatarPath'] as String?,
      commentList: rawComments is List
          ? rawComments
                .whereType<Map>()
                .map(
                  (item) =>
                      PostComment.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
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
    if (icon == Icons.person_rounded) return 'default_person';
    if (icon == Icons.face_rounded) return 'anonymous';
    if (icon == Icons.pets_rounded) return 'cat';
    if (icon == Icons.cruelty_free_rounded) return 'dog';
    if (icon == Icons.emoji_nature_rounded) return 'rabbit';
    if (icon == Icons.flutter_dash_rounded) return 'bird';
    if (icon == Icons.water_drop_rounded) return 'fish';
    if (icon == Icons.favorite_rounded) return 'favorite';
    if (icon == Icons.health_and_safety_rounded) return 'health';

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
    if (color == AppColors.mint) return 'mint';
    if (color == AppColors.sky) return 'sky';
    if (color == AppColors.lavender) return 'lavender';
    if (color == AppColors.primarySoft) return 'primarySoft';

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
    commentList: [],
  ),
];
