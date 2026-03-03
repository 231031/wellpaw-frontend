import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/activity/presentation/pages/activity_page.dart';
import 'package:well_paw/features/food/presentation/pages/food_home_page.dart';
import 'package:well_paw/features/health/presentation/pages/health_photo_guide_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';
import 'package:well_paw/features/profile/presentation/pages/profile_page.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SkinHeader(),
              const SizedBox(height: 16),
              const _LatestDiagnosisCard(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.auto_awesome_outlined,
                      label: 'เริ่มวินิจฉัย',
                      filled: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HealthPhotoGuidePage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.history,
                      label: 'ประวัติ',
                      filled: false,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('หน้าประวัติจะเปิดใช้งานเร็ว ๆ นี้'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _DiagnosisInfoCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _HealthBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FoodHomePage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ActivityPage()),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class _SkinHeader extends StatelessWidget {
  const _SkinHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สุขภาพผิวหนัง',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Health & Skin Diagnosis',
            style: TextStyle(color: Color(0xFFDCE6FA), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _LatestDiagnosisCard extends StatelessWidget {
  const _LatestDiagnosisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E7EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'การวินิจฉัยล่าสุด',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'สุนัข',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  'https://images.unsplash.com/photo-1591530294104-6c7ef6c7f6ac?auto=format&fit=crop&w=800&q=80',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 88,
                    height: 88,
                    color: const Color(0xFFE5EAF3),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'มิโกะ',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ringworm',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFF39A00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '25 พ.ย. 2567',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 82,
          decoration: BoxDecoration(
            color: filled ? AppColors.primaryBlue : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryBlue, width: 1.3),
            boxShadow: filled
                ? const [
                    BoxShadow(
                      color: Color(0x17000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : AppColors.primaryBlue),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagnosisInfoCard extends StatelessWidget {
  const _DiagnosisInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E7EF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เกี่ยวกับการวินิจฉัย',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI จะวิเคราะห์ภาพผิวหนังและให้คำแนะนำเบื้องต้น\nไม่ทดแทนการวินิจฉัยจากสัตวแพทย์',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthBottomNav extends StatelessWidget {
  const _HealthBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _HealthNavItem(label: 'Home', assetPath: 'assets/icons/home.png'),
    _HealthNavItem(label: 'Food', assetPath: 'assets/icons/food.png'),
    _HealthNavItem(label: 'Health', assetPath: 'assets/icons/health.png'),
    _HealthNavItem(label: 'Calendar', assetPath: 'assets/icons/calendar.png'),
    _HealthNavItem(label: 'Profile', assetPath: 'assets/icons/profile.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: _items
          .map(
            (item) => BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(item.assetPath), size: 24),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _HealthNavItem {
  const _HealthNavItem({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}
