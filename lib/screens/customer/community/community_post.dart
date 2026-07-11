import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PostComment {
  final int id;
  final String authorName;
  final String content;
  final String timeAgo;

  const PostComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timeAgo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'timeAgo': timeAgo,
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: (json['id'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      authorName: json['authorName'] as String? ?? 'Ẩn danh PetHub',
      content: json['content'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
    );
  }
}

class CommunityPost {
  final int id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String content;

  // Tag/chủ đề, có thể rỗng.
  final String category;

  final int likes;
  final List<String> likedBy;

  // Avatar ẩn danh dạng icon.
  final String avatarIconKey;
  final String colorKey;

  // Giữ lại để không vỡ code cũ, nhưng bản này không dùng ảnh local nữa.
  final String? imagePath;
  final String? authorAvatarPath;

  final List<PostComment> commentList;

  const CommunityPost({
    required this.id,
    this.authorId = 'sample',
    this.authorName = 'Ẩn danh PetHub',
    this.authorRole = 'Thành viên ẩn danh',
    required this.timeAgo,
    required this.content,
    this.category = '',
    this.likes = 0,
    this.likedBy = const [],
    this.avatarIconKey = 'anonymous',
    this.colorKey = 'peach',
    this.imagePath,
    this.authorAvatarPath,
    this.commentList = const [],
  });

  int get totalComments => commentList.length;

  IconData get petIcon => iconFromKey(avatarIconKey);

  Color get color => colorFromKey(colorKey);

  bool get hasTag => category.trim().isNotEmpty;

  CommunityPost copyWith({
    int? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? timeAgo,
    String? content,
    String? category,
    int? likes,
    List<String>? likedBy,
    String? avatarIconKey,
    String? colorKey,
    IconData? petIcon,
    Color? color,
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
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      avatarIconKey: avatarIconKey ??
          (petIcon != null ? iconKeyFromIcon(petIcon) : this.avatarIconKey),
      colorKey: colorKey ??
          (color != null ? colorKeyFromColor(color) : this.colorKey),
      imagePath: removeImage ? null : imagePath ?? this.imagePath,
      authorAvatarPath:
      removeAvatar ? null : authorAvatarPath ?? this.authorAvatarPath,
      commentList: commentList ?? this.commentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'timeAgo': timeAgo,
      'content': content,
      'category': category,
      'likes': likes,
      'likedBy': likedBy,
      'avatarIconKey': avatarIconKey,
      'colorKey': colorKey,
      'commentList': commentList.map((comment) => comment.toJson()).toList(),

      // Giữ tương thích dữ liệu cũ.
      'iconKey': avatarIconKey,
      'imagePath': imagePath,
      'authorAvatarPath': authorAvatarPath,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawComments = json['commentList'];
    final rawLikedBy = json['likedBy'];

    final avatarIconKey = json['avatarIconKey'] as String? ??
        json['iconKey'] as String? ??
        'anonymous';

    final colorKey = json['colorKey'] as String? ??
        colorKeyFromIconKey(avatarIconKey);

    return CommunityPost(
      id: (json['id'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      authorId: json['authorId'] as String? ?? 'sample',
      authorName: json['authorName'] as String? ?? 'Ẩn danh PetHub',
      authorRole: json['authorRole'] as String? ?? 'Thành viên ẩn danh',
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy: rawLikedBy is List
          ? rawLikedBy.map((item) => item.toString()).toList()
          : const [],
      avatarIconKey: avatarIconKey,
      colorKey: colorKey,
      imagePath: json['imagePath'] as String?,
      authorAvatarPath: json['authorAvatarPath'] as String?,
      commentList: rawComments is List
          ? rawComments
          .whereType<Map>()
          .map(
            (item) => PostComment.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : const [],
    );
  }

  static String iconKeyFromIcon(IconData icon) {
    if (icon == Icons.cruelty_free_rounded) return 'dog';
    if (icon == Icons.favorite_rounded) return 'favorite';
    if (icon == Icons.health_and_safety_rounded) return 'health';
    if (icon == Icons.emoji_nature_rounded) return 'rabbit';
    if (icon == Icons.flutter_dash_rounded) return 'bird';
    if (icon == Icons.water_drop_rounded) return 'fish';
    if (icon == Icons.face_rounded) return 'anonymous';
    return 'cat';
  }

  static IconData iconFromKey(String key) {
    switch (key) {
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
        return Icons.face_rounded;
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
      case 'anonymous':
        return 'peach';
      case 'cat':
        return 'peach';
      case 'dog':
        return 'mint';
      case 'rabbit':
        return 'primarySoft';
      case 'bird':
        return 'sky';
      case 'fish':
        return 'mint';
      case 'favorite':
        return 'lavender';
      case 'health':
        return 'sky';
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
    timeAgo: '10 phút trước',
    content:
    'Hôm nay bé Miu rất ngoan, nằm cạnh cửa sổ cả buổi chiều. Ai ghé PetHub nhớ chào Miu một tiếng nha.',
    category: 'Mèo',
    likes: 128,
    avatarIconKey: 'cat',
    colorKey: 'peach',
    commentList: [
      PostComment(
        id: 101,
        authorName: 'Ẩn danh PetHub',
        content: 'Miu dễ thương quá, cuối tuần mình ghé chơi.',
        timeAgo: '8 phút trước',
      ),
      PostComment(
        id: 102,
        authorName: 'Ẩn danh PetHub',
        content: 'Cho em xin lịch Miu hay ở quán với ạ.',
        timeAgo: '5 phút trước',
      ),
    ],
  ),
  CommunityPost(
    id: 2,
    authorId: 'sample_2',
    authorName: 'Ẩn danh PetHub',
    authorRole: 'Thành viên ẩn danh',
    timeAgo: '35 phút trước',
    content:
    'Mọi người có mẹo nào giúp cún bớt sợ khi đi spa không? Bé nhà mình cứ thấy máy sấy là nép vào người.',
    category: 'Hỏi đáp',
    likes: 76,
    avatarIconKey: 'dog',
    colorKey: 'mint',
    commentList: [
      PostComment(
        id: 201,
        authorName: 'Ẩn danh PetHub',
        content: 'Có thể cho bé làm quen tiếng máy sấy từ xa trước nha.',
        timeAgo: '30 phút trước',
      ),
    ],
  ),
];