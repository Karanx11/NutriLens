import 'package:flutter/material.dart';
import '../../../core/models/product.dart';

/// A small curated catalog used to power the on-device demo experience.
/// Dates are relative to app start so "expires in N days" stays believable.
final List<ProductAnalysis> demoProducts = _build();

List<ProductAnalysis> _build() {
  final now = DateTime.now();
  return [
    ProductAnalysis(
      id: 'p-cereal',
      name: 'Choco Crunch Cereal',
      brand: 'MorningCo',
      category: 'Breakfast cereal',
      barcode: '8901234500017',
      icon: Icons.breakfast_dining,
      accent: const Color(0xFFB45309),
      nutrition: const NutritionFacts(
        calories: 384,
        protein: 6.5,
        carbs: 82,
        sugar: 34,
        fat: 4.2,
        saturatedFat: 1.8,
        fiber: 5,
        sodium: 410,
      ),
      ingredients: [
        'Whole wheat', 'Sugar', 'Cocoa powder', 'Rice flour',
        'Palm oil', 'Salt', 'Barley malt extract', 'Natural flavor',
      ],
      additives: const [
        Additive(code: 'E322', name: 'Lecithins', purpose: 'Emulsifier', concern: ConcernLevel.none),
        Additive(code: 'E150c', name: 'Ammonia caramel', purpose: 'Color', concern: ConcernLevel.moderate),
      ],
      allergens: ['Wheat', 'Barley (gluten)'],
      dietaryFlags: ['Vegetarian'],
      manufacturedOn: now.subtract(const Duration(days: 40)),
      expiresOn: now.add(const Duration(days: 140)),
      healthScore: 46,
      summary:
          'A convenient breakfast option let down by its sugar load — 34g per '
          '100g means a single bowl can cover most of a daily added-sugar '
          'budget. Whole wheat and 5g of fiber are positives, but the caramel '
          'color adds little nutritional value.',
      pros: ['Source of fiber (5g)', 'Made with whole wheat', 'Low saturated fat'],
      cons: ['Very high in sugar', 'Contains added coloring', 'High sodium for a cereal'],
      scannedAt: now,
    ),
    ProductAnalysis(
      id: 'p-cola',
      name: 'Fizz Max Cola',
      brand: 'Fizz Max',
      category: 'Carbonated drink',
      barcode: '8901234500024',
      icon: Icons.local_drink,
      accent: const Color(0xFF7C2D12),
      nutrition: const NutritionFacts(
        calories: 42,
        protein: 0,
        carbs: 10.6,
        sugar: 10.6,
        fat: 0,
        saturatedFat: 0,
        fiber: 0,
        sodium: 10,
      ),
      ingredients: [
        'Carbonated water', 'Sugar', 'Caramel color', 'Phosphoric acid',
        'Caffeine', 'Natural flavors',
      ],
      additives: const [
        Additive(code: 'E150d', name: 'Sulphite ammonia caramel', purpose: 'Color', concern: ConcernLevel.high),
        Additive(code: 'E338', name: 'Phosphoric acid', purpose: 'Acidity regulator', concern: ConcernLevel.moderate),
      ],
      allergens: [],
      dietaryFlags: ['Vegan', 'Gluten-free'],
      manufacturedOn: now.subtract(const Duration(days: 20)),
      expiresOn: now.add(const Duration(days: 200)),
      healthScore: 18,
      summary:
          'Essentially sugar water with caffeine. Every 100ml delivers ~10.6g '
          'of sugar and no nutrients. Phosphoric acid and caramel coloring are '
          'best kept occasional. There is no fiber, protein or vitamin '
          'contribution here.',
      pros: ['Fat-free', 'No allergens'],
      cons: ['All calories from sugar', 'Contains caffeine', 'High-concern caramel color', 'Zero nutritional value'],
      scannedAt: now,
    ),
    ProductAnalysis(
      id: 'p-yogurt',
      name: 'Greek Yogurt, Plain',
      brand: 'FarmField',
      category: 'Dairy',
      barcode: '8901234500031',
      icon: Icons.icecream,
      accent: const Color(0xFF0E7490),
      nutrition: const NutritionFacts(
        calories: 97,
        protein: 9,
        carbs: 3.6,
        sugar: 3.6,
        fat: 5,
        saturatedFat: 3.1,
        fiber: 0,
        sodium: 36,
      ),
      ingredients: ['Pasteurized milk', 'Live active cultures'],
      additives: const [],
      allergens: ['Milk'],
      dietaryFlags: ['Vegetarian', 'Gluten-free', 'No additives'],
      manufacturedOn: now.subtract(const Duration(days: 4)),
      expiresOn: now.add(const Duration(days: 10)),
      healthScore: 88,
      summary:
          'An excellent whole-food choice: 9g of protein per 100g, live '
          'cultures for gut health and just two clean ingredients. The only '
          'watch-out is saturated fat from full-fat milk — opt for a low-fat '
          'version if that matters for you.',
      pros: ['High in protein (9g)', 'Only 2 ingredients', 'No additives', 'Contains probiotics'],
      cons: ['Moderate saturated fat', 'Contains milk'],
      scannedAt: now,
    ),
    ProductAnalysis(
      id: 'p-noodles',
      name: 'Instant Masala Noodles',
      brand: 'QuickBite',
      category: 'Instant meal',
      barcode: '8901234500048',
      icon: Icons.ramen_dining,
      accent: const Color(0xFFB91C1C),
      nutrition: const NutritionFacts(
        calories: 448,
        protein: 9.5,
        carbs: 60,
        sugar: 4,
        fat: 18,
        saturatedFat: 8.5,
        fiber: 2.5,
        sodium: 1360,
      ),
      ingredients: [
        'Refined wheat flour', 'Palm oil', 'Salt', 'Mixed spices',
        'Hydrolyzed vegetable protein', 'Sugar', 'Acidity regulators',
      ],
      additives: const [
        Additive(code: 'E621', name: 'Monosodium glutamate', purpose: 'Flavor enhancer', concern: ConcernLevel.moderate),
        Additive(code: 'E330', name: 'Citric acid', purpose: 'Acidity regulator', concern: ConcernLevel.none),
        Additive(code: 'E110', name: 'Sunset yellow', purpose: 'Color', concern: ConcernLevel.high),
      ],
      allergens: ['Wheat (gluten)', 'Soy'],
      dietaryFlags: ['Vegetarian'],
      manufacturedOn: now.subtract(const Duration(days: 60)),
      expiresOn: now.add(const Duration(days: 120)),
      healthScore: 28,
      summary:
          'Quick and tasty, but nutritionally heavy: one serving carries a large '
          'share of a day\'s sodium (1360mg per 100g) plus 8.5g saturated fat '
          'from palm oil. MSG and Sunset Yellow are added for taste and color. '
          'Fine occasionally, not as a staple.',
      pros: ['Quick to prepare', 'Some protein (9.5g)'],
      cons: ['Very high sodium', 'High saturated fat', 'Contains high-concern coloring', 'Refined flour base'],
      scannedAt: now,
    ),
    ProductAnalysis(
      id: 'p-granola',
      name: 'Almond & Oat Granola Bar',
      brand: 'TrailKind',
      category: 'Snack bar',
      barcode: '8901234500055',
      icon: Icons.cookie,
      accent: const Color(0xFF92400E),
      nutrition: const NutritionFacts(
        calories: 412,
        protein: 10,
        carbs: 52,
        sugar: 19,
        fat: 17,
        saturatedFat: 2.4,
        fiber: 7,
        sodium: 95,
      ),
      ingredients: [
        'Rolled oats', 'Almonds', 'Honey', 'Sunflower seeds',
        'Dried cranberries', 'Sunflower oil', 'Sea salt',
      ],
      additives: const [
        Additive(code: 'E306', name: 'Tocopherol-rich extract', purpose: 'Antioxidant', concern: ConcernLevel.none),
      ],
      allergens: ['Almonds (tree nuts)'],
      dietaryFlags: ['Vegetarian'],
      manufacturedOn: now.subtract(const Duration(days: 15)),
      expiresOn: now.add(const Duration(days: 90)),
      healthScore: 68,
      summary:
          'A wholesome grab-and-go snack built on oats, almonds and seeds — 7g '
          'of fiber and 10g of protein are genuinely good. Watch the 19g of '
          'sugar, mostly from honey and cranberries. A solid choice in '
          'moderation.',
      pros: ['High fiber (7g)', 'Good protein (10g)', 'Whole-food ingredients', 'Natural antioxidant only'],
      cons: ['Fairly high in sugar', 'Energy-dense', 'Contains tree nuts'],
      scannedAt: now,
    ),
    ProductAnalysis(
      id: 'p-chips',
      name: 'Sea Salt Potato Chips',
      brand: 'CrispField',
      category: 'Snack',
      barcode: '8901234500062',
      icon: Icons.lunch_dining,
      accent: const Color(0xFFCA8A04),
      nutrition: const NutritionFacts(
        calories: 536,
        protein: 6,
        carbs: 50,
        sugar: 0.6,
        fat: 34,
        saturatedFat: 3.2,
        fiber: 4.4,
        sodium: 525,
      ),
      ingredients: ['Potatoes', 'Sunflower oil', 'Sea salt'],
      additives: const [],
      allergens: [],
      dietaryFlags: ['Vegan', 'Gluten-free', 'No additives'],
      manufacturedOn: now.subtract(const Duration(days: 10)),
      expiresOn: now.add(const Duration(days: 70)),
      healthScore: 41,
      summary:
          'A clean, three-ingredient chip with no additives — a plus over most '
          'snacks. Still, it is deep-fried and energy-dense at 536 kcal per '
          '100g with notable fat and salt. Great that there is nothing '
          'artificial; portion size is the thing to manage.',
      pros: ['Only 3 ingredients', 'No additives', 'Very low sugar'],
      cons: ['High in fat (34g)', 'Energy-dense', 'Moderately high sodium'],
      scannedAt: now,
    ),
  ];
}
