import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'registration_screen.dart';
import '/screens/homepage/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _formSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToRegistration() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const RegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> saveLoginState(bool rememberMe, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userId); // or a token
    } else {
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
    }
  }

  void _toggleRememberMe() async {
    setState(() {
      _rememberMe = !_rememberMe;
    });
    HapticFeedback.lightImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          _showSuccessMessage(result.message);

          // Add a short delay to allow success message to show (optional)
          await Future.delayed(const Duration(milliseconds: 500));

          _navigateToHome();
        } else {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('An unexpected error occurred. Please try again.');
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      late final result;

      if (provider == 'Google') {
        result = await AuthService.signInWithGoogle();
      }
      if (provider == 'Apple') {
        result = await AuthService.signInWithApple();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          _showSuccessMessage(result.message);
          _navigateToHome();
        } else {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('$provider sign-in failed. Please try again.');
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email address first.');
      return;
    }

    try {
      final result = await AuthService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        if (result.success) {
          _showSuccessMessage(result.message);
        } else {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to send password reset email.');
      }
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'You have successfully signed in',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 60000),
      ),
    );
    _navigateToHomeScreen();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFFF5E6D3),
                          const Color(0xFFF0E68C),
                          _backgroundAnimation.value,
                        )!,
                        Colors.white,
                        Color.lerp(
                          const Color(0xFFF4E4BC),
                          const Color(0xFFF5E6D3),
                          _backgroundAnimation.value,
                        )!.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),

            // Floating Orbs
            ...List.generate(3, (index) => _buildFloatingOrb(index)),

            // Main Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Header
                    AnimatedBuilder(
                      animation: _formController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _formSlideAnimation.value),
                          child: Opacity(
                            opacity: _formFadeAnimation.value,
                            child: _buildHeader(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),

                    // Login Form
                    AnimatedBuilder(
                      animation: _formController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _formSlideAnimation.value * 0.5),
                          child: Opacity(
                            opacity: _formFadeAnimation.value,
                            child: _buildLoginForm(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Social Login
                    AnimatedBuilder(
                      animation: _formController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _formSlideAnimation.value * 0.3),
                          child: Opacity(
                            opacity: _formFadeAnimation.value,
                            child: _buildSocialLogin(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _navigateToOnboarding();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your premium shopping experience',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            controller: _emailController,
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(_emailController.text.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Remember Me & Forgot Password
          Row(
            children: [
              GestureDetector(
                onTap: _toggleRememberMe,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:
                            _rememberMe
                                ? const Color(0xFFD2B48C)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              _rememberMe
                                  ? const Color(0xFFD2B48C)
                                  : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          _rememberMe
                              ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _handleForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFFD2B48C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Login Button
          AnimatedBuilder(
            animation: _buttonScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) => _buttonController.forward(),
                  onTapUp: (_) => _buttonController.reverse(),
                  onTapCancel: () => _buttonController.reverse(),
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD2B48C), Color(0xFFB8860B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD2B48C).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:
                        _isLoading
                            ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : const Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: SocialLoginButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onTap: () => _handleSocialLogin('Google'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SocialLoginButton(
                icon: Icons.apple,
                label: 'Apple',
                onTap: () => _handleSocialLogin('Apple'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                _navigateToRegistration();
                HapticFeedback.lightImpact();
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xFFD2B48C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingOrb(int index) {
    final sizes = [80.0, 120.0, 60.0];
    final colors = [
      const Color(0xFFD2B48C).withOpacity(0.1),
      const Color(0xFFB8860B).withOpacity(0.08),
      const Color(0xFFCD853F).withOpacity(0.12),
    ];
    final positions = [
      const Offset(0.8, 0.2),
      const Offset(0.1, 0.4),
      const Offset(0.9, 0.7),
    ];

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * positions[index].dx,
          top:
              MediaQuery.of(context).size.height * positions[index].dy +
              (index % 2 == 0 ? 20 : -20) * _backgroundAnimation.value,
          child: Container(
            width: sizes[index],
            height: sizes[index],
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
