import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        children: [
          _buildPage(
            image: 'assets/onboarding1.png',
            title: 'Welcome',
            description: 'Easily convert currencies worldwide.',
          ),
          _buildPage(
            image: 'assets/onboarding2.png',
            title: 'Fast & Reliable',
            description: 'Get real-time currency exchange rates.',
          ),
          _buildPage(
            image: 'assets/onboarding3.png',
            title: 'Get Started',
            description: 'Let\'s begin!',
            isLast: true,
            onPressed: () => _completeOnboarding(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String image,
    required String title,
    required String description,
    bool isLast = false,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          const SizedBox(height: 30),
          Text(title, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center),
          if (isLast)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Start', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}
