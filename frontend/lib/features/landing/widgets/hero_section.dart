import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            "Snap. Scan.\nKnow Before You Eat.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Understand what's really inside your food using AI.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("Analyze Product"),
              ),
              const SizedBox(width: 15),
              OutlinedButton(onPressed: () {}, child: const Text("Learn More")),
            ],
          ),
        ],
      ),
    );
  }
}
