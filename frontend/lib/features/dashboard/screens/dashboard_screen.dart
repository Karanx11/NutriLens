import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/score_utils.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/scan_tile.dart';
import '../../../core/widgets/score_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scanner/providers/scan_provider.dart';
import '../../scanner/scanner_action.dart';

/// Home tab. Rendered inside the main shell, which owns the persistent bottom
/// navigation bar. Tab switches are requested through the callbacks so the
/// bar stays put instead of a new route being pushed.
class DashboardScreen extends StatelessWidget {
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewProfile;

  const DashboardScreen({super.key, this.onViewHistory, this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scan = context.watch<ScanProvider>();
    final recent = scan.history.take(3).toList();

    void openHistory() {
      if (onViewHistory != null) {
        onViewHistory!();
      } else {
        Navigator.pushNamed(context, AppRoutes.history);
      }
    }

    void openProfile() {
      if (onViewProfile != null) {
        onViewProfile!();
      } else {
        Navigator.pushNamed(context, AppRoutes.profile);
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.gutter,
            AppSizes.m,
            AppSizes.gutter,
            AppSizes.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(name: auth.userName, onProfileTap: openProfile),
              const SizedBox(height: AppSizes.l),
              _OverviewCard(scan: scan),
              const SizedBox(height: AppSizes.l),
              const _SectionHeader(title: 'Quick actions'),
              const SizedBox(height: AppSizes.s),
              const _QuickActions(),
              const SizedBox(height: AppSizes.l),
              _SectionHeader(
                title: 'Recent scans',
                actionLabel: 'See all',
                onAction: openHistory,
              ),
              const SizedBox(height: AppSizes.s),
              if (recent.isEmpty)
                const _EmptyScans()
              else
                for (final p in recent)
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
              const SizedBox(height: AppSizes.m),
              const _InsightCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onProfileTap;

  const _Header({required this.name, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final hasName = name.isNotEmpty && name != 'there';
    final title = hasName ? name : 'Welcome back';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.m),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: hasName
                  ? Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    )
                  : const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final ScanProvider scan;
  const _OverviewCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final hasData = scan.scanCount > 0;
    final avg = scan.averageScore.round();
    final ringColor =
        hasData ? ScoreUtils.color(avg) : onSurface.withValues(alpha: 0.3);
    final watchCount = scan.scanCount - scan.healthyCount;

    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            scheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScoreRing(
                score: hasData ? avg : 0,
                color: ringColor,
                size: 112,
                stroke: 11,
                caption: hasData ? ScoreUtils.rating(avg) : 'No data',
              ),
              const SizedBox(width: AppSizes.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health overview',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasData
                          ? 'Average score across your scans'
                          : 'Scan a product to start tracking your score.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    Wrap(
                      spacing: AppSizes.s,
                      runSpacing: AppSizes.s,
                      children: [
                        _Pill(
                          icon: Icons.qr_code_scanner,
                          label: '${scan.scanCount} scans',
                          color: AppColors.primary,
                        ),
                        _Pill(
                          icon: Icons.eco,
                          label: '${scan.healthyCount} healthy',
                          color: AppColors.success,
                        ),
                        _Pill(
                          icon: Icons.warning_amber_rounded,
                          label: '$watchCount to watch',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.l),
          _WeekStrip(history: scan.history),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seven-day scan activity, newest day on the right.
class _WeekStrip extends StatelessWidget {
  final List<ProductAnalysis> history;
  const _WeekStrip({required this.history});

  static const _initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final counts = days
        .map((d) => history.where((p) {
              final s = p.scannedAt;
              return s.year == d.year && s.month == d.month && s.day == d.day;
            }).length)
        .toList();
    final maxCount = counts.fold<int>(0, (m, c) => c > m ? c : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS WEEK',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSizes.s),
        // Tallest bar (46) + gap (6) + label line (~16) needs headroom.
        SizedBox(
          height: 74,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: maxCount == 0
                              ? 6.0
                              : 6.0 + 40.0 * counts[i] / maxCount,
                          decoration: BoxDecoration(
                            color: i == 6
                                ? AppColors.primary
                                : AppColors.primary.withValues(
                                    alpha: counts[i] > 0 ? 0.55 : 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _initials[days[i].weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                i == 6 ? FontWeight.w800 : FontWeight.w500,
                            color: i == 6
                                ? AppColors.primary
                                : onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.qr_code_scanner,
            label: 'Scan\nbarcode',
            color: AppColors.primary,
            action: ScannerAction.barcode,
          ),
        ),
        SizedBox(width: AppSizes.m),
        Expanded(
          child: _ActionTile(
            icon: Icons.photo_camera_outlined,
            label: 'Capture\nlabel',
            color: Color(0xFF0891B2),
            action: ScannerAction.photo,
          ),
        ),
        SizedBox(width: AppSizes.m),
        Expanded(
          child: _ActionTile(
            icon: Icons.inventory_2_outlined,
            label: 'Try a\nsample',
            color: AppColors.warning,
            action: ScannerAction.sample,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ScannerAction action;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.scanner, arguments: action),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.m, horizontal: AppSizes.s),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyScans extends StatelessWidget {
  const _EmptyScans();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        children: [
          Icon(Icons.document_scanner_outlined,
              size: 36, color: onSurface.withValues(alpha: 0.35)),
          const SizedBox(height: AppSizes.s),
          const Text('No scans yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'Your analyzed products will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: AppSizes.s),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
            child: const Text('Scan your first product'),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  static const _tips = [
    'Ingredients are listed by weight — the first few make up most of the product.',
    'Sugar hides under other names: dextrose, maltose, syrup and juice concentrate all count.',
    'Sodium adds up fast in instant meals — compare per-100g values, not per serving.',
    'A shorter ingredient list usually means less processing.',
    'Fiber and protein keep you fuller for longer — look for 3g+ fiber per serving.',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tip = _tips[DateTime.now().day % _tips.length];

    return CustomCard(
      color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily insight',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
