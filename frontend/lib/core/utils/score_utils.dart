import 'package:flutter/material.dart';

/// Maps a 0-100 health score to its rating band and color. Shared by product
/// reports and dashboard aggregates so the bands never drift apart.
class ScoreUtils {
  const ScoreUtils._();

  static String rating(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Avoid';
  }

  static Color color(int score) {
    if (score >= 80) return const Color(0xFF16A34A);
    if (score >= 60) return const Color(0xFF22C55E);
    if (score >= 40) return const Color(0xFFF59E0B);
    if (score >= 20) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  /// A language-free verdict, so anyone can read the result at a glance
  /// regardless of the language they speak.
  static String emoji(int score) {
    if (score >= 80) return '😄';
    if (score >= 60) return '🙂';
    if (score >= 40) return '😐';
    if (score >= 20) return '😟';
    return '🤢';
  }
}
