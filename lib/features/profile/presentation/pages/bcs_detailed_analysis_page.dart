import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';

class BcsDetailedAnalysisPage extends StatefulWidget {
  const BcsDetailedAnalysisPage({
    super.key,
    required this.petType,
    this.initial = 2,
  });

  final String petType;
  final int initial;

  @override
  State<BcsDetailedAnalysisPage> createState() =>
      _BcsDetailedAnalysisPageState();
}

class _BcsDetailedAnalysisPageState extends State<BcsDetailedAnalysisPage> {
  static const int _totalSteps = 4;

  int _currentStep = 0;
  bool _showResult = false;

  final Map<int, int> _answers = <int, int>{};

  late final List<_BcsQuestionStep> _steps = [
    const _BcsQuestionStep(
      nodeId: '146-684',
      title: 'ประเมินจากมุมมองด้านข้าง',
      description: 'ดูสัดส่วนหน้าท้องและแนวลำตัวของสัตว์เลี้ยง',
      options: [
        _BcsOption(value: 0, title: 'ผอมมาก', subtitle: 'เห็นกระดูกชัดเจนมาก'),
        _BcsOption(value: 1, title: 'ผอม', subtitle: 'เห็นโครงชัดและไขมันต่ำ'),
        _BcsOption(value: 2, title: 'เหมาะสม', subtitle: 'สัดส่วนลำตัวสมดุลดี'),
        _BcsOption(
          value: 3,
          title: 'เริ่มอ้วน',
          subtitle: 'ท้องหย่อนและลำตัวหนา',
        ),
        _BcsOption(value: 4, title: 'อ้วนมาก', subtitle: 'ไขมันสะสมชัดเจนมาก'),
      ],
    ),
    const _BcsQuestionStep(
      nodeId: '146-921',
      title: 'ประเมินจากมุมมองด้านบน',
      description: 'สังเกตช่วงเอวเมื่อมองจากด้านบน',
      options: [
        _BcsOption(value: 0, title: 'ผอมมาก', subtitle: 'เอวคอดมากผิดปกติ'),
        _BcsOption(value: 1, title: 'ผอม', subtitle: 'เอวคอดชัดเกินไป'),
        _BcsOption(
          value: 2,
          title: 'เหมาะสม',
          subtitle: 'เห็นเอวพอดีและสมส่วน',
        ),
        _BcsOption(value: 3, title: 'เริ่มอ้วน', subtitle: 'เอวเริ่มไม่ชัดเจน'),
        _BcsOption(value: 4, title: 'อ้วนมาก', subtitle: 'ไม่เห็นเอวและตัวกลม'),
      ],
    ),
    const _BcsQuestionStep(
      nodeId: '146-1164',
      title: 'ประเมินการคลำซี่โครง',
      description: 'ลองคลำบริเวณซี่โครงและชั้นไขมัน',
      options: [
        _BcsOption(value: 0, title: 'ผอมมาก', subtitle: 'คลำซี่โครงได้ชัดมาก'),
        _BcsOption(value: 1, title: 'ผอม', subtitle: 'คลำได้ง่ายและไขมันน้อย'),
        _BcsOption(
          value: 2,
          title: 'เหมาะสม',
          subtitle: 'คลำได้พอดีมีไขมันบาง',
        ),
        _BcsOption(
          value: 3,
          title: 'เริ่มอ้วน',
          subtitle: 'คลำได้ยากขึ้นเล็กน้อย',
        ),
        _BcsOption(value: 4, title: 'อ้วนมาก', subtitle: 'คลำยากมากมีไขมันหนา'),
      ],
    ),
    const _BcsQuestionStep(
      nodeId: '146-1407',
      title: 'ประเมินภาพรวมรูปร่าง',
      description: 'สรุปภาพรวมโครงสร้างร่างกายทั้งหมด',
      options: [
        _BcsOption(
          value: 0,
          title: 'ผอมมาก',
          subtitle: 'ต้องเพิ่มโภชนาการเร่งด่วน',
        ),
        _BcsOption(
          value: 1,
          title: 'ผอม',
          subtitle: 'ควรเพิ่มพลังงานและติดตาม',
        ),
        _BcsOption(
          value: 2,
          title: 'เหมาะสม',
          subtitle: 'คงระดับอาหารและกิจกรรม',
        ),
        _BcsOption(
          value: 3,
          title: 'เริ่มอ้วน',
          subtitle: 'ควบคุมพลังงานและเพิ่มกิจกรรม',
        ),
        _BcsOption(
          value: 4,
          title: 'อ้วนมาก',
          subtitle: 'ควรปรึกษาสัตวแพทย์เรื่องน้ำหนัก',
        ),
      ],
    ),
  ];

  bool get _isCat =>
      widget.petType.contains('แมว') ||
      widget.petType.toLowerCase().contains('cat');

  int get _computedResult {
    if (_answers.isEmpty) {
      return widget.initial.clamp(0, 4);
    }
    final sum = _answers.values.fold<int>(0, (prev, value) => prev + value);
    final avg = sum / _answers.length;
    return avg.round().clamp(0, 4);
  }

  String _bcsLabel(int value) {
    const map = ['1/9', '3/9', '5/9', '7/9', '9/9'];
    return map[value.clamp(0, 4)];
  }

  String _bcsStatus(int value) {
    switch (value.clamp(0, 4)) {
      case 0:
      case 1:
        return 'ผอม';
      case 2:
        return 'เหมาะสม';
      case 3:
      case 4:
        return 'อ้วน';
      default:
        return 'ไม่ระบุ';
    }
  }

  String _recommendation(int value) {
    switch (value.clamp(0, 4)) {
      case 0:
      case 1:
        return 'แนะนำเพิ่มพลังงานและตรวจสุขภาพเพิ่มเติมกับสัตวแพทย์';
      case 2:
        return 'อยู่ในเกณฑ์เหมาะสม ควรรักษาอาหารและกิจกรรมเดิมต่อเนื่อง';
      case 3:
      case 4:
        return 'ควรลดพลังงานอาหาร เพิ่มกิจกรรม และติดตามน้ำหนักอย่างใกล้ชิด';
      default:
        return '-';
    }
  }

  void _next() {
    if (_showResult) {
      return;
    }

    if (!_answers.containsKey(_currentStep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกคำตอบก่อนดำเนินการต่อ')),
      );
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    setState(() {
      _showResult = true;
    });
  }

  void _back() {
    if (_showResult) {
      setState(() {
        _showResult = false;
        _currentStep = 0;
      });
      return;
    }

    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _currentStep = 0;
      _answers.clear();
    });
  }

  void _saveResult() {
    Navigator.of(context).pop(_computedResult);
  }

  @override
  Widget build(BuildContext context) {
    final result = _computedResult;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          _showResult ? 'ผลลัพธ์ BCS' : 'วิเคราะห์ BCS แบบละเอียด',
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _showResult
            ? _BcsResultView(
                scoreLabel: _bcsLabel(result),
                statusLabel: _bcsStatus(result),
                recommendation: _recommendation(result),
                onSave: _saveResult,
                onReset: _reset,
              )
            : _BcsQuestionView(
                step: _steps[_currentStep],
                stepIndex: _currentStep,
                totalSteps: _totalSteps,
                selectedValue: _answers[_currentStep],
                isCat: _isCat,
                onSelect: (value) {
                  setState(() {
                    _answers[_currentStep] = value;
                  });
                },
                onNext: _next,
              ),
      ),
    );
  }
}

class _BcsQuestionView extends StatelessWidget {
  const _BcsQuestionView({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.selectedValue,
    required this.isCat,
    required this.onSelect,
    required this.onNext,
  });

  final _BcsQuestionStep step;
  final int stepIndex;
  final int totalSteps;
  final int? selectedValue;
  final bool isCat;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E6EE)),
            ),
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index <= stepIndex;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index == totalSteps - 1 ? 0 : 6,
                    ),
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryBlue
                          : const Color(0xFFD6DBE6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ขั้นตอนที่ ${stepIndex + 1}/$totalSteps • Node ${step.nodeId}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          _BcsPreviewCard(
            stepIndex: stepIndex,
            isCat: isCat,
            selectedValue: selectedValue,
          ),
          const SizedBox(height: 14),
          ...step.options.map((option) {
            final selected = selectedValue == option.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelect(option.value),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFDDE8FA)
                        : const Color(0xFFF7F7F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : const Color(0xFFE2E6EE),
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primaryBlue
                              : Colors.white,
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryBlue
                                : const Color(0xFFCAD1DE),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: selected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                stepIndex == totalSteps - 1 ? 'ดูผลลัพธ์' : 'ถัดไป',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BcsPreviewCard extends StatelessWidget {
  const _BcsPreviewCard({
    required this.stepIndex,
    required this.isCat,
    required this.selectedValue,
  });

  final int stepIndex;
  final bool isCat;
  final int? selectedValue;

  static const _sideAssets = [
    'assets/bcs image/Image (cat BCS very-thin side view).png',
    'assets/bcs image/Image (cat BCS thin side view).png',
    'assets/bcs image/Image (cat BCS ideal side view).png',
    'assets/bcs image/Image (cat BCS overweight side view).png',
    'assets/bcs image/Image (cat BCS obesity side view).png',
  ];

  static const _topAssets = [
    'assets/bcs image/Image (cat BCS very-thin top view).png',
    'assets/bcs image/Image (cat BCS thin top view).png',
    'assets/bcs image/Image (cat BCS ideal top view).png',
    'assets/bcs image/Image (cat BCS overweight top view).png',
    'assets/bcs image/Image (cat BCS obesity top view).png',
  ];

  @override
  Widget build(BuildContext context) {
    final idx = (selectedValue ?? 2).clamp(0, 4);
    final useTop = stepIndex == 1;
    final imagePath = useTop ? _topAssets[idx] : _sideAssets[idx];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E6EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            useTop ? 'ตัวอย่างภาพมุมบน' : 'ตัวอย่างภาพมุมข้าง',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isCat
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFE8ECF6),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ตัวอย่างสำหรับสุนัข\nโปรดประเมินตามรูปร่างจริง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
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

class _BcsResultView extends StatelessWidget {
  const _BcsResultView({
    required this.scoreLabel,
    required this.statusLabel,
    required this.recommendation,
    required this.onSave,
    required this.onReset,
  });

  final String scoreLabel;
  final String statusLabel;
  final String recommendation;
  final VoidCallback onSave;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A7BC8), Color(0xFF2F5FAF)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ผลการวิเคราะห์ BCS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(41),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        scoreLabel,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'สรุปจากแบบประเมิน 4 ขั้นตอน',
                            style: TextStyle(
                              color: Color(0xFFDCE6FA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E6EE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'คำแนะนำ',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ผลประเมินนี้ใช้ประกอบการดูแลเบื้องต้นเท่านั้น',
                  style: TextStyle(
                    color: Color(0xFFF39A00),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE59DD6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'บันทึกผลลัพธ์',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'ทำแบบประเมินใหม่',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BcsQuestionStep {
  const _BcsQuestionStep({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.options,
  });

  final String nodeId;
  final String title;
  final String description;
  final List<_BcsOption> options;
}

class _BcsOption {
  const _BcsOption({
    required this.value,
    required this.title,
    required this.subtitle,
  });

  final int value;
  final String title;
  final String subtitle;
}
