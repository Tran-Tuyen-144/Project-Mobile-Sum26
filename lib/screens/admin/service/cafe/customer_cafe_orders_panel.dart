import 'package:flutter/material.dart';

import '../../../../services/order_revenue_service.dart';
import '../../../../theme/app_colors.dart';

class CustomerCafeOrdersPanel extends StatelessWidget {
  const CustomerCafeOrdersPanel({super.key});

  String _money(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  String _dateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month/${value.year} $hour:$minute';
  }

  Future<void> _completeOrder(BuildContext context, RevenueOrder order) async {
    final shouldComplete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Xác nhận đã thanh toán?'),
              content: Text(
                'Đơn ${_money(order.totalAmount)} '
                'sẽ được tính vào doanh thu.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Xác nhận'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldComplete) {
      return;
    }

    try {
      await OrderRevenueService.completeOrder(order.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hoàn thành đơn và cập nhật doanh thu.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xác nhận đơn: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RevenueOrder>>(
      stream: OrderRevenueService.watchPendingCustomerCafeOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.peach),
            ),
            child: Text(
              'Không tải được đơn khách hàng: '
              '${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? const [];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.peach, width: 1.3),
          ),
          child: ExpansionTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.peach,
              child: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            ),
            title: Text(
              'Đơn khách hàng chờ xác nhận (${orders.length})',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Đơn thanh toán tại quầy chưa được tính doanh thu.',
              style: TextStyle(color: AppColors.textSoft),
            ),
            children: [
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 18),
                  child: Text(
                    'Hiện không có đơn nào chờ xác nhận.',
                    style: TextStyle(color: AppColors.textSoft),
                  ),
                )
              else
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.peach.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.peach),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.customerName.isNotEmpty
                                      ? order.customerName
                                      : order.customerEmail,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                _money(order.totalAmount),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.itemSummary,
                            style: const TextStyle(
                              color: AppColors.textSoft,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${order.paymentMethod} • '
                            '${_dateTime(order.createdAt)}',
                            style: const TextStyle(
                              color: AppColors.textSoft,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                _completeOrder(context, order);
                              },
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Đã nhận tiền và hoàn tất'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
