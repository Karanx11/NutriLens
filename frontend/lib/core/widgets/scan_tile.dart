import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../models/product.dart';
import '../utils/date_utils.dart';
import 'custom_card.dart';

/// A compact row summarizing one analyzed product, with a colored score badge.
class ScanTile extends StatelessWidget {
  final ProductAnalysis product;
  final VoidCallback onTap;

  const ScanTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.s + 4),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: product.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product.icon, color: product.accent),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.brand} · ${AppDate.timeAgo(product.scannedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s),
          _ScoreBadge(score: product.healthScore, color: product.scoreColor),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Text(
        '$score',
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
