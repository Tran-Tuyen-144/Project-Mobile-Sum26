import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import 'pet_service.dart';
import 'service_widgets.dart';

class CustomerServicesScreen extends StatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  String selectedCategory = 'Tất cả';
  String keyword = '';

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
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = filteredServices[index];

              return ServiceCard(
                service: service,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) {
                      return ServiceDetailSheet(service: service);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}