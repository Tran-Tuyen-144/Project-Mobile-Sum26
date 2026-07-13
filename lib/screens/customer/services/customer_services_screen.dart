import 'package:flutter/material.dart';

import '../../../storage/service_booking_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'pet_service.dart';
import 'featured_service_screen.dart';
import 'service_widgets.dart';

class CustomerServicesScreen extends StatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  String selectedCategory = 'Tất cả';
  String keyword = '';
  List<ServiceBookingRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final requests = await ServiceBookingStorage.loadRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
    });
  }

  List<PetService> get filteredServices {
    return petServices.where((service) {
      final matchCategory =
          selectedCategory == 'Tất cả' || service.category == selectedCategory;

      final matchKeyword =
          service.name.toLowerCase().contains(keyword.toLowerCase()) ||
          service.description.toLowerCase().contains(keyword.toLowerCase());

      return matchCategory && matchKeyword;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceHeader(),

          const SizedBox(height: 22),

          TextField(
            onChanged: (value) {
              setState(() {
                keyword = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Tìm spa, khách sạn, thú y...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Danh mục dịch vụ'),

          const SizedBox(height: 12),

          CategorySelector(
            categories: serviceCategories,
            selectedCategory: selectedCategory,
            onSelected: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 24),

          SectionTitle(
            title: 'Dịch vụ gần bạn',
            actionText: '${filteredServices.length} dịch vụ',
          ),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: filteredServices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = filteredServices[index];

              return ServiceCard(
                service: service,
                onTap: () {
                  if (FeaturedServiceScreen.supports(service)) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FeaturedServiceScreen(service: service),
                      ),
                    );
                    return;
                  }
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) {
                      return ServiceDetailSheet(
                        service: service,
                        onRequestSubmitted: _loadRequests,
                      );
                    },
                  );
                },
              );
            },
          ),

          if (_requests.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionTitle(
              title: 'Lịch dịch vụ của bạn',
              actionText: '${_requests.length} lịch',
            ),
            const SizedBox(height: 12),
            _ServiceRequestList(requests: _requests.take(4).toList()),
          ],
        ],
      ),
    );
  }
}

class _ServiceRequestList extends StatelessWidget {
  final List<ServiceBookingRequest> requests;

  const _ServiceRequestList({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: requests.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _statusColor(request.status),
                  child: Icon(
                    _statusIcon(request.status),
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.petName} • ${request.startDay}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    request.status.label,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(ServiceBookingStatus status) {
    return switch (status) {
      ServiceBookingStatus.sent => AppColors.sky,
      ServiceBookingStatus.confirmed => AppColors.mint,
    };
  }

  IconData _statusIcon(ServiceBookingStatus status) {
    return switch (status) {
      ServiceBookingStatus.sent => Icons.notifications_active_rounded,
      ServiceBookingStatus.confirmed => Icons.check_circle_rounded,
    };
  }
}
