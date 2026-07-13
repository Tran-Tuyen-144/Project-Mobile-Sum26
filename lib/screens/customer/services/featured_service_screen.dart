import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'pet_service.dart';
import 'service_widgets.dart';

/// Full-page presentation for the three core services: spa, pet hotel and vet.
class FeaturedServiceScreen extends StatelessWidget {
  final PetService service;

  const FeaturedServiceScreen({super.key, required this.service});

  static bool supports(PetService service) {
    return const {'Spa', 'Khách sạn', 'Thú y'}.contains(service.category);
  }

  _ServicePageContent get _content {
    return switch (service.category) {
      'Khách sạn' => const _ServicePageContent(
        eyebrow: 'PET HOTEL • CHĂM SÓC LƯU TRÚ',
        headline: 'Ngôi nhà thứ hai an tâm cho bé',
        introduction:
            'Không gian riêng, lịch ăn uống rõ ràng và nhân viên theo dõi hằng ngày để bé luôn thoải mái khi xa chủ.',
        highlight: 'Mỗi bé một không gian riêng • 3 bữa/ngày',
        features: [
          _Feature(
            Icons.meeting_room_rounded,
            'Phòng riêng sạch sẽ',
            'Khử mùi và vệ sinh định kỳ',
          ),
          _Feature(
            Icons.restaurant_rounded,
            'Chăm sóc mỗi ngày',
            'Theo lịch ăn phù hợp với từng bé',
          ),
          _Feature(
            Icons.videocam_rounded,
            'Cập nhật cho chủ',
            'Trao đổi tình hình của bé khi cần',
          ),
          _Feature(
            Icons.health_and_safety_rounded,
            'An toàn sức khỏe',
            'Nhận bé đã tiêm phòng, có sổ sức khỏe',
          ),
        ],
        packages: [
          _Package('Mèo dưới 3kg', 'Từ 100.000đ/ngày'),
          _Package('Chó dưới 5kg', 'Từ 150.000đ/ngày'),
          _Package('Chó từ 5kg trở lên', 'Báo giá theo cân nặng'),
        ],
        note:
            'Gửi dài ngày được tư vấn ưu đãi và lịch tắm trước khi bé về nhà.',
      ),
      'Thú y' => const _ServicePageContent(
        eyebrow: 'PET CARE • THĂM KHÁM & TRỊ LIỆU',
        headline: 'Chăm sóc toàn diện theo nhu cầu của bé',
        introduction:
            'Bác sĩ tiếp nhận thông tin, đánh giá tình trạng và tư vấn lộ trình phù hợp cho sức khỏe thể chất lẫn tinh thần của thú cưng.',
        highlight: 'Đánh giá kỹ trước khi lập phác đồ',
        features: [
          _Feature(
            Icons.health_and_safety_rounded,
            'Khám tổng quát',
            'Đánh giá tình trạng và tiền sử điều trị',
          ),
          _Feature(
            Icons.ac_unit_rounded,
            'Laser therapy',
            'Hỗ trợ giảm đau, giảm viêm và phục hồi mô',
          ),
          _Feature(
            Icons.accessibility_new_rounded,
            'Vật lý trị liệu',
            'Cải thiện vận động và phục hồi sau chấn thương',
          ),
          _Feature(
            Icons.spa_rounded,
            'Trị liệu hỗ trợ',
            'Châm cứu, dinh dưỡng và chăm sóc cá thể hóa',
          ),
        ],
        packages: [
          _Package('Khám & tư vấn ban đầu', 'Từ 90.000đ'),
          _Package('Trị liệu theo chỉ định', 'Báo giá sau thăm khám'),
          _Package('Theo dõi phục hồi', 'Lịch riêng cho từng bé'),
        ],
        note:
            'Nếu bé đau nhiều, khó thở, co giật hoặc có dấu hiệu cấp cứu, hãy gọi ngay để được hướng dẫn.',
      ),
      _ => const _ServicePageContent(
        eyebrow: 'PET SPA • TẮM & CHĂM SÓC LÔNG',
        headline: 'Một buổi spa dịu dàng cho bé xinh hơn',
        introduction:
            'Quy trình chăm sóc nhẹ nhàng, lựa chọn theo tình trạng da lông và yêu cầu tạo kiểu riêng của từng bé.',
        highlight: 'Kiểm tra da lông trước khi thực hiện',
        features: [
          _Feature(
            Icons.search_rounded,
            'Kiểm tra da & lông',
            'Ghi nhận da nhạy cảm và phần lông rối',
          ),
          _Feature(
            Icons.bathtub_rounded,
            'Tắm & massage',
            'Làm sạch, khử mùi và giúp bé thư giãn',
          ),
          _Feature(
            Icons.cleaning_services_rounded,
            'Vệ sinh kỹ',
            'Tai, móng, bàn chân và các vùng cần thiết',
          ),
          _Feature(
            Icons.content_cut_rounded,
            'Sấy & cắt tỉa',
            'Dưỡng lông hoặc tạo kiểu theo yêu cầu',
          ),
        ],
        packages: [
          _Package('Tắm spa cơ bản', 'Từ 120.000đ'),
          _Package('Spa + vệ sinh tai, móng', 'Báo giá theo bé'),
          _Package('Spa + cắt tỉa tạo kiểu', 'Báo giá theo tình trạng lông'),
        ],
        note:
            'Phụ phí gỡ rối hoặc xử lý lông đặc biệt sẽ được báo trước khi thực hiện.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: ElevatedButton.icon(
          onPressed: () => _openBookingForm(context),
          icon: const Icon(Icons.calendar_month_rounded),
          label: const Text('Đặt lịch ngay'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(service: service, content: content),
            const SizedBox(height: 20),
            _ContactBanner(category: service.category),
            if (service.category == 'Thú y') ...[
              const SizedBox(height: 14),
              const _DoctorProfileCard(),
            ],
            const SizedBox(height: 24),
            Text(
              'Điểm nổi bật',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...content.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeatureCard(feature: feature),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Gói dịch vụ tham khảo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...content.packages.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PackageCard(item: item),
              ),
            ),
            const SizedBox(height: 6),
            SoftCard(
              color: AppColors.cream,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(content.note)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookingForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ServiceDetailSheet(service: service),
    );
  }
}

class _Hero extends StatelessWidget {
  final PetService service;
  final _ServicePageContent content;

  const _Hero({required this.service, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: service.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            child: Icon(service.icon, color: AppColors.textDark, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            content.eyebrow,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(content.headline, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            content.introduction,
            style: const TextStyle(height: 1.45, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              content.highlight,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBanner extends StatelessWidget {
  final String category;

  const _ContactBanner({required this.category});

  @override
  Widget build(BuildContext context) {
    final label = category == 'Thú y'
        ? 'Tư vấn tình trạng của bé'
        : 'Tư vấn & đặt lịch';
    return SoftCard(
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.peach,
            child: Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                const Text('Hotline: 0822905915'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorProfileCard extends StatelessWidget {
  const _DoctorProfileCard();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.sky,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: AssetImage(
              'assets/images/bs_nguyen_xuan_hieu.jpg',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BS. Nguyễn Xuân Hiếu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Khám tổng quát • Châm cứu • Laser • Phục hồi vận động',
                  style: TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});
  @override
  Widget build(BuildContext context) => SoftCard(
    color: Colors.white,
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.cream,
          child: Icon(feature.icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 3),
              Text(feature.description),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PackageCard extends StatelessWidget {
  final _Package item;
  const _PackageCard({required this.item});
  @override
  Widget build(BuildContext context) => SoftCard(
    color: AppColors.lavender.withValues(alpha: 0.45),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          item.price,
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _ServicePageContent {
  final String eyebrow, headline, introduction, highlight, note;
  final List<_Feature> features;
  final List<_Package> packages;
  const _ServicePageContent({
    required this.eyebrow,
    required this.headline,
    required this.introduction,
    required this.highlight,
    required this.features,
    required this.packages,
    required this.note,
  });
}

class _Feature {
  final IconData icon;
  final String title, description;
  const _Feature(this.icon, this.title, this.description);
}

class _Package {
  final String name, price;
  const _Package(this.name, this.price);
}
