import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/scan_tile.dart';
import '../../scanner/providers/scan_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final history = scan.history;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan history'),
        // Shown as a tab inside the main shell, so there is nothing to pop.
        automaticallyImplyLeading: false,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? _EmptyState(
                onScan: () =>
                    Navigator.pushNamed(context, AppRoutes.scanner),
              )
            : SingleChildScrollView(
                child: ResponsiveCenter(
                  padding: const EdgeInsets.all(AppSizes.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryChip(
                              label: 'Total scans',
                              value: '${scan.scanCount}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.m),
                          Expanded(
                            child: _SummaryChip(
                              label: 'Average score',
                              value: scan.averageScore.round().toString(),
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.l),
                      Text(
                        'All scans',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s),
                      for (final p in history)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.s),
                          child: ScanTile(
                            product: p,
                            onTap: () {
                              context.read<ScanProvider>().select(p);
                              Navigator.pushNamed(context, AppRoutes.report);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This removes all saved scans from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<ScanProvider>().clearHistory();
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 60, color: onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: AppSizes.m),
            const Text('No scans yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Your analyzed products will appear here.',
              style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: AppSizes.l),
            OutlinedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Scan a product'),
            ),
          ],
        ),
      ),
    );
  }
}
