import 'package:flutter/material.dart';
import '../../../models/onboarding_data.dart';
import '../../../widgets/onboarding_widgets.dart';
import '/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _buttonScaleAnimation;

  int _currentPage = 0;
  final List<OnboardingData> _onboardingData = OnboardingContent.pages;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _onboardingData[_currentPage].accentColor,
                        Colors.white,
                        _onboardingData[_currentPage].accentColor.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),

            // Floating Background Elements
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Stack(
                  children: List.generate(
                    5,
                        (index) => FloatingElement(
                      index: index,
                      floatingAnimation: _floatingAnimation,
                      color: _onboardingData[_currentPage].color,
                      screenSize: screenSize,
                    ),
                  ),
                );
              },
            ),

            Column(
              children: [
                // Header
                _buildHeader(),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return OnboardingPage(
                            data: _onboardingData[index],
                            fadeAnimation: _fadeAnimation,
                            slideAnimation: _slideAnimation,
                            scaleAnimation: _scaleAnimation,
                            floatingAnimation: _floatingAnimation,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom Section
                _buildBottomSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 60),
          Text(
            'FlutterCommerce',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _onboardingData[_currentPage].color,
            ),
          ),
          GestureDetector(
            onTap: _navigateToLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Page Indicator
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: PageIndicator(
                  currentPage: _currentPage,
                  totalPages: _onboardingData.length,
                  activeColor: _onboardingData[_currentPage].color,
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Action Button
          AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _buttonScaleAnimation]),
            builder: (context, child) {
              return GestureDetector(
                onTapDown: (_) => _buttonController.forward(),
                onTapUp: (_) => _buttonController.reverse(),
                onTapCancel: () => _buttonController.reverse(),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: ActionButton(
                    text: _currentPage == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    onPressed: _currentPage == _onboardingData.length - 1
                        ? _navigateToLogin
                        : _nextPage,
                    scaleAnimation: _buttonScaleAnimation,
                    color: _onboardingData[_currentPage].color,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}