import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/data/models/food_plan_models.dart';
import 'package:well_paw/features/food/data/services/food_plan_api_service.dart';
import 'package:well_paw/features/food/presentation/pages/create_meal_plan_page.dart';
import 'package:well_paw/features/food/presentation/pages/food_type_list_page.dart';
import 'package:well_paw/features/food/presentation/pages/manual_add_food_page.dart';
import 'package:well_paw/features/food/presentation/pages/scan_label_page.dart';
import 'package:well_paw/features/health/presentation/pages/health_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';
import 'package:well_paw/features/profile/data/services/pet_api_service.dart';
import 'package:well_paw/features/profile/presentation/pages/create_pet_profile_page.dart';
import 'package:well_paw/features/profile/presentation/pages/profile_page.dart';
import 'package:well_paw/features/activity/presentation/pages/activity_page.dart';

class FoodHomePage extends StatefulWidget {
  const FoodHomePage({super.key, this.initialPetId});

  final int? initialPetId;

  @override
  State<FoodHomePage> createState() => _FoodHomePageState();
}

class _FoodHomePageState extends State<FoodHomePage> {
  final _tokenStorage = const TokenStorage();
  final _petApi = PetApiService();
  final _foodApi = FoodPlanApiService();

  bool _isLoadingPets = true;
  bool _isLoadingPlan = false;
  bool _isLoadingInventory = false;
  String? _error;
  List<PetProfileData> _pets = const [];
  int _selectedPetIndex = 0;
  FoodPlanSummary? _currentPlan;
  FoodInventoryCounts _inventoryCounts = const FoodInventoryCounts();

  PetProfileData? get _selectedPet {
    if (_pets.isEmpty ||
        _selectedPetIndex < 0 ||
        _selectedPetIndex >= _pets.length) {
      return null;
    }
    return _pets[_selectedPetIndex];
  }

  @override
  void initState() {
    super.initState();
    _loadPetsAndPlan();
  }

  Future<void> _loadPetsAndPlan() async {
    if (!AppConfig.hasValidApiBaseUrl) {
      setState(() {
        _isLoadingPets = false;
        _error = 'กรุณาตั้งค่า API Base URL ก่อนใช้งาน';
      });
      return;
    }

    setState(() {
      _isLoadingPets = true;
      _error = null;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final pets = await _petApi.fetchMyPets(accessToken: token);
      if (!mounted) return;

      var selectedIndex = 0;
      if (widget.initialPetId != null) {
        final foundIndex = pets.indexWhere(
          (pet) => pet.id == widget.initialPetId,
        );
        if (foundIndex >= 0) {
          selectedIndex = foundIndex;
        }
      }

      setState(() {
        _pets = pets;
        _selectedPetIndex = selectedIndex;
        _isLoadingPets = false;
      });

      await _loadFoodInventory();
      await _loadFoodPlan();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingPets = false;
        _error = 'โหลดข้อมูลไม่สำเร็จ: $error';
      });
    }
  }

  Future<void> _loadFoodInventory() async {
    setState(() {
      _isLoadingInventory = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final counts = await _foodApi.fetchFoodInventoryCounts(
        accessToken: token,
      );
      if (!mounted) return;

      setState(() {
        _inventoryCounts = counts;
      });
    } catch (_) {
      // Keep UI usable with default 0 counts when inventory endpoint fails.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInventory = false;
        });
      }
    }
  }

  Future<void> _loadFoodPlan() async {
    final selected = _selectedPet;
    if (selected == null) {
      setState(() {
        _currentPlan = null;
      });
      return;
    }

    setState(() {
      _isLoadingPlan = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final plan = await _foodApi.fetchFoodPlan(
        accessToken: token,
        petId: selected.id,
      );

      if (!mounted) return;
      setState(() {
        _currentPlan = plan;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentPlan = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlan = false;
        });
      }
    }
  }

  String _displayPlanName() {
    if (_currentPlan != null && _currentPlan!.planName.trim().isNotEmpty) {
      return _currentPlan!.planName.trim();
    }
    return 'Adult Cat Weight Control';
  }

  String _displayPlanStartDate() {
    final fromApi = _currentPlan?.startDate ?? '';
    if (fromApi.isNotEmpty) {
      return 'เริ่มใช้งาน: $fromApi';
    }
    return 'เริ่มใช้งาน: 1 ก.ค. 2567';
  }

  List<FoodMealItem> _displayMealItems() {
    final fromApi = _currentPlan?.mealItems ?? const <FoodMealItem>[];
    if (fromApi.isNotEmpty) {
      return fromApi.take(2).toList();
    }

    return const <FoodMealItem>[
      FoodMealItem(
        name: "Hill's Science Diet",
        subtitle: 'Adult Dry Food',
        amount: '80g',
        percent: '62%',
      ),
      FoodMealItem(
        name: 'Boiled Chicken',
        subtitle: 'Fresh Protein',
        amount: '50g',
        percent: '38%',
      ),
    ];
  }

  FoodMacroSummary _displayMacros() {
    return _currentPlan?.macros ??
        const FoodMacroSummary(protein: '28g', fat: '12g', kcal: '340');
  }

  List<String> _displayPerformanceNotes() {
    final fromApi = _currentPlan?.performanceNotes ?? const <String>[];
    if (fromApi.isNotEmpty) {
      return fromApi.take(2).toList();
    }

    return const <String>[
      'น้ำหนักคงที่และเหมาะสม ตามเป้าหมายของแผนอาหาร',
      'สมส่วนร่างกายคงที่ที่ 5/9 (เหมาะสม) แผนอาหารดีมาก',
    ];
  }

  Future<void> _openFoodTypeList(int foodType) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodTypeListPage(foodType: foodType)),
    );
    if (!mounted) {
      return;
    }
    _loadFoodInventory();
  }

  Future<void> _openManualAdd() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ManualAddFoodPage()));
    if (saved == true && mounted) {
      _loadFoodInventory();
    }
  }

  Future<void> _openScanLabel() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ScanLabelPage()));
    if (saved == true && mounted) {
      _loadFoodInventory();
    }
  }

  Future<void> _openCreateMealPlan() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateMealPlanPage(initialPetId: _selectedPet?.id),
      ),
    );
    if (saved == true && mounted) {
      _loadFoodPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNoPetState = !_isLoadingPets && _error == null && _pets.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: _isLoadingPets
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : isNoPetState
          ? _NoPetReadyState(
              onAddPet: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreatePetProfilePage(),
                  ),
                );
                if (mounted) {
                  _loadPetsAndPlan();
                }
              },
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FoodHeader(
                    pets: _pets,
                    selectedIndex: _selectedPetIndex,
                    onSelect: (index) {
                      setState(() {
                        _selectedPetIndex = index;
                      });
                      _loadFoodPlan();
                    },
                  ),
                  const SizedBox(height: 88),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'แผนอาหารปัจจุบัน',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlueDark,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _openCreateMealPlan,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('แก้ไข'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(color: Color(0xFFD7DEE8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CurrentPlanCard(
                      planName: _displayPlanName(),
                      startDate: _displayPlanStartDate(),
                      mealItems: _displayMealItems(),
                      macros: _displayMacros(),
                      performanceNotes: _displayPerformanceNotes(),
                      isLoading: _isLoadingPlan,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PrimaryActionButton(
                      text: 'สร้างแผนใหม่ (Create New Plan)',
                      icon: Icons.add,
                      onPressed: _openCreateMealPlan,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _InventorySection(
                      counts: _inventoryCounts,
                      isLoading: _isLoadingInventory,
                      onTapType: _openFoodTypeList,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PrimaryActionButton(
                      text: 'สแกนฉลาก (Scan Label)',
                      icon: Icons.crop_free,
                      isPink: true,
                      onPressed: _openScanLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PrimaryActionButton(
                      text: 'เพิ่มอาหารด้วยตนเอง (Manual Add)',
                      icon: Icons.add,
                      isOutlined: true,
                      onPressed: _openManualAdd,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: _FoodBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HealthPage()),
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

class _NoPetReadyState extends StatelessWidget {
  const _NoPetReadyState({required this.onAddPet});

  final VoidCallback onAddPet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 52,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            const Text(
              'ระบบยังไม่พร้อมใช้งาน กรุณาเพิ่มสัตว์เลี้ยงก่อน',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlueDark,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddPet,
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มสัตว์เลี้ยง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodHeader extends StatelessWidget {
  const _FoodHeader({
    required this.pets,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PetProfileData> pets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 168,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF3E68B2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'อาหาร',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Food & Nutrition',
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                child: Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -72,
          child: SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = index == selectedIndex;
                return _PetAvatarChip(
                  name: pet.name,
                  imageUrl: pet.imagePath,
                  isSelected: isSelected,
                  showAlert: pet.bcs == null,
                  onTap: () => onSelect(index),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: pets.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _PetAvatarChip extends StatelessWidget {
  const _PetAvatarChip({
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.showAlert,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool isSelected;
  final bool showAlert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4EA0FF)
                        : const Color(0xFFE0E7F0),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: imageUrl == null
                      ? Container(
                          color: const Color(0xFFD6E1EF),
                          child: const Icon(
                            Icons.pets,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFD6E1EF),
                            child: const Icon(
                              Icons.pets,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                ),
              ),
              if (showAlert)
                Positioned(
                  top: -3,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 62,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? const Color(0xFFE895D0)
                    : const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.planName,
    required this.startDate,
    required this.mealItems,
    required this.macros,
    required this.performanceNotes,
    required this.isLoading,
  });

  final String planName;
  final String startDate;
  final List<FoodMealItem> mealItems;
  final FoodMacroSummary macros;
  final List<String> performanceNotes;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F6DB9), Color(0xFF5F8BD2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'แผนอาหารปัจจุบัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.monitor_heart_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Current Meal Plan',
                  style: TextStyle(color: Color(0xFFE5EDFA), fontSize: 18),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  startDate,
                                  style: const TextStyle(
                                    color: Color(0xFFE8EFFA),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var i = 0; i < mealItems.length; i++) ...[
                  _FoodItemRow(
                    title: mealItems[i].name,
                    subtitle: mealItems[i].subtitle,
                    amount: mealItems[i].amount,
                    percent: mealItems[i].percent,
                    dotColor: i.isEven
                        ? const Color(0xFF4E7BC8)
                        : const Color(0xFFE8A5D8),
                  ),
                  if (i < mealItems.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MacroTile(
                        icon: Icons.bubble_chart,
                        value: macros.protein.isEmpty ? '-' : macros.protein,
                        label: 'โปรตีน',
                        color: const Color(0xFFFCE6E9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroTile(
                        icon: Icons.water_drop_outlined,
                        value: macros.fat.isEmpty ? '-' : macros.fat,
                        label: 'ไขมัน',
                        color: const Color(0xFFFFF1DD),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroTile(
                        icon: Icons.local_fire_department_outlined,
                        value: macros.kcal.isEmpty ? '-' : macros.kcal,
                        label: 'kcal',
                        color: const Color(0xFFE7F6E8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PerformanceTile(notes: performanceNotes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemRow extends StatelessWidget {
  const _FoodItemRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.percent,
    required this.dotColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String percent;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlueDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlueDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    percent,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: Icon(icon, size: 17, color: AppColors.primaryBlueDark),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlueDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTile extends StatelessWidget {
  const _PerformanceTile({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ผลประสิทธิภาพของแผน',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlueDark,
            ),
          ),
          const SizedBox(height: 10),
          ...notes.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == notes.length - 1 ? 0 : 8,
              ),
              child: Text(
                '✓ ${entry.value}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({
    required this.counts,
    required this.isLoading,
    required this.onTapType,
  });

  final FoodInventoryCounts counts;
  final bool isLoading;
  final ValueChanged<int> onTapType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'คลังอาหาร (Inventory)',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlueDark,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(minHeight: 4),
            ),
          ],
          _InventoryTile(
            icon: Icons.lunch_dining_outlined,
            title: 'อาหารแห้ง (Dry Food)',
            count: '${counts.dry} รายการ',
            bgColor: Color(0xFFE8EFFA),
            onTap: () => onTapType(0),
          ),
          const SizedBox(height: 10),
          _InventoryTile(
            icon: Icons.opacity_outlined,
            title: 'อาหารเปียก (Wet Food)',
            count: '${counts.wet} รายการ',
            bgColor: Color(0xFFFCE6F6),
            onTap: () => onTapType(1),
          ),
          const SizedBox(height: 10),
          _InventoryTile(
            icon: Icons.medication_outlined,
            title: 'อาหารเสริม (Supplements)',
            count: '${counts.supplements} รายการ',
            bgColor: Color(0xFFFFF2DD),
            onTap: () => onTapType(3),
          ),
          const SizedBox(height: 10),
          _InventoryTile(
            icon: Icons.cookie_outlined,
            title: 'ขนม (Treats)',
            count: '${counts.treats} รายการ',
            bgColor: Color(0xFFF4E7FA),
            onTap: () => onTapType(2),
          ),
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String count;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryBlueDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isOutlined = false,
    this.isPink = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isPink;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : isPink
              ? const Color(0xFFE79CD8)
              : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: AppColors.primaryBlue) : null,
          boxShadow: [
            if (!isOutlined)
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOutlined ? AppColors.primaryBlue : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isOutlined ? AppColors.primaryBlue : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodBottomNav extends StatelessWidget {
  const _FoodBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _FoodNavItem(label: 'Home', assetPath: 'assets/icons/home.png'),
    _FoodNavItem(label: 'Food', assetPath: 'assets/icons/food.png'),
    _FoodNavItem(label: 'Health', assetPath: 'assets/icons/health.png'),
    _FoodNavItem(label: 'Calendar', assetPath: 'assets/icons/calendar.png'),
    _FoodNavItem(label: 'Profile', assetPath: 'assets/icons/profile.png'),
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

class _FoodNavItem {
  const _FoodNavItem({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}
