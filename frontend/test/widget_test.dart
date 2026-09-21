// Smoke tests for NutriLens.
//
// These avoid the full app boot (which starts timers and touches platform
// plugins) and instead exercise pure logic and a leaf widget, so they run
// reliably in CI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/models/product.dart';
import 'package:frontend/core/widgets/score_ring.dart';
import 'package:frontend/features/scanner/data/demo_products.dart';

ProductAnalysis _withScore(int score) => ProductAnalysis(
      id: 't',
      name: 'Test',
      brand: 'Brand',
      category: 'Cat',
      barcode: '000',
      icon: Icons.fastfood,
      accent: const Color(0xFF16A34A),
      nutrition: const NutritionFacts(
        calories: 0,
        protein: 0,
        carbs: 0,
        sugar: 0,
        fat: 0,
        saturatedFat: 0,
        fiber: 0,
        sodium: 0,
      ),
      ingredients: const [],
      additives: const [],
      allergens: const [],
      dietaryFlags: const [],
      manufacturedOn: null,
      expiresOn: null,
      healthScore: score,
      summary: '',
      pros: const [],
      cons: const [],
      scannedAt: DateTime(2025),
    );

void main() {
  test('health score maps to the correct rating band', () {
    expect(_withScore(90).rating, 'Excellent');
    expect(_withScore(65).rating, 'Good');
    expect(_withScore(45).rating, 'Fair');
    expect(_withScore(25).rating, 'Poor');
    expect(_withScore(10).rating, 'Avoid');
  });

  test('demo catalog is populated and well-formed', () {
    expect(demoProducts.length, greaterThan(3));
    for (final p in demoProducts) {
      expect(p.name, isNotEmpty);
      expect(p.healthScore, inInclusiveRange(0, 100));
      expect(p.ingredients, isNotEmpty);
    }
  });

  testWidgets('ScoreRing renders its animated value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ScoreRing(score: 88, color: Color(0xFF16A34A)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('88'), findsOneWidget);
  });
}
