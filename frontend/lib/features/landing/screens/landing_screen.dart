import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/responsive_center.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works.dart';
import '../widgets/health_preview.dart';
import '../widgets/testimonials.dart';
import '../widgets/faq_section.dart';
import '../widgets/footer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFeatures() {
    final ctx = _featuresKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ResponsiveCenter(
              child: Column(
                children: [
                  CustomAppBar(
                    onLogin: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    onGetStarted: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                  ),
                  HeroSection(
                    onAnalyze: () =>
                        Navigator.pushNamed(context, AppRoutes.scanner),
                    onLearnMore: _scrollToFeatures,
                  ),
                  KeyedSubtree(
                    key: _featuresKey,
                    child: const FeaturesSection(),
                  ),
                  const SizedBox(height: AppSizes.l),
                  const HowItWorks(),
                  const SizedBox(height: AppSizes.l),
                  const HealthPreview(),
                  const SizedBox(height: AppSizes.l),
                  const Testimonials(),
                  const SizedBox(height: AppSizes.l),
                  const FaqSection(),
                  const SizedBox(height: AppSizes.xl),
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
