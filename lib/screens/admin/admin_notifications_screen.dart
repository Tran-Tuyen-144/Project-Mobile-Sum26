import 'package:flutter/material.dart';

import '../../services/admin_notification_service.dart';
import '../../theme/app_colors.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thông báo Admin')),
    body: StreamBuilder<List<AdminNotification>>(
      stream: AdminNotificationService.watch(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Chưa tải được thông báo.'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty)
          return const Center(child: Text('Chưa có thông báo mới.'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final canApprove = item.type == 'booking' && !item.isApproved;
            return Card(
              color: item.isRead ? Colors.white : AppColors.primarySoft,
              child: ListTile(
                onTap: () => AdminNotificationService.markRead(item.id),
                leading: Icon(_iconFor(item.type), color: AppColors.primary),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w900,
                  ),
                ),
                subtitle: Text(item.body),
                trailing: canApprove
                    ? FilledButton(
                        onPressed: () async {
                          await AdminNotificationService.approveBooking(
                            item.id,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xác nhận lịch đặt bàn.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Xác nhận'),
                      )
                    : item.isApproved
                    ? const Chip(label: Text('Đã xác nhận'))
                    : item.isRead
                    ? null
                    : const Icon(
                        Icons.circle,
                        color: AppColors.primary,
                        size: 12,
                      ),
              ),
            );
          },
        );
      },
    ),
  );

  IconData _iconFor(String type) => switch (type) {
    'booking' => Icons.table_restaurant_rounded,
    'service' => Icons.health_and_safety_rounded,
    'drink_order' => Icons.local_cafe_rounded,
    _ => Icons.notifications_rounded,
  };
}
