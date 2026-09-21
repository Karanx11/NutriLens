import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.gutter,
        vertical: AppSizes.l,
      ),
      child: Column(
        children: [
          Text(
            'Everything you need to eat smarter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.l),
          const Wrap(
            spacing: AppSizes.m,
            runSpacing: AppSizes.m,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.camera_alt,
                  title: 'AI Vision',
                  subtitle: 'Analyze any packaged food using only a photo.',
                ),
              ),
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.science,
                  title: 'Ingredient Breakdown',
                  subtitle: 'Understand what each ingredient really does.',
                ),
              ),
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.favorite,
                  title: 'Health Score',
                  subtitle: 'Get an easy-to-understand 0–100 health rating.',
                ),
              ),
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.warning_amber,
                  title: 'Additive Detection',
                  subtitle: 'Spot preservatives, colors and other additives.',
                ),
              ),
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.no_food,
                  title: 'Allergen Alerts',
                  subtitle: 'Flag allergens and dietary conflicts instantly.',
                ),
              ),
              SizedBox(
                width: 250,
                child: FeatureCard(
                  icon: Icons.event_available,
                  title: 'Expiry via OCR',
                  subtitle: 'Read manufacturing and expiry dates from the pack.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
