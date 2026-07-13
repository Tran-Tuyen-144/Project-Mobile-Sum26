import 'package:flutter/material.dart';

import '../../../services/pet_booking_store.dart';
import '../booking_confirm/booking_confirm_data.dart';
import '../booking_confirm/booking_confirm_screen.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatefulWidget {
  final String? tableBookingId;
  final BookingConfirmData? bookingData;

  const PetListScreen({super.key, this.tableBookingId, this.bookingData});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  late final List<String> _selectedPets;

  bool get _isSelectingPet => widget.bookingData != null;

  @override
  void initState() {
    super.initState();
    _selectedPets = [...?widget.bookingData?.petNames];
  }

  void _togglePet(PetProfile pet) {
    if (_selectedPets.contains(pet.name)) {
      setState(() => _selectedPets.remove(pet.name));
      return;
    }
    if (!pet.isAvailable || pet.bookingStatus == 'Đã được đặt') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet này hiện không thể chọn.')),
      );
      return;
    }
    if (_selectedPets.length == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mỗi khách chỉ được chọn tối đa 3 pet.')),
      );
      return;
    }
    setState(() => _selectedPets.add(pet.name));
  }

  void _continueToConfirm() {
    if (_selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 pet.')),
      );
      return;
    }
    final booking = widget.bookingData!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(
          data: BookingConfirmData(
            petNames: _selectedPets,
            petStatus: 'Đã chọn',
            customerName: booking.customerName,
            branch: booking.branch,
            day: booking.day,
            time: booking.time,
            guests: booking.guests,
            tableName: booking.tableName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petStore = PetBookingStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectingPet ? 'Chọn pet (tối đa 3)' : 'Hồ sơ thú cưng'),
      ),
      body: ValueListenableBuilder<List<PetProfile>>(
        valueListenable: petStore.petsNotifier,
        builder: (context, pets, _) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            final selected = _selectedPets.contains(pet.name);
            final locked =
                !pet.isAvailable || pet.bookingStatus == 'Đã được đặt';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: locked && !selected ? Colors.grey.shade200 : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: selected ? Colors.green.shade100 : pet.color,
                  child: Icon(
                    selected ? Icons.check : (locked ? Icons.lock : Icons.pets),
                  ),
                ),
                title: Text(pet.name),
                subtitle: Text(
                  '${pet.age} • ${pet.healthStatus}\n${locked && !selected
                      ? 'Đã được đặt'
                      : selected
                      ? 'Đang chọn'
                      : 'Còn trống'}',
                ),
                isThreeLine: true,
                trailing: _isSelectingPet
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => _togglePet(pet),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: () => _isSelectingPet
                    ? _togglePet(pet)
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetDetailScreen(pet: pet.toMap()),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _isSelectingPet
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _continueToConfirm,
                icon: const Icon(Icons.arrow_forward),
                label: Text('Tiếp tục (${_selectedPets.length}/3 pet)'),
              ),
            )
          : null,
    );
  }
}
