class ApiConstants {
  const ApiConstants._();

  /// When true, the app runs entirely on-device with realistic demo data and
  /// never contacts a server. Flip to false once the Node/Express backend is
  /// live and set [baseUrl] (or pass --dart-define=NUTRILENS_API_BASE=...).
  static const bool useMockData = true;

  static const String baseUrl = String.fromEnvironment(
    'NUTRILENS_API_BASE',
    defaultValue: 'https://api.nutrilens.app',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Scanning / analysis
  static const String analyzeImage = '/scan/analyze';
  static const String analyzeBarcode = '/scan/barcode';
  static const String history = '/scan/history';
}
