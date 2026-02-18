import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/logo_header.dart';
import 'package:well_paw/core/widgets/custom_text_field.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/features/auth/presentation/pages/register_basic_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';
import 'package:well_paw/features/auth/data/services/auth_api_service.dart';
import 'package:well_paw/features/auth/data/services/google_sign_in_service.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';

/// Login Page - WellPaw Authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApiService();
  final _googleSignIn = GoogleSignInService();
  final _tokenStorage = const TokenStorage();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!AppConfig.hasValidApiBaseUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า API Base URL ก่อนใช้งานการเข้าสู่ระบบ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deviceToken = await _getDeviceToken();
      final authResponse = await _authApi.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        deviceToken: deviceToken,
      );

      await _tokenStorage.saveTokens(
        accessToken: authResponse.token.accessToken,
        refreshToken: authResponse.token.refreshToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เข้าสู่ระบบสำเร็จ!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบไม่สำเร็จ: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getDeviceToken() async {
    // TODO: Replace with real device token (FCM/APNs).
    return 'unknown';
  }

  Future<void> _handleGoogleLogin() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า API Base URL ก่อนใช้งาน Google Login'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!AppConfig.hasValidGoogleWebClientId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า Google Web Client ID ให้ถูกต้อง'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (Platform.isIOS && !AppConfig.hasValidGoogleIosClientId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า Google iOS Client ID ให้ถูกต้อง'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final authCode = account.serverAuthCode;
      if (authCode == null || authCode.isEmpty) {
        throw Exception('Missing server auth code');
      }

      final deviceToken = await _getDeviceToken();
      final authResponse = await _authApi.loginWithGoogle(
        authCode: authCode,
        deviceToken: deviceToken,
      );

      await _tokenStorage.saveTokens(
        accessToken: authResponse.token.accessToken,
        refreshToken: authResponse.token.refreshToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เข้าสู่ระบบด้วย Google สำเร็จ!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google เข้าสู่ระบบไม่สำเร็จ: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    // TODO: Navigate to forgot password page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ฟีเจอร์นี้กำลังพัฒนา')));
  }

  void _handleRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterBasicPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with logo
              const LogoHeader(
                title: 'เข้าสู่ระบบ',
                subtitle: 'ยินดีต้อนรับกลับมา!',
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Email Field
                      CustomTextField(
                        label: 'อีเมล',
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        label: 'รหัสผ่าน',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'ลืมรหัสผ่าน?',
                            style: AppTextStyles.linkText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      CustomButton(
                        text: 'เข้าสู่ระบบ (Login)',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.dividerGray,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'หรือ',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.dividerGray,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Sign-In Button
                      CustomButton(
                        text: 'เข้าสู่ระบบด้วย Google',
                        onPressed: _handleGoogleLogin,
                        isLoading: _isGoogleLoading,
                        isOutlined: true,
                      ),

                      // Register Section
                      Center(
                        child: Text(
                          'ยังไม่มีบัญชี?',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Register Button
                      CustomButton(
                        text: 'สร้างบัญชีใหม่ (Register)',
                        onPressed: _handleRegister,
                        isOutlined: true,
                      ),

                      const SizedBox(height: 24),

                      // Demo Credentials
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBlueLight.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Demo: user@wellpaw.com / password123',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
