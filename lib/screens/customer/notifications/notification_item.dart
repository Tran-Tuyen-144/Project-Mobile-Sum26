import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PetNotification {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type;
  final bool isRead;
  final IconData icon;
  final Color color;

  const PetNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}

const List<String> notificationCategories = [
  'Tất cả',
  'Đặt bàn',
  'Dịch vụ',
  'Ưu đãi',
  'Cộng đồng',
];

const List<PetNotification> petNotifications = [
  PetNotification(
    id: 1,
    title: 'Sắp tới giờ đặt bàn',
    message: 'Bạn có lịch đặt bàn tại PetHub Quận 1 lúc 18:00 hôm nay.',
    time: '5 phút trước',
    type: 'Đặt bàn',
    isRead: false,
    icon: Icons.event_seat_rounded,
    color: AppColors.peach,
  ),
  PetNotification(
    id: 2,
    title: 'Đơn gọi nước đã sẵn sàng',
    message: 'Latte Mây Xanh và Cookie Paw đang được chuẩn bị cho bạn.',
    time: '15 phút trước',
    type: 'Đặt bàn',
    isRead: false,
    icon: Icons.local_cafe_rounded,
    color: AppColors.sky,
  ),
  PetNotification(
    id: 3,
    title: 'Ưu đãi spa thú cưng',
    message: 'Giảm 20% dịch vụ grooming cho thành viên PetHub trong tuần này.',
    time: '1 giờ trước',
    type: 'Ưu đãi',
    isRead: true,
    icon: Icons.discount_rounded,
    color: AppColors.mint,
  ),
  PetNotification(
    id: 4,
    title: 'Lịch dịch vụ đã được xác nhận',
    message: 'Dịch vụ Spa thú cưng cho bé Mochi đã được đặt thành công.',
    time: '2 giờ trước',
    type: 'Dịch vụ',
    isRead: true,
    icon: Icons.spa_rounded,
    color: AppColors.lavender,
  ),
  PetNotification(
    id: 5,
    title: 'Bài viết của bạn có bình luận mới',
    message: 'Một thành viên vừa bình luận trong bài chia sẻ về bé Bông.',
    time: 'Hôm qua',
    type: 'Cộng đồng',
    isRead: true,
    icon: Icons.forum_rounded,
    color: AppColors.primarySoft,
  ),
];
