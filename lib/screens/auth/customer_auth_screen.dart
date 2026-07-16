import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/customer_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_card.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoginMode = true;
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      showPassword = false;
      showConfirmPassword = false;
    });
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Hãy nhập email và mật khẩu trước nha.');
      return;
    }

    if (!isLoginMode && name.isEmpty) {
      _showMessage('Hãy nhập họ tên trước nha.');
      return;
    }

    if (!isLoginMode && password != confirmPassword) {
      _showMessage('Mật khẩu nhập lại chưa khớp.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Mật khẩu phải từ 6 ký tự trở lên.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLoginMode) {
        await CustomerAuthService.loginWithEmail(
          email: email,
          password: password,
        );
      } else {
        await CustomerAuthService.registerWithEmail(
          displayName: name,
          email: email,
          password: password,
        );
      }

      final homeRoute = await CustomerAuthService.getCurrentUserHomeRoute();

      if (!mounted) {
        return;
      }

      context.go(homeRoute);
    } catch (error) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await CustomerAuthService.loginWithGoogle();

      final homeRoute = await CustomerAuthService.getCurrentUserHomeRoute();

      if (!mounted) {
        return;
      }

      context.go(homeRoute);
    } catch (error) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    try {
      await CustomerAuthService.sendForgotPasswordEmail(email);

      if (!mounted) return;

      _showMessage('Đã gửi email đặt lại mật khẩu. Hãy kiểm tra hộp thư nha.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email này đã có tài khoản.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'user-not-found':
          return 'Không tìm thấy tài khoản.';
        case 'wrong-password':
          return 'Mật khẩu không đúng.';
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không đúng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu.';
        case 'network-request-failed':
          return 'Lỗi mạng, em kiểm tra internet nha.';
        case 'account-exists-with-different-credential':
          return 'Email này đã đăng nhập bằng phương thức khác.';
        default:
          return error.message ?? 'Có lỗi xảy ra.';
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = isLoginMode ? 'Đăng nhập' : 'Đăng ký';

    final subtitle = isLoginMode
        ? 'Chào mừng bạn quay lại PetHub.'
        : 'Tạo tài khoản khách hàng để lưu hồ sơ và bài viết.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuthHeader(title: title, subtitle: subtitle),
              const SizedBox(height: 22),
              SoftCard(
                color: Colors.white,
                child: Column(
                  children: [
                    if (!isLoginMode) ...[
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      textInputAction: isLoginMode
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onSubmitted: (_) {
                        if (isLoginMode) {
                          _submit();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    if (!isLoginMode) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (isLoginMode) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : _forgotPassword,
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isLoginMode
                                    ? Icons.login_rounded
                                    : Icons.person_add_rounded,
                              ),
                        label: Text(
                          isLoading
                              ? 'Đang xử lý...'
                              : isLoginMode
                              ? 'Đăng nhập'
                              : 'Đăng ký',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'hoặc',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _loginWithGoogle,
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: const Text('Tiếp tục với Google'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLoginMode
                              ? 'Chưa có tài khoản?'
                              : 'Đã có tài khoản?',
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _toggleMode,
                          child: Text(isLoginMode ? 'Đăng ký' : 'Đăng nhập'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AuthHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.peach, AppColors.cream],
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
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  subtitle,
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
