class FoodPlanSummary {
  final String planName;
  final String startDate;
  final List<FoodMealItem> mealItems;
  final FoodMacroSummary? macros;
  final List<String> performanceNotes;

  const FoodPlanSummary({
    required this.planName,
    required this.startDate,
    this.mealItems = const <FoodMealItem>[],
    this.macros,
    this.performanceNotes = const <String>[],
  });

  bool get hasPlan => planName.trim().isNotEmpty;
}

class FoodMealItem {
  final String name;
  final String subtitle;
  final String amount;
  final String percent;

  const FoodMealItem({
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.percent,
  });
}

class FoodMacroSummary {
  final String protein;
  final String fat;
  final String kcal;

  const FoodMacroSummary({
    required this.protein,
    required this.fat,
    required this.kcal,
  });
}

class FoodInventoryCounts {
  final int dry;
  final int wet;
  final int treats;
  final int supplements;

  const FoodInventoryCounts({
    this.dry = 0,
    this.wet = 0,
    this.treats = 0,
    this.supplements = 0,
  });

  int countByType(int foodType) {
    switch (foodType) {
      case 0:
        return dry;
      case 1:
        return wet;
      case 2:
        return treats;
      case 3:
        return supplements;
      default:
        return 0;
    }
  }

  FoodInventoryCounts copyWith({
    int? dry,
    int? wet,
    int? treats,
    int? supplements,
  }) {
    return FoodInventoryCounts(
      dry: dry ?? this.dry,
      wet: wet ?? this.wet,
      treats: treats ?? this.treats,
      supplements: supplements ?? this.supplements,
    );
  }
}

class FoodTypeOption {
  final int id;
  final String titleThai;
  final String titleEn;

  const FoodTypeOption({
    required this.id,
    required this.titleThai,
    required this.titleEn,
  });

  String get displayTitle => '$titleThai ($titleEn)';

  static const dry = FoodTypeOption(
    id: 0,
    titleThai: 'อาหารแห้ง',
    titleEn: 'Dry Food',
  );
  static const wet = FoodTypeOption(
    id: 1,
    titleThai: 'อาหารเปียก',
    titleEn: 'Wet Food',
  );
  static const treats = FoodTypeOption(
    id: 2,
    titleThai: 'ขนม',
    titleEn: 'Treats',
  );
  static const supplements = FoodTypeOption(
    id: 3,
    titleThai: 'อาหารเสริม',
    titleEn: 'Supplements',
  );

  static const all = <FoodTypeOption>[dry, wet, treats, supplements];

  static FoodTypeOption fromId(int id) {
    return all.firstWhere((item) => item.id == id, orElse: () => dry);
  }
}

class FoodItemSummary {
  final int id;
  final int foodType;
  final String name;
  final String brand;
  final String imageUrl;
  final int stockCount;
  final double protein;
  final double fat;
  final double moisture;
  final double energy;
  final double? gramsPerCup;

  const FoodItemSummary({
    required this.id,
    required this.foodType,
    required this.name,
    required this.brand,
    this.imageUrl = '',
    this.stockCount = 0,
    this.protein = 0,
    this.fat = 0,
    this.moisture = 0,
    this.energy = 0,
    this.gramsPerCup,
  });
}

class CreateFoodPayload {
  final int foodType;
  final String brand;
  final String name;
  final double unitGram;
  final double? gramsPerCup;
  final int stockCount;
  final double protein;
  final double fat;
  final double moisture;
  final double energy;

  const CreateFoodPayload({
    required this.foodType,
    required this.brand,
    required this.name,
    required this.unitGram,
    this.gramsPerCup,
    required this.stockCount,
    required this.protein,
    required this.fat,
    required this.moisture,
    required this.energy,
  });

  Map<String, dynamic> toJson() {
    return {
      // Primary keys expected by backend validator (Food.Type, Food.Quantity,
      // Food.Weight, Food.Moist)
      'type': foodType,
      'quantity': stockCount,
      'weight': unitGram,
      'moist': moisture,
      if (gramsPerCup != null) 'grams_per_cup': gramsPerCup,

      // Nutrition aliases
      'kcal': energy,

      // Existing aliases for compatibility with previous payload parsing
      'food_type': foodType,
      'brand': brand.trim(),
      'name': name.trim(),
      'unit_gram': unitGram,
      if (gramsPerCup != null) 'gram_per_cup': gramsPerCup,
      if (gramsPerCup != null) 'g_per_cup': gramsPerCup,
      if (gramsPerCup != null) 'gramsPerCup': gramsPerCup,
      'stock_count': stockCount,
      'protein': protein,
      'fat': fat,
      'moisture': moisture,
      'energy': energy,

      // Additional common field aliases seen in some backend structs
      'food_name': name.trim(),
      'brand_name': brand.trim(),
    };
  }
}

class OcrNutritionResult {
  final double? energy;
  final double? protein;
  final double? fat;
  final double? moisture;

  const OcrNutritionResult({
    this.energy,
    this.protein,
    this.fat,
    this.moisture,
  });
}
