// TODO Implement this library.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "NutriLens",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
