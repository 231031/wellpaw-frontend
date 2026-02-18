import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.background)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const _WelcomeSection(),
                  const SizedBox(height: 16),
                  _PetSelector(items: HomeMockData.pets),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HealthSummaryRow(items: HomeMockData.healthSummaries),
                        const SizedBox(height: 16),
                        _QuickActionsRow(items: HomeMockData.quickActions),
                        const SizedBox(height: 24),
                        _NutritionSection(data: HomeMockData.nutrition),
                        const SizedBox(height: 24),
                        _TrendSection(
                          data: HomeMockData.weightTrend,
                          infoCard: HomeMockData.weightInfo,
                          showInfoIcon: true,
                        ),
                        const SizedBox(height: 24),
                        _TrendSection(
                          data: HomeMockData.bcsTrend,
                          infoCard: HomeMockData.bcsInfo,
                          showInfoIcon: false,
                        ),
                        const SizedBox(height: 24),
                        _TrendSection(
                          data: HomeMockData.activityTrend,
                          infoCard: HomeMockData.activityInfo,
                          showInfoIcon: false,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _HomeBottomNav(items: HomeMockData.navItems, currentIndex: 0),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ยินดีต้อนรับ', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('WellPaw', style: AppTextStyles.h2),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetSelector extends StatelessWidget {
  final List<PetProfile> items;

  const _PetSelector({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pet = items[index];
          return Column(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: pet.isSelected
                      ? AppColors.planPink.withValues(alpha: 0.6)
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: pet.isSelected
                          ? AppColors.planPink
                          : AppColors.inputBorder,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      pet.icon,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(pet.name, style: AppTextStyles.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _HealthSummaryRow extends StatelessWidget {
  final List<HealthSummaryItem> items;

  const _HealthSummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.value, style: AppTextStyles.h3),
                      const SizedBox(width: 4),
                      Text(item.unit, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final List<QuickActionItem> items;

  const _QuickActionsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(item.label, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NutritionSection extends StatefulWidget {
  final NutritionData data;

  const _NutritionSection({required this.data});

  @override
  State<_NutritionSection> createState() => _NutritionSectionState();
}

class _NutritionSectionState extends State<_NutritionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: AppTextStyles.bodyLarge),
                    Text(data.rangeLabel, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _NutritionChip(
                label: 'Protein',
                value: data.protein,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 10),
              _NutritionChip(
                label: 'Fat',
                value: data.fat,
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              _NutritionChip(
                label: 'Energy',
                value: data.energy,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: _MealPlanCard(data: data.plan),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.bodyLarge),
            Text('เฉลี่ย/วัน', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  final MealPlanData data;

  const _MealPlanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(data.title, style: AppTextStyles.bodyLarge)),
            ],
          ),
          const SizedBox(height: 4),
          Text(data.rangeLabel, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(data.note, style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          ),
          if (data.footerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              data.footerNote,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  final TrendSectionData data;
  final InfoCardData infoCard;
  final bool showInfoIcon;

  const _TrendSection({
    required this.data,
    required this.infoCard,
    required this.showInfoIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(data.title, style: AppTextStyles.bodyLarge),
                  ),
                  Text(data.rangeLabel, style: AppTextStyles.bodySmall),
                  if (showInfoIcon) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.info_outline, size: 16),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: _TrendPainter(
                    points: data.points,
                    min: data.minValue,
                    max: data.maxValue,
                    lineColor: AppColors.primaryBlue,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.labels
                          .map(
                            (label) =>
                                Text(label, style: AppTextStyles.bodySmall),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(data.deltaLabel, style: AppTextStyles.bodySmall),
                  const Spacer(),
                  Text(data.latestValue, style: AppTextStyles.bodyLarge),
                ],
              ),
              if (data.analysisText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(data.analysisText, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        if (infoCard.title.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(data: infoCard),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final InfoCardData data;

  const _InfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlueLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 6),
          ...data.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: AppTextStyles.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> points;
  final double min;
  final double max;
  final Color lineColor;

  _TrendPainter({
    required this.points,
    required this.min,
    required this.max,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final double chartHeight = size.height - 24;
    final double dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final normalized = (points[i] - min) / (max - min);
      final x = dx * i;
      final y = chartHeight - (chartHeight * normalized);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeBottomNav extends StatelessWidget {
  final List<HomeNavItem> items;
  final int currentIndex;

  const _HomeBottomNav({required this.items, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: _NavIcon(item: item, isSelected: false),
              activeIcon: _NavIcon(item: item, isSelected: true),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final HomeNavItem item;
  final bool isSelected;

  const _NavIcon({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(item.assetPath),
      size: 24,
      color: isSelected ? AppColors.primaryBlue : AppColors.textHint,
    );
  }
}

class HomeMockData {
  static const pets = <PetProfile>[
    PetProfile(name: 'Milo', icon: Icons.pets, isSelected: true),
    PetProfile(name: 'Nina', icon: Icons.pets, isSelected: false),
    PetProfile(name: 'Coco', icon: Icons.pets, isSelected: false),
  ];

  static const healthSummaries = <HealthSummaryItem>[
    HealthSummaryItem(label: 'น้ำหนัก', value: '7.2', unit: 'kg'),
    HealthSummaryItem(label: 'BCS', value: '5', unit: '/9'),
    HealthSummaryItem(label: 'พลังงาน/วัน', value: '360', unit: 'kcal'),
  ];

  static const quickActions = <QuickActionItem>[
    QuickActionItem(
      label: 'อัพเดตน้ำหนัก',
      icon: Icons.monitor_weight_outlined,
      color: AppColors.primaryBlue,
    ),
    QuickActionItem(
      label: 'อัพเดตคะแนนร่างกาย',
      icon: Icons.favorite_border,
      color: AppColors.warning,
    ),
    QuickActionItem(
      label: 'สร้างมื้ออาหาร',
      icon: Icons.restaurant_menu,
      color: AppColors.success,
    ),
  ];

  static const nutrition = NutritionData(
    title: 'ข้อมูลโภชนาการ (12 เดือนล่าสุด)',
    rangeLabel: 'ก.พ. → มิ.ย.',
    protein: '30.0 g',
    fat: '14.0 g',
    energy: '360 kcal',
    plan: MealPlanData(
      title: 'Active Cat High Protein',
      rangeLabel: 'ก.พ. → มิ.ย.',
      note: 'ข้อมูลนี้เป็นบันทึกโภชนาการตามแผนมื้ออาหารในช่วง ก.พ. ถึง มิ.ย.',
      footerNote: '* ค่าเฉลี่ยคำนวณจาก 5 จุดข้อมูล',
    ),
  );

  static const weightTrend = TrendSectionData(
    title: 'ข้อมูลน้ำหนัก (12 เดือนล่าสุด)',
    rangeLabel: '12 เดือนล่าสุด',
    points: [7.8, 7.7, 7.6, 7.45, 7.35, 7.3, 7.25, 7.2, 7.18, 7.15, 7.1, 7.2],
    labels: ['ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.'],
    minValue: 6.8,
    maxValue: 8.0,
    deltaLabel: 'อัตราการเปลี่ยนแปลงน้ำหนักต่อเดือน',
    latestValue: '+0.03 kg',
    analysisText:
        'น้ำหนักคงที่และเหมาะสม การเปลี่ยนแปลงอยู่ในเกณฑ์ปกติ (+2% ต่อเดือน) เหมาะสำหรับแมวโตเต็มวัยสุขภาพดี',
  );

  static const weightInfo = InfoCardData(
    title: 'เกณฑ์มาตรฐานแมวโต:',
    items: [
      'คงที่: ±2% (คงที่ หรือ 2-4% ต่อเดือน)',
      'การลดน้ำหนักที่เหมาะสม: 3-5% ต่อเดือน',
    ],
  );

  static const bcsTrend = TrendSectionData(
    title: 'ข้อมูลคะแนนร่างกาย (12 เดือนล่าสุด)',
    rangeLabel: '12 เดือนล่าสุด',
    points: [5, 5, 5, 5, 5, 5, 4.5, 4.5, 4.5, 5, 5, 5],
    labels: ['ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.'],
    minValue: 3,
    maxValue: 7,
    deltaLabel: 'แนวโน้มคะแนนร่างกาย',
    latestValue: '5/9',
    analysisText: 'คะแนนร่างกายอยู่ในระดับเหมาะสม มีแนวโน้มคงที่',
  );

  static const bcsInfo = InfoCardData(
    title: 'เกณฑ์คะแนนร่างกาย:',
    items: ['เหมาะสม: 4-5/9', 'ผอม: 1-3/9', 'อ้วน: 6-9/9'],
  );

  static const activityTrend = TrendSectionData(
    title: 'ระดับกิจกรรม (12 เดือนล่าสุด)',
    rangeLabel: '12 เดือนล่าสุด',
    points: [3.1, 3.0, 2.9, 3.2, 3.0, 3.1, 3.2, 3.1, 3.0, 3.0, 3.1, 3.2],
    labels: ['ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.'],
    minValue: 2.5,
    maxValue: 3.6,
    deltaLabel: 'ระดับกิจกรรมเฉลี่ย',
    latestValue: '3.2',
    analysisText: 'ระดับกิจกรรมอยู่ในช่วงเหมาะสม',
  );

  static const activityInfo = InfoCardData(
    title: 'ระดับกิจกรรม:',
    items: ['ต่ำ: < 2.5', 'ปกติ: 2.5 - 3.5', 'สูง: > 3.5'],
  );
  static const header = HomeHeaderData(
    greeting: 'สวัสดี, June',
    subtitle: 'วันนี้น้องหมากินน้ำครบหรือยัง?',
    leadingIcon: Icons.pets,
    trailingIcon: Icons.notifications_none,
    statusTitle: 'สุขภาพวันนี้',
    statusSubtitle: 'อัปเดตครั้งล่าสุด 08:30 น.',
    statusLabel: 'ดีมาก',
    statusColor: AppColors.success,
    statusIcon: Icons.health_and_safety_outlined,
  );

  static const summaries = <SummaryItem>[
    SummaryItem(
      title: 'น้ำหนัก',
      value: '7.2 kg',
      icon: Icons.monitor_weight_outlined,
      color: AppColors.primaryBlue,
    ),
    SummaryItem(
      title: 'น้ำดื่ม',
      value: '450 ml',
      icon: Icons.water_drop_outlined,
      color: AppColors.primaryBlueDark,
    ),
    SummaryItem(
      title: 'แคลอรี่',
      value: '320 kcal',
      icon: Icons.local_fire_department_outlined,
      color: AppColors.warning,
    ),
  ];

  static const goals = <GoalItem>[
    GoalItem(
      title: 'น้ำดื่มวันนี้',
      valueText: '450 ml',
      subtitle: 'เป้าหมาย 800 ml',
      progress: 0.56,
      icon: Icons.water_drop_outlined,
      color: AppColors.primaryBlue,
    ),
    GoalItem(
      title: 'พลังงานวันนี้',
      valueText: '320 kcal',
      subtitle: 'เป้าหมาย 600 kcal',
      progress: 0.53,
      icon: Icons.local_fire_department_outlined,
      color: AppColors.warning,
    ),
  ];

  static const trend = TrendData(
    title: 'น้ำหนักเฉลี่ย',
    rangeLabel: '7 วันล่าสุด',
    points: [7.4, 7.35, 7.3, 7.28, 7.25, 7.2, 7.22],
    labels: ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'],
    minValue: 7.1,
    maxValue: 7.5,
    deltaLabel: 'ลดลง 0.2 kg จากสัปดาห์ก่อน',
    latestValue: '7.22 kg',
  );

  static const plan = DailyPlanData(
    title: 'แผนการดูแลรายวัน',
    subtitle: 'ครบแล้ว 3 จาก 5 รายการ',
    progress: 0.6,
    tasks: [
      PlanTask(label: 'อาหารเช้า', isDone: true),
      PlanTask(label: 'เดินเล่น', isDone: true),
      PlanTask(label: 'น้ำดื่ม', isDone: false),
    ],
  );

  static const activities = <ActivityItem>[
    ActivityItem(
      title: 'ให้อาหารเม็ด 1 ถ้วย',
      time: '08:20 น.',
      icon: Icons.rice_bowl_outlined,
    ),
    ActivityItem(
      title: 'พาเดินเล่น 20 นาที',
      time: '07:00 น.',
      icon: Icons.directions_walk,
    ),
    ActivityItem(
      title: 'ดื่มน้ำ 150 ml',
      time: '06:30 น.',
      icon: Icons.water_drop_outlined,
    ),
  ];

  static const tip = TipData(
    title: 'เพิ่มน้ำดื่มระหว่างวัน',
    description: 'ถ้าน้องหมาออกกำลังกายมาก ควรเพิ่มน้ำอีก 100-150 ml',
  );

  static const navItems = <HomeNavItem>[
    HomeNavItem(label: 'Home', assetPath: 'assets/icons/home.png'),
    HomeNavItem(label: 'Food', assetPath: 'assets/icons/food.png'),
    HomeNavItem(label: 'Health', assetPath: 'assets/icons/health.png'),
    HomeNavItem(label: 'Calendar', assetPath: 'assets/icons/calendar.png'),
    HomeNavItem(label: 'Profile', assetPath: 'assets/icons/profile.png'),
  ];
}

class HomeHeaderData {
  final String greeting;
  final String subtitle;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String statusTitle;
  final String statusSubtitle;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;

  const HomeHeaderData({
    required this.greeting,
    required this.subtitle,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
  });
}

class SummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class PetProfile {
  final String name;
  final IconData icon;
  final bool isSelected;

  const PetProfile({
    required this.name,
    required this.icon,
    required this.isSelected,
  });
}

class HealthSummaryItem {
  final String label;
  final String value;
  final String unit;

  const HealthSummaryItem({
    required this.label,
    required this.value,
    required this.unit,
  });
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class NutritionData {
  final String title;
  final String rangeLabel;
  final String protein;
  final String fat;
  final String energy;
  final MealPlanData plan;

  const NutritionData({
    required this.title,
    required this.rangeLabel,
    required this.protein,
    required this.fat,
    required this.energy,
    required this.plan,
  });
}

class MealPlanData {
  final String title;
  final String rangeLabel;
  final String note;
  final String footerNote;

  const MealPlanData({
    required this.title,
    required this.rangeLabel,
    required this.note,
    required this.footerNote,
  });
}

class TrendSectionData {
  final String title;
  final String rangeLabel;
  final List<double> points;
  final List<String> labels;
  final double minValue;
  final double maxValue;
  final String deltaLabel;
  final String latestValue;
  final String analysisText;

  const TrendSectionData({
    required this.title,
    required this.rangeLabel,
    required this.points,
    required this.labels,
    required this.minValue,
    required this.maxValue,
    required this.deltaLabel,
    required this.latestValue,
    required this.analysisText,
  });
}

class InfoCardData {
  final String title;
  final List<String> items;

  const InfoCardData({required this.title, required this.items});
}

class GoalItem {
  final String title;
  final String valueText;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color color;

  const GoalItem({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.color,
  });
}

class TrendData {
  final String title;
  final String rangeLabel;
  final List<double> points;
  final List<String> labels;
  final double minValue;
  final double maxValue;
  final String deltaLabel;
  final String latestValue;

  const TrendData({
    required this.title,
    required this.rangeLabel,
    required this.points,
    required this.labels,
    required this.minValue,
    required this.maxValue,
    required this.deltaLabel,
    required this.latestValue,
  });
}

class DailyPlanData {
  final String title;
  final String subtitle;
  final double progress;
  final List<PlanTask> tasks;

  const DailyPlanData({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.tasks,
  });
}

class PlanTask {
  final String label;
  final bool isDone;

  const PlanTask({required this.label, required this.isDone});
}

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;

  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
  });
}

class TipData {
  final String title;
  final String description;

  const TipData({required this.title, required this.description});
}

class HomeNavItem {
  final String label;
  final String assetPath;

  const HomeNavItem({required this.label, required this.assetPath});
}
