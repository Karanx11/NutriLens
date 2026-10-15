import 'dart:math';

import '../constants/api_constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../../features/scanner/data/demo_products.dart';
import 'open_food_facts_service.dart';

/// Turns a scan into a [ProductAnalysis].
///
/// Scanned barcodes are looked up for real in Open Food Facts. The demo
/// catalog remains available for "Try a sample" and as the legacy mock path.
class ScanService {
  final ApiService _api = ApiService();
  final OpenFoodFactsService _openFoodFacts = OpenFoodFactsService();
  final Random _rng = Random();

  /// Real lookup of a scanned barcode. Returns null when the product is not
  /// in the database; throws on network failure.
  Future<ProductAnalysis?> lookupBarcode(String barcode) =>
      _openFoodFacts.lookup(barcode);

  /// Legacy analysis path: demo data in mock mode, otherwise the app backend.
  Future<ProductAnalysis> analyze({String? barcode}) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1700));
      if (barcode != null) {
        final match = demoProducts.where((p) => p.barcode == barcode);
        if (match.isNotEmpty) {
          return match.first.copyWith(scannedAt: DateTime.now());
        }
      }
      final picked = demoProducts[_rng.nextInt(demoProducts.length)];
      return picked.copyWith(scannedAt: DateTime.now());
    }

    final endpoint =
        barcode != null ? ApiConstants.analyzeBarcode : ApiConstants.analyzeImage;
    final response = await _api.post(
      endpoint,
      data: {'barcode': ?barcode},
    );
    return ProductAnalysis.fromJson(response.data as Map<String, dynamic>);
  }

  /// Analyze a chosen sample product (used by the "try a sample" flow).
  Future<ProductAnalysis> analyzeSample(ProductAnalysis product) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    return product.copyWith(scannedAt: DateTime.now());
  }
}
