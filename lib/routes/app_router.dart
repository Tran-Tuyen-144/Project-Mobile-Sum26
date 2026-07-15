import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/admin/admin_main_screen.dart';
import '../screens/app_intro_screen.dart';
import '../screens/admin/service_request_admin_screen.dart';
import '../screens/auth/customer_auth_screen.dart';
import '../screens/customer/booking/customer_drink_order_screen.dart';
import '../screens/customer/booking_confirm/booking_confirm_data.dart';
import '../screens/customer/booking_confirm/booking_confirm_screen.dart';
import '../screens/customer/community/community_post.dart';
import '../screens/customer/community/community_post_detail_screen.dart';
import '../screens/customer/community/create_community_post_screen.dart';
import '../screens/customer/customer_shell_screen.dart';
import '../screens/customer/notifications/customer_notification_screen.dart';
import '../screens/customer/petprofile/pet_list_screen.dart';
import '../screens/customer/profile/customer_profile_screen.dart';
import '../screens/customer/profile/profile_menu_screens.dart';
import '../services/customer_auth_service.dart';
import '../screens/role_select_screen.dart';
import '../screens/staff/staff_department.dart';
import '../screens/staff/staff_main_screen.dart';
import '../screens/staff/staff_role_select_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/intro',
  overridePlatformDefaultLocation: true,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) => const AppIntroScreen(),
    ),
    GoRoute(
      path: '/role',
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
          appBar: AppBar(
            title: const Text('Trang cá nhân'),
            actions: const [_CustomerProfileMenu()],
          ),
          body: const CustomerProfileScreen(),
        );
      },
    ),
    GoRoute(
      path: '/profile/account',
      name: 'profile-account',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Tài khoản & bảo mật')),
        body: const AccountCenterScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/saved-posts',
      name: 'profile-saved-posts',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Bài viết đã lưu')),
        body: const SavedPostsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/personal-information',
      name: 'profile-personal-information',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Thông tin cá nhân')),
        body: const PersonalInformationScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/password-security',
      name: 'profile-password-security',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Mật khẩu & bảo mật')),
        body: const PasswordSecurityScreen(),
      ),
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
      path: '/order',
      name: 'order',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Gọi nước trước')),
          body: const CustomerDrinkOrderScreen(),
        );
      },
    ),
    GoRoute(
      path: '/staff-role',
      name: 'staff-role',
      builder: (context, state) {
        return const StaffRoleSelectScreen();
      },
    ),
    GoRoute(
      path: '/staff',
      name: 'staff',
      builder: (context, state) {
        final departmentKey = state.uri.queryParameters['department'];
        final department = staffDepartmentFromKey(departmentKey);

        return StaffMainScreen(department: department);
      },
    ),
    GoRoute(
      path: '/admin-service-requests',
      name: 'admin-service-requests',
      builder: (context, state) {
        return const ServiceRequestAdminScreen();
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

class _CustomerProfileMenu extends StatelessWidget {
  const _CustomerProfileMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_rounded),
      tooltip: 'Tùy chọn tài khoản',
      onSelected: (value) async {
        if (value == 'saved') {
          context.push('/profile/saved-posts');
          return;
        }
        if (value == 'account') {
          context.push('/profile/account');
          return;
        }

        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Đăng xuất tài khoản?'),
            content: const Text('Bạn sẽ cần đăng nhập lại để tiếp tục.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        );
        if (shouldLogout != true || !context.mounted) return;
        try {
          await CustomerAuthService.logout();
        } finally {
          // Always leave the protected profile route, even if a provider
          // (for example Google on web) has already ended its session.
          if (context.mounted) context.go('/customer-auth');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'saved',
          child: ListTile(
            leading: Icon(Icons.bookmark_outline_rounded),
            title: Text('Bài viết đã lưu'),
            subtitle: Text('Xem lại các bài bạn đã đánh dấu'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'account',
          child: ListTile(
            leading: Icon(Icons.manage_accounts_outlined),
            title: Text('Tài khoản & mật khẩu'),
            subtitle: Text('Thông tin cá nhân và bảo mật'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
