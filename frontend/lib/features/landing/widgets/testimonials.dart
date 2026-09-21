import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';

class Testimonials extends StatelessWidget {
  const Testimonials({super.key});

  static const _items = [
    (
      quote:
          'I finally understand what those E-numbers on the label actually mean. Grocery runs are so much faster now.',
      name: 'Aisha R.',
      role: 'Parent of two',
    ),
    (
      quote:
          'The health score is brilliant for quick decisions. It caught the hidden sugar in my "healthy" cereal.',
      name: 'Daniel K.',
      role: 'Fitness coach',
    ),
    (
      quote:
          'As someone with a nut allergy, the instant allergen alerts give me real peace of mind.',
      name: 'Meera S.',
      role: 'Student',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: Column(
        children: [
          Text(
            'Loved by mindful eaters',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Wrap(
            spacing: AppSizes.m,
            runSpacing: AppSizes.m,
            alignment: WrapAlignment.center,
            children: [
              for (final t in _items)
                SizedBox(
                  width: 300,
                  child: _TestimonialCard(
                    quote: t.quote,
                    name: t.name,
                    role: t.role,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String role;

  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: AppColors.warning, size: 18),
              Icon(Icons.star, color: AppColors.warning, size: 18),
              Icon(Icons.star, color: AppColors.warning, size: 18),
              Icon(Icons.star, color: AppColors.warning, size: 18),
              Icon(Icons.star, color: AppColors.warning, size: 18),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          Text(
            '"$quote"',
            style: TextStyle(
              height: 1.5,
              color: onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSizes.m),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
