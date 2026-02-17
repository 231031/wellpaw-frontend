import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';

class SubscriptionPlanPage extends StatelessWidget {
  const SubscriptionPlanPage({super.key});

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
        child: SingleChildScrollView(
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
              _PlanCard(
                title: 'Free Trial',
                subtitle: 'ทดลองใช้ฟรี',
                price: 'ฟรี',
                priceDetail: '7 วันแรก',
                color: AppColors.planFree,
                buttonText: 'เริ่มทดลองใช้ฟรี',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                features: const [
                  _PlanFeature(text: 'สร้างโปรไฟล์สัตว์เลี้ยง 1 ตัว'),
                  _PlanFeature(text: 'เพิ่มอาหารได้ 3 รายการ'),
                  _PlanFeature(
                    text:
                        'ใช้ฟีเจอร์หลักได้ 1 อย่าง (คำนวณอาหาร, วินิจฉัย, BCS)',
                  ),
                  _PlanFeature(text: 'ดูประวัติย้อนหลัง 7 วัน'),
                  _PlanFeature(text: 'การสนับสนุนพื้นฐาน'),
                  _PlanFeature(text: 'ไม่มีคำแนะนำโปรไฟล์', enabled: false),
                  _PlanFeature(
                    text: 'ไม่มีคำแนะนำในเชิงสุขภาพ',
                    enabled: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PlanCard(
                title: 'Premium',
                subtitle: 'รายเดือน',
                price: '69',
                priceDetail: 'บาท/เดือน',
                color: AppColors.planBlue,
                buttonText: 'เลือกแพ็กเกจนี้',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                features: const [
                  _PlanFeature(text: 'สร้างโปรไฟล์สัตว์เลี้ยงไม่จำกัด'),
                  _PlanFeature(text: 'เพิ่มอาหารไม่จำกัด'),
                  _PlanFeature(text: 'ใช้ฟีเจอร์หลักไม่จำกัด'),
                  _PlanFeature(text: 'ดูประวัติย้อนหลังไม่จำกัด'),
                  _PlanFeature(text: 'AI วิเคราะห์ขั้นสูง'),
                  _PlanFeature(text: 'คำแนะนำเฉพาะบุคคล'),
                  _PlanFeature(text: 'รายงานสุขภาพรายเดือน'),
                  _PlanFeature(text: 'การสนับสนุนแบบ Priority'),
                  _PlanFeature(text: 'ปรึกษาสัตวแพทย์ออนไลน์'),
                  _PlanFeature(text: 'ส่วนลด 20% สินค้าพาร์ทเนอร์'),
                ],
              ),
              const SizedBox(height: 16),
              _PlanCard(
                title: 'Premium',
                subtitle: 'รายปี',
                price: '690',
                priceDetail: 'บาท/ปี',
                badgeText: 'แนะนำ',
                discountText: 'ประหยัด 17%',
                color: AppColors.planPink,
                buttonText: 'เลือกแพ็กเกจนี้',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                features: const [
                  _PlanFeature(text: 'สร้างโปรไฟล์สัตว์เลี้ยงไม่จำกัด'),
                  _PlanFeature(text: 'เพิ่มอาหารไม่จำกัด'),
                  _PlanFeature(text: 'ใช้ฟีเจอร์หลักไม่จำกัด'),
                  _PlanFeature(text: 'ดูประวัติย้อนหลังไม่จำกัด'),
                  _PlanFeature(text: 'AI วิเคราะห์ขั้นสูง'),
                  _PlanFeature(text: 'คำแนะนำเฉพาะบุคคล'),
                  _PlanFeature(text: 'รายงานสุขภาพรายเดือน'),
                  _PlanFeature(text: 'การสนับสนุนแบบ Priority'),
                  _PlanFeature(text: 'ปรึกษาสัตวแพทย์ออนไลน์'),
                  _PlanFeature(text: 'ส่วนลด 20% สินค้าพาร์ทเนอร์'),
                ],
              ),
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
                CustomButton(text: buttonText, onPressed: onPressed),
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
