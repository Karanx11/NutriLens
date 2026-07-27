import 'package:flutter/material.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: const [
          SizedBox(
            width: 250,
            child: FeatureCard(
              icon: Icons.camera_alt,
              title: "AI Vision",
              subtitle: "Analyze any packaged food using only a photo.",
            ),
          ),
          SizedBox(
            width: 250,
            child: FeatureCard(
              icon: Icons.restaurant,
              title: "Ingredient Breakdown",
              subtitle: "Understand what each ingredient does.",
            ),
          ),
          SizedBox(
            width: 250,
            child: FeatureCard(
              icon: Icons.favorite,
              title: "Health Score",
              subtitle: "Get an easy-to-understand health rating.",
            ),
          ),
          SizedBox(
            width: 250,
            child: FeatureCard(
              icon: Icons.warning,
              title: "Additive Detection",
              subtitle: "Spot preservatives, colors, and other additives.",
            ),
          ),
        ],
      ),
    );
  }
}
