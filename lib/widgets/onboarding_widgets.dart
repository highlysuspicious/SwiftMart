import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/onboarding_data.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> floatingAnimation;

  const OnboardingPage({
    Key? key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.floatingAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, slideAnimation.value),
      child: Opacity(
        opacity: fadeAnimation.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              Transform.scale(
                scale: scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation.value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          data.color.withOpacity(0.2),
                          data.color.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      size: 60,
                      color: data.color,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: data.color,
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;

  const PageIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == currentPage ? 24 : 8,
          decoration: BoxDecoration(
            color: index == currentPage
                ? activeColor
                : activeColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class FloatingElement extends StatelessWidget {
  final int index;
  final Animation<double> floatingAnimation;
  final Color color;
  final Size screenSize;

  const FloatingElement({
    Key? key,
    required this.index,
    required this.floatingAnimation,
    required this.color,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final size = 20.0 + random.nextDouble() * 40;
    final left = random.nextDouble() * screenSize.width;
    final top = random.nextDouble() * screenSize.height;

    return Positioned(
      left: left,
      top: top + floatingAnimation.value * (index % 2 == 0 ? 1 : -1),
      child: Opacity(
        opacity: 0.1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Animation<double> scaleAnimation;
  final Color color;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.scaleAnimation,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scaleAnimation.value,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}