import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/models/auth_models.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/auth/presentation/pages/login_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';
import 'package:well_paw/features/profile/data/services/user_api_service.dart';
import 'package:well_paw/features/profile/presentation/pages/create_pet_profile_page.dart';
import 'package:well_paw/features/profile/presentation/pages/pet_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _tokenStorage = const TokenStorage();
  final _userApi = UserApiService();
  bool _isLoadingUser = true;
  String? _userError;
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      setState(() {
        _isLoadingUser = false;
        _userError = 'กรุณาตั้งค่า API Base URL ก่อนใช้งานข้อมูลโปรไฟล์';
      });
      return;
    }

    setState(() {
      _isLoadingUser = true;
      _userError = null;
    });

    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final user = await _userApi.fetchCurrentUser(accessToken: accessToken);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingUser = false;
        _userError = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้: $error';
      });
    }
  }

  String _displayName(AuthUser? user) {
    if (user == null) {
      return _isLoadingUser ? 'กำลังโหลด...' : 'ไม่พบข้อมูลผู้ใช้';
    }

    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return fullName.isNotEmpty ? fullName : 'ผู้ใช้';
  }

  String _displayEmail(AuthUser? user) {
    if (user == null) {
      return _isLoadingUser ? 'กำลังโหลด...' : '—';
    }

    return user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _ProfileColors.primaryBlue,
                    _ProfileColors.primaryBlueLight,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
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
                            Text('โปรไฟล์', style: _ProfileText.h1),
                            const SizedBox(height: 4),
                            Text('Profile & Settings', style: _ProfileText.sub),
                          ],
                        ),
                      ),
                      _HeaderIcon(icon: Icons.settings),
                      const SizedBox(width: 12),
                      _HeaderIcon(icon: Icons.notifications_none),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ProfileCard(
                    name: _displayName(_user),
                    email: _displayEmail(_user),
                  ),
                  if (_userError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userError!,
                      style: _ProfileText.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'สัตว์เลี้ยงของฉัน (My Pets)',
                          style: _ProfileText.sectionTitle,
                        ),
                      ),
                      _AddPetButton(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreatePetProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._mockPets
                      .map(
                        (pet) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PetCard(
                            pet: pet,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PetDetailPage(pet: pet),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 8),
                  Text(
                    '💡 คลิกที่การ์ดเพื่อดูและแก้ไขรายละเอียดสัตว์เลี้ยง',
                    style: _ProfileText.caption,
                  ),
                  const SizedBox(height: 24),
                  _SettingsCard(),
                  const SizedBox(height: 16),
                  _LogoutButton(
                    onTap: () async {
                      await _tokenStorage.clear();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ProfileBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class _ProfileColors {
  static const background = Color(0xFFF8F9FD);
  static const primaryBlue = Color(0xFF3662AA);
  static const primaryBlueLight = Color(0xFF4A7BC8);
  static const cardBorder = Color(0xFFF3F4F6);
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const logout = Color(0xFFFB2C36);
}

class _ProfileText {
  static final h1 = GoogleFonts.sarabun(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static final sub = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static final sectionTitle = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _ProfileColors.textPrimary,
  );
  static final cardTitle = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _ProfileColors.textPrimary,
  );
  static final body = GoogleFonts.sarabun(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _ProfileColors.textSecondary,
  );
  static final caption = GoogleFonts.sarabun(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _ProfileColors.textHint,
  );
  static final logout = GoogleFonts.sarabun(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _ProfileColors.logout,
  );
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: _ProfileColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: _ProfileText.cardTitle),
              const SizedBox(height: 4),
              Text(
                email,
                style: _ProfileText.body.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _ProfileColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 16, color: _ProfileColors.primaryBlue),
            const SizedBox(width: 6),
            Text('เพิ่มสัตว์เลี้ยง', style: _ProfileText.body),
          ],
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetProfileData pet;
  final VoidCallback onTap;

  const _PetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ProfileColors.cardBorder),
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _ProfileColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.pets, color: _ProfileColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: _ProfileText.cardTitle),
                  const SizedBox(height: 6),
                  Text('น้ำหนักล่าสุด', style: _ProfileText.caption),
                  const SizedBox(height: 4),
                  Text(pet.weightLabel, style: _ProfileText.body),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: _ProfileColors.textHint),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _ProfileColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfileColors.cardBorder),
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
        children: const [
          _SettingsRow(label: 'การแจ้งเตือน'),
          _SettingsRow(label: 'ความเป็นส่วนตัว'),
          _SettingsRow(label: 'ภาษา', trailing: 'ไทย'),
          _SettingsRow(label: 'เกี่ยวกับ', showDivider: false),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? trailing;
  final bool showDivider;

  const _SettingsRow({
    required this.label,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(child: Text(label, style: _ProfileText.body)),
              if (trailing != null) ...[
                Text(trailing!, style: _ProfileText.caption),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right, color: _ProfileColors.textHint),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: _ProfileColors.cardBorder),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ProfileColors.logout),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: _ProfileColors.logout, size: 20),
            const SizedBox(width: 8),
            Text('ออกจากระบบ', style: _ProfileText.logout),
          ],
        ),
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ProfileBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

const _mockPets = [
  PetProfileData(
    id: 1,
    name: 'มิโกะ',
    weightLabel: '4.2 kg',
    type: 'สุนัข',
    breed: 'ชิวาวา',
    gender: 'ตัวเมีย',
    birthDate: '2021-07-12',
    weight: '4.2',
  ),
  PetProfileData(
    id: 2,
    name: 'โมโม่',
    weightLabel: '3.8 kg',
    type: 'แมว',
    breed: 'เปอร์เซีย',
    gender: 'ตัวผู้',
    birthDate: '2020-10-05',
    weight: '3.8',
  ),
  PetProfileData(
    id: 3,
    name: 'โคโค่',
    weightLabel: '5.1 kg',
    type: 'สุนัข',
    breed: 'ปอมเมอเรเนียน',
    gender: 'ตัวผู้',
    birthDate: '2019-02-22',
    weight: '5.1',
  ),
];
