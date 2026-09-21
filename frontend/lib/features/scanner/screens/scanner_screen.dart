import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loading_widget.dart';
import '../data/demo_products.dart';
import '../providers/scan_provider.dart';
import '../scanner_action.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lineController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  bool _isAnalyzing = false;
  bool _autoRan = false;

  @override
  void initState() {
    super.initState();
    // A dashboard shortcut may ask us to start a specific action right away.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runInitialAction());
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  void _runInitialAction() {
    if (_autoRan || !mounted) return;
    _autoRan = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! ScannerAction) return;
    switch (arg) {
      case ScannerAction.barcode:
        _scanBarcode();
      case ScannerAction.photo:
        _capturePhoto();
      case ScannerAction.sample:
        _pickSample();
    }
  }

  Future<void> _run(Future<ProductAnalysis> Function() task) async {
    setState(() => _isAnalyzing = true);
    try {
      await task();
      if (!mounted) return;
      await Navigator.pushNamed(context, AppRoutes.report);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _scanBarcode() {
    _run(() => context.read<ScanProvider>().analyze(barcode: null));
  }

  void _capturePhoto() {
    _run(() => context.read<ScanProvider>().analyze());
  }

  Future<void> _pickSample() async {
    final selected = await showModalBottomSheet<ProductAnalysis>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => _SampleSheet(products: demoProducts),
    );
    if (selected == null || !mounted) return;
    _run(() => context.read<ScanProvider>().analyzeSample(selected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(onClose: () => Navigator.maybePop(context)),
                const Spacer(),
                _Viewfinder(controller: _lineController),
                const SizedBox(height: AppSizes.l),
                const Text(
                  'Position the label or barcode in the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
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
                              icon: Icons.qr_code_scanner,
                              label: 'Scan barcode',
                              onTap: _scanBarcode,
                            ),
                          ),
                          const SizedBox(width: AppSizes.m),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.photo_camera,
                              label: 'Capture photo',
                              onTap: _capturePhoto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.m),
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
          if (_isAnalyzing)
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
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;
  const _TopBar({required this.onClose});

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
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.s),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  final AnimationController controller;
  const _Viewfinder({required this.controller});

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Animated scanning line
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
            // Corner accents
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
      color: Colors.white.withValues(alpha: 0.1),
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
                'Pick a product to analyze',
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
