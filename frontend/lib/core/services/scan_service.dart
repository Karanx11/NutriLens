import 'dart:math';

import '../constants/api_constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../../features/scanner/data/demo_products.dart';

/// Turns a scan (photo capture or barcode) into a [ProductAnalysis].
///
/// In demo mode this returns curated on-device data after a short delay to
/// mimic network + AI latency. With [ApiConstants.useMockData] set to false it
/// posts to the backend instead.
class ScanService {
  final ApiService _api = ApiService();
  final Random _rng = Random();

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
