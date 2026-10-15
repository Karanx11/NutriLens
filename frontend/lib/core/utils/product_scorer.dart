import 'dart:math' as math;

import '../models/product.dart';

/// Result of evaluating a product's nutrition, additives and processing.
class ScoredReport {
  final int score;
  final String summary;
  final List<String> pros;
  final List<String> cons;

  const ScoredReport({
    required this.score,
    required this.summary,
    required this.pros,
    required this.cons,
  });
}

/// Rule-based scoring and plain-language report generation for real product
/// data. Uses the Nutri-Score grade as the baseline when the data source
/// provides one, otherwise a per-100g nutrient formula, then adjusts for
/// additives of concern and ultra-processing. Thresholds follow the common
/// per-100g "traffic light" cut-offs. Nutrients listed in [missing] are
/// absent from the source record and never produce a "low X" claim.
class ProductScorer {
  const ProductScorer._();

  static const Map<String, int> _gradeBase = {
    'a': 90,
    'b': 74,
    'c': 56,
    'd': 36,
    'e': 16,
  };

  /// A graded product never drops below this: the Nutri-Score verdict is
  /// already the message, and a literal 0 reads like an error.
  static const int _gradedFloor = 5;

  static ScoredReport evaluate({
    required NutritionFacts nutrition,
    required List<Additive> additives,
    String? nutriscoreGrade,
    int? novaGroup,
    bool isBeverage = false,
    List<String> dietaryFlags = const [],
    bool containsPalmOil = false,
    Set<String> missing = const {},
  }) {
    final n = nutrition;
    final grade = nutriscoreGrade?.toLowerCase();
    final hasGrade = grade != null && _gradeBase.containsKey(grade);
    final highAdditives =
        additives.where((a) => a.concern == ConcernLevel.high).length;
    final moderateAdditives =
        additives.where((a) => a.concern == ConcernLevel.moderate).length;
    bool has(String key) => !missing.contains(key);

    // ---- score ----
    double score;
    if (hasGrade) {
      score = _gradeBase[grade]!.toDouble();
    } else {
      final sugarPenalty = math.min(35.0, n.sugar * (isBeverage ? 3.0 : 1.2));
      final satFatPenalty = math.min(20.0, n.saturatedFat * 2.2);
      final sodiumPenalty = math.min(25.0, n.sodium / 48);
      final fatPenalty =
          n.fat > 17.5 ? math.min(12.0, (n.fat - 17.5) * 0.6) : 0.0;
      final fiberBonus = math.min(10.0, n.fiber * 1.6);
      final proteinBonus = math.min(8.0, n.protein * 0.9);
      score = 100 -
          sugarPenalty -
          satFatPenalty -
          sodiumPenalty -
          fatPenalty +
          fiberBonus +
          proteinBonus;
    }
    score -= math.min(18.0, highAdditives * 6.0 + moderateAdditives * 3.0);
    if (novaGroup == 4) score -= 5;
    if (hasGrade) score = math.max(score, _gradedFloor.toDouble());
    final finalScore = score.clamp(0, 100).round();

    // ---- pros ----
    final pros = <String>[];
    if (grade == 'a' || grade == 'b') {
      pros.add('Nutri-Score ${grade!.toUpperCase()}');
    }
    if (has('protein') && n.protein >= 8) {
      pros.add('Good source of protein (${_g(n.protein)}g)');
    }
    if (has('fiber')) {
      if (n.fiber >= 6) {
        pros.add('High in fiber (${_g(n.fiber)}g)');
      } else if (n.fiber >= 3) {
        pros.add('Source of fiber (${_g(n.fiber)}g)');
      }
    }
    if (has('sugar') && n.sugar <= 5) pros.add('Low sugar');
    if (has('saturatedFat') && n.saturatedFat <= 1.5) {
      pros.add('Low saturated fat');
    }
    if (has('sodium') && n.sodium <= 120) pros.add('Low sodium');
    if (additives.isEmpty) pros.add('No additives listed');
    if (dietaryFlags.contains('Vegan')) {
      pros.add('Vegan');
    } else if (dietaryFlags.contains('Vegetarian')) {
      pros.add('Vegetarian');
    }
    if (novaGroup == 1) pros.add('Unprocessed or minimally processed');

    // ---- cons ----
    final cons = <String>[];
    if (grade == 'd' || grade == 'e') {
      cons.add('Nutri-Score ${grade!.toUpperCase()}');
    }
    if (n.sugar >= 22.5) {
      cons.add('High in sugar (${_g(n.sugar)}g per 100g)');
    } else if (n.sugar >= 12.5) {
      cons.add('Fairly high in sugar (${_g(n.sugar)}g per 100g)');
    }
    if (n.saturatedFat >= 5) {
      cons.add('High saturated fat (${_g(n.saturatedFat)}g per 100g)');
    }
    if (n.sodium >= 600) {
      cons.add('High sodium (${n.sodium.round()} mg per 100g)');
    } else if (n.sodium >= 300) {
      cons.add('Moderately high sodium (${n.sodium.round()} mg per 100g)');
    }
    if (n.fat >= 17.5) cons.add('High in fat (${_g(n.fat)}g per 100g)');
    if (highAdditives > 0) {
      final plural = highAdditives == 1 ? '' : 's';
      cons.add('$highAdditives additive$plural of high concern');
    }
    if (moderateAdditives > 0) {
      final plural = moderateAdditives == 1 ? '' : 's';
      cons.add('$moderateAdditives additive$plural of moderate concern');
    }
    if (containsPalmOil) cons.add('Contains palm oil');
    if (novaGroup == 4) cons.add('Ultra-processed (NOVA group 4)');

    // ---- summary ----
    final parts = <String>[];
    if (hasGrade) {
      parts.add('Nutri-Score ${grade.toUpperCase()} — ${_gradeMeaning(grade)}.');
    } else {
      parts.add('No Nutri-Score is available for this product, so the score '
          'is estimated from its nutrients per 100g.');
    }
    if (novaGroup != null) parts.add(_novaMeaning(novaGroup));
    final watch = cons.where((c) => !c.startsWith('Nutri-Score')).take(3);
    if (watch.isNotEmpty) {
      parts.add('Watch out for: ${watch.map(_lower).join(', ')}.');
    }
    final plus = pros.where((p) => !p.startsWith('Nutri-Score')).take(2);
    if (plus.isNotEmpty) {
      parts.add('On the plus side: ${plus.map(_lower).join(', ')}.');
    }
    if (missing.isNotEmpty) {
      parts.add('Some nutrient values are missing from the source record.');
    }

    return ScoredReport(
      score: finalScore,
      summary: parts.join(' '),
      pros: pros,
      cons: cons,
    );
  }

  static String _g(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static String _lower(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  static String _gradeMeaning(String g) => switch (g) {
        'a' => 'among the most favourable nutritional profiles',
        'b' => 'a good nutritional profile',
        'c' => 'an average nutritional profile',
        'd' => 'a poor nutritional profile',
        _ => 'among the least favourable nutritional profiles',
      };

  static String _novaMeaning(int nova) => switch (nova) {
        1 => 'Unprocessed or minimally processed (NOVA group 1).',
        2 => 'A processed culinary ingredient (NOVA group 2).',
        3 => 'A processed food (NOVA group 3).',
        _ => 'Ultra-processed (NOVA group 4).',
      };
}
