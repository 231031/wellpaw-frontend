import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/core/widgets/custom_text_field.dart';
import 'package:well_paw/core/widgets/step_indicator.dart';
import 'package:well_paw/features/auth/presentation/pages/register_password_page.dart';

class RegisterBasicPage extends StatefulWidget {
  const RegisterBasicPage({super.key});

  @override
  State<RegisterBasicPage> createState() => _RegisterBasicPageState();
}

class _RegisterBasicPageState extends State<RegisterBasicPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกชื่อ-นามสกุล';
    }
    return null;
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

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegisterPasswordPage(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

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
                const StepIndicator(totalSteps: 2, currentStep: 0),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text('ข้อมูลพื้นฐาน', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        'กรอกข้อมูลเพื่อเริ่มต้นใช้งาน',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'ชื่อ-นามสกุล',
                  hintText: 'ชื่อของคุณ',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  validator: _validateName,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'อีเมล',
                  hintText: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 28),
                CustomButton(text: 'ถัดไป (Next)', onPressed: _handleNext),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
