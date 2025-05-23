import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Animation<double>? slideAnimation;

  const AnimatedFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.slideAnimation,
  }) : super(key: key);

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  late Animation<double> _labelAnimation;

  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOutCubic,
    ));

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOutBack,
    ));

    widget.controller.addListener(_checkText);
  }

  @override
  void dispose() {
    _focusController.dispose();
    widget.controller.removeListener(_checkText);
    super.dispose();
  }

  void _checkText() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      if (hasText || _isFocused) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    }
  }

  void _onFocusChanged(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus || _hasText) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }

    if (hasFocus) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget field = AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Focus(
          onFocusChange: _onFocusChanged,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Stack(
              children: [
                // Main Field Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.lerp(
                        Colors.grey.shade200,
                        const Color(0xFFD2B48C),
                        _focusAnimation.value,
                      )!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(
                          Colors.transparent,
                          const Color(0xFFD2B48C).withOpacity(0.15),
                          _focusAnimation.value,
                        )!,
                        blurRadius: 25 * _focusAnimation.value,
                        offset: const Offset(0, 10),
                        spreadRadius: 2 * _focusAnimation.value,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    validator: widget.validator,
                    inputFormatters: widget.inputFormatters,
                    maxLength: widget.maxLength,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: _isFocused || _hasText ? widget.hintText : '',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      prefixIcon: Transform.scale(
                        scale: 1.0 + (0.1 * _focusAnimation.value),
                        child: Icon(
                          widget.prefixIcon,
                          color: Color.lerp(
                            Colors.grey.shade400,
                            const Color(0xFFD2B48C),
                            _focusAnimation.value,
                          ),
                          size: 22,
                        ),
                      ),
                      suffixIcon: widget.suffixIcon,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      counterText: '',
                    ),
                  ),
                ),

                // Floating Label
                AnimatedBuilder(
                  animation: _labelAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 20,
                      top: _isFocused || _hasText
                          ? -8 + (8 * (1 - _labelAnimation.value))
                          : 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: _isFocused || _hasText
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: _isFocused || _hasText ? 12 : 16,
                            fontWeight: _isFocused || _hasText
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: Color.lerp(
                              Colors.grey.shade500,
                              const Color(0xFFD2B48C),
                              _focusAnimation.value,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.slideAnimation != null) {
      return AnimatedBuilder(
        animation: widget.slideAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.slideAnimation!.value),
            child: Opacity(
              opacity: 1.0 - (widget.slideAnimation!.value / 100),
              child: field,
            ),
          );
        },
      );
    }

    return field;
  }
}

class GenderSelector extends StatefulWidget {
  final String selectedGender;
  final Function(String) onGenderChanged;
  final Animation<double>? slideAnimation;

  const GenderSelector({
    Key? key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.slideAnimation,
  }) : super(key: key);

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  void _selectGender(String gender) {
    widget.onGenderChanged(gender);
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final genders = [
      {'value': 'male', 'label': 'Male', 'icon': Icons.male},
      {'value': 'female', 'label': 'Female', 'icon': Icons.female},
      {'value': 'other', 'label': 'Other', 'icon': Icons.person},
    ];

    Widget selector = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: genders.map((gender) {
            final isSelected = widget.selectedGender == gender['value'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedBuilder(
                  animation: _selectionAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected
                          ? 1.0 + (0.05 * _selectionAnimation.value)
                          : 1.0,
                      child: GestureDetector(
                        onTap: () => _selectGender(gender['value'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD2B48C)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD2B48C)
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFFD2B48C).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                gender['icon'] as IconData,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                gender['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (widget.slideAnimation != null) {
      return AnimatedBuilder(
        animation: widget.slideAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.slideAnimation!.value),
            child: Opacity(
              opacity: 1.0 - (widget.slideAnimation!.value / 100),
              child: selector,
            ),
          );
        },
      );
    }

    return selector;
  }
}

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final String label;
  final Animation<double>? slideAnimation;

  const AnimatedCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.slideAnimation,
  }) : super(key: key);

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.2, 1.0, curve: Curves.bounceOut),
    ));

    if (widget.value) {
      _checkController.forward();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggle() {
    final newValue = !widget.value;
    widget.onChanged(newValue);

    if (newValue) {
      _checkController.forward();
    } else {
      _checkController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    Widget checkbox = GestureDetector(
      onTap: _toggle,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.transparent,
                    const Color(0xFFD2B48C),
                    _checkAnimation.value,
                  ),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.grey.shade300,
                      const Color(0xFFD2B48C),
                      _checkAnimation.value,
                    )!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.slideAnimation != null) {
      return AnimatedBuilder(
        animation: widget.slideAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.slideAnimation!.value),
            child: Opacity(
              opacity: 1.0 - (widget.slideAnimation!.value / 100),
              child: checkbox,
            ),
          );
        },
      );
    }

    return checkbox;
  }
}

class ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Animation<double> progressAnimation;

  const ProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.progressAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${((currentStep / totalSteps) * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD2B48C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: (progressAnimation.value * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD2B48C),
                              Color(0xFFB8860B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 100 - (progressAnimation.value * 100).round(),
                      child: const SizedBox(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FloatingParticle extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Color color;
  final Size screenSize;

  const FloatingParticle({
    Key? key,
    required this.index,
    required this.animation,
    required this.color,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index * 42);
    final size = 15.0 + random.nextDouble() * 25;
    final left = random.nextDouble() * screenSize.width;
    final top = random.nextDouble() * screenSize.height;
    final floatDistance = 20.0 + random.nextDouble() * 30;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: top + math.sin(animation.value * 2 * math.pi) * floatDistance,
          child: Transform.rotate(
            angle: animation.value * 2 * math.pi,
            child: Opacity(
              opacity: 0.1 + (0.05 * math.sin(animation.value * math.pi)),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: random.nextBool() ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: random.nextBool()
                      ? BorderRadius.circular(size * 0.3)
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}