import 'package:flutter/material.dart';

import '../../../storage/booking_history_storage.dart';
import '../../../storage/offline_drink_order_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';

const Map<int, String> _drinkNames = {
  1: 'Latte Mây Xanh',
  2: 'Cappuccino PetHub',
  3: 'Trà Đào Cam Sả',
  4: 'Trà Sữa Pastel',
  5: 'Sinh Tố Dâu Mây',
  6: 'Sinh Tố Bơ Sữa',
  7: 'Cheesecake Mini',
  8: 'Cookie Paw',
};

class CatSavedDataButton extends StatelessWidget {
  const CatSavedDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Dữ liệu đã lưu',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showSavedData(context),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primarySoft),
            ),
            child: const Text('🐱', style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }

  Future<void> _showSavedData(BuildContext context) async {
    final bookings = await BookingHistoryStorage.loadBookings();
    final drinkOrders = await OfflineDrinkOrderStorage.loadOrderHistory();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CatSavedDataSheet(
          bookings: bookings,
          drinkOrders: drinkOrders.reversed.toList(),
        );
      },
    );
  }
}

class _CatSavedDataSheet extends StatelessWidget {
  final List<BookingHistoryItem> bookings;
  final List<OfflineDrinkOrder> drinkOrders;

  const _CatSavedDataSheet({required this.bookings, required this.drinkOrders});

  @override
  Widget build(BuildContext context) {
    final hasData = bookings.isNotEmpty || drinkOrders.isNotEmpty;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBF5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('🐱', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dữ liệu đã lưu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!hasData)
                  SoftCard(
                    color: Colors.white,
                    child: Text(
                      'Chưa có dữ liệu đặt bàn hoặc đặt nước nào được lưu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (bookings.isNotEmpty) ...[
                  _SheetTitle(title: 'Đặt bàn', count: bookings.length),
                  const SizedBox(height: 10),
                  ...bookings.map((booking) => _BookingSavedTile(booking)),
                  const SizedBox(height: 14),
                ],
                if (drinkOrders.isNotEmpty) ...[
                  _SheetTitle(title: 'Đặt nước', count: drinkOrders.length),
                  const SizedBox(height: 10),
                  ...drinkOrders.map((order) => _DrinkSavedTile(order)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SheetTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingSavedTile extends StatelessWidget {
  final BookingHistoryItem booking;

  const _BookingSavedTile(this.booking);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.peach,
              child: Icon(Icons.event_seat_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.tableName} • ${booking.branch}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.day} lúc ${booking.time} • ${booking.guests} khách',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (booking.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SĐT: ${booking.phone}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusTag(label: booking.status.label),
          ],
        ),
      ),
    );
  }
}

class _DrinkSavedTile extends StatelessWidget {
  final OfflineDrinkOrder order;

  const _DrinkSavedTile(this.order);

  @override
  Widget build(BuildContext context) {
    final totalItems = order.items.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFDDF6FF),
              child: Icon(Icons.local_cafe_rounded, color: Color(0xFF2D6A8D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalItems món • ${_money(order.totalPrice)}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.items.entries
                        .map(
                          (entry) =>
                              '${_drinkNames[entry.key] ?? 'Món #${entry.key}'} x${entry.value}',
                        )
                        .join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.paymentMethod,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2D6A8D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _StatusTag(label: 'Đã lưu'),
          ],
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;

  const _StatusTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _money(int value) {
  return '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
}
