import 'package:flutter/material.dart';

import '../../../models/pet_booking.dart';
import '../../../services/pet_booking_store.dart';
import '../../../theme/app_colors.dart';
import '../booking_history_screen.dart';

class BookingPetScreen extends StatefulWidget {
  final String petName;
  final BookingType bookingType;

  const BookingPetScreen({
    super.key,
    required this.petName,
    this.bookingType = BookingType.offline,
  });

  @override
  State<BookingPetScreen> createState() => _BookingPetScreenState();
}

class _BookingPetScreenState extends State<BookingPetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _customerController = TextEditingController();

  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;

  bool get _isOnline {
    return widget.bookingType == BookingType.online;
  }

  @override
  void dispose() {
    _customerController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectBookingTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Chọn giờ nhận pet',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    final hour = selectedTime.hour.toString().padLeft(2, '0');
    final minute = selectedTime.minute.toString().padLeft(2, '0');

    setState(() {
      _timeController.text = '$hour:$minute';
    });
  }

  String _normalizeCustomerId(String customerName) {
    return customerName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> _askHowToUseActiveBooking(PetBooking booking) async {
    final currentPets = booking.pets.isEmpty
        ? 'Chưa có pet'
        : booking.pets.join(', ');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Booking đang hoạt động'),
          content: Text(
            'Booking hiện tại đang có: $currentPets.\n\n'
            'Bạn muốn thêm ${widget.petName} vào booking hiện tại '
            'hay tạo booking mới?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Tạo booking mới'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Thêm vào booking'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final customerName = _customerController.text.trim();

      final customerId = _normalizeCustomerId(customerName);

      final activeBooking = await PetBookingStore.instance.findActiveBooking(
        customerId: customerId,
        bookingType: widget.bookingType,
      );

      if (!mounted) {
        return;
      }

      bool addToCurrentBooking = false;

      if (activeBooking != null) {
        addToCurrentBooking = await _askHowToUseActiveBooking(activeBooking);
      }

      if (!mounted) {
        return;
      }

      if (activeBooking != null && addToCurrentBooking) {
        await PetBookingStore.instance.addPetToBooking(
          bookingId: activeBooking.bookingId,
          petName: widget.petName,
        );
      } else {
        await PetBookingStore.instance.createModernBooking(
          customerId: customerId,
          customerName: customerName,
          bookingType: widget.bookingType,
          petName: widget.petName,
          bookingDate: DateTime.now(),
          startTime: _timeController.text.trim(),
          address: _isOnline ? _locationController.text.trim() : null,
          tableNumber: _isOnline ? null : _locationController.text.trim(),
          note: _noteController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addToCurrentBooking
                ? 'Đã thêm ${widget.petName} vào booking hiện tại.'
                : 'Đặt ${widget.petName} thành công.',
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) {
            return BookingHistoryScreen(customerId: customerId);
          },
        ),
      );
    } on BookingPetLimitException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mỗi booking chỉ được đặt tối đa 3 pet.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lưu booking: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationLabel = _isOnline ? 'Địa chỉ nhận pet' : 'Số bàn';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isOnline ? 'Đặt Pet Online' : 'Đặt Pet tại chỗ'),
        actions: [
          IconButton(
            tooltip: 'Lịch sử đặt',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const BookingHistoryScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pet được chọn',
                              style: TextStyle(
                                color: AppColors.textSoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.petName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isOnline
                                  ? 'Nhân viên sẽ tiếp nhận theo địa chỉ đã nhập.'
                                  : 'Pet sẽ được giữ tại bàn đã chọn.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _customerController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tên khách hoặc SĐT',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên khách hoặc SĐT';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _selectBookingTime,
                  decoration: const InputDecoration(
                    labelText: 'Giờ nhận pet',
                    prefixIcon: Icon(Icons.access_time_rounded),
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng chọn giờ nhận pet';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: locationLabel,
                    prefixIcon: Icon(
                      _isOnline
                          ? Icons.location_on_outlined
                          : Icons.table_restaurant_outlined,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập '
                          '${locationLabel.toLowerCase()}';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(_isSaving ? 'Đang lưu...' : 'Xác nhận đặt'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
