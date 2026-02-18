import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/core/widgets/step_indicator.dart';
import 'package:well_paw/features/auth/data/services/auth_token_service.dart';
import 'package:well_paw/features/auth/presentation/pages/login_page.dart';

class WelcomeFlowPage extends StatefulWidget {
  const WelcomeFlowPage({super.key, this.onFinish});

  final VoidCallback? onFinish;

  @override
  State<WelcomeFlowPage> createState() => _WelcomeFlowPageState();
}

class _WelcomeFlowPageState extends State<WelcomeFlowPage> {
  late final PageController _controller;
  int _currentIndex = 0;
  bool _isCheckingAuth = true;
  final _tokenService = AuthTokenService();

  final List<_WelcomeSlide> _slides = const [
    _WelcomeSlide(
      title: 'ยินดีต้อนรับสู่ WellPaw',
      description: 'เริ่มต้นดูแลโภชนาการและสุขภาพสัตว์เลี้ยงอย่างเป็นระบบ',
      icon: Icons.pets,
      accentColor: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
    ),
    _WelcomeSlide(
      title: 'สร้างโปรไฟล์สัตว์เลี้ยง',
      description: 'เก็บข้อมูลพื้นฐานเพื่อวางแผนโภชนาการที่เหมาะสม',
      icon: Icons.badge_outlined,
      accentColor: AppColors.primaryBlueDark,
      backgroundColor: AppColors.primaryBlueLight,
    ),
    _WelcomeSlide(
      title: 'ติดตามโภชนาการรายวัน',
      description: 'บันทึกอาหารและพลังงานอย่างง่ายในทุกวัน',
      icon: Icons.restaurant_menu,
      accentColor: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
    ),
    _WelcomeSlide(
      title: 'วิเคราะห์สุขภาพด้วย AI',
      description: 'รับคำแนะนำเชิงลึกเพื่อดูแลสัตว์เลี้ยงให้แข็งแรง',
      icon: Icons.analytics_outlined,
      accentColor: AppColors.primaryBlueDark,
      backgroundColor: AppColors.primaryBlueLight,
    ),
    _WelcomeSlide(
      title: 'พร้อมเริ่มต้นใช้งาน',
      description: 'ไปต่อเพื่อสัมผัสประสบการณ์เต็มรูปแบบของ WellPaw',
      icon: Icons.star_outline,
      accentColor: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _verifyAccessToken();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentIndex < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSkip() {
    _controller.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _verifyAccessToken() async {
    final hasValidToken = await _tokenService.ensureValidAccessToken();
    if (!mounted) {
      return;
    }

    if (!hasValidToken) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLast)
                    TextButton(
                      onPressed: _handleSkip,
                      child: Text('ข้าม', style: AppTextStyles.linkText),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _WelcomeSlideView(slide: _slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  StepIndicator(
                    totalSteps: _slides.length,
                    currentStep: _currentIndex,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        Expanded(
                          child: CustomButton(
                            text: 'ย้อนกลับ',
                            onPressed: _handleBack,
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: CustomButton(
                          text: isLast ? 'เริ่มต้นใช้งาน' : 'ถัดไป',
                          onPressed: _handleNext,
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
    );
  }
}

class _WelcomeSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  const _WelcomeSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });
}

class _WelcomeSlideView extends StatelessWidget {
  const _WelcomeSlideView({required this.slide});

  final _WelcomeSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: slide.backgroundColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Icon(slide.icon, size: 120, color: slide.accentColor),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
