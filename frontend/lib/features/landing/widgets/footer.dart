import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.gutter,
        vertical: AppSizes.xl,
      ),
      color: onSurface.withValues(alpha: 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSizes.s),
              const Text(
                'NutriLens',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          Wrap(
            spacing: AppSizes.l,
            runSpacing: AppSizes.s,
            alignment: WrapAlignment.center,
            children: [
              for (final link in ['About', 'Privacy', 'Terms', 'Contact'])
                Text(
                  link,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.65)),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          Text(
            '© ${DateTime.now().year} NutriLens · Made with care for what you eat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
