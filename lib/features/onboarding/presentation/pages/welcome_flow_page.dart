import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/core/widgets/step_indicator.dart';
import 'package:well_paw/features/auth/data/services/auth_token_service.dart';
import 'package:well_paw/features/auth/presentation/pages/login_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';

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
      description: 'ผู้ช่วยดูแลโภชนาการและสุขภาพสัตว์เลี้ยงในทุกวัน',
      icon: Icons.pets_rounded,
      accentColor: Color(0xFF2E5FAE),
      backgroundColor: Color(0xFFE9F0FF),
      highlight: 'ดูแลครบทั้ง อาหาร น้ำหนัก และสุขภาพผิวหนัง',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6F96D8), Color(0xFF4472C4)],
      ),
    ),
    _WelcomeSlide(
      title: 'สร้างโปรไฟล์สัตว์เลี้ยง',
      description: 'บันทึกข้อมูลพื้นฐาน เพื่อคำนวณโภชนาการที่เหมาะสม',
      icon: Icons.badge_outlined,
      accentColor: Color(0xFF2D5CA7),
      backgroundColor: Color(0xFFEFF4FF),
      highlight: 'ประเภท อายุ น้ำหนัก และกิจกรรมสำคัญต่อการแนะนำอาหาร',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF81A5E0), Color(0xFF4E7BCB)],
      ),
    ),
    _WelcomeSlide(
      title: 'ติดตามโภชนาการรายวัน',
      description: 'จัดแผนอาหารและติดตามพลังงานที่ได้รับในแต่ละวัน',
      icon: Icons.restaurant_menu_rounded,
      accentColor: Color(0xFF2E5FAE),
      backgroundColor: Color(0xFFE8F5EC),
      highlight: 'ช่วยให้ควบคุมน้ำหนักและภาวะโภชนาการได้ง่ายขึ้น',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7BCFA1), Color(0xFF43A66F)],
      ),
    ),
    _WelcomeSlide(
      title: 'วิเคราะห์สุขภาพด้วย AI',
      description: 'ประเมินภาพผิวหนังเบื้องต้นและรับคำแนะนำในการดูแล',
      icon: Icons.analytics_outlined,
      accentColor: Color(0xFF2B5AA0),
      backgroundColor: Color(0xFFFFF2E6),
      highlight: 'ผลลัพธ์ใช้ประกอบการดูแล ไม่ทดแทนการวินิจฉัยของสัตวแพทย์',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFC98B), Color(0xFFF39A3D)],
      ),
    ),
    _WelcomeSlide(
      title: 'พร้อมเริ่มต้นใช้งาน',
      description: 'เริ่มดูแลสัตว์เลี้ยงของคุณด้วย WellPaw ได้เลยตอนนี้',
      icon: Icons.star_rounded,
      accentColor: Color(0xFF2D5DA9),
      backgroundColor: Color(0xFFF3EDFF),
      highlight: 'กดเริ่มต้นใช้งานเพื่อเข้าสู่หน้า Home ทันที',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB6A6F6), Color(0xFF8B78E5)],
      ),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
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
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'ข้ามไปใช้งานเลย',
                      style: AppTextStyles.linkText.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
  final String highlight;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final LinearGradient gradient;

  const _WelcomeSlide({
    required this.title,
    required this.description,
    required this.highlight,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.gradient,
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
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              gradient: slide.gradient,
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2A4472C4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  top: 26,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -28,
                  bottom: -24,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: slide.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(slide.icon, size: 88, color: slide.accentColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD7E3FA)),
            ),
            child: Text(
              slide.highlight,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
