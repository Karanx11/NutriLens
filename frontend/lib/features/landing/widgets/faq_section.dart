import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  static const _faqs = [
    (
      q: 'Is NutriLens free to use?',
      a: 'Yes — scanning and health scores are free. This build runs a fully on-device demo so you can explore every screen without an account.',
    ),
    (
      q: 'How accurate is the health score?',
      a: 'The score blends sugar, sodium, saturated fat, fiber, protein and additive concern into a 0–100 rating. It is guidance, not medical advice.',
    ),
    (
      q: 'Do you support barcodes?',
      a: 'Yes. You can scan a barcode or capture the label — the app extracts ingredients, nutrition and expiry dates for you.',
    ),
    (
      q: 'What about my data?',
      a: 'Your scans stay on your device in this demo. Nothing is uploaded and there is no tracking.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: Column(
        children: [
          Text(
            'Frequently asked questions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.l),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                for (final f in _faqs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.s),
                    child: CustomCard(
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.m),
                          childrenPadding: const EdgeInsets.fromLTRB(
                              AppSizes.m, 0, AppSizes.m, AppSizes.m),
                          title: Text(
                            f.q,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                f.a,
                                style: TextStyle(
                                  height: 1.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
