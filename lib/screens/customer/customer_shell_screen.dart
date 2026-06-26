import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import 'customer_home_screen.dart';
import 'placeholder_feature_screen.dart';
import 'booking/customer_booking_screen.dart';

class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({super.key});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'PetHub',
    'Đặt bàn',
    'Dịch vụ',
    'Bản đồ',
    'Cộng đồng',
  ];

  void _backToRoleSelect() {
    // Nếu màn này được mở bằng context.push('/customer')
    // thì context.pop() sẽ quay về màn chọn chức vụ.
    if (context.canPop()) {
      context.pop();
    } else {
      // Trường hợp không còn màn trước đó trong stack,
      // đưa về thẳng màn chọn chức vụ.
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = const [
      CustomerHomeScreen(),

      CustomerBookingScreen(),

      PlaceholderFeatureScreen(
        icon: Icons.spa_rounded,
        title: 'Dịch vụ thú cưng',
        subtitle:
        'Màn này sẽ có spa, khách sạn thú cưng, bệnh viện thú y và grooming.',
      ),

      PlaceholderFeatureScreen(
        icon: Icons.map_rounded,
        title: 'Bản đồ',
        subtitle:
        'Màn này trước mắt làm UI giả lập bản đồ, sau đó mới gắn Google Maps API.',
      ),

      PlaceholderFeatureScreen(
        icon: Icons.forum_rounded,
        title: 'Cộng đồng',
        subtitle: 'Màn này sẽ có bài viết, hình ảnh thú cưng và bình luận.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _backToRoleSelect,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat_outlined),
            selectedIcon: Icon(
              Icons.event_seat_rounded,
              color: AppColors.primary,
            ),
            label: 'Đặt bàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
            ),
            label: 'Dịch vụ',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(
              Icons.map_rounded,
              color: AppColors.primary,
            ),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(
              Icons.forum_rounded,
              color: AppColors.primary,
            ),
            label: 'Forum',
          ),
        ],
      ),
    );
  }
}