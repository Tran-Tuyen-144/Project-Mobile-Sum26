import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/role_select_screen.dart';
import '../screens/customer/customer_shell_screen.dart';
import '../screens/customer/booking/customer_booking_screen.dart';
import '../screens/customer/placeholder_feature_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  overridePlatformDefaultLocation: true,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'role',
      builder: (context, state) {
        return const RoleSelectScreen();
      },
    ),

    GoRoute(
      path: '/customer',
      name: 'customer',
      builder: (context, state) {
        return const CustomerShellScreen();
      },
    ),

    GoRoute(
      path: '/booking',
      name: 'booking',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Đặt bàn'),
          ),
          body: const CustomerBookingScreen(),
        );
      },
    ),

    GoRoute(
      path: '/order',
      name: 'order',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gọi món'),
          ),
          body: const PlaceholderFeatureScreen(
            icon: Icons.local_cafe_rounded,
            title: 'Gọi món',
            subtitle:
            'Màn này sẽ dùng để chọn nước, bánh ngọt và đặt món trước khi đến quán.',
          ),
        );
      },
    ),

    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dịch vụ thú cưng'),
          ),
          body: const PlaceholderFeatureScreen(
            icon: Icons.spa_rounded,
            title: 'Dịch vụ thú cưng',
            subtitle:
            'Màn này sẽ có spa, khách sạn thú cưng, bệnh viện thú y và grooming.',
          ),
        );
      },
    ),

    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bản đồ'),
          ),
          body: const PlaceholderFeatureScreen(
            icon: Icons.map_rounded,
            title: 'Bản đồ',
            subtitle:
            'Màn này trước mắt làm UI giả lập bản đồ, sau đó mới gắn Google Maps API.',
          ),
        );
      },
    ),

    GoRoute(
      path: '/community',
      name: 'community',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cộng đồng'),
          ),
          body: const PlaceholderFeatureScreen(
            icon: Icons.forum_rounded,
            title: 'Cộng đồng',
            subtitle:
            'Màn này sẽ có bài viết, hình ảnh thú cưng và bình luận.',
          ),
        );
      },
    ),
  ],
);