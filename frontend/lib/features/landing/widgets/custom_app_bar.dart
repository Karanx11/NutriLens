import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          const Text(
            "NutriLens",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text("Login")),
          ElevatedButton(onPressed: () {}, child: const Text("Get Started")),
        ],
      ),
    );
  }
}
