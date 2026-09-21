import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onAnalyze;
  final VoidCallback onLearnMore;

  const HeroSection({
    super.key,
    required this.onAnalyze,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.gutter,
        AppSizes.xl,
        AppSizes.gutter,
        AppSizes.l,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 15, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'AI-powered food analysis',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Text(
            AppStrings.heroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.m),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              AppStrings.heroSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Wrap(
            spacing: AppSizes.m,
            runSpacing: AppSizes.s,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onAnalyze,
                icon: const Icon(Icons.center_focus_strong, size: 20),
                label: const Text('Analyze a Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 16),
                ),
              ),
              OutlinedButton(
                onPressed: onLearnMore,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 16),
                ),
                child: const Text('Learn More'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
