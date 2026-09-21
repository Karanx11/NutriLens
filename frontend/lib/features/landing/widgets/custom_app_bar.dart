import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;

  const CustomAppBar({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.gutter,
        vertical: AppSizes.m,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSizes.s),
          const Text(
            'NutriLens',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton(onPressed: onLogin, child: const Text('Login')),
          const SizedBox(width: AppSizes.xs),
          ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}
