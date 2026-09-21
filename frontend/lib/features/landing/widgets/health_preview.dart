import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/score_ring.dart';

/// A static preview of what a scan result looks like, to entice sign-ups.
class HealthPreview extends StatelessWidget {
  const HealthPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: CustomCard(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E7490).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.icecream, color: Color(0xFF0E7490)),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Greek Yogurt, Plain',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: onSurface,
                          ),
                        ),
                        Text(
                          'FarmField · Dairy',
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.l),
              Row(
                children: [
                  const ScoreRing(
                    score: 88,
                    color: AppColors.primary,
                    size: 108,
                    caption: 'Excellent',
                  ),
                  const SizedBox(width: AppSizes.l),
                  Expanded(
                    child: Column(
                      children: const [
                        _MiniStat(label: 'Protein', value: '9g', good: true),
                        SizedBox(height: 10),
                        _MiniStat(label: 'Sugar', value: '3.6g', good: true),
                        SizedBox(height: 10),
                        _MiniStat(
                            label: 'Additives', value: 'None', good: true),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool good;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.good,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(
          good ? Icons.check_circle : Icons.error,
          size: 18,
          color: good ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
