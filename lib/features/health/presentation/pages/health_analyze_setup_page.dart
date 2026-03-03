import 'dart:io';

import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/health/presentation/pages/health_result_page.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';
import 'package:well_paw/features/profile/data/services/pet_api_service.dart';

enum _DiagnosisMode { profile, anonymous }

enum _AnimalType { dog, cat }

class HealthAnalyzeSetupPage extends StatefulWidget {
  const HealthAnalyzeSetupPage({super.key, required this.imageFile});

  final File imageFile;

  @override
  State<HealthAnalyzeSetupPage> createState() => _HealthAnalyzeSetupPageState();
}

class _HealthAnalyzeSetupPageState extends State<HealthAnalyzeSetupPage> {
  final _tokenStorage = const TokenStorage();
  final _petApi = PetApiService();

  _DiagnosisMode _mode = _DiagnosisMode.profile;
  _AnimalType _selectedAnimal = _AnimalType.dog;

  bool _isLoadingPets = true;
  List<PetProfileData> _pets = const [];
  int _selectedPetIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoadingPets = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับดึงข้อมูลสัตว์เลี้ยง');
      }

      final pets = await _petApi.fetchMyPets(accessToken: token);
      if (!mounted) return;
      setState(() {
        _pets = pets;
        if (_selectedPetIndex >= pets.length) {
          _selectedPetIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pets = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
      }
    }
  }

  Future<void> _startAnalyze() async {
    if (_mode == _DiagnosisMode.profile) {
      if (_pets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลสัตว์เลี้ยงสำหรับโหมดโปรไฟล์'),
          ),
        );
        return;
      }
      if (_selectedPetIndex < 0 || _selectedPetIndex >= _pets.length) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกสัตว์เลี้ยง')));
        return;
      }
    }

    final saveToHistory = _mode == _DiagnosisMode.profile;
    final petType = saveToHistory
        ? _pets[_selectedPetIndex].type
        : (_selectedAnimal == _AnimalType.dog ? 'สุนัข' : 'แมว');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthResultPage(
          imageFile: widget.imageFile,
          petTypeLabel: petType,
          shouldSaveHistory: saveToHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saveToHistory = _mode == _DiagnosisMode.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      body: SafeArea(
        child: Column(
          children: [
            _FlowTopBar(
              title: 'วิเคราะห์',
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
                        child: Image.file(widget.imageFile, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'เลือกวิธีการวินิจฉัย',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeCard(
                            title: 'เลือกโปรไฟล์',
                            subtitle: 'บันทึกในประวัติ',
                            icon: Icons.person_outline,
                            selected: _mode == _DiagnosisMode.profile,
                            selectedColor: AppColors.primaryBlue,
                            onTap: () {
                              setState(() {
                                _mode = _DiagnosisMode.profile;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeCard(
                            title: 'ไม่ระบุตัวตน',
                            subtitle: 'ไม่บันทึกประวัติ',
                            icon: Icons.person_off_outlined,
                            selected: _mode == _DiagnosisMode.anonymous,
                            selectedColor: const Color(0xFFE89BD9),
                            onTap: () {
                              setState(() {
                                _mode = _DiagnosisMode.anonymous;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      saveToHistory
                          ? 'เลือกสัตว์เลี้ยง'
                          : 'เลือกประเภทสัตว์เลี้ยง',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (saveToHistory)
                      _isLoadingPets
                          ? const Center(child: CircularProgressIndicator())
                          : _pets.isEmpty
                          ? _NoPetCard(onReload: _loadPets)
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pets.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.1,
                                  ),
                              itemBuilder: (context, index) {
                                final pet = _pets[index];
                                final selected = _selectedPetIndex == index;
                                final isCat = pet.type.contains('แมว');
                                return _PetCard(
                                  name: pet.name,
                                  typeLabel: pet.type,
                                  avatar: isCat ? '🐈' : '🐕',
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      _selectedPetIndex = index;
                                    });
                                  },
                                );
                              },
                            )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _AnimalTypeCard(
                              label: 'สุนัข (Dog)',
                              emoji: '🐕',
                              selected: _selectedAnimal == _AnimalType.dog,
                              onTap: () {
                                setState(() {
                                  _selectedAnimal = _AnimalType.dog;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AnimalTypeCard(
                              label: 'แมว (Cat)',
                              emoji: '🐈',
                              selected: _selectedAnimal == _AnimalType.cat,
                              onTap: () {
                                setState(() {
                                  _selectedAnimal = _AnimalType.cat;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD0D8E8)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AI',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'จะวิเคราะห์ภาพและให้คำแนะนำเบื้องต้น\nไม่ทดแทนการดูแลจากสัตวแพทย์',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: Color(0xFFDEE3EF)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                saveToHistory ? '✓ ' : 'ⓘ ',
                                style: TextStyle(
                                  color: saveToHistory
                                      ? AppColors.primaryBlue
                                      : const Color(0xFFE89BD9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  saveToHistory
                                      ? 'ผลการวินิจฉัยจะถูกบันทึกในประวัติของสัตว์เลี้ยง'
                                      : 'โหมดนี้ไม่บันทึกข้อมูลในระบบ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: saveToHistory
                                        ? AppColors.primaryBlue
                                        : const Color(0xFFE89BD9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _startAnalyze,
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text(
                          'วิเคราะห์ด้วย AI (Analyze)',
                          style: TextStyle(
                            fontSize: 18,
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? selectedColor : const Color(0xFFF7F7F8);
    final foreground = selected ? Colors.white : const Color(0xFF666666);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 116,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6D9E1)),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: foreground.withValues(alpha: selected ? 0.92 : 0.75),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.name,
    required this.typeLabel,
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String typeLabel;
  final String avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6D9E1)),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: selected
                    ? const Color(0xFF65A1EB)
                    : const Color(0xFF1E89E4),
                child: Text(avatar, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                typeLabel,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFD8E6FF)
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalTypeCard extends StatelessWidget {
  const _AnimalTypeCard({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 112,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6D9E1)),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$emoji\n$label',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoPetCard extends StatelessWidget {
  const _NoPetCard({required this.onReload});

  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6D9E1)),
      ),
      child: Column(
        children: [
          const Text(
            'ไม่พบข้อมูลสัตว์เลี้ยง',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onReload, child: const Text('ลองโหลดใหม่')),
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
