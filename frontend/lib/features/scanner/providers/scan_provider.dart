import 'package:flutter/foundation.dart';

import '../../../core/models/product.dart';
import '../../../core/services/scan_service.dart';
import '../data/demo_products.dart';

/// Holds the current analysis and the running scan history.
class ScanProvider extends ChangeNotifier {
  final ScanService _service = ScanService();

  final List<ProductAnalysis> _history = [];
  ProductAnalysis? _current;
  bool _isAnalyzing = false;

  ScanProvider() {
    _seedHistory();
  }

  List<ProductAnalysis> get history => List.unmodifiable(_history);
  ProductAnalysis? get current => _current;
  bool get isAnalyzing => _isAnalyzing;
  int get scanCount => _history.length;

  double get averageScore {
    if (_history.isEmpty) return 0;
    final total = _history.fold<int>(0, (sum, p) => sum + p.healthScore);
    return total / _history.length;
  }

  int get healthyCount => _history.where((p) => p.healthScore >= 60).length;

  void _seedHistory() {
    final now = DateTime.now();
    _history.addAll([
      demoProducts[2].copyWith(scannedAt: now.subtract(const Duration(hours: 5))),
      demoProducts[4].copyWith(
          scannedAt: now.subtract(const Duration(days: 1, hours: 3))),
      demoProducts[1].copyWith(
          scannedAt: now.subtract(const Duration(days: 2, hours: 1))),
    ]);
  }

  Future<ProductAnalysis> analyze({String? barcode}) async {
    _isAnalyzing = true;
    notifyListeners();

    final result = await _service.analyze(barcode: barcode);
    _current = result;
    _history.insert(0, result);

    _isAnalyzing = false;
    notifyListeners();
    return result;
  }

  Future<ProductAnalysis> analyzeSample(ProductAnalysis product) async {
    _isAnalyzing = true;
    notifyListeners();

    final result = await _service.analyzeSample(product);
    _current = result;
    _history.insert(0, result);

    _isAnalyzing = false;
    notifyListeners();
    return result;
  }

  void select(ProductAnalysis product) {
    _current = product;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
