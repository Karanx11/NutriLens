import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works.dart';
import '../widgets/health_preview.dart';
import '../widgets/testimonials.dart';
import '../widgets/faq_section.dart';
import '../widgets/footer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              CustomAppBar(),
              HeroSection(),
              FeaturesSection(),
              HowItWorks(),
              HealthPreview(),
              TestimonialsSection(),
              FAQSection(),
              FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}
