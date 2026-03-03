import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_text_styles.dart';
import 'package:well_paw/core/widgets/custom_button.dart';
import 'package:well_paw/core/widgets/custom_text_field.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/profile/presentation/pages/bcs_detailed_analysis_page.dart';
import 'package:well_paw/features/profile/data/services/pet_api_service.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';

enum PetDetailFocusSection { weight, bcs, activity }

class PetDetailPage extends StatefulWidget {
  final PetProfileData pet;
  final PetDetailFocusSection? focusSection;

  const PetDetailPage({super.key, required this.pet, this.focusSection});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _bcsController = TextEditingController();
  final _gestationDateController = TextEditingController();
  final _weightSectionKey = GlobalKey();
  final _bcsSectionKey = GlobalKey();
  final _activitySectionKey = GlobalKey();

  final _tokenStorage = const TokenStorage();
  final _petApi = PetApiService();
  final _imagePicker = ImagePicker();

  File? _petImage;

  String _petType = 'สุนัข';
  String _gender = 'ตัวผู้';
  String _activityLevel = 'ปกติ';
  bool _neutered = false;
  bool _lactation = false;
  bool _gestation = false;
  int? _bcsValue;
  DateTime? _bcsUpdatedAt;
  int _activityIndex = 2;
  bool _isSaving = false;
  bool _isLoadingAnalysis = false;
  String? _analysisError;
  String? _remoteImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshHeader);
    _applyPetProfile(widget.pet);
    _loadLatestPetProfile();
    _loadPetAnalysis();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocusedSection();
    });
  }

  void _scrollToFocusedSection() {
    final focusSection = widget.focusSection;
    if (focusSection == null || !mounted) {
      return;
    }

    final key = switch (focusSection) {
      PetDetailFocusSection.weight => _weightSectionKey,
      PetDetailFocusSection.bcs => _bcsSectionKey,
      PetDetailFocusSection.activity => _activitySectionKey,
    };

    final context = key.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.15,
    );
  }

  void _applyPetProfile(PetProfileData pet) {
    _nameController.text = pet.name;
    _breedController.text = pet.breed;
    _weightController.text = pet.weight;
    _birthdayController.text = pet.birthDate;
    _remoteImageUrl = pet.imagePath;
    _petType = pet.type;
    _gender = pet.gender;
    _neutered = false;
    _lactation = false;
    _gestation = false;
    _activityIndex = ((pet.activityLevel ?? 2).clamp(0, 3) as int);
    _activityLevel = _mapActivityLevelLabel(_activityIndex);
    _bcsValue = ((pet.bcs ?? 2).clamp(0, 4) as int);
    _bcsController.text = _bcsValue.toString();
    _bcsUpdatedAt = DateTime.now();
  }

  Future<void> _loadLatestPetProfile() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      return;
    }

    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      final latest = await _petApi.fetchPetById(
        accessToken: accessToken,
        petId: widget.pet.id,
      );
      if (!mounted || latest == null) {
        return;
      }

      setState(() {
        _applyPetProfile(latest);
      });
    } catch (_) {
      // Keep existing local values when latest fetch fails.
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshHeader);
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _birthdayController.dispose();
    _bcsController.dispose();
    _gestationDateController.dispose();
    super.dispose();
  }

  void _refreshHeader() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ImageSourceSheet(),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (picked == null) return;

    setState(() {
      _petImage = File(picked.path);
    });
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบถ้วน';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกน้ำหนัก';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'กรุณากรอกน้ำหนักให้ถูกต้อง';
    }
    return null;
  }

  String? _validateBcs(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก BCS';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 4) {
      return 'กรุณากรอก BCS ช่วง 0-4';
    }
    return null;
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryBlue),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (result == null) return;

    _birthdayController.text = DateTime.utc(
      result.year,
      result.month,
      result.day,
    ).toIso8601String();
  }

  Future<void> _pickGestationDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryBlue),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (result == null) return;

    _gestationDateController.text = DateTime.utc(
      result.year,
      result.month,
      result.day,
    ).toIso8601String();
  }

  String _ensureRfc3339(String value) {
    if (value.contains('T')) {
      return value;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final parsed = DateTime.tryParse('${trimmed}T00:00:00Z');
    return parsed?.toUtc().toIso8601String() ?? trimmed;
  }

  int _mapPetType(String value) => value == 'แมว' ? 1 : 0;

  int _mapSexType(String value) => value == 'ตัวเมีย' ? 1 : 0;

  int _mapActivityLevel(String value) {
    switch (value) {
      case 'น้อยมาก':
        return 0;
      case 'น้อย':
        return 1;
      case 'สูง':
        return 3;
      default:
        return 2;
    }
  }

  String _mapActivityLevelLabel(int value) {
    switch (value) {
      case 0:
        return 'น้อยมาก';
      case 1:
        return 'น้อย';
      case 3:
        return 'สูง';
      default:
        return 'ปกติ';
    }
  }

  String _formatWeight(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _normalizeDateText(String dateText) {
    final trimmed = dateText.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed.length >= 10 ? trimmed.substring(0, 10) : trimmed;
  }

  Future<void> _loadPetAnalysis() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      return;
    }

    setState(() {
      _isLoadingAnalysis = true;
      _analysisError = null;
    });

    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final analysis = await _petApi.fetchPetAnalysis(
        accessToken: accessToken,
        petId: widget.pet.id,
      );

      if (!mounted) return;

      if (analysis != null) {
        setState(() {
          if (analysis.weight != null) {
            _weightController.text = _formatWeight(analysis.weight!);
          }

          if (analysis.activityLevel != null) {
            _activityIndex = (analysis.activityLevel!.clamp(0, 3) as int);
            _activityLevel = _mapActivityLevelLabel(_activityIndex);
          }

          if (analysis.bcs != null) {
            _bcsValue = (analysis.bcs!.clamp(0, 4) as int);
            _bcsController.text = _bcsValue.toString();
            _bcsUpdatedAt = DateTime.now();
          }

          if (analysis.neutered != null) {
            _neutered = analysis.neutered!;
          }

          if (analysis.lactation != null) {
            _lactation = analysis.lactation!;
          }

          if (analysis.gestation != null) {
            _gestation = analysis.gestation!;
          }

          if (analysis.gestationStartDate != null &&
              analysis.gestationStartDate!.trim().isNotEmpty) {
            _gestationDateController.text = _normalizeDateText(
              analysis.gestationStartDate!,
            );
          }

          if (analysis.imagePath != null && analysis.imagePath!.isNotEmpty) {
            _remoteImageUrl = analysis.imagePath;
          }
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _analysisError = 'ไม่สามารถโหลดข้อมูลวิเคราะห์ได้: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
        });
      }
    }
  }

  String _bcsLabel(int value) {
    switch (value) {
      case 0:
        return '1/9';
      case 1:
        return '3/9';
      case 2:
        return '5/9';
      case 3:
        return '7/9';
      case 4:
        return '9/9';
      default:
        return '5/9';
    }
  }

  String _bcsThaiStatus(int value) {
    switch (value) {
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

  void _setBcs(int value) {
    setState(() {
      _bcsValue = value.clamp(0, 4);
      _bcsController.text = _bcsValue.toString();
      _bcsUpdatedAt = DateTime.now();
    });
  }

  Future<void> _openBcsCalculator() async {
    final result = await showDialog<_BcsCalcMode>(
      context: context,
      builder: (_) => const _BcsCalcModeDialog(),
    );

    if (!mounted || result == null) return;

    if (result == _BcsCalcMode.simple) {
      final selected = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => _BcsSimpleCalculatorPage(initial: _bcsValue ?? 2),
        ),
      );
      if (selected != null) {
        _setBcs(selected);
      }
      return;
    }

    final selected = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            BcsDetailedAnalysisPage(petType: _petType, initial: _bcsValue ?? 2),
      ),
    );

    if (selected != null) {
      _setBcs(selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกผลการวิเคราะห์ BCS แล้ว'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _selectActivityLevel() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityLevelSheet(selectedIndex: _activityIndex),
    );

    if (selected == null) return;

    setState(() {
      _activityIndex = selected;
      _activityLevel = const ['น้อยมาก', 'น้อย', 'ปกติ', 'สูง'][selected];
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_bcsValue == null || _bcsValue! < 0 || _bcsValue! > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกค่า BCS ให้ถูกต้อง'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!AppConfig.hasValidApiBaseUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า API Base URL ก่อนใช้งานการบันทึก'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final infoPayload = PetInfoPayload(
        petId: widget.pet.id,
        name: _nameController.text,
        type: _mapPetType(_petType),
        breed: _breedController.text,
        sexType: _mapSexType(_gender),
        birthDate: _ensureRfc3339(_birthdayController.text),
      );

      final weightValue = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );
      final bcsValue = _bcsValue!;

      final detailPayload = PetDetailPayload(
        petId: widget.pet.id,
        weight: weightValue,
        activityLevel: _mapActivityLevel(_activityLevel),
        bcs: bcsValue,
        neutered: _neutered,
        lactation: _lactation,
        gestation: _gestation,
        gestationStartDate: _gestation
            ? _ensureRfc3339(_gestationDateController.text)
            : null,
      );

      await _petApi.updatePetInfo(
        accessToken: accessToken,
        payload: infoPayload,
      );
      await _petApi.updatePetDetail(
        accessToken: accessToken,
        payload: detailPayload,
      );

      await _loadLatestPetProfile();
      await _loadPetAnalysis();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัปเดตโปรไฟล์สัตว์เลี้ยงสำเร็จ'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถบันทึกได้: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeletePetDialog(),
    );

    if (confirmed != true) return;

    if (!AppConfig.hasValidApiBaseUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า API Base URL ก่อนใช้งานการลบ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      await _petApi.deletePet(accessToken: accessToken, petId: widget.pet.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบโปรไฟล์สัตว์เลี้ยงแล้ว'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถลบได้: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
        title: Text('รายละเอียดสัตว์เลี้ยง', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingAnalysis)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  )
                else if (_analysisError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _analysisError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                _PetHeaderCard(name: _nameController.text),
                const SizedBox(height: 24),
                Center(
                  child: _ImagePickerAvatar(
                    imageFile: _petImage,
                    imageUrl: _remoteImageUrl,
                    onTap: _showImageSourceSheet,
                  ),
                ),
                const SizedBox(height: 24),
                Text('ข้อมูลพื้นฐาน', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'ชื่อสัตว์เลี้ยง',
                  hintText: 'เช่น มิโกะ',
                  prefixIcon: Icons.pets_outlined,
                  controller: _nameController,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 20),
                _OptionSelector(
                  label: 'ประเภทสัตว์เลี้ยง',
                  options: const ['สุนัข', 'แมว'],
                  selected: _petType,
                  onChanged: (value) {
                    setState(() {
                      _petType = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'สายพันธุ์',
                  hintText: 'เช่น ชิวาวา',
                  prefixIcon: Icons.badge_outlined,
                  controller: _breedController,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 20),
                _OptionSelector(
                  label: 'เพศ',
                  options: const ['ตัวผู้', 'ตัวเมีย'],
                  selected: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                      if (_gender == 'ตัวผู้') {
                        _gestation = false;
                        _gestationDateController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                _DateField(
                  label: 'วันเกิด',
                  controller: _birthdayController,
                  onTap: _pickBirthday,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 20),
                Container(
                  key: _weightSectionKey,
                  child: CustomTextField(
                    label: 'น้ำหนัก (กก.)',
                    hintText: 'เช่น 4.2',
                    prefixIcon: Icons.monitor_weight_outlined,
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    validator: _validateWeight,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  key: _bcsSectionKey,
                  child: _BcsSummaryCard(
                    valueLabel: _bcsValue != null
                        ? _bcsLabel(_bcsValue!)
                        : null,
                    statusLabel: _bcsValue != null
                        ? _bcsThaiStatus(_bcsValue!)
                        : null,
                    updatedAt: _bcsUpdatedAt,
                    onCalculate: _openBcsCalculator,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  key: _activitySectionKey,
                  child: _ActivitySelector(
                    label: 'ระดับกิจกรรม',
                    value: _activityLevel,
                    onTap: _selectActivityLevel,
                  ),
                ),
                const SizedBox(height: 20),
                _NeuteredSelector(
                  value: _neutered,
                  onChanged: (value) {
                    setState(() {
                      _neutered = value;
                      if (_neutered) {
                        _gestation = false;
                        _gestationDateController.clear();
                      }
                    });
                  },
                ),
                if (_gender == 'ตัวเมีย' && !_neutered) ...[
                  const SizedBox(height: 20),
                  _ToggleCard(
                    label: 'อยู่ในช่วงให้นม',
                    subtitle: 'ใช้สำหรับปรับการคำนวณโภชนาการ',
                    value: _lactation,
                    onChanged: (value) {
                      setState(() {
                        _lactation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _ToggleCard(
                    label: 'อยู่ในช่วงตั้งท้อง',
                    subtitle: 'คำนวณพลังงานสำหรับสัตว์ตั้งท้อง',
                    value: _gestation,
                    onChanged: (value) {
                      setState(() {
                        _gestation = value;
                      });
                    },
                  ),
                  if (_gestation) ...[
                    const SizedBox(height: 20),
                    _DateField(
                      label: 'วันเริ่มตั้งท้อง',
                      controller: _gestationDateController,
                      onTap: _pickGestationDate,
                      validator: _validateRequired,
                    ),
                  ],
                ],
                const SizedBox(height: 28),
                CustomButton(
                  text: 'บันทึกการเปลี่ยนแปลง',
                  onPressed: _handleSave,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: 16),
                _DeleteButton(onTap: _handleDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetHeaderCard extends StatelessWidget {
  final String name;

  const _PetHeaderCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'โปรไฟล์สัตว์เลี้ยง' : name;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'แก้ไขข้อมูลเพื่อการดูแลที่เหมาะสม',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: AppTextStyles.bodyLarge),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.iconGray,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          onTap: onTap,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'เลือกวันเกิด',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.iconGray,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _ImagePickerAvatar extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ImagePickerAvatar({
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(60),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inputBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imageFile != null)
              ClipOval(
                child: Image.file(
                  imageFile!,
                  width: 106,
                  height: 106,
                  fit: BoxFit.cover,
                ),
              ),
            if (imageFile == null && imageUrl != null && imageUrl!.isNotEmpty)
              ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: 106,
                  height: 106,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.iconGray,
                    size: 32,
                  ),
                ),
              ),
            if (imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
              const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.iconGray,
                size: 32,
              ),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Text('เพิ่มรูปภาพสัตว์เลี้ยง', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _ImageSourceTile(
            icon: Icons.camera_alt_outlined,
            title: 'ถ่ายภาพ',
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _ImageSourceTile(
            icon: Icons.photo_library_outlined,
            title: 'เลือกรูปจากคลัง',
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodyLarge)),
            const Icon(Icons.chevron_right, color: AppColors.iconGray),
          ],
        ),
      ),
    );
  }
}

class _OptionSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _OptionSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Row(
          children: options.map((option) {
            final isSelected = option == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: option == options.last ? 0 : 8),
                child: InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.12)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.inputBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NeuteredSelector extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NeuteredSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('สถานะทำหมัน', style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            _NeuteredOption(
              label: 'ยังไม่ทำหมัน',
              subtitle: 'ปกติยังไม่ได้ทำหมัน',
              icon: Icons.remove_circle_outline,
              selected: !value,
              onTap: () => onChanged(false),
            ),
            const SizedBox(width: 12),
            _NeuteredOption(
              label: 'ทำหมันแล้ว',
              subtitle: 'ผ่านการทำหมันแล้ว',
              icon: Icons.check_circle_outline,
              selected: value,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ],
    );
  }
}

class _NeuteredOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NeuteredOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withValues(alpha: 0.12)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.primaryBlue : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySelector extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ActivitySelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value, style: AppTextStyles.bodyLarge)),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.iconGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityLevelSheet extends StatelessWidget {
  final int selectedIndex;

  const _ActivityLevelSheet({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final options = const [
      {
        'title': 'ไม่ออกกำลังกาย (Inactive)',
        'subtitle': 'ไม่ออกกำลังกายหรือออกกำลังกายน้อยมาก',
      },
      {
        'title': 'ออกกำลังกายน้อย (Somewhat Active)',
        'subtitle': 'ออกกำลังกาย 1-2 วัน/สัปดาห์',
      },
      {
        'title': 'ออกกำลังกายปานกลาง (Active)',
        'subtitle': 'ออกกำลังกาย 3-5 วัน/สัปดาห์',
      },
      {
        'title': 'ออกกำลังกายมาก (Very Active)',
        'subtitle': 'ออกกำลังกายทุกวัน (Daily active)',
      },
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('ระดับกิจกรรม (Activity Level)', style: AppTextStyles.h3),
              const SizedBox(height: 6),
              Text('ความถี่ในการออกกำลังกาย', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value['title']!;
                final subtitle = entry.value['subtitle']!;
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.inputBorder,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: selected
                                        ? Colors.white70
                                        : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BcsSummaryCard extends StatelessWidget {
  final String? valueLabel;
  final String? statusLabel;
  final DateTime? updatedAt;
  final VoidCallback onCalculate;

  const _BcsSummaryCard({
    required this.valueLabel,
    required this.statusLabel,
    required this.updatedAt,
    required this.onCalculate,
  });

  String _formatThaiDate(DateTime date) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final buddhistYear = date.year + 543;
    return '${date.day} ${months[date.month - 1]} $buddhistYear';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue =
        valueLabel != null && statusLabel != null && updatedAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3E6DC0), Color(0xFF4E7DCE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Body Condition Score',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: hasValue
                    ? Column(
                        children: [
                          Text(
                            valueLabel!,
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontSize: 56,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusLabel!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'อัปเดตล่าสุด: ${_formatThaiDate(updatedAt!)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            'ยังไม่มีข้อมูล BCS',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'คำนวณค่า BCS\nเพื่อประเมินสุขภาพสัตว์เลี้ยงของคุณ',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: onCalculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.planPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text(
                    hasValue ? 'คำนวณ BCS ใหม่' : 'คำนวณค่า BCS',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 38 / 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '💡 เกี่ยวกับ BCS: Body Condition Score คือการประเมินสุขภาพร่างกายของสัตว์เลี้ยงโดยดูจากรูปร่างและการสัมผัส',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _BcsCalcMode { simple, advanced }

class _BcsCalcModeDialog extends StatelessWidget {
  const _BcsCalcModeDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คำนวณ BCS', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Text('เลือกวิธีคำนวณที่ต้องการ', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 20),
            _CalcModeTile(
              title: 'คำนวณแบบง่าย',
              subtitle: 'เลือกจากแถบระดับ 1/9 - 9/9',
              onTap: () => Navigator.of(context).pop(_BcsCalcMode.simple),
            ),
            const SizedBox(height: 12),
            _CalcModeTile(
              title: 'คำนวณแบบละเอียด',
              subtitle: 'ตอบคำถามเพื่อคำนวณค่าที่แม่นยำ',
              onTap: () => Navigator.of(context).pop(_BcsCalcMode.advanced),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalcModeTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.iconGray),
          ],
        ),
      ),
    );
  }
}

class _BcsSimpleCalculatorPage extends StatefulWidget {
  final int initial;

  const _BcsSimpleCalculatorPage({required this.initial});

  @override
  State<_BcsSimpleCalculatorPage> createState() =>
      _BcsSimpleCalculatorPageState();
}

class _BcsSimpleCalculatorPageState extends State<_BcsSimpleCalculatorPage> {
  late int _current;

  final _labels = const ['1/9', '3/9', '5/9', '7/9', '9/9'];
  final _titles = const ['ผอมมาก', 'ผอม', 'สมส่วน', 'อ้วน', 'อ้วนมาก'];
  final _english = const [
    'Very Thin',
    'Underweight',
    'Ideal',
    'Overweight',
    'Obese',
  ];

  final _status = const ['TOO THIN', 'THIN', 'NORMAL', 'OVERWEIGHT', 'OBESE'];

  final _ribs = const [
    'ซี่โครงโผล่ชัดเจนมาก มองเห็นได้ง่าย',
    'ซี่โครงมองเห็นได้เล็กน้อยและคลำได้ชัด',
    'คลำซี่โครงได้ง่าย มีไขมันปกคลุมบาง ๆ',
    'คลำซี่โครงยากขึ้น มีไขมันปกคลุมมาก',
    'ซี่โครงคลำได้ยากมากเพราะไขมันสะสมหนา',
  ];

  final _waist = const [
    'เอวคอดชัดเจนมาก',
    'เอวคอดชัดเจน',
    'มีเอวเห็นได้จากมุมบน',
    'เอวเริ่มหายไปจากมุมบน',
    'ไม่เห็นเอวและรูปร่างกลม',
  ];

  final _abdomen = const [
    'ไม่มีไขมันบริเวณหน้าท้อง',
    'หน้าท้องยกขึ้นเล็กน้อย ไขมันน้อย',
    'หน้าท้องกระชับตามเกณฑ์ปกติ',
    'มีไขมันหน้าท้องสะสมชัดเจน',
    'มีไขมันหน้าท้องมากและหย่อน',
  ];

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
  void initState() {
    super.initState();
    _current = widget.initial.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'BCS - โหมดง่าย',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ประเมิน โคโค่', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            Text(
                              'เลื่อนแถบเลือกคะแนนที่ตรงกับรูปร่างของสัตว์เลี้ยงมากที่สุด',
                              style: AppTextStyles.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'สังเกตจากภาพด้านข้างและด้านบนประกอบการประเมิน',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _PosePreviewCard(
                                titleTh: 'ภาพด้านข้าง',
                                titleEn: 'Side View',
                                imagePath: _sideAssets[_current],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PosePreviewCard(
                                titleTh: 'ภาพด้านบน',
                                titleEn: 'Top View',
                                imagePath: _topAssets[_current],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBE8EA),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                _labels[_current],
                                style: AppTextStyles.h2.copyWith(
                                  color: const Color(0xFFEF5350),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _titles[_current],
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _english[_current],
                              style: AppTextStyles.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _status[_current],
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 14),
                            const Divider(
                              color: AppColors.inputBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 14),
                            _Bullet(text: 'ซี่โครง: ${_ribs[_current]}'),
                            const SizedBox(height: 8),
                            _Bullet(text: 'เอว: ${_waist[_current]}'),
                            const SizedBox(height: 8),
                            _Bullet(text: 'หน้าท้อง: ${_abdomen[_current]}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 36,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF06262),
                                          Color(0xFF31D07D),
                                          Color(0xFFF06262),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 18,
                                      activeTrackColor: Colors.transparent,
                                      inactiveTrackColor: Colors.transparent,
                                      thumbColor: Colors.white,
                                      thumbShape: const _BlueBorderThumbShape(),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 16,
                                          ),
                                      overlayColor: AppColors.primaryBlue
                                          .withValues(alpha: 0.16),
                                    ),
                                    child: Slider(
                                      value: _current.toDouble(),
                                      min: 0,
                                      max: 4,
                                      divisions: 4,
                                      onChanged: (value) {
                                        setState(() {
                                          _current = value.round();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('1 ผอมมาก'),
                                Text('5 เหมาะสม'),
                                Text('9 อ้วนเกิน'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.planPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(_current),
                  child: Text(
                    'ยืนยันผลการประเมิน  →',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PosePreviewCard extends StatelessWidget {
  final String titleTh;
  final String titleEn;
  final String imagePath;

  const _PosePreviewCard({
    required this.titleTh,
    required this.titleEn,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titleTh,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          Text(titleEn, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final parts = text.split(':');
    final title = parts.first;
    final detail = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 8, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlueBorderThumbShape extends SliderComponentShape {
  const _BlueBorderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.primaryBlue,
    );
  }
}

class _NoteField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NoteField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'เช่น พฤติกรรมพิเศษที่ต้องระวัง',
            prefixIcon: Icon(
              Icons.notes_outlined,
              color: AppColors.iconGray,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error),
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
            const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'ลบโปรไฟล์สัตว์เลี้ยง',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletePetDialog extends StatelessWidget {
  const _DeletePetDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text('ยืนยันการลบโปรไฟล์', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'การลบจะไม่สามารถกู้คืนได้ คุณต้องการลบใช่หรือไม่?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'ยกเลิก',
                    onPressed: () => Navigator.of(context).pop(false),
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'ลบโปรไฟล์',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
