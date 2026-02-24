import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/features/auth/data/models/subscription_models.dart';
import 'package:well_paw/features/auth/data/services/auth_token_service.dart';
import 'package:well_paw/features/auth/data/services/subscription_api_service.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/auth/presentation/widgets/stripe_web_controller.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';

class SubscriptionPlanPage extends StatefulWidget {
  const SubscriptionPlanPage({super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  final _api = SubscriptionApiService();
  final _tokenService = AuthTokenService();
  final _tokenStorage = const TokenStorage();
  final _stripeController = StripeWebController();

  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isValid = await _tokenService.ensureValidAccessToken();
    if (!isValid) {
      setState(() {
        _errorMessage = 'กรุณาเข้าสู่ระบบใหม่';
        _isLoading = false;
      });
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'ไม่พบ access token';
        _isLoading = false;
      });
      return;
    }

    try {
      final plans = await _api.fetchPlans(accessToken: token);
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startPlan(SubscriptionPlan plan) async {
    if (_isProcessing) {
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token == null) {
      _showSnack('ไม่พบ access token');
      return;
    }

    final paymentMethodId = await _collectPaymentMethod();
    if (paymentMethodId == null || paymentMethodId.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await _api.updatePaymentMethod(
        accessToken: token,
        paymentMethodId: paymentMethodId,
      );
      final result = await _api.startSubscription(
        accessToken: token,
        subscriptionPlanId: plan.id,
        paymentMethodId: paymentMethodId,
      );
      if (result.clientSecret.isEmpty) {
        throw Exception('ไม่พบ client_secret สำหรับการชำระเงิน');
      }

      if (!_stripeController.isSupported) {
        _showSnack('ต้องยืนยันการชำระเงินผ่าน Stripe.js บนเว็บ');
        return;
      }

      final confirmed = await _stripeController.confirmCardPayment(
        clientSecret: result.clientSecret,
        paymentMethodId: paymentMethodId,
      );
      if (!confirmed) {
        throw Exception('ยืนยันการชำระเงินไม่สำเร็จ');
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (error) {
      _showSnack('สมัครแพ็กเกจไม่สำเร็จ: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<String?> _collectPaymentMethod() async {
    if (kIsWeb && !AppConfig.hasValidStripePublishableKey) {
      _showSnack('กรุณาตั้งค่า Stripe publishable key');
      return null;
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final manualController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เพิ่มวิธีชำระเงิน', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              if (_stripeController.isSupported) ...[
                const Text('กรอกข้อมูลบัตรด้วย Stripe Elements'),
                const SizedBox(height: 12),
                StripeCardField(controller: _stripeController),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'สร้างวิธีชำระเงิน',
                  onPressed: () async {
                    final id = await _stripeController.createPaymentMethod();
                    if (!mounted) return;
                    if (id == null || id.isEmpty) {
                      _showSnack('สร้าง Payment Method ไม่สำเร็จ');
                      return;
                    }
                    Navigator.of(context).pop(id);
                  },
                ),
              ] else ...[
                const Text('กรอก payment_method_id เพื่อทดสอบบนมือถือ'),
                const SizedBox(height: 12),
                TextField(
                  controller: manualController,
                  decoration: const InputDecoration(
                    hintText: 'pm_123456789',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'ยืนยัน',
                  onPressed: () =>
                      Navigator.of(context).pop(manualController.text.trim()),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
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
        title: Text('เลือกแพ็กเกจ', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(_errorMessage!, style: AppTextStyles.bodyMedium),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เลือกแพ็กเกจที่เหมาะกับคุณ', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    Text(
                      'เริ่มต้นดูแลสัตว์เลี้ยงของคุณวันนี้',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ..._plans.asMap().entries.map((entry) {
                      final plan = entry.value;
                      final color = entry.key == 0
                          ? AppColors.planFree
                          : entry.key == 1
                          ? AppColors.planBlue
                          : AppColors.planPink;
                      final features = plan.features
                          .map((text) => _PlanFeature(text: text))
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PlanCard(
                          title: plan.name,
                          subtitle: plan.intervalLabel,
                          price: plan.priceLabel,
                          priceDetail: plan.priceDetail,
                          color: color,
                          buttonText: plan.amount == 0
                              ? 'เริ่มทดลองใช้ฟรี'
                              : 'เลือกแพ็กเกจนี้',
                          isLoading: _isProcessing,
                          onPressed: () => _startPlan(plan),
                          features: features,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _InfoNote(
                      text:
                          'สามารถยกเลิกหรือเปลี่ยนแพ็กเกจได้ตลอดเวลา\nไม่มีค่าใช้จ่ายเพิ่มเติม',
                    ),
                    const SizedBox(height: 16),
                    Text('คำถามที่พบบ่อย', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    _FaqItem(
                      question: 'ทดลองใช้ฟรีแล้วต้องจ่ายเงินไหม?',
                      answer:
                          'ไม่ต้องจ่าย! ครบ 7 วันจะหยุดใช้งานอัตโนมัติ สามารถยกเลิกได้ตลอดเวลา',
                    ),
                    const SizedBox(height: 12),
                    _FaqItem(
                      question: 'ยกเลิกได้ไหม?',
                      answer:
                          'ยกเลิกได้ทุกเมื่อ ไม่มีค่าปรับ ใช้งานได้ถึงสิ้นสุดรอบบิล',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String priceDetail;
  final String buttonText;
  final VoidCallback onPressed;
  final Color color;
  final bool isLoading;
  final String? badgeText;
  final String? discountText;
  final List<_PlanFeature> features;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceDetail,
    required this.buttonText,
    required this.onPressed,
    required this.color,
    required this.features,
    required this.isLoading,
    this.badgeText,
    this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badgeText!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryBlueDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(priceDetail, style: AppTextStyles.bodySmall),
                    if (discountText != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discountText!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          feature.enabled ? Icons.check_circle : Icons.cancel,
                          color: feature.enabled
                              ? AppColors.success
                              : AppColors.dividerGray,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature.text,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: feature.enabled
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: buttonText,
                  onPressed: onPressed,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanFeature {
  final String text;
  final bool enabled;

  const _PlanFeature({required this.text, this.enabled = true});
}

class _InfoNote extends StatelessWidget {
  final String text;

  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(answer, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
