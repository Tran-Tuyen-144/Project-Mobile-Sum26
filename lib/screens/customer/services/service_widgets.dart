import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../storage/service_booking_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'pet_service.dart';

class ServiceHeader extends StatelessWidget {
  const ServiceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.mint, AppColors.peach, AppColors.cream],
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
            child: const Icon(
              Icons.pets_rounded,
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
                  'Dịch vụ thú cưng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tìm spa, khách sạn thú cưng, phòng khám và dịch vụ chăm sóc gần bạn.',
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

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.peach,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final PetService service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: service.color,
            child: Icon(service.icon, color: AppColors.textDark, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.rating.toString(),
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.distance,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                service.price,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSoft,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceDetailSheet extends StatefulWidget {
  final PetService service;
  final VoidCallback? onRequestSubmitted;

  const ServiceDetailSheet({
    super.key,
    required this.service,
    this.onRequestSubmitted,
  });

  @override
  State<ServiceDetailSheet> createState() => _ServiceDetailSheetState();
}

class _ServiceDetailSheetState extends State<ServiceDetailSheet> {
  late DateTime _selectedDate;
  late DateTime _endDate;
  late TimeOfDay _selectedTime;
  late TimeOfDay _hotelCheckInTime;
  late TimeOfDay _hotelCheckOutTime;
  int _roomCount = 1;
  late String _selectedPackage;
  String _selectedHotelSize = 'Mèo dưới 3kg';
  bool _hasVaccinationRecord = false;
  bool _needsPickup = false;
  String _symptomDuration = 'Dưới 24 giờ';
  String _selectedTherapy = 'Khám tổng quát & lập phác đồ';
  String _healthConcern = 'Đau mãn tính / vận động';
  String _selectedPaymentMethod = 'ZaloPay';
  final Set<String> _spaAddOns = {};
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _endDate = _selectedDate.add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _hotelCheckInTime = const TimeOfDay(hour: 9, minute: 0);
    _hotelCheckOutTime = const TimeOfDay(hour: 10, minute: 0);
    _selectedPackage = _packageOptions.first;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSoft.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: service.color,
                  child: Icon(
                    service.icon,
                    color: AppColors.textDark,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                SoftCard(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.category_rounded,
                        label: 'Loại dịch vụ',
                        value: service.category,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Khoảng cách',
                        value: service.distance,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.star_rounded,
                        label: 'Đánh giá',
                        value: '${service.rating}/5',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.payments_rounded,
                        label: 'Giá tham khảo',
                        value: service.price,
                      ),
                    ],
                  ),
                ),
                if (_isSpa) ...[
                  const SizedBox(height: 12),
                  _SpaProcessCard(),
                  const SizedBox(height: 12),
                  SoftCard(
                    color: AppColors.peach,
                    onTap: _callHotline,
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.phone_in_talk_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cần tư vấn tình trạng lông hoặc báo giá trước? Liên hệ: 0822905915',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_isHotel || _isVeterinary) ...[
                  const SizedBox(height: 12),
                  _ServiceContactCard(
                    onTap: _callHotline,
                    message: _isHotel
                        ? 'Cần kiểm tra phòng hoặc tư vấn trước khi gửi bé? Liên hệ: 0822905915'
                        : 'Cần tư vấn tình trạng của bé trước khi đặt lịch? Liên hệ: 0822905915',
                  ),
                ],
                const SizedBox(height: 16),
                _DatePickCard(
                  label: _isHotel ? 'Ngày nhận pet' : 'Ngày hẹn',
                  value: _dateText(_selectedDate),
                  onTap: _pickStartDate,
                ),
                if (_isHotel) ...[
                  const SizedBox(height: 12),
                  _DatePickCard(
                    label: 'Ngày trả pet',
                    value: _dateText(_endDate),
                    onTap: _pickEndDate,
                  ),
                ],
                if (!_isHotel) ...[
                  const SizedBox(height: 12),
                  _TimePickCard(
                    label: 'Giờ hẹn',
                    value: _timeText(_selectedTime),
                    onTap: _pickTime,
                  ),
                ],
                Text(
                  _formTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customerNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Tên khách hàng',
                    hintText: 'Ví dụ: Nguyễn Hiếu',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Số điện thoại',
                    hintText: 'Nhân viên dùng để liên hệ xác nhận',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPackage,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Gói dịch vụ',
                    prefixIcon: Icon(Icons.spa_outlined),
                  ),
                  items: _packageOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedPackage = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ..._specializedFields(context),
                const SizedBox(height: 12),
                SoftCard(
                  color: AppColors.lavender,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isHotel ? 'Tạm tính lưu trú' : 'Tổng dịch vụ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        _money(_servicePrice),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Phương thức thanh toán',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ZaloPay',
                      child: Text('ZaloPay • Quét QR demo'),
                    ),
                    DropdownMenuItem(
                      value: 'Thanh toán tại quầy',
                      child: Text('Thanh toán tại quầy'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _selectedPaymentMethod =
                        value ?? _selectedPaymentMethod,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: _noteLabel,
                    hintText: _noteHint,
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitRequest,
                    icon: const Icon(Icons.send_rounded),
                    label: Text('Thanh toán ${_money(_servicePrice)}'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _isHotel => widget.service.category == 'Khách sạn';
  bool get _isSpa => widget.service.category == 'Spa';
  bool get _isVeterinary => widget.service.category == 'Thú y';

  int get _servicePrice => switch (_selectedPackage) {
    'Tắm spa trọn gói' => 120000,
    'Tắm spa + vệ sinh tai, móng, bàn chân' => 180000,
    'Spa trọn gói + cắt tỉa lông theo yêu cầu' => 280000,
    'Khám tổng quát & lập phác đồ' => 90000,
    'Châm cứu hỗ trợ' => 220000,
    'Laser therapy' => 250000,
    'Vật lý trị liệu' => 200000,
    'Tư vấn thảo dược / dinh dưỡng' => 150000,
    _ when _isHotel =>
      _hotelDailyPrice *
          _endDate.difference(_selectedDate).inDays.clamp(1, 60).toInt() *
          _roomCount,
    _ => 120000,
  };

  int get _hotelDailyPrice => switch (_selectedHotelSize) {
    'Mèo dưới 3kg' => 100000,
    'Mèo từ 3kg trở lên' => 120000,
    'Chó dưới 5kg' => 150000,
    'Chó từ 5kg đến dưới 10kg' => 200000,
    'Chó từ 10kg đến 20kg' => 250000,
    _ => 300000,
  };

  String _money(int value) =>
      '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}đ';

  List<String> get _packageOptions {
    return switch (widget.service.category) {
      'Khách sạn' => const [
        'Phòng riêng tiêu chuẩn • 3 bữa/ngày',
        'Phòng riêng + cập nhật video',
        'Lưu trú dài ngày + tắm trước khi về',
      ],
      'Thú y' => const [
        'Khám tổng quát & lập phác đồ',
        'Châm cứu hỗ trợ',
        'Laser therapy',
        'Vật lý trị liệu',
        'Tư vấn thảo dược / dinh dưỡng',
      ],
      'Grooming' => const [
        'Cắt tỉa vệ sinh cơ bản',
        'Tạo kiểu theo giống',
        'Grooming trọn gói + dưỡng lông',
      ],
      'Spa' => const [
        'Tắm spa trọn gói',
        'Tắm spa + vệ sinh tai, móng, bàn chân',
        'Spa trọn gói + cắt tỉa lông theo yêu cầu',
      ],
      _ => const [
        'Tắm spa cơ bản',
        'Tắm + vệ sinh tai móng',
        'Spa trọn gói + dưỡng lông',
      ],
    };
  }

  String get _formTitle {
    return switch (widget.service.category) {
      'Khách sạn' => 'Thông tin gửi pet',
      'Thú y' => 'Thông tin khám & trị liệu',
      'Grooming' => 'Thông tin tạo kiểu',
      _ => 'Thông tin spa',
    };
  }

  String get _noteLabel {
    return switch (widget.service.category) {
      'Khách sạn' => 'Thói quen / đồ gửi kèm',
      'Thú y' => 'Triệu chứng / tiền sử điều trị',
      _ => 'Yêu cầu chăm sóc',
    };
  }

  String get _noteHint {
    return switch (widget.service.category) {
      'Khách sạn' => 'Ví dụ: ăn hạt riêng, sợ tiếng lớn, có gửi đồ chơi...',
      'Thú y' => 'Ví dụ: đau khớp, vừa phẫu thuật, lo âu, đang dùng thuốc...',
      _ => 'Ví dụ: bé hơi nhát, cần nhân viên nhẹ tay...',
    };
  }

  List<Widget> _specializedFields(BuildContext context) {
    switch (widget.service.category) {
      case 'Khách sạn':
        return [
          DropdownButtonFormField<String>(
            initialValue: _selectedHotelSize,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Loại pet / cân nặng',
              prefixIcon: Icon(Icons.monitor_weight_outlined),
            ),
            items:
                const [
                      'Mèo dưới 3kg',
                      'Mèo từ 3kg trở lên',
                      'Chó dưới 5kg',
                      'Chó từ 5kg đến dưới 10kg',
                      'Chó từ 10kg đến 20kg',
                      'Chó trên 20kg',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) => setState(
              () => _selectedHotelSize = value ?? _selectedHotelSize,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _roomCount,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Số phòng cần đặt',
              prefixIcon: Icon(Icons.meeting_room_outlined),
            ),
            items: List.generate(
              4,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('${index + 1} phòng'),
              ),
            ),
            onChanged: (value) => setState(() => _roomCount = value ?? 1),
          ),
          const SizedBox(height: 12),
          _TimePickCard(
            label: 'Giờ nhận pet',
            value: _timeText(_hotelCheckInTime),
            onTap: () => _pickHotelTime(isCheckIn: true),
          ),
          const SizedBox(height: 12),
          _TimePickCard(
            label: 'Giờ trả pet',
            value: _timeText(_hotelCheckOutTime),
            onTap: () => _pickHotelTime(isCheckIn: false),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _hasVaccinationRecord,
            onChanged: (value) =>
                setState(() => _hasVaccinationRecord = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Bé đã tiêm phòng và có sổ sức khỏe'),
            subtitle: const Text(
              'Khách sạn chỉ nhận bé đủ điều kiện sức khỏe.',
            ),
          ),
          CheckboxListTile(
            value: _needsPickup,
            onChanged: (value) => setState(() => _needsPickup = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Cần hỗ trợ đưa đón thú cưng'),
          ),
        ];
      case 'Thú y':
        return [
          DropdownButtonFormField<String>(
            initialValue: _selectedTherapy,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Phương pháp hỗ trợ',
              prefixIcon: Icon(Icons.healing_rounded),
            ),
            items:
                const [
                      'Khám tổng quát & lập phác đồ',
                      'Châm cứu',
                      'Laser therapy',
                      'Vật lý trị liệu',
                      'Thảo dược / dinh dưỡng',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) =>
                setState(() => _selectedTherapy = value ?? _selectedTherapy),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _healthConcern,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Vấn đề cần hỗ trợ',
              prefixIcon: Icon(Icons.favorite_border_rounded),
            ),
            items:
                const [
                      'Đau mãn tính / vận động',
                      'Phục hồi sau chấn thương / phẫu thuật',
                      'Lo âu / hành vi',
                      'Da, dị ứng hoặc tiêu hóa',
                      'Khác / cần bác sĩ đánh giá',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) =>
                setState(() => _healthConcern = value ?? _healthConcern),
          ),
          DropdownButtonFormField<String>(
            initialValue: _symptomDuration,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Thời gian xuất hiện triệu chứng',
              prefixIcon: Icon(Icons.timelapse_rounded),
            ),
            items: const ['Dưới 24 giờ', '1–3 ngày', 'Trên 3 ngày', 'Không rõ']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _symptomDuration = value ?? _symptomDuration),
          ),
        ];
      case 'Spa':
        return [
          TextField(
            controller: _conditionController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Tình trạng lông / da',
              hintText: 'Ví dụ: lông rối nhẹ, da nhạy cảm...',
              prefixIcon: Icon(Icons.pets_outlined),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dịch vụ bổ sung',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      'Cạo lông bàn chân',
                      'Vệ sinh tai',
                      'Cắt & dũa móng',
                      'Gỡ rối lông',
                      'Vắt tuyến hôi',
                      'Massage',
                      'Dưỡng lông',
                      'Cắt tạo kiểu',
                    ]
                    .map(
                      (item) => FilterChip(
                        label: Text(item),
                        selected: _spaAddOns.contains(item),
                        onSelected: (selected) => setState(() {
                          selected
                              ? _spaAddOns.add(item)
                              : _spaAddOns.remove(item);
                        }),
                      ),
                    )
                    .toList(),
          ),
        ];
      default:
        return [
          TextField(
            controller: _conditionController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Yêu cầu tạo kiểu',
              hintText: 'Ví dụ: tỉa gọn mặt, giữ độ dài lông...',
              prefixIcon: Icon(Icons.content_cut_rounded),
            ),
          ),
        ];
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: 'Chọn ngày dịch vụ',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      if (_endDate.isBefore(_selectedDate.add(const Duration(days: 1)))) {
        _endDate = _selectedDate.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickEndDate() async {
    final firstEndDate = _selectedDate.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(firstEndDate) ? firstEndDate : _endDate,
      firstDate: firstEndDate,
      lastDate: _selectedDate.add(const Duration(days: 60)),
      helpText: 'Chọn ngày trả pet',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _endDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Chọn giờ hẹn',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _selectedTime = picked;
    });
  }

  Future<void> _pickHotelTime({required bool isCheckIn}) async {
    final currentTime = isCheckIn ? _hotelCheckInTime : _hotelCheckOutTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: isCheckIn ? 'Chọn giờ nhận pet' : 'Chọn giờ trả pet',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _hotelCheckInTime = picked;
      } else {
        _hotelCheckOutTime = picked;
      }
    });
  }

  Future<void> _submitRequest() async {
    final localContext = context;
    final customerName = _customerNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên khách hàng.')),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text('Số điện thoại cần đủ 10 số.')),
      );
      return;
    }

    if (widget.service.category == 'Thú y' &&
        _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng mô tả triệu chứng để bác sĩ chuẩn bị.'),
        ),
      );
      return;
    }

    if (_isHotel && !_hasVaccinationRecord) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng xác nhận bé đã tiêm phòng và có sổ sức khỏe.',
          ),
        ),
      );
      return;
    }

    final service = widget.service;
    final details = _serviceDetails();
    final request = ServiceBookingRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      serviceName: service.name,
      serviceCategory: service.category,
      packageName: _selectedPackage,
      customerName: customerName,
      phone: phone,
      petName: '',
      petType: '',
      startDay: _dateText(_selectedDate),
      endDay: _isHotel ? _dateText(_endDate) : '',
      time: _isHotel
          ? 'Nhận ${_timeText(_hotelCheckInTime)} • Trả ${_timeText(_hotelCheckOutTime)}'
          : _timeText(_selectedTime),
      note: _noteController.text.trim(),
      details: {
        ...details,
        'Tổng thanh toán': _money(_servicePrice),
        'Phương thức thanh toán': _selectedPaymentMethod,
      },
      status: ServiceBookingStatus.sent,
    );

    final shouldSend = await _showBookingSummary(request);
    if (!shouldSend) return;

    if (_selectedPaymentMethod == 'ZaloPay' && !await _showZaloPayPayment()) {
      return;
    }

    try {
      await ServiceBookingStorage.saveRequest(request);
    } catch (error) {
      if (!localContext.mounted) return;
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(
          content: Text(
            'Chưa gửi được lên Firestore. Kiểm tra Firestore Database và rules: $error',
          ),
        ),
      );
      return;
    }
    widget.onRequestSubmitted?.call();

    if (!mounted) return;
    Navigator.pop(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yêu cầu đã gửi admin'),
          content: Text(
            'Lịch dịch vụ đã được lưu. Admin sẽ kiểm tra và xác nhận lịch qua số $phone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> _serviceDetails() {
    switch (widget.service.category) {
      case 'Khách sạn':
        return {
          'Loại pet / cân nặng': _selectedHotelSize,
          'Số phòng': '$_roomCount phòng',
          'Giờ nhận pet': _timeText(_hotelCheckInTime),
          'Giờ trả pet': _timeText(_hotelCheckOutTime),
          'Đưa đón': _needsPickup ? 'Cần hỗ trợ' : 'Tự đưa đón',
        };
      case 'Thú y':
        return {
          'Phương pháp hỗ trợ': _selectedTherapy,
          'Vấn đề cần hỗ trợ': _healthConcern,
          'Thời gian triệu chứng': _symptomDuration,
        };
      case 'Spa':
        return {
          if (_conditionController.text.trim().isNotEmpty)
            'Tình trạng lông / da': _conditionController.text.trim(),
          if (_spaAddOns.isNotEmpty) 'Dịch vụ bổ sung': _spaAddOns.join(', '),
        };
      default:
        return {
          if (_conditionController.text.trim().isNotEmpty)
            'Yêu cầu tạo kiểu': _conditionController.text.trim(),
        };
    }
  }

  Future<bool> _showBookingSummary(ServiceBookingRequest request) async {
    final summaryLines = <String>[
      'Dịch vụ: ${request.serviceName}',
      'Gói: ${request.packageName}',
      request.endDay.isEmpty
          ? 'Lịch hẹn: ${request.startDay} • ${request.time}'
          : 'Lưu trú: ${request.startDay} đến ${request.endDay} • ${request.time}',
      ...request.details.entries.map((entry) => '${entry.key}: ${entry.value}'),
      if (request.note.isNotEmpty) 'Ghi chú: ${request.note}',
    ];

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xác nhận thông tin đặt lịch'),
            content: SingleChildScrollView(
              child: Text(summaryLines.join('\n\n')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Chỉnh sửa'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Gửi admin'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showZaloPayPayment() async {
    final paymentCode = 'ZLP-${DateTime.now().millisecondsSinceEpoch}';
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    });
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Quét mã ZaloPay'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 150,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  _money(_servicePrice),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(paymentCode),
                const SizedBox(height: 8),
                const Text(
                  'Demo sẽ tự xác nhận thanh toán sau vài giây.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _callHotline() async {
    final opened = await launchUrl(Uri(scheme: 'tel', path: '0822905915'));
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiết bị này không hỗ trợ gọi điện.')),
      );
    }
  }

  String _dateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    final label = normalized == today ? 'Hôm nay' : _weekdayLabel(date.weekday);
    return '$label, ${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      DateTime.sunday => 'CN',
      _ => '',
    };
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _timeText(TimeOfDay time) {
    return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
  }
}

class _DatePickCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.sky,
            child: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _TimePickCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.peach,
            child: Icon(Icons.schedule_rounded, color: AppColors.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.access_time_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SpaProcessCard extends StatelessWidget {
  const _SpaProcessCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Kiểm tra da & lông',
      'Vệ sinh tai, móng, bàn chân',
      'Tắm & massage',
      'Sấy khô, dưỡng lông',
      'Cắt tỉa theo yêu cầu',
    ];

    return SoftCard(
      color: AppColors.mint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quy trình spa cho bé',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...List.generate(
            steps.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.white,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(steps[index])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceContactCard extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _ServiceContactCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.peach,
      onTap: onTap,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
