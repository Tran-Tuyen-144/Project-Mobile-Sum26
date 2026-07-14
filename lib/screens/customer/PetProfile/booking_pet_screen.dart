import 'package:flutter/material.dart';

import '../../../models/pet_booking.dart';
import '../../../services/pet_booking_store.dart';

class BookingPetScreen extends StatefulWidget {
  const BookingPetScreen({super.key, required this.petName});

  final String petName;

  @override
  State<BookingPetScreen> createState() => _BookingPetScreenState();
}

class _BookingPetScreenState extends State<BookingPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();
  BookingType _bookingType = BookingType.offline;
  bool _saving = false;

  @override
  void dispose() {
    _customerController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() => _timeController.text = time.format(context));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await PetBookingStore.instance.createModernBooking(
        customerId: _customerController.text.trim().toLowerCase(),
        customerName: _customerController.text.trim(),
        bookingType: _bookingType,
        petName: widget.petName,
        bookingDate: DateTime.now(),
        startTime: _timeController.text,
        address: _bookingType == BookingType.online
            ? _locationController.text.trim()
            : null,
        tableNumber: _bookingType == BookingType.offline
            ? _locationController.text.trim()
            : null,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt pet thành công.')));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu booking: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = _bookingType == BookingType.online;
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đặt pet: ${widget.petName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'offline',
                    label: Text('Tại quán'),
                    icon: Icon(Icons.store),
                  ),
                  ButtonSegment(
                    value: 'online',
                    label: Text('Online'),
                    icon: Icon(Icons.home),
                  ),
                ],
                selected: {online ? 'online' : 'offline'},
                onSelectionChanged: (value) => setState(
                  () => _bookingType = value.first == 'online'
                      ? BookingType.online
                      : BookingType.offline,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hoặc SĐT',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _pickTime,
                decoration: const InputDecoration(
                  labelText: 'Giờ nhận pet',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: online ? 'Địa chỉ' : 'Số bàn',
                  border: const OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Đang lưu...' : 'Xác nhận đặt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Vui lòng nhập thông tin này'
      : null;
}
