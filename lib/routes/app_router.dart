import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/customer/profile/customer_profile_screen.dart';
import '../screens/customer/profile/profile_menu_screens.dart';
import '../screens/role_select_screen.dart';
import '../screens/customer/customer_shell_screen.dart';
import '../screens/customer/booking/customer_drink_order_screen.dart';
import '../screens/customer/notifications/customer_notification_screen.dart';
import '../screens/customer/booking_confirm/booking_confirm_data.dart';
import '../screens/customer/booking_confirm/booking_confirm_screen.dart';
import '../screens/customer/community/community_post_detail_screen.dart';
import '../screens/customer/community/create_community_post_screen.dart';
import '../screens/customer/petprofile/pet_list_screen.dart';
import '../screens/customer/community/community_post.dart';
import '../screens/auth/customer_auth_screen.dart';

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
      path: '/customer-auth',
      name: 'customer-auth',
      builder: (context, state) {
        return const CustomerAuthScreen();
      },
    ),

    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Thông báo')),
          body: const CustomerNotificationScreen(),
        );
      },
    ),

    GoRoute(
      path: '/customer',
      name: 'customer',
      builder: (context, state) {
        return const CustomerShellScreen(initialIndex: 0);
      },
    ),

    GoRoute(
      path: '/community/create-post',
      name: 'community-create-post',
      builder: (context, state) {
        final initialPost = state.extra is CommunityPost
            ? state.extra as CommunityPost
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              initialPost == null ? 'Tạo bài viết' : 'Chỉnh sửa bài viết',
            ),
          ),
          body: CreateCommunityPostScreen(initialPost: initialPost),
        );
      },
    ),

    GoRoute(
      path: '/booking',
      name: 'booking',
      builder: (context, state) {
        return const CustomerShellScreen(initialIndex: 1);
      },
    ),

    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) {
        return const CustomerShellScreen(initialIndex: 2);
      },
    ),

    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) {
        return const CustomerShellScreen(initialIndex: 3);
      },
    ),

    GoRoute(
      path: '/community',
      name: 'community',
      builder: (context, state) {
        return const CustomerShellScreen(initialIndex: 4);
      },
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
          body: const CustomerProfileScreen(),
        );
      },
    ),
    GoRoute(
      path: '/profile/account',
      name: 'profile-account',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tài khoản & bảo mật')),
          body: const AccountCenterScreen(),
        );
      },
    ),

    GoRoute(
      path: '/profile/saved-posts',
      name: 'profile-saved-posts',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Bài viết đã lưu')),
          body: const SavedPostsScreen(),
        );
      },
    ),

    GoRoute(
      path: '/profile/personal-information',
      name: 'profile-personal-information',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Thông tin cá nhân')),
          body: const PersonalInformationScreen(),
        );
      },
    ),

    GoRoute(
      path: '/profile/password-security',
      name: 'profile-password-security',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mật khẩu & bảo mật')),
          body: const PasswordSecurityScreen(),
        );
      },
    ),

    GoRoute(
      path: '/pet-profile',
      name: 'pet-profile',
      builder: (context, state) {
        return PetListScreen();
      },
    ),

    GoRoute(
      path: '/community/post-detail',
      name: 'community-post-detail',
      builder: (context, state) {
        final args = state.extra is PostDetailArgs
            ? state.extra as PostDetailArgs
            : PostDetailArgs.fallback();

        return CommunityPostDetailScreen(args: args);
      },
    ),

    GoRoute(
      path: '/booking-confirm',
      name: 'booking-confirm',
      builder: (context, state) {
        final data = state.extra as BookingConfirmData?;

        return Scaffold(
          appBar: AppBar(title: const Text('Xác nhận đặt bàn')),
          body: BookingConfirmScreen(
            data:
                data ??
                const BookingConfirmData(
                  branch: 'PetHub Quận 1',
                  day: 'Hôm nay',
                  time: '18:00',
                  guests: 2,
                  tableName: 'Bàn A1',
                ),
          ),
        );
      },
    ),

    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Gọi nước trước')),
          body: const CustomerDrinkOrderScreen(),
        );
      },
    ),

    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) {
        return const AdminMainScreen();
      },
    ),
  ],
);
