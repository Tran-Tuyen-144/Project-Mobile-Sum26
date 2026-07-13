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
  final _formKey = GlobalKey<FormState>();
  final customerController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();
  final noteController = TextEditingController();
  bool _isSaving = false;

  bool get _isOnline => widget.bookingType == BookingType.online;

  @override
  void dispose() {
    customerController.dispose();
    locationController.dispose();
    timeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectBookingTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selected != null && mounted) {
      setState(() {
        timeController.text =
            '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<bool> _askHowToUseActiveBooking(PetBooking booking) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking đang hoạt động'),
            content: const Text(
              'Bạn đã có booking đang hoạt động cùng loại đặt. Bạn muốn làm gì?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tạo booking mới'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Thêm pet vào booking hiện tại'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final customerName = customerController.text.trim();
      final customerId = customerName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      final active = await PetBookingStore.instance.findActiveBooking(
        customerId: customerId,
        bookingType: widget.bookingType,
      );
      final addToCurrent = active != null
          ? await _askHowToUseActiveBooking(active)
          : false;

      if (addToCurrent) {
        await PetBookingStore.instance.addPetToBooking(
          bookingId: active.bookingId,
          petName: widget.petName,
        );
      } else {
        await PetBookingStore.instance.createModernBooking(
          customerId: customerId,
          customerName: customerName,
          bookingType: widget.bookingType,
          petName: widget.petName,
          bookingDate: DateTime.now(),
          startTime: timeController.text,
          address: _isOnline ? locationController.text.trim() : null,
          tableNumber: _isOnline ? null : locationController.text.trim(),
          note: noteController.text.trim(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addToCurrent
              ? 'Đã thêm ${widget.petName} vào booking hiện tại.'
              : 'Đặt pet thành công.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingHistoryScreen(customerId: customerId),
        ),
      );
    } on BookingPetLimitException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mỗi booking chỉ được đặt tối đa 3 pet.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu booking: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationLabel = _isOnline ? 'Địa chỉ' : 'Số bàn';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookingType == BookingType.online
            ? 'Đặt Pet Online'
            : 'Đặt Pet Offline'),
        actions: [
          IconButton(
            tooltip: 'Lịch sử đặt',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đặt pet: ${widget.petName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: customerController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hoặc SĐT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập tên khách hoặc SĐT'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: timeController,
                readOnly: true,
                onTap: _selectBookingTime,
                decoration: const InputDecoration(
                  labelText: 'Giờ nhận pet',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng chọn giờ nhận pet'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: locationLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập ${locationLabel.toLowerCase()}'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Xác nhận đặt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
