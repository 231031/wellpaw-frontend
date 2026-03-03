import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/data/models/food_plan_models.dart';
import 'package:well_paw/features/food/data/services/food_plan_api_service.dart';

class FoodDetailPage extends StatefulWidget {
  const FoodDetailPage({super.key, required this.item});

  final FoodItemSummary item;

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _tokenStorage = const TokenStorage();
  final _foodApi = FoodPlanApiService();

  late final TextEditingController _brandController;
  late final TextEditingController _nameController;
  final _unitGramController = TextEditingController(text: '0');
  late final TextEditingController _gramsPerCupController;
  late final TextEditingController _stockCountController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _moistureController;
  late final TextEditingController _energyController;

  late int _selectedFoodType;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _canSave {
    return _brandController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty &&
        _parseDouble(_unitGramController, fallback: 0) >= 0 &&
        _parseDouble(_gramsPerCupController, fallback: 0) > 0 &&
        _parseInt(_stockCountController, fallback: 0) > 0 &&
        _parseDouble(_moistureController, fallback: 0) >= 0;
  }

  @override
  void initState() {
    super.initState();
    _selectedFoodType = widget.item.foodType < 0 ? 0 : widget.item.foodType;

    _brandController = TextEditingController(text: widget.item.brand);
    _nameController = TextEditingController(text: widget.item.name);
    _gramsPerCupController = TextEditingController(
      text: widget.item.gramsPerCup == null
          ? ''
          : widget.item.gramsPerCup!.toStringAsFixed(1),
    );
    _stockCountController = TextEditingController(
      text: widget.item.stockCount.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.item.protein.toStringAsFixed(1),
    );
    _fatController = TextEditingController(
      text: widget.item.fat.toStringAsFixed(1),
    );
    _moistureController = TextEditingController(
      text: widget.item.moisture.toStringAsFixed(1),
    );
    _energyController = TextEditingController(
      text: widget.item.energy.toStringAsFixed(1),
    );

    for (final controller in [
      _brandController,
      _nameController,
      _unitGramController,
      _gramsPerCupController,
      _stockCountController,
      _proteinController,
      _fatController,
      _moistureController,
      _energyController,
    ]) {
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _unitGramController.dispose();
    _gramsPerCupController.dispose();
    _stockCountController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _moistureController.dispose();
    _energyController.dispose();
    super.dispose();
  }

  double _parseDouble(TextEditingController controller, {double fallback = 0}) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ??
        fallback;
  }

  int _parseInt(TextEditingController controller, {int fallback = 0}) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }

  Future<void> _save() async {
    if (_isSaving || _isDeleting || !_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบ: ชื่อ/ยี่ห้อ/กรัมต่อถ้วย/จำนวนในคลัง',
          ),
        ),
      );
      return;
    }

    if (!AppConfig.hasValidApiBaseUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาตั้งค่า API Base URL ก่อนใช้งาน')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      await _foodApi.updateFood(
        accessToken: token,
        foodId: widget.item.id,
        payload: CreateFoodPayload(
          foodType: _selectedFoodType,
          brand: _brandController.text,
          name: _nameController.text,
          unitGram: _parseDouble(_unitGramController, fallback: 0),
          gramsPerCup: _parseDouble(_gramsPerCupController, fallback: 0),
          stockCount: _parseInt(_stockCountController, fallback: 0),
          protein: _parseDouble(_proteinController, fallback: 0),
          fat: _parseDouble(_fatController, fallback: 0),
          moisture: _parseDouble(_moistureController, fallback: 0),
          energy: _parseDouble(_energyController, fallback: 0),
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อัปเดตอาหารสำเร็จ')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('อัปเดตไม่สำเร็จ: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    if (_isSaving || _isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบอาหาร'),
        content: const Text('ยืนยันการลบรายการอาหารนี้ใช่หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      await _foodApi.deleteFood(accessToken: token, foodId: widget.item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบอาหารสำเร็จ')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = FoodTypeOption.fromId(_selectedFoodType);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'รายละเอียดอาหาร',
          style: TextStyle(color: AppColors.primaryBlueDark),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: widget.item.imageUrl.isEmpty
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Color(0xFF9EB0CC),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          widget.item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Color(0xFF9EB0CC),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ประเภทอาหาร',
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: FoodTypeOption.all
                    .map(
                      (type) => _FoodTypeChip(
                        option: type,
                        selected: type.id == selectedType.id,
                        onTap: () {
                          setState(() {
                            _selectedFoodType = type.id;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              _LabeledField(
                label: 'ยี่ห้อ',
                controller: _brandController,
                hint: 'เช่น Royal Canin',
              ),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'ชื่อผลิตภัณฑ์',
                controller: _nameController,
                hint: 'เช่น Adult Medium Breed',
              ),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'ขนาดต่อ 1 หน่วย (ถุง/กระป๋อง/ซอง) - กรัม',
                controller: _unitGramController,
                hint: '100',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'กรัมต่อ 1 ถ้วยตวง (grams_per_cup)',
                controller: _gramsPerCupController,
                hint: '120',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _LabeledField(
                label: 'จำนวนในคลัง',
                controller: _stockCountController,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDE3EE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อมูลโภชนาการ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlueDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LabeledField(
                      label: 'โปรตีน (%)',
                      controller: _proteinController,
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                      compact: true,
                    ),
                    _LabeledField(
                      label: 'ไขมัน (%)',
                      controller: _fatController,
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                      compact: true,
                    ),
                    _LabeledField(
                      label: 'ความชื้น (%)',
                      controller: _moistureController,
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                      compact: true,
                    ),
                    _LabeledField(
                      label: 'พลังงาน (kcal/100g)',
                      controller: _energyController,
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isSaving || _isDeleting ? null : _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('ลบอาหาร'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canSave && !_isSaving && !_isDeleting
                            ? _save
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('บันทึกการแก้ไข'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.compact = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD9DFEA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
          if (!compact) const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _FoodTypeChip extends StatelessWidget {
  const _FoodTypeChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final FoodTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  IconData _iconForType(int typeId) {
    switch (typeId) {
      case 0:
        return Icons.lunch_dining_outlined;
      case 1:
        return Icons.opacity_outlined;
      case 2:
        return Icons.cookie_outlined;
      case 3:
        return Icons.medication_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 146,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9F1FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : const Color(0xFFD6DCE7),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _iconForType(option.id),
              color: selected ? AppColors.primaryBlue : const Color(0xFF6E7787),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.titleThai,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
