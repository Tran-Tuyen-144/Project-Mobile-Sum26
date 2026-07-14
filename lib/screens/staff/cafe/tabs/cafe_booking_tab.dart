import 'package:flutter/material.dart';
import '../../../../models/staff/cafe_booking.dart';
import '../../../../storage/staff_booking_storage.dart';
import '../../../../theme/app_colors.dart';

class CafeBookingTab extends StatelessWidget {
  const CafeBookingTab({super.key});

  void _handleAction(BuildContext context, String id, String status) async {
    bool success = await StaffBookingStorage.updateBookingStatus(id, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Đã cập nhật: $status', style: const TextStyle(color: AppColors.surface)),
              backgroundColor: AppColors.textDark
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Quản lý Đặt bàn', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textDark,
          elevation: 0
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('YÊU CẦU ĐẶT BÀN MỚI (REALTIME)', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),

          Expanded(
            child: StreamBuilder<List<CafeBooking>>(
              stream: StaffBookingStorage.streamPendingBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(child: Text('Không có khách nào đang chờ duyệt', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      color: AppColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.peach, width: 2),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(booking.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Chờ duyệt', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('📞 SĐT: ${booking.phone}', style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('⏰ Giờ đến: ${booking.time}', style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('🪑 Bàn: ${booking.table}', style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () => _handleAction(context, booking.id, 'Từ chối'),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.textSoft,
                                            side: const BorderSide(color: AppColors.textSoft),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                        ),
                                        child: const Text('Từ chối')
                                    )
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: () => _handleAction(context, booking.id, 'Đã xác nhận'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: AppColors.surface,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                        ),
                                        child: const Text('Duyệt ngay', style: TextStyle(fontWeight: FontWeight.bold))
                                    )
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}