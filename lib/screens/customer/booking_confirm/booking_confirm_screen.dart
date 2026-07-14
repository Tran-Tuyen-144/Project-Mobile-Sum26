import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/firebase_booking_service.dart';
import '../../../services/pet_booking_store.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import '../booking_history_screen.dart';
import 'booking_confirm_data.dart';

class BookingConfirmScreen extends StatefulWidget {
  final BookingConfirmData data;

  const BookingConfirmScreen({super.key, required this.data});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _isSaving = false;

  BookingConfirmData get data => widget.data;

  bool get _isPetBooking => data.petNames.isNotEmpty;

  Future<void> _confirmBooking() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isPetBooking) {
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
      } else {
        await FirebaseBookingService.createBooking(data);
      }

      if (!mounted) return;

      if (_isPetBooking) {
        await _showPetBookingSuccessDialog();
      } else {
        _showTableBookingSuccessDialog();
      }
    } on BookingPetLimitException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mỗi booking chỉ được chọn tối đa 3 pet.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPetBooking
                ? 'Không lưu được lịch đặt pet: $error'
                : 'Không lưu được lịch đặt bàn: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showPetBookingSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Đặt pet thành công'),
          content: Text(
            'Đã giữ ${data.tableName} cho ${data.petName} tại '
            '${data.branch} vào ${data.day} lúc ${data.time}.',
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('Xem lịch sử'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) {
          return BookingHistoryScreen(customerId: data.customerId);
        },
      ),
      (route) => route.isFirst,
    );
  }

  void _showTableBookingSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Đặt bàn thành công'),
          content: Text(
            'PetHub đã giữ ${data.tableName} tại ${data.branch} '
            'cho bạn vào ${data.day} lúc ${data.time}. '
            'Lịch đặt bàn đã được lưu.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/customer');
              },
              child: const Text('Về trang chính'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfirmHeader(isPetBooking: _isPetBooking),
          const SizedBox(height: 24),
          SectionTitle(
            title: _isPetBooking ? 'Thông tin đặt pet' : 'Thông tin đặt bàn',
          ),
          const SizedBox(height: 12),
          SoftCard(
            color: Colors.white,
            child: Column(
              children: [
                if (_isPetBooking) ...[
                  _ConfirmRow(
                    icon: Icons.person_rounded,
                    label: 'Khách hàng',
                    value: data.customerName,
                  ),
                  const SizedBox(height: 14),
                  _ConfirmRow(
                    icon: Icons.pets_rounded,
                    label: 'Thú cưng',
                    value: data.petName,
                  ),
                  const SizedBox(height: 14),
                  _ConfirmRow(
                    icon: Icons.health_and_safety_rounded,
                    label: 'Tình trạng',
                    value: data.petStatus.trim().isEmpty
                        ? 'Đã chọn'
                        : data.petStatus,
                  ),
                  const SizedBox(height: 14),
                ],
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
                    _isPetBooking
                        ? 'Pet sẽ được giữ theo lịch đã chọn. '
                              'Mỗi booking được chọn tối đa 3 pet.'
                        : 'Vui lòng đến trước giờ hẹn khoảng 10 phút. '
                              'Nếu cần đổi giờ, bạn có thể liên hệ nhân viên PetHub.',
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
              children: [
                _PriceRow(
                  label: _isPetBooking ? 'Phí đặt pet' : 'Phí giữ bàn',
                  value: '20.000đ',
                ),
                const SizedBox(height: 10),
                const _PriceRow(label: 'Nước gọi trước', value: 'Chưa chọn'),
                const SizedBox(height: 10),
                const Divider(height: 18),
                const _PriceRow(
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
                  onPressed: _isSaving
                      ? null
                      : () {
                          context.pop();
                        },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Chỉnh sửa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _confirmBooking,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Xác nhận'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmHeader extends StatelessWidget {
  final bool isPetBooking;

  const _ConfirmHeader({required this.isPetBooking});

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
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isPetBooking ? Icons.pets_rounded : Icons.fact_check_rounded,
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
                  isPetBooking ? 'Xác nhận đặt pet' : 'Xác nhận đặt bàn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  isPetBooking
                      ? 'Kiểm tra thú cưng và thông tin booking '
                            'trước khi xác nhận.'
                      : 'Kiểm tra lại thông tin trước khi '
                            'hoàn tất lịch ghé PetHub.',
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
