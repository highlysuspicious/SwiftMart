import 'package:flutter/material.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}

class OnboardingContent {
  static final List<OnboardingData> pages = [
    OnboardingData(
      title: "Discover Premium Fashion",
      subtitle: "Curated collections from world-class designers and brands",
      description: "Explore our handpicked selection of premium clothing, accessories, and lifestyle products that define modern elegance.",
      icon: Icons.star_rounded,
      color: const Color(0xFFD2B48C),
      accentColor: const Color(0xFFF5E6D3),
    ),
    OnboardingData(
      title: "Seamless Shopping",
      subtitle: "Intuitive design meets powerful functionality",
      description: "Experience smooth navigation, smart search, and personalized recommendations powered by advanced algorithms.",
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFB8860B),
      accentColor: const Color(0xFFF4E4BC),
    ),
    OnboardingData(
      title: "Secure & Fast",
      subtitle: "Your satisfaction is our priority",
      description: "Enjoy secure payments, real-time order tracking, and lightning-fast delivery to your doorstep.",
      icon: Icons.security_rounded,
      color: const Color(0xFFCD853F),
      accentColor: const Color(0xFFF0E68C),
    ),
  ];
}