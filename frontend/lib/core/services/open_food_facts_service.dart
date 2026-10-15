import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/additives_db.dart';
import '../models/product.dart';
import '../utils/product_scorer.dart';

/// Looks up scanned barcodes in the public Open Food Facts database
/// (https://world.openfoodfacts.org, data licensed under the ODbL).
class OpenFoodFactsService {
  static const String source = 'Open Food Facts';

  static const String _fields =
      'code,product_name,product_name_en,brands,categories,categories_tags,'
      'ingredients_text,ingredients_text_en,additives_tags,allergens_tags,'
      'traces_tags,ingredients_analysis_tags,nutriscore_grade,nova_group,'
      'image_front_small_url,image_front_url,nutriments';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://world.openfoodfacts.org',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'User-Agent':
            'NutriLens/1.0 (Flutter; https://github.com/Karanx11/NutriLens)',
      },
      // Unknown products answer 404 with a JSON body; treat that as "not
      // found" rather than an error.
      validateStatus: (status) => status == 200 || status == 404,
    ),
  );

  /// Returns null when the barcode is not in the database. Throws a
  /// [DioException] on network failures.
  Future<ProductAnalysis?> lookup(String barcode) async {
    final response = await _dio.get(
      '/api/v2/product/$barcode.json',
      queryParameters: {'fields': _fields},
    );
    final data = response.data;
    if (data is! Map || data['status'] != 1 || data['product'] is! Map) {
      return null;
    }
    return OffProductMapper.toAnalysis(
      Map<String, dynamic>.from(data['product'] as Map),
    );
  }
}

/// Converts an Open Food Facts product record into a [ProductAnalysis].
class OffProductMapper {
  const OffProductMapper._();

  static const Set<String> _nutrientKeys = {
    'calories',
    'protein',
    'carbs',
    'sugar',
    'fat',
    'saturatedFat',
    'fiber',
    'sodium',
  };

  static ProductAnalysis toAnalysis(Map<String, dynamic> p) {
    final nutriments = p['nutriments'] is Map
        ? Map<String, dynamic>.from(p['nutriments'] as Map)
        : <String, dynamic>{};

    final code = _str(p['code']);
    final rawName = _str(p['product_name_en']).isNotEmpty
        ? _str(p['product_name_en'])
        : _str(p['product_name']);
    final name = _capitalize(rawName, fallback: 'Unknown product');
    final brand = _str(p['brands']).split(',').first.trim();

    final categoriesText = _str(p['categories']);
    final categoryTags = _strList(p['categories_tags']);
    final category = categoriesText.isNotEmpty
        ? categoriesText.split(',').last.trim()
        : categoryTags.isNotEmpty
            ? _label(categoryTags.last)
            : 'Packaged food';

    final ingredientsText = _str(p['ingredients_text_en']).isNotEmpty
        ? _str(p['ingredients_text_en'])
        : _str(p['ingredients_text']);
    final ingredients = _splitIngredients(ingredientsText);

    final additives =
        _strList(p['additives_tags']).map(AdditivesDb.fromTag).toList();
    final allergens = <String>[
      ..._strList(p['allergens_tags']).map(_label),
      ..._strList(p['traces_tags'])
          .map((t) => 'May contain ${_label(t).toLowerCase()}'),
    ];

    final analysisTags = _strList(p['ingredients_analysis_tags']);
    final dietaryFlags = <String>[
      if (analysisTags.contains('en:vegan')) 'Vegan',
      if (analysisTags.contains('en:vegetarian')) 'Vegetarian',
      if (analysisTags.contains('en:palm-oil-free')) 'Palm-oil free',
    ];
    final containsPalmOil = analysisTags.contains('en:palm-oil');

    final gradeRaw = _str(p['nutriscore_grade']).toLowerCase();
    final grade = const ['a', 'b', 'c', 'd', 'e'].contains(gradeRaw)
        ? gradeRaw
        : null;
    final nova = _int(p['nova_group']);

    final smallImage = _str(p['image_front_small_url']);
    final largeImage = _str(p['image_front_url']);
    final imageUrl = smallImage.isNotEmpty
        ? smallImage
        : largeImage.isNotEmpty
            ? largeImage
            : null;

    // ---- nutrients ----
    // Prefer per-100g values; fall back to "as prepared" values (some
    // records, e.g. instant noodles, only carry those) and remember which
    // keys were missing so the UI never shows a misleading zero.
    final found = <String>{};
    var usedPrepared = false;
    var usedPlain = false;

    double take(String offKey, String ourKey) {
      final r = _readNutrient(nutriments, offKey);
      if (r == null) return 0;
      found.add(ourKey);
      if (r.$2) {
        usedPrepared = true;
      } else {
        usedPlain = true;
      }
      return r.$1;
    }

    final protein = take('proteins', 'protein');
    final carbs = take('carbohydrates', 'carbs');
    final sugar = take('sugars', 'sugar');
    final fat = take('fat', 'fat');
    final saturatedFat = take('saturated-fat', 'saturatedFat');
    final fiber = take('fiber', 'fiber');

    var calories = take('energy-kcal', 'calories');
    if (!found.contains('calories')) {
      final kj = _readNutrient(nutriments, 'energy');
      if (kj != null && kj.$1 > 0) {
        calories = kj.$1 / 4.184;
        found.add('calories');
        if (kj.$2) {
          usedPrepared = true;
        } else {
          usedPlain = true;
        }
      }
    }

    // Sodium may only be present as salt (g): sodium = salt / 2.5.
    var sodiumMg = 0.0;
    final sodiumG = _readNutrient(nutriments, 'sodium');
    final saltG = sodiumG == null ? _readNutrient(nutriments, 'salt') : null;
    final sodiumSource = sodiumG ?? saltG;
    if (sodiumSource != null) {
      sodiumMg = sodiumG != null
          ? sodiumSource.$1 * 1000
          : sodiumSource.$1 / 2.5 * 1000;
      found.add('sodium');
      if (sodiumSource.$2) {
        usedPrepared = true;
      } else {
        usedPlain = true;
      }
    }

    final missing = _nutrientKeys.difference(found);
    final String? basis = found.isEmpty
        ? null
        : usedPrepared && !usedPlain
            ? 'per 100 g as prepared'
            : usedPrepared
                ? 'per 100 g (some values as prepared)'
                : 'per 100 g';

    final nutrition = NutritionFacts(
      calories: calories,
      protein: protein,
      carbs: carbs,
      sugar: sugar,
      fat: fat,
      saturatedFat: saturatedFat,
      fiber: fiber,
      sodium: sodiumMg,
    );

    final visualText =
        '$categoriesText ${categoryTags.join(' ')} $name'.toLowerCase();
    final isBeverage = visualText.contains('beverage') ||
        visualText.contains('drink') ||
        visualText.contains('juice') ||
        visualText.contains('soda') ||
        visualText.contains('cola');
    final (icon, accent) = _visual(visualText);

    final report = ProductScorer.evaluate(
      nutrition: nutrition,
      additives: additives,
      nutriscoreGrade: grade,
      novaGroup: nova,
      isBeverage: isBeverage,
      dietaryFlags: dietaryFlags,
      containsPalmOil: containsPalmOil,
      missing: missing,
    );

    return ProductAnalysis(
      id: 'off-$code',
      name: name,
      brand: brand.isEmpty ? 'Unknown brand' : brand,
      category: category,
      barcode: code,
      icon: icon,
      accent: accent,
      nutrition: nutrition,
      ingredients: ingredients,
      additives: additives,
      allergens: allergens,
      dietaryFlags: dietaryFlags,
      manufacturedOn: null,
      expiresOn: null,
      healthScore: report.score,
      summary: report.summary,
      pros: report.pros,
      cons: report.cons,
      scannedAt: DateTime.now(),
      imageUrl: imageUrl,
      dataSource: OpenFoodFactsService.source,
      nutriscoreGrade: grade,
      novaGroup: nova,
      missingNutrients: missing,
      nutritionBasis: basis,
    );
  }

  static String _str(dynamic v) => v == null ? '' : v.toString().trim();

  static List<String> _strList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(_str(v));
  }

  /// Reads a nutrient, returning its value and whether it came from an
  /// "as prepared" field; null when the record has no usable value.
  static (double, bool)? _readNutrient(Map<String, dynamic> n, String key) {
    for (final (k, prepared) in [
      ('${key}_100g', false),
      ('${key}_prepared_100g', true),
      ('${key}_value', false),
      (key, false),
    ]) {
      final v = n[k];
      if (v is num) return (v.toDouble(), prepared);
      if (v is String) {
        final d = double.tryParse(v);
        if (d != null) return (d, prepared);
      }
    }
    return null;
  }

  /// "en:gluten" -> "Gluten", "en:instant-noodles" -> "Instant noodles".
  static String _label(String tag) {
    final raw = tag.contains(':') ? tag.substring(tag.indexOf(':') + 1) : tag;
    return _capitalize(raw.replaceAll('-', ' ').trim(), fallback: '');
  }

  static String _capitalize(String s, {required String fallback}) {
    if (s.isEmpty) return fallback;
    return s[0].toUpperCase() + s.substring(1);
  }

  static const int _chipMax = 48;
  static const int _chipCount = 30;

  static String _clip(String s) =>
      s.length > _chipMax ? '${s.substring(0, _chipMax - 1)}…' : s;

  /// Turns the free-text ingredient list into chips: decodes entities,
  /// drops section labels ("NOODLES:"), splits only outside parentheses and
  /// expands long compound items ("Seasoning (A, B, C)") into the parent
  /// plus its sub-ingredients.
  static List<String> _splitIngredients(String raw) {
    if (raw.trim().isEmpty) return const [];
    var text = raw
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('"', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    text = text.replaceAll(RegExp(r'\b[A-Z][A-Z0-9 ®™&\-]{2,}:\s*'), '');

    final chips = <String>[];
    for (final item in _splitTopLevel(text)) {
      if (chips.length >= _chipCount) break;
      if (item.length <= _chipMax) {
        chips.add(item);
        continue;
      }
      final open = _firstListParen(item);
      if (open < 0) {
        chips.add(_clip(item));
        continue;
      }
      final close = _matchingParen(item, open);
      final parent = item.substring(0, open).trim();
      if (parent.length > 1) chips.add(_clip(parent));
      for (final child in _splitTopLevel(item.substring(open + 1, close))) {
        if (chips.length >= _chipCount) break;
        chips.add(_clip(child));
      }
    }
    return chips;
  }

  /// Splits on commas, semicolons, sentence breaks and " and " — only
  /// outside parentheses, so sub-ingredients stay with their parent.
  static List<String> _splitTopLevel(String text) {
    final parts = <String>[];
    final buffer = StringBuffer();
    var depth = 0;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == '(') depth++;
      if (ch == ')' && depth > 0) depth--;
      if (depth == 0) {
        if (ch == ',' || ch == ';') {
          parts.add(buffer.toString());
          buffer.clear();
          continue;
        }
        if (ch == '.' && (i + 1 == text.length || text[i + 1] == ' ')) {
          parts.add(buffer.toString());
          buffer.clear();
          continue;
        }
        if (text.startsWith(' and ', i)) {
          parts.add(buffer.toString());
          buffer.clear();
          i += 4;
          continue;
        }
      }
      buffer.write(ch);
    }
    parts.add(buffer.toString());
    return parts.map((s) => s.trim()).where((s) => s.length > 1).toList();
  }

  /// Index of the first "(" whose group contains a comma (a list), or -1.
  static int _firstListParen(String s) {
    for (var i = 0; i < s.length; i++) {
      if (s[i] != '(') continue;
      final close = _matchingParen(s, i);
      if (s.substring(i + 1, close).contains(',')) return i;
    }
    return -1;
  }

  static int _matchingParen(String s, int open) {
    var depth = 0;
    for (var i = open; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return s.length; // Unbalanced: treat the rest as the group.
  }

  static (IconData, Color) _visual(String t) {
    if (t.contains('drink') ||
        t.contains('beverage') ||
        t.contains('juice') ||
        t.contains('cola') ||
        t.contains('soda') ||
        t.contains('water')) {
      return (Icons.local_drink, const Color(0xFF7C2D12));
    }
    if (t.contains('noodle') || t.contains('pasta')) {
      return (Icons.ramen_dining, const Color(0xFFB91C1C));
    }
    if (t.contains('chip') || t.contains('crisp') || t.contains('snack')) {
      return (Icons.lunch_dining, const Color(0xFFCA8A04));
    }
    if (t.contains('cereal') || t.contains('breakfast') || t.contains('oat')) {
      return (Icons.breakfast_dining, const Color(0xFFB45309));
    }
    if (t.contains('yogurt') ||
        t.contains('yoghurt') ||
        t.contains('milk') ||
        t.contains('dairy') ||
        t.contains('cheese')) {
      return (Icons.icecream, const Color(0xFF0E7490));
    }
    if (t.contains('chocolate') ||
        t.contains('biscuit') ||
        t.contains('cookie') ||
        t.contains('candy') ||
        t.contains('sweet') ||
        t.contains('bar')) {
      return (Icons.cookie, const Color(0xFF92400E));
    }
    return (Icons.fastfood, const Color(0xFF16A34A));
  }
}
