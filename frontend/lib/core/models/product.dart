import 'package:flutter/material.dart';
import '../utils/score_utils.dart';

/// How much concern an additive raises, driving its badge color.
enum ConcernLevel { none, low, moderate, high }

extension ConcernLevelX on ConcernLevel {
  String get label => switch (this) {
        ConcernLevel.none => 'Safe',
        ConcernLevel.low => 'Low',
        ConcernLevel.moderate => 'Moderate',
        ConcernLevel.high => 'High concern',
      };

  Color get color => switch (this) {
        ConcernLevel.none => const Color(0xFF22C55E),
        ConcernLevel.low => const Color(0xFF84CC16),
        ConcernLevel.moderate => const Color(0xFFF59E0B),
        ConcernLevel.high => const Color(0xFFDC2626),
      };
}

class Additive {
  final String code; // e.g. E211
  final String name; // Sodium benzoate
  final String purpose; // Preservative
  final ConcernLevel concern;

  const Additive({
    required this.code,
    required this.name,
    required this.purpose,
    required this.concern,
  });

  factory Additive.fromJson(Map<String, dynamic> json) => Additive(
        code: (json['code'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        purpose: (json['purpose'] ?? '') as String,
        concern: ConcernLevel.values.firstWhere(
          (c) => c.name == json['concern'],
          orElse: () => ConcernLevel.low,
        ),
      );
}

class NutritionFacts {
  final double servingSize; // grams that the values below are stated per
  final double calories; // kcal
  final double protein; // g
  final double carbs; // g
  final double sugar; // g
  final double fat; // g
  final double saturatedFat; // g
  final double fiber; // g
  final double sodium; // mg

  const NutritionFacts({
    this.servingSize = 100,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.sugar,
    required this.fat,
    required this.saturatedFat,
    required this.fiber,
    required this.sodium,
  });

  factory NutritionFacts.fromJson(Map<String, dynamic> json) => NutritionFacts(
        servingSize: (json['servingSize'] ?? 100).toDouble(),
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        sugar: (json['sugar'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        saturatedFat: (json['saturatedFat'] ?? 0).toDouble(),
        fiber: (json['fiber'] ?? 0).toDouble(),
        sodium: (json['sodium'] ?? 0).toDouble(),
      );
}

class ProductAnalysis {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String barcode;
  final IconData icon;
  final Color accent;
  final NutritionFacts nutrition;
  final List<String> ingredients;
  final List<Additive> additives;
  final List<String> allergens;
  final List<String> dietaryFlags; // Vegetarian, Vegan, Gluten-free, ...
  final DateTime? manufacturedOn;
  final DateTime? expiresOn;
  final int healthScore; // 0 - 100
  final String summary; // AI-generated analysis paragraph
  final List<String> pros;
  final List<String> cons;
  final DateTime scannedAt;

  const ProductAnalysis({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.barcode,
    required this.icon,
    required this.accent,
    required this.nutrition,
    required this.ingredients,
    required this.additives,
    required this.allergens,
    required this.dietaryFlags,
    required this.manufacturedOn,
    required this.expiresOn,
    required this.healthScore,
    required this.summary,
    required this.pros,
    required this.cons,
    required this.scannedAt,
  });

  String get rating => ScoreUtils.rating(healthScore);

  Color get scoreColor => ScoreUtils.color(healthScore);

  /// Language-free verdict for the score (see [ScoreUtils.emoji]).
  String get emoji => ScoreUtils.emoji(healthScore);

  bool get isExpired =>
      expiresOn != null && expiresOn!.isBefore(DateTime.now());

  int? get daysToExpiry =>
      expiresOn?.difference(DateTime.now()).inDays;

  ProductAnalysis copyWith({DateTime? scannedAt}) => ProductAnalysis(
        id: id,
        name: name,
        brand: brand,
        category: category,
        barcode: barcode,
        icon: icon,
        accent: accent,
        nutrition: nutrition,
        ingredients: ingredients,
        additives: additives,
        allergens: allergens,
        dietaryFlags: dietaryFlags,
        manufacturedOn: manufacturedOn,
        expiresOn: expiresOn,
        healthScore: healthScore,
        summary: summary,
        pros: pros,
        cons: cons,
        scannedAt: scannedAt ?? this.scannedAt,
      );

  /// Best-effort parsing for when a real backend is wired up. Icon/accent are
  /// presentation-only and fall back to sensible defaults.
  factory ProductAnalysis.fromJson(Map<String, dynamic> json) =>
      ProductAnalysis(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? 'Unknown product') as String,
        brand: (json['brand'] ?? '') as String,
        category: (json['category'] ?? '') as String,
        barcode: (json['barcode'] ?? '') as String,
        icon: Icons.fastfood,
        accent: const Color(0xFF16A34A),
        nutrition: NutritionFacts.fromJson(
          (json['nutrition'] ?? const {}) as Map<String, dynamic>,
        ),
        ingredients: List<String>.from(json['ingredients'] ?? const []),
        additives: ((json['additives'] ?? const []) as List)
            .map((e) => Additive.fromJson(e as Map<String, dynamic>))
            .toList(),
        allergens: List<String>.from(json['allergens'] ?? const []),
        dietaryFlags: List<String>.from(json['dietaryFlags'] ?? const []),
        manufacturedOn: DateTime.tryParse('${json['manufacturedOn'] ?? ''}'),
        expiresOn: DateTime.tryParse('${json['expiresOn'] ?? ''}'),
        healthScore: (json['healthScore'] ?? 0) as int,
        summary: (json['summary'] ?? '') as String,
        pros: List<String>.from(json['pros'] ?? const []),
        cons: List<String>.from(json['cons'] ?? const []),
        scannedAt: DateTime.now(),
      );
}
