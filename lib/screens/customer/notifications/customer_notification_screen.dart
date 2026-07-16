import 'package:flutter/material.dart';

import '../../../services/customer_booking_notification_service.dart';
import '../../../storage/booking_history_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import 'notification_item.dart';
import 'notification_widgets.dart';

class CustomerNotificationScreen extends StatefulWidget {
  const CustomerNotificationScreen({super.key});

  @override
  State<CustomerNotificationScreen> createState() =>
      _CustomerNotificationScreenState();
}

class _CustomerNotificationScreenState
    extends State<CustomerNotificationScreen> {
  String selectedCategory = 'Tất cả';

  final Set<int> readIds = {
    for (final item in petNotifications)
      if (item.isRead) item.id,
  };

  List<PetNotification> get filteredNotifications {
    return petNotifications.where((notification) {
      final matchCategory =
          selectedCategory == 'Tất cả' || notification.type == selectedCategory;

      return matchCategory;
    }).toList();
  }

  int get unreadCount {
    return petNotifications.where((item) => !readIds.contains(item.id)).length;
  }

  void _openNotification(PetNotification notification) {
    setState(() {
      readIds.add(notification.id);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return NotificationDetailSheet(notification: notification);
      },
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final item in petNotifications) {
        readIds.add(item.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả thông báo là đã đọc.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: CustomerBookingNotificationService.localChanges,
      builder: (context, _) => FutureBuilder<List<BookingHistoryItem>>(
        future: BookingHistoryStorage.loadBookings(),
        builder: (context, historySnapshot) {
          final history = historySnapshot.data ?? const <BookingHistoryItem>[];
          return StreamBuilder<List<CustomerBookingNotification>>(
            stream: CustomerBookingNotificationService.watch(),
            builder: (context, snapshot) {
              final bookingItems = (snapshot.data ?? const [])
                  .map(_toPetNotification)
                  .toList();
              final notifiedBookingIds = {
                for (final item in snapshot.data ?? const []) item.bookingId,
              };
              final historyItems = history
                  .where((item) => !notifiedBookingIds.contains(item.id))
                  .map(_historyToPetNotification)
                  .toList();
              final notifications = [
                ...bookingItems,
                ...historyItems,
                ...petNotifications,
              ];
              final filtered = notifications
                  .where(
                    (item) =>
                        selectedCategory == 'Tất cả' ||
                        item.type == selectedCategory,
                  )
                  .toList();
              final unread = notifications
                  .where((item) => !readIds.contains(item.id))
                  .length;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationHeader(unreadCount: unread),

                    const SizedBox(height: 24),

                    SectionTitle(
                      title: 'Bộ lọc thông báo',
                      actionText: 'Đọc tất cả',
                      onActionTap: _markAllAsRead,
                    ),

                    const SizedBox(height: 12),

                    NotificationCategorySelector(
                      categories: notificationCategories,
                      selectedCategory: selectedCategory,
                      onSelected: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(
                      title: 'Thông báo mới',
                      actionText: '${filtered.length} mục',
                    ),

                    const SizedBox(height: 12),

                    ListView.separated(
                      itemCount: filtered.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = filtered[index];

                        return NotificationCard(
                          notification: notification,
                          isRead: readIds.contains(notification.id),
                          onTap: () => _openNotification(notification),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  PetNotification _toPetNotification(CustomerBookingNotification item) {
    return PetNotification(
      id: item.id.hashCode,
      title: item.title,
      message: item.message,
      time: item.isConfirmed ? 'Vừa cập nhật' : 'Đang chờ xác nhận',
      type: 'Đặt bàn',
      isRead: false,
      icon: item.isConfirmed
          ? Icons.check_circle_rounded
          : Icons.hourglass_top_rounded,
      color: item.isConfirmed ? AppColors.mint : AppColors.peach,
    );
  }

  PetNotification _historyToPetNotification(BookingHistoryItem item) {
    final isConfirmed = item.status == BookingStatus.confirmed;
    final isCancelled = item.status == BookingStatus.cancelled;
    return PetNotification(
      id: item.id.hashCode,
      title: isConfirmed
          ? 'Đặt bàn thành công'
          : isCancelled
          ? 'Đặt bàn đã hủy'
          : 'Yêu cầu đặt bàn đang chờ xác nhận',
      message: '${item.tableName} • ${item.day} lúc ${item.time}',
      time: item.createdAt.toString().substring(0, 16),
      type: 'Đặt bàn',
      isRead: false,
      icon: isConfirmed
          ? Icons.check_circle_rounded
          : isCancelled
          ? Icons.cancel_rounded
          : Icons.hourglass_top_rounded,
      color: isConfirmed
          ? AppColors.mint
          : isCancelled
          ? const Color(0xFFE5E0DC)
          : AppColors.peach,
    );
  }
}
