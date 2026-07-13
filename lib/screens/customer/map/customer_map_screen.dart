import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import 'branch_location.dart';
import 'map_widgets.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  String selectedCategory = 'Tất cả';
  String keyword = '';
  BranchLocation? selectedLocation;

  List<BranchLocation> get filteredLocations {
    return branchLocations.where((location) {
      final matchCategory =
          selectedCategory == 'Tất cả' || location.category == selectedCategory;

      final matchKeyword =
          location.name.toLowerCase().contains(keyword.toLowerCase()) ||
          location.address.toLowerCase().contains(keyword.toLowerCase());

      return matchCategory && matchKeyword;
    }).toList();
  }

  void _selectLocation(BranchLocation location) {
    setState(() {
      selectedLocation = location;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return BranchDetailSheet(location: location);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MapHeader(),

          const SizedBox(height: 22),

          FakeMapPanel(selectedLocation: selectedLocation),

          const SizedBox(height: 22),

          TextField(
            onChanged: (value) {
              setState(() {
                keyword = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Tìm chi nhánh, địa chỉ...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Loại chi nhánh'),

          const SizedBox(height: 12),

          BranchCategorySelector(
            categories: branchCategories,
            selectedCategory: selectedCategory,
            onSelected: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 24),

          SectionTitle(
            title: 'Chi nhánh gần bạn',
            actionText: '${filteredLocations.length} nơi',
          ),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: filteredLocations.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final location = filteredLocations[index];

              return BranchLocationCard(
                location: location,
                isSelected: selectedLocation?.name == location.name,
                onTap: () => _selectLocation(location),
              );
            },
          ),
        ],
      ),
    );
  }
}
