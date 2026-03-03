import 'dart:io';

import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';

class HealthResultPage extends StatelessWidget {
  const HealthResultPage({
    super.key,
    required this.imageFile,
    required this.petTypeLabel,
    required this.shouldSaveHistory,
  });

  final File imageFile;
  final String petTypeLabel;
  final bool shouldSaveHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      body: SafeArea(
        child: Column(
          children: [
            _FlowTopBar(
              title: 'ผลการวิเคราะห์',
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: Image.file(imageFile, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DiagnosisHeroCard(petTypeLabel: petTypeLabel),
                    const SizedBox(height: 16),
                    const _InfoCard(
                      title: 'อาการที่พบ',
                      items: [
                        'บริเวณที่เป็นมีรูปร่างกลม',
                        'ขนร่วงหรือหักง่าย',
                        'ผิวหนังแห้งลอก',
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InfoCard(
                      title: 'คำแนะนำ',
                      leadingArrow: true,
                      items: [
                        'พาพบสัตวแพทย์เพื่อยืนยันการวินิจฉัย',
                        'ทำความสะอาดพื้นที่ที่สัตว์เลี้ยงสัมผัส',
                        'หลีกเลี่ยงการสัมผัสโดยตรง',
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _WarningCard(),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final message = shouldSaveHistory
                              ? 'บันทึกผลการวิเคราะห์แล้ว'
                              : 'โหมดไม่ระบุตัวตน: ไม่ได้บันทึกผล';
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE59DD6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          shouldSaveHistory
                              ? 'บันทึกผลการวิเคราะห์'
                              : 'เสร็จสิ้น',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisHeroCard extends StatelessWidget {
  const _DiagnosisHeroCard({required this.petTypeLabel});

  final String petTypeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA20A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Ringworm\n(โรคเชื้อราที่ผิวหนัง)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.22,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC86A),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              petTypeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB948),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ระดับความมั่นใจในการวินิจฉัย',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    5,
                    (_) => Expanded(
                      child: Container(
                        height: 34,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'ระดับ 5/5',
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                    Spacer(),
                    Text(
                      'สูงมาก',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.items,
    this.leadingArrow = false,
  });

  final String title;
  final List<String> items;
  final bool leadingArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E6ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 38,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    leadingArrow
                        ? Icons.arrow_right_alt
                        : Icons.check_circle_outline,
                    size: leadingArrow ? 20 : 18,
                    color: const Color(0xFFFFA20A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        height: 1.34,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFA20A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFFFA20A), size: 20),
              SizedBox(width: 8),
              Text(
                'ข้อควรระวัง',
                style: TextStyle(
                  color: Color(0xFFFFA20A),
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'ผลนี้เป็นการวิเคราะห์เบื้องต้นเท่านั้น\nกรุณาปรึกษาสัตวแพทย์เพื่อการวินิจฉัยที่แม่นยำ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTopBar extends StatelessWidget {
  const _FlowTopBar({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(bottom: BorderSide(color: Color(0xFFE1E4EC))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
