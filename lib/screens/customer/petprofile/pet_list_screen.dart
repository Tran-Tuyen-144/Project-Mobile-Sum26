import 'package:flutter/material.dart';

import '../../../services/pet_booking_store.dart';
import '../booking_confirm/booking_confirm_data.dart';
import '../booking_confirm/booking_confirm_screen.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key, this.tableBookingId, this.bookingData});

  final String? tableBookingId;
  final BookingConfirmData? bookingData;

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  late final List<String> _selectedPets;
  bool get _selecting => widget.bookingData != null;

  @override
  void initState() {
    super.initState();
    _selectedPets = [...?widget.bookingData?.petNames];
  }

  void _toggle(PetProfile pet) {
    if (_selectedPets.contains(pet.name)) {
      setState(() => _selectedPets.remove(pet.name));
    } else if (pet.isAvailable && _selectedPets.length < 3) {
      setState(() => _selectedPets.add(pet.name));
    }
  }

  void _continue() {
    if (_selectedPets.isEmpty) return;
    final data = widget.bookingData!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(
          data: BookingConfirmData(
            petNames: _selectedPets,
            petStatus: 'Đã chọn',
            customerName: data.customerName,
            branch: data.branch,
            day: data.day,
            time: data.time,
            guests: data.guests,
            tableName: data.tableName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_selecting ? 'Chọn pet (tối đa 3)' : 'Hồ sơ thú cưng'),
    ),
    body: ValueListenableBuilder<List<PetProfile>>(
      valueListenable: PetBookingStore.instance.petsNotifier,
      builder: (context, pets, _) => ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final selected = _selectedPets.contains(pet.name);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: pet.color,
              child: Icon(selected ? Icons.check : Icons.pets),
            ),
            title: Text(pet.name),
            subtitle: Text('${pet.age} • ${pet.healthStatus}'),
            trailing: _selecting
                ? Checkbox(value: selected, onChanged: (_) => _toggle(pet))
                : const Icon(Icons.chevron_right),
            onTap: _selecting
                ? () => _toggle(pet)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PetDetailScreen(pet: pet.toMap()),
                    ),
                  ),
          );
        },
      ),
    ),
    bottomNavigationBar: _selecting
        ? SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedPets.isEmpty ? null : _continue,
              child: Text('Tiếp tục (${_selectedPets.length}/3)'),
            ),
          )
        : null,
  );
}
