import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/product.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/score_ring.dart';
import '../../scanner/providers/scan_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ScanProvider>().current;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.document_scanner_outlined, size: 56),
                const SizedBox(height: AppSizes.m),
                const Text('Nothing to show yet.'),
                const SizedBox(height: AppSizes.m),
                PrimaryButton(
                  label: 'Scan a product',
                  expand: false,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.scanner),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(AppSizes.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(product: product),
                const SizedBox(height: AppSizes.l),
                _ScoreCard(product: product),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('AI analysis'),
                CustomCard(
                  child: Text(
                    product.summary,
                    style: const TextStyle(height: 1.55, fontSize: 14.5),
                  ),
                ),
                const SizedBox(height: AppSizes.l),
                _ProsCons(product: product),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('Nutrition (per 100g)'),
                _NutritionCard(nutrition: product.nutrition),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('Additives (${product.additives.length})'),
                _AdditivesCard(additives: product.additives),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('Allergens'),
                _AllergenCard(allergens: product.allergens),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('Ingredients'),
                _IngredientsCard(ingredients: product.ingredients),
                const SizedBox(height: AppSizes.l),
                _SectionTitle('Freshness (OCR)'),
                _DatesCard(product: product),
                const SizedBox(height: AppSizes.xl),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Scan another',
                        icon: Icons.center_focus_strong,
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.scanner),
                      ),
                    ),
                    const SizedBox(width: AppSizes.m),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Done',
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.dashboard, (r) => false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProductAnalysis product;
  const _Header({required this.product});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: product.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(product.icon, color: product.accent, size: 32),
        ),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                '${product.brand} · ${product.category}',
                style: TextStyle(color: onSurface.withValues(alpha: 0.65)),
              ),
              Text(
                'Barcode ${product.barcode}',
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final ProductAnalysis product;
  const _ScoreCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = product.scoreColor;
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        children: [
          // Two language-free signals side by side — the score ring and a big
          // emoji verdict in the matching color — so the result reads at a
          // glance no matter what language the user speaks.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScoreRing(score: product.healthScore, color: color, size: 116),
              const SizedBox(width: AppSizes.l),
              Semantics(
                label: product.rating,
                child: ExcludeSemantics(
                  child: Container(
                    width: 116,
                    height: 116,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.45),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 60, height: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(
              product.rating,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            'Overall health score based on nutrition, additives and processing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProsCons extends StatelessWidget {
  final ProductAnalysis product;
  const _ProsCons({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ProsConsCard(
            title: 'Pros',
            icon: Icons.thumb_up_alt_outlined,
            color: AppColors.success,
            items: product.pros,
          ),
        ),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: _ProsConsCard(
            title: 'Watch-outs',
            icon: Icons.thumb_down_alt_outlined,
            color: AppColors.error,
            items: product.cons,
          ),
        ),
      ],
    );
  }
}

class _ProsConsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ProsConsCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          if (items.isEmpty)
            const Text('—')
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 13.5, height: 1.35)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionFacts nutrition;
  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _NutrientTile(
                  label: 'Calories',
                  value: '${nutrition.calories.round()}',
                  unit: 'kcal',
                ),
              ),
              Expanded(
                child: _NutrientTile(
                  label: 'Protein',
                  value: nutrition.protein.toStringAsFixed(1),
                  unit: 'g',
                ),
              ),
              Expanded(
                child: _NutrientTile(
                  label: 'Carbs',
                  value: nutrition.carbs.toStringAsFixed(1),
                  unit: 'g',
                ),
              ),
            ],
          ),
          const Divider(height: AppSizes.l),
          _MacroBar(
            label: 'Sugar',
            value: nutrition.sugar,
            unit: 'g',
            reference: 27,
          ),
          _MacroBar(
            label: 'Fat',
            value: nutrition.fat,
            unit: 'g',
            reference: 40,
          ),
          _MacroBar(
            label: 'Saturated fat',
            value: nutrition.saturatedFat,
            unit: 'g',
            reference: 20,
          ),
          _MacroBar(
            label: 'Sodium',
            value: nutrition.sodium,
            unit: 'mg',
            reference: 600,
          ),
          _MacroBar(
            label: 'Fiber',
            value: nutrition.fiber,
            unit: 'g',
            reference: 10,
            higherIsBetter: true,
          ),
        ],
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                    fontSize: 12,
                    color: onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double reference;
  final bool higherIsBetter;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.reference,
    this.higherIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final fraction = (value / reference).clamp(0.0, 1.0);

    Color barColor;
    if (higherIsBetter) {
      barColor = fraction >= 0.5 ? AppColors.success : AppColors.warning;
    } else if (fraction < 0.4) {
      barColor = AppColors.success;
    } else if (fraction < 0.75) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13.5,
                      color: onSurface.withValues(alpha: 0.8))),
              Text(
                '${value % 1 == 0 ? value.round() : value.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditivesCard extends StatelessWidget {
  final List<Additive> additives;
  const _AdditivesCard({required this.additives});

  @override
  Widget build(BuildContext context) {
    if (additives.isEmpty) {
      return const CustomCard(
        child: Row(
          children: [
            Icon(Icons.verified, color: AppColors.success),
            SizedBox(width: AppSizes.s),
            Expanded(child: Text('No additives detected — clean label.')),
          ],
        ),
      );
    }
    return CustomCard(
      child: Column(
        children: [
          for (int i = 0; i < additives.length; i++) ...[
            if (i > 0) const Divider(height: AppSizes.l),
            _AdditiveRow(additive: additives[i]),
          ],
        ],
      ),
    );
  }
}

class _AdditiveRow extends StatelessWidget {
  final Additive additive;
  const _AdditiveRow({required this.additive});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            additive.code,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(additive.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                additive.purpose,
                style: TextStyle(
                    fontSize: 12.5,
                    color: onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: additive.concern.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Text(
            additive.concern.label,
            style: TextStyle(
              color: additive.concern.color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllergenCard extends StatelessWidget {
  final List<String> allergens;
  const _AllergenCard({required this.allergens});

  @override
  Widget build(BuildContext context) {
    if (allergens.isEmpty) {
      return const CustomCard(
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: AppSizes.s),
            Expanded(child: Text('No major allergens listed.')),
          ],
        ),
      );
    }
    return CustomCard(
      child: Wrap(
        spacing: AppSizes.s,
        runSpacing: AppSizes.s,
        children: [
          for (final a in allergens)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber,
                      size: 15, color: AppColors.error),
                  const SizedBox(width: 5),
                  Text(
                    a,
                    style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<String> ingredients;
  const _IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return CustomCard(
      child: Wrap(
        spacing: AppSizes.s,
        runSpacing: AppSizes.s,
        children: [
          for (int i = 0; i < ingredients.length; i++)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                ingredients[i],
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _DatesCard extends StatelessWidget {
  final ProductAnalysis product;
  const _DatesCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final expired = product.isExpired;
    final days = product.daysToExpiry;

    String expiryStatus;
    Color statusColor;
    if (product.expiresOn == null) {
      expiryStatus = 'Not detected';
      statusColor = AppColors.textSecondary;
    } else if (expired) {
      expiryStatus = 'Expired';
      statusColor = AppColors.error;
    } else if (days != null && days <= 14) {
      expiryStatus = 'Expiring soon · ${days}d';
      statusColor = AppColors.warning;
    } else {
      expiryStatus = 'Fresh · ${days}d left';
      statusColor = AppColors.success;
    }

    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateBlock(
                  icon: Icons.precision_manufacturing,
                  label: 'Manufactured',
                  value: product.manufacturedOn == null
                      ? '—'
                      : AppDate.format(product.manufacturedOn!),
                ),
              ),
              Expanded(
                child: _DateBlock(
                  icon: Icons.event_busy,
                  label: 'Expires',
                  value: product.expiresOn == null
                      ? '—'
                      : AppDate.format(product.expiresOn!),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.m, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Row(
              children: [
                Icon(expired ? Icons.error : Icons.schedule,
                    size: 18, color: statusColor),
                const SizedBox(width: AppSizes.s),
                Text(
                  expiryStatus,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DateBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12.5, color: onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
