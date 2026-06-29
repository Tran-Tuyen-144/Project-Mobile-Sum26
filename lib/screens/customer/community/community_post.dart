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
      authorName: json['authorName'] as String? ?? 'Bạn',
      content: json['content'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
    );
  }
}

class CommunityPost {
  final int id;
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String content;
  final String category;
  final int likes;
  final IconData petIcon;
  final Color color;
  final String? imagePath;
  final List<PostComment> commentList;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    required this.content,
    required this.category,
    required this.likes,
    required this.petIcon,
    required this.color,
    this.imagePath,
    this.commentList = const [],
  });

  int get totalComments => commentList.length;

  CommunityPost copyWith({
    int? id,
    String? authorName,
    String? authorRole,
    String? timeAgo,
    String? content,
    String? category,
    int? likes,
    IconData? petIcon,
    Color? color,
    String? imagePath,
    List<PostComment>? commentList,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      petIcon: petIcon ?? this.petIcon,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      commentList: commentList ?? this.commentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorRole': authorRole,
      'timeAgo': timeAgo,
      'content': content,
      'category': category,
      'likes': likes,
      'iconKey': _iconKeyFromIcon(petIcon),
      'colorKey': _colorKeyFromColor(color),
      'imagePath': imagePath,
      'commentList': commentList.map((comment) => comment.toJson()).toList(),
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawComments = json['commentList'];

    return CommunityPost(
      id: (json['id'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      authorName: json['authorName'] as String? ?? 'Bạn',
      authorRole: json['authorRole'] as String? ?? 'Thành viên PetHub',
      timeAgo: json['timeAgo'] as String? ?? 'Vừa xong',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'Mèo',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      petIcon: _iconFromKey(json['iconKey'] as String? ?? 'pets'),
      color: _colorFromKey(json['colorKey'] as String? ?? 'peach'),
      imagePath: json['imagePath'] as String?,
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
}

String _iconKeyFromIcon(IconData icon) {
  if (icon == Icons.cruelty_free_rounded) return 'dog';
  if (icon == Icons.favorite_rounded) return 'favorite';
  if (icon == Icons.health_and_safety_rounded) return 'health';
  return 'pets';
}

IconData _iconFromKey(String key) {
  switch (key) {
    case 'dog':
      return Icons.cruelty_free_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'health':
      return Icons.health_and_safety_rounded;
    case 'pets':
    default:
      return Icons.pets_rounded;
  }
}

String _colorKeyFromColor(Color color) {
  if (color == AppColors.mint) return 'mint';
  if (color == AppColors.sky) return 'sky';
  if (color == AppColors.lavender) return 'lavender';
  if (color == AppColors.primarySoft) return 'primarySoft';
  return 'peach';
}

Color _colorFromKey(String key) {
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

const List<String> communityCategories = [
  'Tất cả',
  'Mèo',
  'Cún',
  'Chăm sóc',
  'Hỏi đáp',
];

const List<CommunityPost> communityPosts = [
  CommunityPost(
    id: 1,
    authorName: 'Mochi House',
    authorRole: 'Cafe mèo PetHub',
    timeAgo: '10 phút trước',
    content:
    'Hôm nay bé Miu rất ngoan, nằm cạnh cửa sổ cả buổi chiều. Ai ghé PetHub nhớ chào Miu một tiếng nha.',
    category: 'Mèo',
    likes: 128,
    petIcon: Icons.pets_rounded,
    color: AppColors.peach,
    commentList: [
      PostComment(
        id: 101,
        authorName: 'An Nhiên',
        content: 'Miu dễ thương quá, cuối tuần mình ghé chơi.',
        timeAgo: '8 phút trước',
      ),
      PostComment(
        id: 102,
        authorName: 'Bé Cam',
        content: 'Cho em xin lịch Miu hay ở quán với ạ.',
        timeAgo: '5 phút trước',
      ),
    ],
  ),
  CommunityPost(
    id: 2,
    authorName: 'Cún Bông',
    authorRole: 'Thành viên cộng đồng',
    timeAgo: '35 phút trước',
    content:
    'Mọi người có mẹo nào giúp cún bớt sợ khi đi spa không? Bé nhà mình cứ thấy máy sấy là nép vào người.',
    category: 'Hỏi đáp',
    likes: 76,
    petIcon: Icons.cruelty_free_rounded,
    color: AppColors.mint,
    commentList: [
      PostComment(
        id: 201,
        authorName: 'PetCare Tips',
        content: 'Có thể cho bé làm quen tiếng máy sấy từ xa trước nha.',
        timeAgo: '30 phút trước',
      ),
      PostComment(
        id: 202,
        authorName: 'Mochi House',
        content: 'Mang theo khăn hoặc đồ chơi quen thuộc cũng giúp bé bình tĩnh hơn.',
        timeAgo: '25 phút trước',
      ),
    ],
  ),
  CommunityPost(
    id: 3,
    authorName: 'PetCare Tips',
    authorRole: 'Chăm sóc thú cưng',
    timeAgo: '1 giờ trước',
    content:
    'Mùa nóng nên thay nước cho pet thường xuyên hơn, đặt bát nước ở nơi mát và tránh nắng trực tiếp.',
    category: 'Chăm sóc',
    likes: 214,
    petIcon: Icons.health_and_safety_rounded,
    color: AppColors.sky,
    commentList: [
      PostComment(
        id: 301,
        authorName: 'Sen nhà Bông',
        content: 'Thông tin hữu ích quá, cảm ơn PetCare.',
        timeAgo: '45 phút trước',
      ),
    ],
  ),
  CommunityPost(
    id: 4,
    authorName: 'Boss Cam',
    authorRole: 'Khách quen PetHub',
    timeAgo: '2 giờ trước',
    content:
    'Lần đầu dẫn bé Cam đi cafe thú cưng, bé hơi rụt rè nhưng sau 15 phút đã chịu chơi cùng các bạn rồi.',
    category: 'Cún',
    likes: 92,
    petIcon: Icons.favorite_rounded,
    color: AppColors.lavender,
    commentList: [
      PostComment(
        id: 401,
        authorName: 'Cún Bông',
        content: 'Bé Cam giỏi quá trời.',
        timeAgo: '1 giờ trước',
      ),
    ],
  ),
];