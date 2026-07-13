import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/pet_booking_store.dart';
import '../../../theme/app_colors.dart';
import '../booking_history_screen.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'booking_confirm_data.dart';

class BookingConfirmScreen extends StatelessWidget {
  final BookingConfirmData data;

  const BookingConfirmScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ConfirmHeader(),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Thông tin đặt bàn'),

          const SizedBox(height: 12),

          SoftCard(
            color: Colors.white,
            child: Column(
              children: [
                _ConfirmRow(
                  icon: Icons.pets_rounded,
                  label: 'Thú cưng',
                  value: data.petName,
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.health_and_safety_rounded,
                  label: 'Tình trạng',
                  value: data.petStatus,
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.storefront_rounded,
                  label: 'Chi nhánh',
                  value: data.branch,
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'Ngày',
                  value: data.day,
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.access_time_rounded,
                  label: 'Khung giờ',
                  value: data.time,
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.groups_rounded,
                  label: 'Số khách',
                  value: '${data.guests} khách',
                ),
                const SizedBox(height: 14),
                _ConfirmRow(
                  icon: Icons.table_restaurant_rounded,
                  label: 'Bàn',
                  value: data.tableName,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Ghi chú'),

          const SizedBox(height: 12),

          SoftCard(
            color: AppColors.peach,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Vui lòng đến trước giờ hẹn khoảng 10 phút. Nếu cần đổi giờ, bạn có thể liên hệ nhân viên PetHub.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Tạm tính'),

          const SizedBox(height: 12),

          SoftCard(
            color: AppColors.lavender,
            child: Column(
              children: const [
                _PriceRow(label: 'Phí giữ bàn', value: '20.000đ'),
                SizedBox(height: 10),
                _PriceRow(label: 'Nước gọi trước', value: 'Chưa chọn'),
                SizedBox(height: 10),
                Divider(height: 18),
                _PriceRow(
                  label: 'Tổng tạm tính',
                  value: '20.000đ',
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Chỉnh sửa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirm(context),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    try {
      await PetBookingStore.instance.createOnlineTableBooking(
        customerId: data.customerId,
        customerName: data.customerName,
        petNames: data.petNames,
        branch: data.branch,
        day: data.day,
        time: data.time,
        guests: data.guests,
        tableName: data.tableName,
      );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Đặt pet thành công'),
          content: Text(
            'Đã giữ ${data.tableName} cho ${data.petName}. Bạn có thể xem, sửa hoặc hủy booking trong lịch sử.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Xem lịch sử'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BookingHistoryScreen(customerId: data.customerId),
        ),
        (route) => route.isFirst,
      );
    } on BookingPetLimitException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mỗi booking chỉ được chọn tối đa 3 pet.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu booking: $error')),
        );
      }
    }
  }
}

class _ConfirmHeader extends StatelessWidget {
  const _ConfirmHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.peach, AppColors.cream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xác nhận đặt bàn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Kiểm tra lại thông tin trước khi hoàn tất lịch ghé PetHub.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 21),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textDark : AppColors.textSoft,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.primary : AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
