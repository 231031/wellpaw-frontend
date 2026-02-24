import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/features/profile/presentation/pages/profile_page.dart';

class _HomeColors {
  static const background = Color(0xFFF8F9FD);
  static const primaryBlue = Color(0xFF3662AA);
  static const primaryBlueLight = Color(0xFF4A7BC8);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const bcsGreen = Color(0xFF66BB6A);
  static const energyGreen = Color(0xFF4CAF50);
  static const fatOrange = Color(0xFFFB8C00);
  static const petPink = Color(0xFFF5A9E1);
  static const currentGreen = Color(0xFF008235);
  static const badgeOrange = Color(0xFFF97316);
  static const cardBorder = Color(0xFFF3F4F6);
  static const weightCardBorder = Color(0xFFDBEAFE);
  static const bcsCardBorder = Color(0xFFD1FAE5);
  static const energyCardBorder = Color(0xFFDCFCE7);

  static const LinearGradient weightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
  );
  static const LinearGradient bcsCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD1FAE5), Color(0xFFFFFFFF)],
  );
  static const LinearGradient energyCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
  );

  static const LinearGradient actionAddMealGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );
  static const LinearGradient actionWeightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3662AA), Color(0xFF4A7BC8)],
  );
  static const LinearGradient actionBcsGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5A9E1), Color(0xFFF8C1ED)],
  );
}

class _HomeTextStyles {
  static TextStyle welcomeTitle = GoogleFonts.sarabun(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.33,
  );
  static TextStyle welcomeSubtitle = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.4,
  );
  static TextStyle petNameSelected = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _HomeColors.petPink,
  );
  static TextStyle petName = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textSecondary,
  );
  static TextStyle summaryValue(Color color) => GoogleFonts.sarabun(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.33,
  );
  static TextStyle summaryUnit = GoogleFonts.sarabun(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textSecondary,
  );
  static TextStyle summaryCaption = GoogleFonts.sarabun(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textHint,
  );
  static TextStyle buttonLabel = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle sectionTitle = GoogleFonts.sarabun(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _HomeColors.primaryBlue,
  );
  static TextStyle sectionSubtitle = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textSecondary,
  );
  static TextStyle cardTitle = GoogleFonts.sarabun(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: _HomeColors.primaryBlue,
  );
  static TextStyle body = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textSecondary,
  );
  static TextStyle bodyStrong(Color color) => GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
  );
  static TextStyle valueMedium = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _HomeColors.primaryBlue,
  );
  static TextStyle chartLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _HomeColors.textHint,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 273,
              decoration: BoxDecoration(
                color: _HomeColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const _WelcomeSection(),
                    const SizedBox(height: 16),
                    _PetSelector(items: HomeMockData.pets),
                  ],
                ),
              ),
            ),
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
                  _WeightTrackingSection(data: HomeMockData.weightTracking),
                  const SizedBox(height: 24),
                  _BcsSection(data: HomeMockData.bcsSection),
                  const SizedBox(height: 24),
                  _ActivitySection(data: HomeMockData.activitySection),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
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
        child: _HomeBottomNav(
          items: HomeMockData.navItems,
          currentIndex: 0,
          onTap: (index) {
            if (index == 4) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ยินดีต้อนรับ!', style: _HomeTextStyles.welcomeTitle),
                const SizedBox(height: 4),
                Text(
                  'WellPaw Dashboard',
                  style: _HomeTextStyles.welcomeSubtitle,
                ),
              ],
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
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pet = items[index];
          return Container(
            width: 76,
            height: 105,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: pet.isSelected
                          ? _HomeColors.petPink
                          : _HomeColors.cardBorder,
                    ),
                  ),
                  child: Icon(
                    pet.icon,
                    color: _HomeColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet.name,
                  style: pet.isSelected
                      ? _HomeTextStyles.petNameSelected
                      : _HomeTextStyles.petName,
                ),
              ],
            ),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == items.length - 1 ? 0 : 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: item.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: item.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.borderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.value,
                          style: _HomeTextStyles.summaryValue(item.valueColor),
                        ),
                        if (item.unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(item.unit, style: _HomeTextStyles.summaryUnit),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.status, style: _HomeTextStyles.summaryCaption),
                    if (item.caption.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.caption, style: _HomeTextStyles.summaryCaption),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
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
                gradient: item.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 6),
                      Icon(item.icon, color: Colors.white, size: 22),
                      const SizedBox(height: 8),
                      Text(item.label, style: _HomeTextStyles.buttonLabel),
                    ],
                  ),
                  if (item.showBadge)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _HomeColors.badgeOrange,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text(
                            '!',
                            style: _HomeTextStyles.summaryValue(
                              Colors.white,
                            ).copyWith(fontSize: 12),
                          ),
                        ),
                      ),
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

class _NutritionSection extends StatelessWidget {
  final NutritionData data;

  const _NutritionSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HomeColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _HomeColors.weightCardBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: _HomeColors.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: _HomeTextStyles.cardTitle),
                    Text(data.subtitle, style: _HomeTextStyles.sectionSubtitle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _TrendPainter(
                points: data.chart.points,
                min: data.chart.minValue,
                max: data.chart.maxValue,
                lineColor: _HomeColors.primaryBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.chart.labels
                      .map(
                        (label) =>
                            Text(label, style: _HomeTextStyles.chartLabel),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: data.legends
                .map(
                  (legend) => Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: legend.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            legend.label,
                            style: _HomeTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Column(
            children: data.plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MealPlanCard(data: plan),
                  ),
                )
                .toList(),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HomeColors.cardBorder),
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
                  color: _HomeColors.weightCardBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: _HomeTextStyles.bodyStrong(
                        _HomeColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(data.startLabel, style: _HomeTextStyles.body),
                        const SizedBox(width: 6),
                        Text('→', style: _HomeTextStyles.body),
                        const SizedBox(width: 6),
                        Text(data.endLabel, style: _HomeTextStyles.body),
                        if (data.statusLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            data.statusLabel,
                            style: GoogleFonts.sarabun(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _HomeColors.currentGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _HomeColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightTrackingSection extends StatelessWidget {
  final WeightTrackingData data;

  const _WeightTrackingSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _HomeColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: _HomeTextStyles.cardTitle),
                        Text(
                          data.subtitle,
                          style: _HomeTextStyles.sectionSubtitle,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.currentValue,
                        style: _HomeTextStyles.valueMedium,
                      ),
                      Text(
                        data.currentLabel,
                        style: _HomeTextStyles.sectionSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: CustomPaint(
                  painter: _TrendPainter(
                    points: data.chart.points,
                    min: data.chart.minValue,
                    max: data.chart.maxValue,
                    lineColor: _HomeColors.primaryBlue,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.chart.labels
                          .map(
                            (label) => Text(
                              label,
                              style: _HomeTextStyles.chartLabel.copyWith(
                                color: _HomeColors.textSecondary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _WeightChangeCard(data: data.change),
      ],
    );
  }
}

class _WeightChangeCard extends StatelessWidget {
  final WeightChangeData data;

  const _WeightChangeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HomeColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _HomeColors.weightCardBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: _HomeColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  style: _HomeTextStyles.bodyStrong(_HomeColors.primaryBlue),
                ),
              ),
              const Icon(Icons.more_horiz, color: _HomeColors.textHint),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(data.changeValue, style: _HomeTextStyles.valueMedium),
              const SizedBox(width: 8),
              Text(data.changePercent, style: _HomeTextStyles.sectionSubtitle),
            ],
          ),
          const SizedBox(height: 6),
          Text(data.note, style: _HomeTextStyles.body),
        ],
      ),
    );
  }
}

class _BcsSection extends StatelessWidget {
  final BcsSectionData data;

  const _BcsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: _HomeTextStyles.cardTitle),
                  Text(data.subtitle, style: _HomeTextStyles.sectionSubtitle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _HomeColors.bcsCardBorder,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    data.summary.emoji,
                    style: _HomeTextStyles.bodyStrong(_HomeColors.primaryBlue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.summary.score,
                    style: _HomeTextStyles.summaryValue(
                      _HomeColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.summary.status,
                    style: _HomeTextStyles.summaryCaption,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data.summary.title,
                style: _HomeTextStyles.bodyStrong(_HomeColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(data.summary.description, style: _HomeTextStyles.body),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(data.scale.length, (index) {
            final item = data.scale[index];
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index == data.scale.length - 1 ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: item.isActive
                      ? _HomeColors.bcsCardBorder
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _HomeColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Text(item.emoji),
                    const SizedBox(height: 4),
                    Text(item.value, style: _HomeTextStyles.summaryCaption),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          data.historyTitle,
          style: _HomeTextStyles.bodyStrong(_HomeColors.primaryBlue),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _TrendPainter(
              points: data.history.points,
              min: data.history.minValue,
              max: data.history.maxValue,
              lineColor: _HomeColors.bcsGreen,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.history.labels
                    .map(
                      (label) => Text(label, style: _HomeTextStyles.chartLabel),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _HomeColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: _HomeColors.energyGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(data.note, style: _HomeTextStyles.body)),
                ],
              ),
              const SizedBox(height: 6),
              Text(data.footnote, style: _HomeTextStyles.summaryCaption),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final ActivitySectionData data;

  const _ActivitySection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: _HomeTextStyles.cardTitle),
                  Text(data.subtitle, style: _HomeTextStyles.sectionSubtitle),
                ],
              ),
            ),
            const Icon(Icons.directions_run, color: _HomeColors.primaryBlue),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _HomeColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.currentLabel,
                      style: _HomeTextStyles.summaryCaption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.currentValue,
                      style: _HomeTextStyles.bodyStrong(
                        _HomeColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _HomeColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.trendLabel,
                      style: _HomeTextStyles.summaryCaption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.trendValue,
                      style: _HomeTextStyles.bodyStrong(
                        _HomeColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _TrendPainter(
              points: data.chart.points,
              min: data.chart.minValue,
              max: data.chart.maxValue,
              lineColor: _HomeColors.primaryBlue,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.chart.labels
                    .map(
                      (label) => Text(label, style: _HomeTextStyles.chartLabel),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
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

    final dotFill = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < points.length; i++) {
      final normalized = (points[i] - min) / (max - min);
      final x = dx * i;
      final y = chartHeight - (chartHeight * normalized);
      canvas.drawCircle(Offset(x, y), 3, dotFill);
      canvas.drawCircle(Offset(x, y), 3, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeBottomNav extends StatelessWidget {
  final List<HomeNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _HomeBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
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
    PetProfile(name: 'มิโกะ', icon: Icons.pets, isSelected: true),
    PetProfile(name: 'โมโม่', icon: Icons.pets, isSelected: false),
    PetProfile(name: 'โคโค่', icon: Icons.pets, isSelected: false),
  ];

  static const healthSummaries = <HealthSummaryItem>[
    HealthSummaryItem(
      value: '4.2',
      unit: 'kg',
      status: 'คงที่',
      caption: '',
      icon: Icons.monitor_weight_outlined,
      iconColor: _HomeColors.primaryBlue,
      valueColor: _HomeColors.primaryBlue,
      background: _HomeColors.weightCardGradient,
      borderColor: _HomeColors.weightCardBorder,
    ),
    HealthSummaryItem(
      value: '5/9',
      unit: '',
      status: 'สมส่วนดี',
      caption: 'Body Condition Score',
      icon: Icons.favorite_border,
      iconColor: _HomeColors.bcsGreen,
      valueColor: _HomeColors.bcsGreen,
      background: _HomeColors.bcsCardGradient,
      borderColor: _HomeColors.bcsCardBorder,
    ),
    HealthSummaryItem(
      value: '340',
      unit: 'kcal',
      status: '28g โปรตีน',
      caption: '',
      icon: Icons.local_fire_department_outlined,
      iconColor: _HomeColors.energyGreen,
      valueColor: _HomeColors.energyGreen,
      background: _HomeColors.energyCardGradient,
      borderColor: _HomeColors.energyCardBorder,
    ),
  ];

  static const quickActions = <QuickActionItem>[
    QuickActionItem(
      label: 'เพิ่มมื้ออาหาร',
      icon: Icons.restaurant_menu,
      background: _HomeColors.actionAddMealGradient,
      showBadge: false,
    ),
    QuickActionItem(
      label: 'อัพเดตน้ำหนัก',
      icon: Icons.monitor_weight_outlined,
      background: _HomeColors.actionWeightGradient,
      showBadge: true,
    ),
    QuickActionItem(
      label: 'ประเมิน BCS',
      icon: Icons.favorite_border,
      background: _HomeColors.actionBcsGradient,
      showBadge: true,
    ),
  ];

  static const nutrition = NutritionData(
    title: 'Nutrient Intake Analytics',
    subtitle: 'ติดตามโภชนาการของ มิโกะ',
    chart: TrendSectionData(
      title: 'Nutrient Chart',
      rangeLabel: '',
      points: [120, 160, 210, 240, 310, 360],
      labels: ['มี.ค.', 'พ.ค.', 'ก.ค.', 'ก.ย.', 'พ.ย.', 'ม.ค.'],
      minValue: 0,
      maxValue: 360,
      deltaLabel: '',
      latestValue: '',
      analysisText: '',
    ),
    legends: [
      NutritionLegendItem(label: 'Protein (g)', color: _HomeColors.primaryBlue),
      NutritionLegendItem(label: 'Fat (g)', color: _HomeColors.fatOrange),
      NutritionLegendItem(
        label: 'Energy (kcal)',
        color: _HomeColors.energyGreen,
      ),
    ],
    plans: [
      MealPlanData(
        title: 'Active Cat High Protein',
        startLabel: 'ก.พ.',
        endLabel: 'มิ.ย.',
        statusLabel: '',
      ),
      MealPlanData(
        title: 'Adult Cat Weight Control',
        startLabel: 'ก.ค.',
        endLabel: 'ม.ค.',
        statusLabel: 'ปัจจุบัน',
      ),
    ],
  );

  static const weightTracking = WeightTrackingData(
    title: 'การติดตามน้ำหนัก',
    subtitle: 'Weight Tracking',
    currentValue: '4.2 kg',
    currentLabel: 'น้ำหนักปัจจุบัน',
    chart: TrendSectionData(
      title: 'Weight Chart',
      rangeLabel: '',
      points: [3.8, 3.9, 4.0, 4.1, 4.2, 4.2],
      labels: ['มี.ค.', 'พ.ค.', 'ก.ค.', 'ก.ย.', 'พ.ย.', 'ม.ค.'],
      minValue: 3.8,
      maxValue: 4.2,
      deltaLabel: '',
      latestValue: '',
      analysisText: '',
    ),
    change: WeightChangeData(
      title: 'อัตราการเปลี่ยนแปลงน้ำหนักต่อเดือน',
      changeValue: '+0.03 kg',
      changePercent: '+0.9% ต่อเดือน',
      note: '✓ น้ำหนักคงที่และเหมาะสม การเปลี่ยนแปลงอยู่ในเกณฑ์',
    ),
  );

  static const bcsSection = BcsSectionData(
    title: 'BCS / Health Score',
    subtitle: 'คะแนนสมส่วนร่างกายของ มิโกะ',
    summary: BcsSummaryData(
      emoji: '✨',
      score: '5/9',
      status: 'คงที่',
      title: 'สมส่วนดี',
      description:
          'สัมผัสกระดูกซี่โครงได้ แต่ไม่เห็นชัด เอวชัดเจน ไขมันพอเหมาะ',
    ),
    scale: [
      BcsScaleItem(emoji: '🚨', value: '1/9', isActive: false),
      BcsScaleItem(emoji: '⚠️', value: '3/9', isActive: false),
      BcsScaleItem(emoji: '✨', value: '5/9', isActive: true),
      BcsScaleItem(emoji: '⚡', value: '7/9', isActive: false),
      BcsScaleItem(emoji: '🔴', value: '9/9', isActive: false),
    ],
    historyTitle: 'ประวัติคะแนน BCS',
    history: TrendSectionData(
      title: 'BCS History',
      rangeLabel: '',
      points: [1, 3, 5, 7, 5, 5],
      labels: ['มี.ค.', 'พ.ค.', 'ก.ค.', 'ก.ย.', 'พ.ย.', 'ม.ค.'],
      minValue: 1,
      maxValue: 9,
      deltaLabel: '',
      latestValue: '',
      analysisText: '',
    ),
    note: '✓ รูปร่างสมส่วนดี แต่ควรติดตามและรักษาแผนการดูแลปัจจุบัน',
    footnote: '* BCS คำนวณจากการสังเกตรูปร่างและการสัมผัสตัวสัตว์',
  );

  static const activitySection = ActivitySectionData(
    title: 'ระดับกิจกรรม',
    subtitle: 'Activity Level',
    currentLabel: 'ปัจจุบัน',
    currentValue: 'กระฉับกระเฉง',
    trendLabel: 'แนวโน้ม',
    trendValue: 'คงที่',
    chart: TrendSectionData(
      title: 'Activity Chart',
      rangeLabel: '',
      points: [1, 2, 3, 2.5, 3.5, 3.0],
      labels: ['มี.ค.', 'พ.ค.', 'ก.ค.', 'ก.ย.', 'พ.ย.', 'ม.ค.'],
      minValue: 1,
      maxValue: 4,
      deltaLabel: '',
      latestValue: '',
      analysisText: '',
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
  final String value;
  final String unit;
  final String status;
  final String caption;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  final Gradient background;
  final Color borderColor;

  const HealthSummaryItem({
    required this.value,
    required this.unit,
    required this.status,
    required this.caption,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
    required this.background,
    required this.borderColor,
  });
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final Gradient background;
  final bool showBadge;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.background,
    required this.showBadge,
  });
}

class NutritionData {
  final String title;
  final String subtitle;
  final TrendSectionData chart;
  final List<NutritionLegendItem> legends;
  final List<MealPlanData> plans;

  const NutritionData({
    required this.title,
    required this.subtitle,
    required this.chart,
    required this.legends,
    required this.plans,
  });
}

class NutritionLegendItem {
  final String label;
  final Color color;

  const NutritionLegendItem({required this.label, required this.color});
}

class MealPlanData {
  final String title;
  final String startLabel;
  final String endLabel;
  final String statusLabel;

  const MealPlanData({
    required this.title,
    required this.startLabel,
    required this.endLabel,
    required this.statusLabel,
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

class WeightTrackingData {
  final String title;
  final String subtitle;
  final String currentValue;
  final String currentLabel;
  final TrendSectionData chart;
  final WeightChangeData change;

  const WeightTrackingData({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.currentLabel,
    required this.chart,
    required this.change,
  });
}

class WeightChangeData {
  final String title;
  final String changeValue;
  final String changePercent;
  final String note;

  const WeightChangeData({
    required this.title,
    required this.changeValue,
    required this.changePercent,
    required this.note,
  });
}

class BcsSectionData {
  final String title;
  final String subtitle;
  final BcsSummaryData summary;
  final List<BcsScaleItem> scale;
  final String historyTitle;
  final TrendSectionData history;
  final String note;
  final String footnote;

  const BcsSectionData({
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.scale,
    required this.historyTitle,
    required this.history,
    required this.note,
    required this.footnote,
  });
}

class BcsSummaryData {
  final String emoji;
  final String score;
  final String status;
  final String title;
  final String description;

  const BcsSummaryData({
    required this.emoji,
    required this.score,
    required this.status,
    required this.title,
    required this.description,
  });
}

class BcsScaleItem {
  final String emoji;
  final String value;
  final bool isActive;

  const BcsScaleItem({
    required this.emoji,
    required this.value,
    required this.isActive,
  });
}

class ActivitySectionData {
  final String title;
  final String subtitle;
  final String currentLabel;
  final String currentValue;
  final String trendLabel;
  final String trendValue;
  final TrendSectionData chart;

  const ActivitySectionData({
    required this.title,
    required this.subtitle,
    required this.currentLabel,
    required this.currentValue,
    required this.trendLabel,
    required this.trendValue,
    required this.chart,
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
