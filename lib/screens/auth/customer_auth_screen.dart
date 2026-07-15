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
      _showMessage('Em nháº­p email vĂ  máº­t kháº©u trÆ°á»›c nha.');
      return;
    }

    if (!isLoginMode && name.isEmpty) {
      _showMessage('Em nháº­p há» tĂªn trÆ°á»›c nha.');
      return;
    }

    if (!isLoginMode && password != confirmPassword) {
      _showMessage('Máº­t kháº©u nháº­p láº¡i chÆ°a khá»›p.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Máº­t kháº©u pháº£i tá»« 6 kĂ½ tá»± trá»Ÿ lĂªn.');
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

      if (!mounted) return;

      context.go('/customer');
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

      if (!mounted) return;

      context.go('/customer');
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

      _showMessage(
        'ÄĂ£ gá»­i email Ä‘áº·t láº¡i máº­t kháº©u. Em kiá»ƒm tra há»™p thÆ° nha.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email nĂ y Ä‘Ă£ cĂ³ tĂ i khoáº£n.';
        case 'invalid-email':
          return 'Email khĂ´ng há»£p lá»‡.';
        case 'user-not-found':
          return 'KhĂ´ng tĂ¬m tháº¥y tĂ i khoáº£n.';
        case 'wrong-password':
          return 'Máº­t kháº©u khĂ´ng Ä‘Ăºng.';
        case 'invalid-credential':
          return 'Email hoáº·c máº­t kháº©u khĂ´ng Ä‘Ăºng.';
        case 'weak-password':
          return 'Máº­t kháº©u quĂ¡ yáº¿u.';
        case 'network-request-failed':
          return 'Lá»—i máº¡ng, em kiá»ƒm tra internet nha.';
        case 'account-exists-with-different-credential':
          return 'Email nĂ y Ä‘Ă£ Ä‘Äƒng nháº­p báº±ng phÆ°Æ¡ng thá»©c khĂ¡c.';
        default:
          return error.message ?? 'CĂ³ lá»—i xáº£y ra.';
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
    final title = isLoginMode ? 'ÄÄƒng nháº­p' : 'ÄÄƒng kĂ½';

    final subtitle = isLoginMode
        ? 'ChĂ o má»«ng em quay láº¡i PetHub.'
        : 'Táº¡o tĂ i khoáº£n khĂ¡ch hĂ ng Ä‘á»ƒ lÆ°u há»“ sÆ¡ vĂ  bĂ i viáº¿t.';

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
                          labelText: 'Há» tĂªn',
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
                        labelText: 'Máº­t kháº©u',
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
                          labelText: 'Nháº­p láº¡i máº­t kháº©u',
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
                          child: const Text('QuĂªn máº­t kháº©u?'),
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
                              ? 'Äang xá»­ lĂ½...'
                              : isLoginMode
                              ? 'ÄÄƒng nháº­p'
                              : 'ÄÄƒng kĂ½',
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
                            'hoáº·c',
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
                        label: const Text('Tiáº¿p tá»¥c vá»›i Google'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLoginMode
                              ? 'ChÆ°a cĂ³ tĂ i khoáº£n?'
                              : 'ÄĂ£ cĂ³ tĂ i khoáº£n?',
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _toggleMode,
                          child: Text(
                            isLoginMode ? 'ÄÄƒng kĂ½' : 'ÄÄƒng nháº­p',
                          ),
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
