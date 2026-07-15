import 'package:flutter/material.dart';

import '../../../models/crm_customer.dart';
import '../../../models/crm_pet.dart';
import '../../../services/crm_service.dart';
import '../../../storage/booking_history_storage.dart';
import '../../../theme/app_colors.dart';

class AdminCustomerListScreen extends StatefulWidget {
  const AdminCustomerListScreen({super.key});

  @override
  State<AdminCustomerListScreen> createState() =>
      _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState extends State<AdminCustomerListScreen> {
  final _phoneController = TextEditingController();
  String _phone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Khách hàng CRM'),
      actions: [
        IconButton(
          tooltip: 'Thêm khách hàng',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _CustomerFormScreen()),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded),
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (value) => setState(() => _phone = value.trim()),
            decoration: InputDecoration(
              hintText: 'Tra cứu nhanh bằng số điện thoại',
              prefixIcon: const Icon(Icons.phone_rounded),
              suffixIcon: _phone.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        _phoneController.clear();
                        setState(() => _phone = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CrmCustomer>>(
            stream: CrmService.watchCustomers(phone: _phone),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _LocalCustomersFallback(phone: _phone);
              }
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final customers = snapshot.data!;
              if (customers.isEmpty)
                return _EmptyCustomers(isSearching: _phone.isNotEmpty);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: customers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _CustomerDetailScreen(customerId: customer.id),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: _tierColor(
                          customer.tier,
                        ).withValues(alpha: .18),
                        child: Icon(
                          Icons.person_rounded,
                          color: _tierColor(customer.tier),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        customer.phone.isEmpty
                            ? 'Chưa có số điện thoại'
                            : customer.phone,
                      ),
                      trailing: _TierChip(
                        tier: customer.tier,
                        points: customer.points,
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

/// Firestore can be temporarily unavailable (for example while its rules are
/// being deployed).  Bookings stored on this device still give admin a usable
/// customer list instead of an empty error page.
class _LocalCustomersFallback extends StatelessWidget {
  final String phone;
  const _LocalCustomersFallback({required this.phone});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<BookingHistoryItem>>(
    future: BookingHistoryStorage.loadBookings(),
    builder: (context, snapshot) {
      if (!snapshot.hasData)
        return const Center(child: CircularProgressIndicator());
      final byPhone = <String, BookingHistoryItem>{};
      for (final booking in snapshot.data!) {
        final key = booking.phone.isEmpty
            ? booking.customerName
            : booking.phone;
        if (key.isNotEmpty) byPhone.putIfAbsent(key, () => booking);
      }
      final customers = byPhone.values.where((booking) {
        return phone.isEmpty || booking.phone.contains(phone);
      }).toList();
      if (customers.isEmpty) {
        return const _ErrorState(
          message:
              'Chưa có khách hàng lưu trên thiết bị này. Dữ liệu CRM sẽ tự đồng bộ khi Firestore hoạt động lại.',
        );
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Đang hiển thị dữ liệu đặt bàn lưu trên máy.',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          ...customers.map(
            (booking) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                title: Text(
                  booking.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${booking.phone}\n${booking.tableName} • ${booking.branch}',
                ),
                isThreeLine: true,
                trailing: const Chip(label: Text('Cục bộ')),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _CustomerDetailScreen extends StatelessWidget {
  final String customerId;
  const _CustomerDetailScreen({required this.customerId});

  @override
  Widget build(BuildContext context) => StreamBuilder<CrmCustomer?>(
    stream: CrmService.watchCustomer(customerId),
    builder: (context, snapshot) {
      final customer = snapshot.data;
      if (!snapshot.hasData)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (customer == null)
        return const Scaffold(
          body: _ErrorState(message: 'Không tìm thấy khách hàng.'),
        );
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết khách hàng'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _CustomerFormScreen(customer: customer),
                ),
              ),
              icon: const Icon(Icons.edit_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _PetFormScreen(ownerId: customer.id),
            ),
          ),
          icon: const Icon(Icons.pets_rounded),
          label: const Text('Thêm thú cưng'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        child: Icon(Icons.person_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              customer.phone.isEmpty
                                  ? 'Chưa cập nhật số điện thoại'
                                  : customer.phone,
                            ),
                          ],
                        ),
                      ),
                      _TierChip(tier: customer.tier, points: customer.points),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${customer.points} điểm tích lũy',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Quy đổi: mỗi 10.000đ hoàn tất = 1 điểm'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thú cưng sở hữu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<CrmPet>>(
              stream: CrmService.watchPets(customer.id),
              builder: (context, petSnapshot) {
                if (!petSnapshot.hasData)
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                final pets = petSnapshot.data!;
                if (pets.isEmpty)
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Chưa có hồ sơ thú cưng.'),
                    ),
                  );
                return Column(
                  children: pets
                      .map(
                        (pet) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _PetProfileScreen(pet: pet),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.peach,
                                child: const Icon(Icons.pets_rounded),
                              ),
                              title: Text(
                                pet.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text('${pet.species} • ${pet.breed}'),
                              trailing: pet.vaccinationDue
                                  ? const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    )
                                  : const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _CustomerFormScreen extends StatefulWidget {
  final CrmCustomer? customer;
  const _CustomerFormScreen({this.customer});
  @override
  State<_CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<_CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.customer?.name ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.customer?.phone ?? '',
  );
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await CrmService.saveCustomer(
        id: widget.customer?.id,
        name: _name.text,
        phone: _phone.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu khách hàng.')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.customer == null ? 'Thêm khách hàng' : 'Sửa khách hàng',
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên khách hàng'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Vui lòng nhập số điện thoại'
                  : null,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Đang lưu...' : 'Lưu khách hàng'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PetProfileScreen extends StatelessWidget {
  final CrmPet pet;
  const _PetProfileScreen({required this.pet});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ thú cưng')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 34,
              child: Icon(Icons.pets_rounded, size: 34),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                Text('${pet.species} • ${pet.breed}'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (pet.vaccinationDue)
          Card(
            color: const Color(0xFFFFE9E7),
            child: const ListTile(
              leading: Icon(Icons.warning_rounded, color: Colors.red),
              title: Text(
                'Cần kiểm tra lịch tiêm phòng',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(
                'Chưa có lịch tiêm hoặc mũi gần nhất đã từ 12 tháng.',
              ),
            ),
          ),
        _InfoCard(
          icon: Icons.vaccines_rounded,
          title: 'Lịch tiêm gần nhất',
          value: pet.lastVaccination == null
              ? 'Chưa cập nhật'
              : _date(pet.lastVaccination!),
        ),
        _InfoCard(
          icon: Icons.restaurant_menu_rounded,
          title: 'Dị ứng & chế độ ăn',
          value: pet.dietaryNotes.isEmpty
              ? 'Không có ghi chú'
              : pet.dietaryNotes,
          emphasis: pet.dietaryNotes.isNotEmpty,
        ),
        _InfoCard(
          icon: Icons.medical_information_rounded,
          title: 'Tiền sử bệnh lý',
          value: pet.medicalHistory.isEmpty
              ? 'Chưa có ghi chú'
              : pet.medicalHistory,
        ),
      ],
    ),
  );
}

class _PetFormScreen extends StatefulWidget {
  final String ownerId;
  const _PetFormScreen({required this.ownerId});
  @override
  State<_PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<_PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _breed = TextEditingController();
  final _diet = TextEditingController();
  final _medical = TextEditingController();
  DateTime? _vaccination;
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    _diet.dispose();
    _medical.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await CrmService.savePet(
        ownerId: widget.ownerId,
        name: _name.text,
        species: _species.text,
        breed: _breed.text,
        vaccinationDates: _vaccination == null ? [] : [_vaccination!],
        dietaryNotes: _diet.text,
        medicalHistory: _medical.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu hồ sơ thú cưng.')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thêm thú cưng')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên thú cưng'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _species,
              decoration: const InputDecoration(
                labelText: 'Loài (Chó, Mèo...)',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập loài' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'Giống'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày tiêm gần nhất'),
              subtitle: Text(
                _vaccination == null ? 'Chưa cập nhật' : _date(_vaccination!),
              ),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: _vaccination ?? DateTime.now(),
                );
                if (picked != null) setState(() => _vaccination = picked);
              },
            ),
            TextFormField(
              controller: _diet,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Dị ứng / chế độ ăn',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medical,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Tiền sử bệnh lý'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Đang lưu...' : 'Lưu hồ sơ'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool emphasis;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.emphasis = false,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          value,
          style: TextStyle(
            fontWeight: emphasis ? FontWeight.w900 : FontWeight.normal,
            color: emphasis ? Colors.red.shade800 : null,
          ),
        ),
      ),
    ),
  );
}

class _TierChip extends StatelessWidget {
  final String tier;
  final int points;
  const _TierChip({required this.tier, required this.points});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(
      tier == 'Vàng' ? Icons.workspace_premium_rounded : Icons.stars_rounded,
      size: 17,
      color: _tierColor(tier),
    ),
    label: Text(
      '$tier\n$points đ',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
    ),
    backgroundColor: _tierColor(tier).withValues(alpha: .14),
  );
}

class _EmptyCustomers extends StatelessWidget {
  final bool isSearching;
  const _EmptyCustomers({required this.isSearching});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        isSearching
            ? 'Không tìm thấy khách hàng với số điện thoại này.'
            : 'Chưa có khách hàng. Nhấn + để tạo hồ sơ.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

Color _tierColor(String tier) => switch (tier) {
  'Vàng' => const Color(0xFFB8860B),
  'Bạc' => const Color(0xFF607D8B),
  _ => const Color(0xFF9A6641),
};
String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
