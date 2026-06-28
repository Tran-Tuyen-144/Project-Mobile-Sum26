import 'package:flutter/material.dart';

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
      final matchCategory = selectedCategory == 'Tất cả' ||
          notification.type == selectedCategory;

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
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationHeader(
            unreadCount: unreadCount,
          ),

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
            actionText: '${filteredNotifications.length} mục',
          ),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: filteredNotifications.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];

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
  }
}