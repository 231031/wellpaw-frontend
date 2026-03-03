import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/data/models/food_plan_models.dart';
import 'package:well_paw/features/food/data/services/food_plan_api_service.dart';
import 'package:well_paw/features/food/presentation/pages/food_detail_page.dart';
import 'package:well_paw/features/food/presentation/pages/manual_add_food_page.dart';

class FoodTypeListPage extends StatefulWidget {
  const FoodTypeListPage({super.key, required this.foodType});

  final int foodType;

  @override
  State<FoodTypeListPage> createState() => _FoodTypeListPageState();
}

class _FoodTypeListPageState extends State<FoodTypeListPage> {
  final _tokenStorage = const TokenStorage();
  final _foodApi = FoodPlanApiService();

  bool _isLoading = true;
  String? _error;
  List<FoodItemSummary> _items = const [];

  FoodTypeOption get _foodType => FoodTypeOption.fromId(widget.foodType);

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

      final items = await _foodApi.fetchFoodItemsByType(
        accessToken: token,
        foodType: widget.foodType,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _openAddFood() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManualAddFoodPage(initialFoodType: widget.foodType),
      ),
    );

    if (changed == true && mounted) {
      _load();
    }
  }

  Future<void> _openFoodDetail(FoodItemSummary item) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => FoodDetailPage(item: item)));

    if (changed == true && mounted) {
      _load();
    }
  }

  String _percentText(double value) {
    return value % 1 == 0
        ? '${value.toInt()}%'
        : '${value.toStringAsFixed(1)}%';
  }

  IconData _typeIcon(int typeId) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          _foodType.displayTitle,
          style: const TextStyle(color: AppColors.primaryBlueDark),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8B5DF),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: _openAddFood,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _typeIcon(widget.foodType),
                      size: 48,
                      color: Color(0xFF8FA1BE),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ยังไม่มีรายการ${_foodType.titleThai}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openAddFood,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มอาหาร'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openFoodDetail(item),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD9DFEA)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: item.imageUrl.isEmpty
                              ? Container(
                                  width: 84,
                                  height: 84,
                                  color: const Color(0xFFE7ECF4),
                                  child: Icon(
                                    _typeIcon(widget.foodType),
                                    color: Color(0xFF8FA1BE),
                                  ),
                                )
                              : Image.network(
                                  item.imageUrl,
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 84,
                                    height: 84,
                                    color: const Color(0xFFE7ECF4),
                                    child: Icon(
                                      _typeIcon(widget.foodType),
                                      color: Color(0xFF8FA1BE),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.isEmpty ? '-' : item.name,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.brand.isEmpty ? '-' : item.brand,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'โปรตีน\n${_percentText(item.protein)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'ไขมัน\n${_percentText(item.fat)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.stockCount} หน่วย',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9AA4B2),
                          size: 22,
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
