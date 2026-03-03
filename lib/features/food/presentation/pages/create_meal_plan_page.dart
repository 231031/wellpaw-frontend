import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/data/models/food_plan_models.dart';
import 'package:well_paw/features/food/data/services/food_plan_api_service.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';
import 'package:well_paw/features/profile/data/services/pet_api_service.dart';

class CreateMealPlanPage extends StatefulWidget {
  const CreateMealPlanPage({super.key, this.initialPetId});

  final int? initialPetId;

  @override
  State<CreateMealPlanPage> createState() => _CreateMealPlanPageState();
}

class _CreateMealPlanPageState extends State<CreateMealPlanPage> {
  final _tokenStorage = const TokenStorage();
  final _petApi = PetApiService();
  final _foodApi = FoodPlanApiService();

  bool _isLoading = true;
  String? _error;

  List<PetProfileData> _pets = const [];
  final Map<int, List<FoodItemSummary>> _foodsByType =
      <int, List<FoodItemSummary>>{};
  final Set<int> _selectedFoodIds = <int>{};

  int _selectedPetIndex = 0;
  int? _selectedUnit; // 0=grams, 1=cups
  bool _isCalculatingPlan = false;
  bool _isSavingPlan = false;
  bool _hasCreatedPlan = false;
  _MealPlanResult? _result;

  PetProfileData? get _selectedPet {
    if (_pets.isEmpty ||
        _selectedPetIndex < 0 ||
        _selectedPetIndex >= _pets.length) {
      return null;
    }
    return _pets[_selectedPetIndex];
  }

  bool get _canCalculate {
    return _selectedPet != null &&
        _selectedFoodIds.isNotEmpty &&
        _selectedUnit != null &&
        !_isCalculatingPlan &&
        !_isSavingPlan;
  }

  bool get _canSave {
    return _result != null &&
        !_hasCreatedPlan &&
        !_isSavingPlan &&
        !_isCalculatingPlan;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      setState(() {
        _isLoading = false;
        _error = 'กรุณาตั้งค่า API Base URL ก่อนใช้งาน';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final pets = await _petApi.fetchMyPets(accessToken: token);
      final foods0 = await _safeFetchByType(token, 0);
      final foods1 = await _safeFetchByType(token, 1);
      final foods2 = await _safeFetchByType(token, 2);
      final foods3 = await _safeFetchByType(token, 3);

      var selectedIndex = 0;
      if (widget.initialPetId != null) {
        final foundIndex = pets.indexWhere(
          (pet) => pet.id == widget.initialPetId,
        );
        if (foundIndex >= 0) {
          selectedIndex = foundIndex;
        }
      }

      if (!mounted) return;
      setState(() {
        _pets = pets;
        _selectedPetIndex = selectedIndex;
        _foodsByType[0] = foods0;
        _foodsByType[1] = foods1;
        _foodsByType[2] = foods2;
        _foodsByType[3] = foods3;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$e';
      });
    }
  }

  Future<List<FoodItemSummary>> _safeFetchByType(String token, int type) async {
    try {
      return await _foodApi.fetchFoodItemsByType(
        accessToken: token,
        foodType: type,
      );
    } catch (_) {
      return const <FoodItemSummary>[];
    }
  }

  void _toggleFood(FoodItemSummary food) {
    setState(() {
      if (_selectedFoodIds.contains(food.id)) {
        _selectedFoodIds.remove(food.id);
      } else {
        _selectedFoodIds.add(food.id);
      }
      _result = null;
      _hasCreatedPlan = false;
    });
  }

  double _parseWeight(PetProfileData pet) {
    final text = pet.weightLabel
        .trim()
        .toLowerCase()
        .replaceAll('kg', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }

  String _buildPlanName(PetProfileData pet) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'Plan $date - ${pet.name}';
  }

  _MealPlanDraft _buildDraftResult(List<FoodItemSummary> selectedFoods) {
    final pet = _selectedPet!;
    final weightKg = _parseWeight(pet);
    final totalGrams = (weightKg > 0 ? weightKg * 20 : 80)
        .clamp(40, 220)
        .toDouble();
    final each = totalGrams / selectedFoods.length;

    var totalProtein = 0.0;
    var totalFat = 0.0;
    var totalKcal = 0.0;

    final amounts = <int, double>{};
    for (final food in selectedFoods) {
      amounts[food.id] = each;
      totalProtein += (food.protein * each) / 100;
      totalFat += (food.fat * each) / 100;
      totalKcal += (food.energy * each) / 100;
    }

    return _MealPlanDraft(
      amountsByFoodId: amounts,
      totalProtein: totalProtein,
      totalFat: totalFat,
      totalKcal: totalKcal,
    );
  }

  List<FoodItemSummary> _currentSelectedFoods() {
    return _foodsByType.values
        .expand((e) => e)
        .where((f) => _selectedFoodIds.contains(f.id))
        .toList();
  }

  List<Map<String, dynamic>>? _buildFoodsPayload({
    required List<FoodItemSummary> selectedFoods,
    required Map<int, double> amountsByFoodId,
    required int unit,
  }) {
    if (unit == 1) {
      final missingCupFoods = selectedFoods
          .where((food) => food.gramsPerCup == null || food.gramsPerCup! <= 0)
          .toList();

      if (missingCupFoods.isNotEmpty) {
        final names = missingCupFoods
            .map((food) => food.name.trim())
            .where((name) => name.isNotEmpty)
            .join(', ');
        final detail = names.isEmpty ? '' : ' ($names)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อาหารที่เลือกยังไม่มีค่า grams_per_cup$detail กรุณาเลือกหน่วยกรัมหรืออัปเดตข้อมูลอาหารก่อน',
            ),
          ),
        );
        return null;
      }
    }

    return selectedFoods.map((food) {
      final amount = amountsByFoodId[food.id] ?? 0;
      return <String, dynamic>{
        'food_id': food.id,
        'amount': amount,
        if (unit == 1) 'grams_per_cup': food.gramsPerCup,
      };
    }).toList();
  }

  Future<void> _calculate() async {
    if (!_canCalculate) {
      return;
    }

    final selectedFoods = _currentSelectedFoods();

    if (selectedFoods.isEmpty) {
      return;
    }

    final selectedUnit = _selectedUnit;
    if (selectedUnit == null) {
      return;
    }

    final pet = _selectedPet!;
    final draft = _buildDraftResult(selectedFoods);
    final planName = _buildPlanName(pet);
    final foodsPayload = _buildFoodsPayload(
      selectedFoods: selectedFoods,
      amountsByFoodId: draft.amountsByFoodId,
      unit: selectedUnit,
    );
    if (foodsPayload == null) {
      return;
    }

    setState(() {
      _isCalculatingPlan = true;
      _hasCreatedPlan = false;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      await _foodApi.calculateFoodPlan(
        accessToken: token,
        name: planName,
        petId: pet.id,
        unit: selectedUnit,
        foods: foodsPayload,
      );

      if (!mounted) return;
      setState(() {
        _result = _MealPlanResult(
          amountsByFoodId: draft.amountsByFoodId,
          totalProtein: draft.totalProtein,
          totalFat: draft.totalFat,
          totalKcal: draft.totalKcal,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('คำนวณแผนอาหารสำเร็จ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('คำนวณแผนอาหารไม่สำเร็จ: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isCalculatingPlan = false;
        });
      }
    }
  }

  Future<void> _savePlan() async {
    if (!_canSave) {
      return;
    }

    final selectedUnit = _selectedUnit;
    final pet = _selectedPet;
    final result = _result;
    if (selectedUnit == null || pet == null || result == null) {
      return;
    }

    final selectedFoods = _currentSelectedFoods();
    if (selectedFoods.isEmpty) {
      return;
    }

    final foodsPayload =
        _buildFoodsPayload(
          selectedFoods: selectedFoods,
          amountsByFoodId: result.amountsByFoodId,
          unit: selectedUnit,
        )?.where((item) {
          final amount = item['amount'];
          if (amount is num) {
            return amount > 0;
          }
          return false;
        }).toList();

    if (foodsPayload == null || foodsPayload.isEmpty) {
      return;
    }

    setState(() {
      _isSavingPlan = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      await _foodApi.createFoodPlan(
        accessToken: token,
        name: _buildPlanName(pet),
        petId: pet.id,
        unit: selectedUnit,
        foods: foodsPayload,
      );

      if (!mounted) return;
      setState(() {
        _hasCreatedPlan = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกแผนอาหารสำเร็จ')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกแผนอาหารไม่สำเร็จ: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPlan = false;
        });
      }
    }
  }

  String _activityLabel(int? level) {
    switch (level) {
      case 1:
        return 'ต่ำ';
      case 2:
        return 'ปกติ';
      case 3:
        return 'สูง';
      default:
        return 'ปกติ';
    }
  }

  String _statusLabel(PetProfileData pet) {
    return pet.type.trim().isEmpty ? '-' : 'วัยเจริญพันธุ์';
  }

  String _amountText(double grams) {
    if (_selectedUnit != 1) {
      return '${grams.toStringAsFixed(2)} กรัม';
    }
    final cups = grams / 120;
    return '${cups.toStringAsFixed(2)} ถ้วยตวง';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'สร้างแผนอาหาร',
          style: TextStyle(color: AppColors.primaryBlueDark),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(index: 1, title: 'เลือกสัตว์เลี้ยง'),
                  const SizedBox(height: 10),
                  _PetSelector(
                    pets: _pets,
                    selectedIndex: _selectedPetIndex,
                    onSelect: (i) => setState(() {
                      _selectedPetIndex = i;
                      _result = null;
                      _hasCreatedPlan = false;
                    }),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedPet != null)
                    _PetSummaryCard(
                      pet: _selectedPet!,
                      activityLabel: _activityLabel(
                        _selectedPet!.activityLevel,
                      ),
                      statusLabel: _statusLabel(_selectedPet!),
                    ),
                  const SizedBox(height: 16),
                  _SectionHeader(index: 2, title: 'เลือกอาหาร'),
                  const SizedBox(height: 10),
                  _FoodGroup(
                    title: 'อาหารแห้ง',
                    subtitle: 'อาหารหลัก',
                    requiredTag: true,
                    foods: _foodsByType[0] ?? const [],
                    selectedFoodIds: _selectedFoodIds,
                    onTapFood: _toggleFood,
                  ),
                  const SizedBox(height: 12),
                  _FoodGroup(
                    title: 'อาหารเปียก',
                    subtitle: 'อาหารหลัก',
                    requiredTag: true,
                    foods: _foodsByType[1] ?? const [],
                    selectedFoodIds: _selectedFoodIds,
                    onTapFood: _toggleFood,
                  ),
                  const SizedBox(height: 12),
                  _FoodGroup(
                    title: 'ขนม',
                    subtitle: 'อาหารเสริม',
                    foods: _foodsByType[2] ?? const [],
                    selectedFoodIds: _selectedFoodIds,
                    onTapFood: _toggleFood,
                  ),
                  const SizedBox(height: 12),
                  _FoodGroup(
                    title: 'อื่นๆ',
                    subtitle: 'อาหารเสริม',
                    foods: _foodsByType[3] ?? const [],
                    selectedFoodIds: _selectedFoodIds,
                    onTapFood: _toggleFood,
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(index: 3, title: 'เลือกหน่วยวัด'),
                  const SizedBox(height: 10),
                  _UnitSelector(
                    selectedUnit: _selectedUnit,
                    onSelect: (value) => setState(() {
                      _selectedUnit = value;
                      _result = null;
                      _hasCreatedPlan = false;
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _canCalculate ? _calculate : null,
                      icon: _isCalculatingPlan
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.calculate_outlined),
                      label: Text(
                        _isCalculatingPlan
                            ? 'กำลังคำนวณแผนอาหาร...'
                            : 'คำนวณแผนอาหาร (Calculate Meal Plan)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canCalculate
                            ? AppColors.primaryBlue
                            : const Color(0xFFD0D7E2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD0D7E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_result != null)
                    _ResultSection(
                      foods: _foodsByType.values
                          .expand((e) => e)
                          .where((f) => _selectedFoodIds.contains(f.id))
                          .toList(),
                      result: _result!,
                      amountText: _amountText,
                    ),
                  if (_result != null) const SizedBox(height: 16),
                  if (_result != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canSave ? _savePlan : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD0D7E2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSavingPlan
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('บันทึกแผนอาหาร (Save Plan)'),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryBlue,
          child: Text('$index', style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlueDark,
          ),
        ),
      ],
    );
  }
}

class _PetSelector extends StatelessWidget {
  const _PetSelector({
    required this.pets,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PetProfileData> pets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return const Text('ยังไม่มีข้อมูลสัตว์เลี้ยง');
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pet = pets[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 148,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD7DEEA)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.lightBlue.shade100,
                    backgroundImage:
                        pet.imagePath == null || pet.imagePath!.isEmpty
                        ? null
                        : NetworkImage(pet.imagePath!),
                    child: pet.imagePath == null || pet.imagePath!.isEmpty
                        ? const Icon(Icons.pets, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.weightLabel,
                    style: TextStyle(
                      color: selected
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PetSummaryCard extends StatelessWidget {
  const _PetSummaryCard({
    required this.pet,
    required this.activityLabel,
    required this.statusLabel,
  });

  final PetProfileData pet;
  final String activityLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7D0FF)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'น้ำหนัก', value: pet.weightLabel),
          _SummaryRow(
            label: 'BCS Score',
            value: pet.bcs == null ? '-' : '${pet.bcs}/9',
          ),
          _SummaryRow(label: 'ระดับการเคลื่อนไหว', value: activityLabel),
          _SummaryRow(label: 'สถานะ', value: statusLabel),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryBlueDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodGroup extends StatelessWidget {
  const _FoodGroup({
    required this.title,
    required this.subtitle,
    required this.foods,
    required this.selectedFoodIds,
    required this.onTapFood,
    this.requiredTag = false,
  });

  final String title;
  final String subtitle;
  final bool requiredTag;
  final List<FoodItemSummary> foods;
  final Set<int> selectedFoodIds;
  final ValueChanged<FoodItemSummary> onTapFood;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (requiredTag)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'จำเป็น',
                  style: TextStyle(color: Color(0xFFD36BAA)),
                ),
              ),
          ],
        ),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        if (foods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('ไม่มีรายการอาหารในคลัง'),
          )
        else
          ...foods.map((food) {
            final selected = selectedFoodIds.contains(food.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onTapFood(food),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7DEEA)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFB8C2D1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${food.name} (${title.replaceAll('อาหาร', '').trim()})',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Protein ${food.protein.toStringAsFixed(0)}% • Fat ${food.fat.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white70
                                    : AppColors.textSecondary,
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
      ],
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.selectedUnit, required this.onSelect});

  final int? selectedUnit;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DEEA)),
      ),
      child: Row(
        children: [
          _UnitTab(
            selected: selectedUnit == 0,
            title: 'กรัม (g)',
            subtitle: 'Grams per day',
            onTap: () => onSelect(0),
          ),
          _UnitTab(
            selected: selectedUnit == 1,
            title: 'ถ้วยตวง (cups)',
            subtitle: 'Cups per day',
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _UnitTab extends StatelessWidget {
  const _UnitTab({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.foods,
    required this.result,
    required this.amountText,
  });

  final List<FoodItemSummary> foods;
  final _MealPlanResult result;
  final String Function(double grams) amountText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFE69AD5)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ผลลัพธ์แผนอาหาร',
                style: TextStyle(
                  fontSize: 26,
                  color: AppColors.primaryBlueDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('แก้ไขเอง'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7DEEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายการอาหาร',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primaryBlueDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...foods.map((food) {
                final grams = result.amountsByFoodId[food.id] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        amountText(grams),
                        style: const TextStyle(
                          color: AppColors.primaryBlueDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5BDE8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สรุปโภชนาการรวม',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'โปรตีนรวม',
                value: '${result.totalProtein.toStringAsFixed(2)} g',
              ),
              _SummaryRow(
                label: 'ไขมันรวม',
                value: '${result.totalFat.toStringAsFixed(2)} g',
              ),
              _SummaryRow(
                label: 'พลังงานรวม',
                value: '${result.totalKcal.toStringAsFixed(2)} kcal',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealPlanDraft {
  const _MealPlanDraft({
    required this.amountsByFoodId,
    required this.totalProtein,
    required this.totalFat,
    required this.totalKcal,
  });

  final Map<int, double> amountsByFoodId;
  final double totalProtein;
  final double totalFat;
  final double totalKcal;
}

class _MealPlanResult {
  const _MealPlanResult({
    required this.amountsByFoodId,
    required this.totalProtein,
    required this.totalFat,
    required this.totalKcal,
  });

  final Map<int, double> amountsByFoodId;
  final double totalProtein;
  final double totalFat;
  final double totalKcal;
}
