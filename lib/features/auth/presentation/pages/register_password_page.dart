import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/core/widgets/custom_text_field.dart';
import 'package:well_paw/core/widgets/step_indicator.dart';
import 'package:well_paw/features/auth/presentation/pages/subscription_plan_page.dart';

class RegisterPasswordPage extends StatefulWidget {
  final String fullName;
  final String email;

  const RegisterPasswordPage({
    super.key,
    required this.fullName,
    required this.email,
  });

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    if (value != _passwordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  void _handleCreateAccount() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SubscriptionPlanPage()));
    }
  }

  void _openTerms() {}

  void _openPrivacy() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('สร้างบัญชีใหม่', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const StepIndicator(totalSteps: 2, currentStep: 1),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text('ตั้งรหัสผ่าน', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        'สร้างรหัสผ่านที่ปลอดภัย',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'รหัสผ่าน',
                  hintText: 'อย่างน้อย 6 ตัวอักษร',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'ยืนยันรหัสผ่าน',
                  hintText: 'กรอกรหัสผ่านอีกครั้ง',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmController,
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.bodySmall,
                      children: [
                        const TextSpan(text: 'การสร้างบัญชีถือว่าคุณยอมรับ '),
                        TextSpan(
                          text: 'ข้อกำหนดการใช้งาน',
                          style: AppTextStyles.linkText,
                          recognizer: TapGestureRecognizer()
                            ..onTap = _openTerms,
                        ),
                        const TextSpan(text: ' และ '),
                        TextSpan(
                          text: 'นโยบายความเป็นส่วนตัว',
                          style: AppTextStyles.linkText,
                          recognizer: TapGestureRecognizer()
                            ..onTap = _openPrivacy,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'ย้อนกลับ',
                        onPressed: () => Navigator.of(context).pop(),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'สร้างบัญชี',
                        onPressed: _handleCreateAccount,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
