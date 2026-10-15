import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loading_widget.dart';
import '../data/demo_products.dart';
import '../providers/scan_provider.dart';
import '../scanner_action.dart';

/// Live barcode scanner backed by the device camera. A detected barcode is
/// looked up in Open Food Facts and opens the analysis report. Photos (camera
/// or gallery) are scanned for a barcode on-device; "Try a sample" keeps the
/// demo catalog available.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const double _frameSize = 260;
  static const List<BarcodeFormat> _formats = [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.code128,
  ];

  late final MobileScannerController _camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: _formats,
  );
  late final AnimationController _lineController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  final ImagePicker _picker = ImagePicker();

  bool _busy = false;
  bool _autoRan = false;
  String? _hint;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A dashboard shortcut may ask us to start a specific action right away.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runInitialAction());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hintTimer?.cancel();
    _lineController.dispose();
    _camera.dispose();
    super.dispose();
  }

  // Release the camera while the app is in the background (or while the
  // system camera / picker is in front) and resume it when we come back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_busy) _safeStart();
    } else {
      _safeStop();
    }
  }

  Future<void> _safeStart() async {
    try {
      await _camera.start();
    } catch (_) {
      // Already running, no camera, or disposed — nothing to do.
    }
  }

  Future<void> _safeStop() async {
    try {
      await _camera.stop();
    } catch (_) {
      // Already stopped or disposed — nothing to do.
    }
  }

  void _runInitialAction() {
    if (_autoRan || !mounted) return;
    _autoRan = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! ScannerAction) return;
    switch (arg) {
      case ScannerAction.barcode:
        break; // Live scanning is already running.
      case ScannerAction.photo:
        _pickAndScan(ImageSource.camera);
      case ScannerAction.sample:
        _pickSample();
    }
  }

  void _setHint(String message) {
    _hintTimer?.cancel();
    setState(() => _hint = message);
    _hintTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  String _firstCode(BarcodeCapture? capture) {
    if (capture == null) return '';
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    final code = _firstCode(capture);
    if (code.isEmpty) return;
    _lookup(code);
  }

  /// Looks a barcode up and opens the report, pausing the camera meanwhile.
  Future<void> _lookup(String code) async {
    if (_busy) return;
    final provider = context.read<ScanProvider>();
    setState(() {
      _busy = true;
      _hint = null;
    });
    HapticFeedback.mediumImpact();
    await _safeStop();
    try {
      final product = await provider.lookupBarcode(code);
      if (!mounted) return;
      if (product == null) {
        await _showNotFound(code);
      } else {
        await Navigator.pushNamed(context, AppRoutes.report);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not look up $code — check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        unawaited(_safeStart());
      }
    }
  }

  Future<void> _showNotFound(String code) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Product not found'),
        content: Text(
          'Barcode $code is not in Open Food Facts yet. Try another product, '
          'or explore a sample.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Scan again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _pickSample();
            },
            child: const Text('Try a sample'),
          ),
        ],
      ),
    );
  }

  /// Takes or picks a photo and scans it for a barcode on-device.
  Future<void> _pickAndScan(ImageSource source) async {
    if (_busy) return;
    if (kIsWeb) {
      _setHint('Reading barcodes from photos is not supported on the web yet '
          '— use the live camera instead.');
      return;
    }
    await _safeStop();
    XFile? file;
    try {
      file = await _picker.pickImage(source: source, maxWidth: 1600);
    } catch (_) {
      // Picker cancelled or unavailable; treated as "no photo".
    }
    if (!mounted) return;
    if (file == null) {
      unawaited(_safeStart());
      return;
    }
    setState(() {
      _busy = true;
      _hint = 'Looking for a barcode in the photo…';
    });
    var code = '';
    try {
      final capture = await _camera.analyzeImage(file.path, formats: _formats);
      code = _firstCode(capture);
    } catch (_) {
      // Unreadable image; handled below as "no barcode found".
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (code.isEmpty) {
      _setHint('No barcode found in that photo. Reading labels by OCR is not '
          'available yet — try scanning the barcode.');
      unawaited(_safeStart());
      return;
    }
    await _lookup(code);
  }

  Future<void> _pickSample() async {
    if (_busy) return;
    final selected = await showModalBottomSheet<ProductAnalysis>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => _SampleSheet(products: demoProducts),
    );
    if (selected == null || !mounted) return;
    await _runSample(selected);
  }

  Future<void> _runSample(ProductAnalysis product) async {
    if (_busy) return;
    final provider = context.read<ScanProvider>();
    setState(() {
      _busy = true;
      _hint = null;
    });
    await _safeStop();
    try {
      await provider.analyzeSample(product);
      if (!mounted) return;
      await Navigator.pushNamed(context, AppRoutes.report);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        unawaited(_safeStart());
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _camera.toggleTorch();
    } catch (_) {
      // No torch on this device.
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _camera.switchCamera();
    } catch (_) {
      // Only one camera available.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight * 0.42,
          );
          return Stack(
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: _camera,
                  fit: BoxFit.cover,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => _CameraError(error: error),
                  placeholderBuilder: (context) =>
                      const ColoredBox(color: Color(0xFF0B1120)),
                ),
              ),
              // Darken everything outside the scan window.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScrimPainter(center: center, frame: _frameSize),
                  ),
                ),
              ),
              Positioned(
                left: center.dx - _frameSize / 2,
                top: center.dy - _frameSize / 2,
                child: _Viewfinder(controller: _lineController, size: _frameSize),
              ),
              Positioned(
                left: AppSizes.gutter,
                right: AppSizes.gutter,
                top: center.dy + _frameSize / 2 + AppSizes.l,
                child: Text(
                  _hint ?? 'Point the camera at a product barcode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _TopBar(
                      onClose: () => Navigator.maybePop(context),
                      onTorch: _toggleTorch,
                      onFlip: _switchCamera,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.gutter),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.photo_camera,
                                  label: 'Capture photo',
                                  onTap: () => _pickAndScan(ImageSource.camera),
                                ),
                              ),
                              const SizedBox(width: AppSizes.m),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.photo_library_outlined,
                                  label: 'From gallery',
                                  onTap: () => _pickAndScan(ImageSource.gallery),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.s),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: _pickSample,
                              icon: const Icon(Icons.inventory_2_outlined,
                                  color: Colors.white),
                              label: const Text(
                                'Try a sample product',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0B1120).withValues(alpha: 0.92),
                    child: const Center(
                      child: DefaultTextStyle(
                        style: TextStyle(color: Colors.white),
                        child: AnalyzingOverlay(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onTorch;
  final VoidCallback onFlip;

  const _TopBar({
    required this.onClose,
    required this.onTorch,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s, vertical: AppSizes.s),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Scanner',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSizes.s),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Torch',
            onPressed: onTorch,
            icon: const Icon(Icons.flashlight_on_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: onFlip,
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Dark overlay with a rounded window cut out around the scan frame.
class _ScrimPainter extends CustomPainter {
  final Offset center;
  final double frame;

  const _ScrimPainter({required this.center, required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final window = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: frame, height: frame),
        const Radius.circular(28),
      ));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, window),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.center != center || old.frame != frame;
}

class _Viewfinder extends StatelessWidget {
  final AnimationController controller;
  final double size;

  const _Viewfinder({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Positioned(
                  top: 20 + (size - 40) * controller.value,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0),
                          AppColors.success,
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const _Corner(alignment: Alignment.topLeft),
            const _Corner(alignment: Alignment.topRight),
            const _Corner(alignment: Alignment.bottomLeft),
            const _Corner(alignment: Alignment.bottomRight),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            border: Border(
              top: isTop
                  ? const BorderSide(color: AppColors.success, width: 3)
                  : BorderSide.none,
              bottom: !isTop
                  ? const BorderSide(color: AppColors.success, width: 3)
                  : BorderSide.none,
              left: isLeft
                  ? const BorderSide(color: AppColors.success, width: 3)
                  : BorderSide.none,
              right: !isLeft
                  ? const BorderSide(color: AppColors.success, width: 3)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;
  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Camera permission is needed to scan barcodes. Allow it in your '
            'device settings, then come back.',
      MobileScannerErrorCode.unsupported =>
        'Barcode scanning is not supported on this device or browser. '
            'You can still try a sample product.',
      _ => 'The camera could not be started (${error.errorCode.name}).',
    };
    return ColoredBox(
      color: const Color(0xFF0B1120),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white54, size: 48),
              const SizedBox(height: AppSizes.m),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.m),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleSheet extends StatelessWidget {
  final List<ProductAnalysis> products;
  const _SampleSheet({required this.products});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.m, 0, AppSizes.m, AppSizes.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Pick a sample product (demo data)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            for (final p in products)
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.icon, color: p.accent),
                ),
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.brand} · ${p.category}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, p),
              ),
          ],
        ),
      ),
    );
  }
}
