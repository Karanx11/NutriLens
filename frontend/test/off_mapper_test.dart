import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/models/product.dart';
import 'package:frontend/core/services/open_food_facts_service.dart';

void main() {
  test('maps a record that only has "as prepared" nutrients (Maggi)', () {
    final product = OffProductMapper.toAnalysis({
      'code': '8901058000290',
      'product_name': 'maggi',
      'brands': 'Nestlé',
      'categories': 'Instant noodles, Instant Noodles with Seasoning',
      'ingredients_text':
          'NOODLES: Refined wheat flour (Maida), Palm oil, Iodized salt, '
              'Wheat gluten, Thickeners (508 & 412). Acidity regulators '
              '(501(i) & 500(i)) and Humectant (451(i)). MASALA TASTEMAKER®: '
              'Mixed spices (25.6%) (Onion powder, Coriander powder, '
              'Turmeric powder)',
      'additives_tags': ['en:e150d', 'en:e330', 'en:e621'],
      'allergens_tags': ['en:gluten'],
      'traces_tags': ['en:milk'],
      'ingredients_analysis_tags': ['en:palm-oil', 'en:vegetarian'],
      'nutriscore_grade': 'e',
      'nova_group': 4,
      'image_front_small_url': 'https://example.com/maggi.jpg',
      'nutriments': {
        'energy-kcal_prepared_100g': 384,
        'proteins_prepared_100g': 8.2,
        'carbohydrates_prepared_100g': 59.6,
        'sugars_prepared_100g': 1.8,
        'fat_prepared_100g': 12.5,
        'saturated-fat_prepared_100g': 8.2,
        'salt_prepared_100g': 2.0,
      },
    });

    expect(product.name, 'Maggi');
    expect(product.brand, 'Nestlé');
    expect(product.category, 'Instant Noodles with Seasoning');
    expect(product.nutrition.calories, 384);
    expect(product.nutrition.saturatedFat, 8.2);
    // 2 g salt per 100 g -> 800 mg sodium.
    expect(product.nutrition.sodium, closeTo(800, 0.01));
    // Fiber is absent from the record: flagged, not shown as 0.
    expect(product.missingNutrients, unorderedEquals(['fiber']));
    expect(product.nutritionBasis, 'per 100 g as prepared');
    expect(product.pros, isNot(contains(startsWith('Source of fiber'))));

    expect(product.additives.map((a) => a.code), ['E150d', 'E330', 'E621']);
    expect(product.additives.first.concern, ConcernLevel.high);
    expect(product.allergens, ['Gluten', 'May contain milk']);
    expect(product.dietaryFlags, ['Vegetarian']);
    expect(product.imageUrl, 'https://example.com/maggi.jpg');
    expect(product.dataSource, 'Open Food Facts');

    // Section labels dropped, nothing lost around sentence breaks / "and",
    // and long compound items expanded into parent + sub-ingredients.
    expect(
      product.ingredients,
      containsAll([
        'Refined wheat flour (Maida)',
        'Palm oil',
        'Iodized salt',
        'Wheat gluten',
        'Thickeners (508 & 412)',
        'Acidity regulators (501(i) & 500(i))',
        'Humectant (451(i))',
        'Mixed spices (25.6%)',
        'Onion powder',
        'Turmeric powder',
      ]),
    );
    expect(
      product.ingredients.where(
        (i) => i.startsWith('(') || i.contains('NOODLES') || i.contains(':'),
      ),
      isEmpty,
    );

    // Nutri-Score E with additive and NOVA penalties: "Avoid", but floored
    // so it never reads as a broken 0.
    expect(product.healthScore, greaterThanOrEqualTo(5));
    expect(product.healthScore, lessThan(20));
    expect(product.cons, contains('Contains palm oil'));
    expect(product.cons, contains('Ultra-processed (NOVA group 4)'));
    expect(product.summary, contains('Nutri-Score E'));
    expect(product.summary, contains('missing from the source record'));
  });

  test('cleans HTML entities and keeps sub-ingredients of nested lists', () {
    final product = OffProductMapper.toAnalysis({
      'code': '8901491101837',
      'product_name': 'Lays Classics Salted',
      'brands': "Lay's",
      'ingredients_text':
          'Potato, Edible Vegetable Oil\n\n(Palmolein Oil), &quot;Seasoning '
              '(Maltodextrin, Iodised Salt, Sugar, Flavour (Natural and Nature '
              'Identical Flavouring Substances), Anticaking Agent (551), '
              'Flavour Enhancers (627, 631))',
      'additives_tags': ['en:e551', 'en:e627', 'en:e631'],
      'nutriscore_grade': 'd',
      'nova_group': 4,
      'nutriments': {
        'energy-kcal_100g': 554,
        'proteins_100g': 7,
        'carbohydrates_100g': 51.7,
        'sugars_100g': 2.6,
        'fat_100g': 35.5,
        'saturated-fat_100g': 14,
        'fiber_100g': 0,
        'sodium_100g': 0.204,
      },
    });

    expect(
      product.ingredients,
      containsAll([
        'Potato',
        'Edible Vegetable Oil (Palmolein Oil)',
        'Seasoning',
        'Maltodextrin',
        'Sugar',
        'Anticaking Agent (551)',
        'Flavour Enhancers (627, 631)',
      ]),
    );
    expect(
      product.ingredients.any((i) => i.contains('&quot;') || i.contains('\n')),
      isFalse,
    );
    expect(product.nutritionBasis, 'per 100 g');
    expect(product.missingNutrients, isEmpty);
    expect(product.nutrition.sodium, closeTo(204, 0.01));
    // D (36) - two moderate additives (6) - NOVA 4 (5) = 25.
    expect(product.healthScore, 25);
  });

  test('falls back to a nutrient formula when Nutri-Score is missing', () {
    final product = OffProductMapper.toAnalysis({
      'code': '0000000000000',
      'product_name': 'plain yogurt',
      'nutriments': {
        'proteins_100g': 9,
        'sugars_100g': 3.6,
        'fat_100g': 5,
        'saturated-fat_100g': 3.1,
        'sodium_100g': 0.036,
      },
    });

    expect(product.name, 'Plain yogurt');
    expect(product.nutrition.sodium, closeTo(36, 0.01));
    expect(product.nutritionBasis, 'per 100 g');
    expect(product.missingNutrients, unorderedEquals(['calories', 'carbs', 'fiber']));
    expect(product.healthScore, greaterThanOrEqualTo(60));
    expect(product.summary, contains('No Nutri-Score'));
    expect(product.additives, isEmpty);
    expect(product.pros, contains('No additives listed'));
  });
}
