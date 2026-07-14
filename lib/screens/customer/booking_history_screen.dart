import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/pet_booking.dart';
import '../../services/pet_booking_store.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String? customerId;
  const BookingHistoryScreen({super.key, this.customerId});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late final TextEditingController _customerController;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _customerId = widget.customerId;
    _customerController = TextEditingController(text: widget.customerId ?? '');
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Đặt Online'),
            Tab(text: 'Đặt tại chỗ'),
          ],
        ),
      ),
      body: _customerId == null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      labelText: 'Tên khách hoặc SĐT',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final value = _customerController.text
                          .trim()
                          .toLowerCase()
                          .replaceAll(RegExp(r'\s+'), ' ');
                      if (value.isNotEmpty) setState(() => _customerId = value);
                    },
                    child: const Text('Xem lịch sử'),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<PetBooking>>(
              stream: PetBookingStore.instance.bookingHistory(_customerId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data!;
                return TabBarView(
                  children: [
                    _BookingList(
                      bookings
                          .where((b) => b.bookingType == BookingType.online)
                          .toList(),
                    ),
                    _BookingList(
                      bookings
                          .where((b) => b.bookingType == BookingType.offline)
                          .toList(),
                    ),
                  ],
                );
              },
            ),
    ),
  );
}

class _BookingList extends StatelessWidget {
  final List<PetBooking> bookings;
  const _BookingList(this.bookings);

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return const Center(child: Text('Chưa có booking.'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          child: ListTile(
            title: Text('Mã booking: ${booking.bookingId}'),
            subtitle: Text(
              'Pet: ${booking.pets.join(', ')}\n'
              '${booking.bookingType == BookingType.online ? 'Chi nhánh: ${booking.address ?? '-'} • Bàn: ${booking.tableNumber ?? '-'}' : 'Bàn: ${booking.tableNumber ?? '-'}'}\n'
              'Ngày đặt: ${_date(booking.bookingDate)} • Giờ: ${booking.startTime}\n'
              'Trạng thái: ${booking.status.label}',
            ),
            isThreeLine: false,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BookingDetailScreen(bookingId: booking.bookingId),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  Future<void> _cancel(BuildContext context, PetBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy booking này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PetBookingStore.instance.cancelBooking(booking.bookingId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã hủy booking.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<PetBooking?>(
    stream: FirebaseBookingStream(bookingId).stream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final booking = snapshot.data;
      if (booking == null) {
        return const Scaffold(
          body: Center(child: Text('Không tìm thấy booking.')),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết booking')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _row('Mã booking', booking.bookingId),
            _row('Danh sách pet', booking.pets.join(', ')),
            _row('Loại đặt', booking.bookingType.label),
            _row('Giờ nhận pet', booking.startTime),
            if (booking.bookingType == BookingType.online) ...[
              _row('Chi nhánh', booking.address ?? '-'),
              _row('Bàn', booking.tableNumber ?? '-'),
            ] else
              _row('Số bàn', booking.tableNumber ?? '-'),
            _row('Ghi chú', booking.note.isEmpty ? '-' : booking.note),
            _row('Trạng thái', booking.status.label),
            _row(
              'Ngày tạo booking',
              _date(booking.createdAt ?? booking.bookingDate),
            ),
            if (booking.isActive) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditBookingScreen(booking: booking),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa booking'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _cancel(context, booking),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy đơn'),
              ),
            ],
          ],
        ),
      );
    },
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
}

class EditBookingScreen extends StatefulWidget {
  final PetBooking booking;
  const EditBookingScreen({super.key, required this.booking});
  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _time;
  late final TextEditingController _location;
  late final TextEditingController _note;
  late List<String> _pets;

  @override
  void initState() {
    super.initState();
    _pets = [...widget.booking.pets];
    _time = TextEditingController(text: widget.booking.startTime);
    _location = TextEditingController(
      text: widget.booking.bookingType == BookingType.online
          ? widget.booking.address
          : widget.booking.tableNumber,
    );
    _note = TextEditingController(text: widget.booking.note);
  }

  @override
  void dispose() {
    _time.dispose();
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(
        () => _time.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _choosePet({int? replaceIndex}) async {
    final choices = PetBookingStore.instance.pets
        .where((pet) => pet.isAvailable || _pets.contains(pet.name))
        .toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: choices
            .map(
              (pet) => ListTile(
                title: Text(pet.name),
                onTap: () => Navigator.pop(context, pet.name),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (replaceIndex != null) {
        _pets[replaceIndex] = selected;
      } else if (_pets.length < 3 && !_pets.contains(selected)) {
        _pets.add(selected);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _pets.isEmpty) {
      return;
    }
    final updated = PetBooking(
      bookingId: widget.booking.bookingId,
      customerId: widget.booking.customerId,
      customerName: widget.booking.customerName,
      bookingType: widget.booking.bookingType,
      pets: _pets,
      bookingDate: widget.booking.bookingDate,
      startTime: _time.text,
      address: widget.booking.bookingType == BookingType.online
          ? _location.text.trim()
          : null,
      tableNumber: widget.booking.bookingType == BookingType.offline
          ? _location.text.trim()
          : widget.booking.tableNumber,
      note: _note.text.trim(),
      status: widget.booking.status,
      createdAt: widget.booking.createdAt,
    );
    try {
      await PetBookingStore.instance.updateModernBooking(updated);
      if (mounted) Navigator.pop(context);
    } on BookingPetLimitException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mỗi booking chỉ được đặt tối đa 3 pet.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chỉnh sửa booking')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách pet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(
              _pets.length,
              (i) => ListTile(
                title: Text(_pets[i]),
                onTap: () => _choosePet(replaceIndex: i),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _pets.length == 1
                      ? null
                      : () => setState(() => _pets.removeAt(i)),
                ),
              ),
            ),
            if (_pets.length < 3)
              OutlinedButton.icon(
                onPressed: _choosePet,
                icon: const Icon(Icons.add),
                label: const Text('Thêm pet'),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _time,
              readOnly: true,
              onTap: _pickTime,
              decoration: const InputDecoration(
                labelText: 'Giờ nhận pet',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng chọn giờ' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: InputDecoration(
                labelText: widget.booking.bookingType == BookingType.online
                    ? 'Chi nhánh'
                    : 'Số bàn',
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
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
                onPressed: _save,
                child: const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class FirebaseBookingStream {
  final String id;
  FirebaseBookingStream(this.id);
  Stream<PetBooking?> get stream => FirebaseFirestore.instance
      .collection('bookings')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? PetBooking.fromFirestore(doc) : null);
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
