import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'map/customer_map_screen.dart';
import '../../theme/app_colors.dart';
import 'customer_home_screen.dart';
import 'placeholder_feature_screen.dart';

import 'booking/customer_booking_screen.dart';
import 'services/customer_services_screen.dart';
import 'community/customer_community_screen.dart';
class CustomerShellScreen extends StatefulWidget {
  final int initialIndex;

  const CustomerShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  late int _currentIndex;

  final List<String> _titles = const [
    'PetHub',
    'Đặt bàn',
    'Dịch vụ',
    'Bản đồ',
    'Cộng đồng',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleBack() {
    // Nếu đang ở tab khác Home thì quay về Home trước
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    // Nếu đang ở Home thì mới quay về màn chọn chức vụ
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CustomerHomeScreen(
        onOpenBooking: () => _goToTab(1),
        onOpenOrder: () => context.push('/order'),
        onOpenServices: () => _goToTab(2),
        onOpenMap: () => _goToTab(3),
        onOpenCommunity: () => _goToTab(4),

        onOpenPetProfile: () {
          context.push('/pet-profile');
        },
      ),

      const CustomerBookingScreen(),

      const CustomerServicesScreen(),

      const CustomerMapScreen(),

      const CustomerCommunityScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(_titles[_currentIndex]),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/notifications');
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              onPressed: () {
                context.push('/profile');
              },
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
      ),
    );
  }
}