import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class CommunityPost {
  final int id;
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String content;
  final String category;
  final int likes;
  final int comments;
  final IconData petIcon;
  final Color color;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    required this.content,
    required this.category,
    required this.likes,
    required this.comments,
    required this.petIcon,
    required this.color,
  });
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
    comments: 24,
    petIcon: Icons.pets_rounded,
    color: AppColors.peach,
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
    comments: 18,
    petIcon: Icons.cruelty_free_rounded,
    color: AppColors.mint,
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
    comments: 31,
    petIcon: Icons.health_and_safety_rounded,
    color: AppColors.sky,
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
    comments: 12,
    petIcon: Icons.favorite_rounded,
    color: AppColors.lavender,
  ),
];