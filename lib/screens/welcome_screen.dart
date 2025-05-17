import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'welcome_screen_1.dart';

class ModernWelcomeScreen extends StatefulWidget {
  const ModernWelcomeScreen({super.key});

  @override
  State<ModernWelcomeScreen> createState() => _ModernWelcomeScreenState();
}

class _ModernWelcomeScreenState extends State<ModernWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseController;
  late AnimationController _flowController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  // For parallax effect
  final _parallaxController = TransformationController();

  // For liquid animation effect
  late List<Offset> _liquidPoints = [];

  bool _isScreenTapped = false;
  double _tapX = 0;
  double _tapY = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLiquidEffect();
    _startAnimationSequence();

    // Enable device motion effects if available
    _initializeDeviceMotion();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _flowController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _initializeLiquidEffect() {
    const pointCount = 8;
    _liquidPoints = List.generate(pointCount, (index) {
      final angle = index * (2 * math.pi / pointCount);
      return Offset(math.cos(angle), math.sin(angle));
    });
  }

  void _initializeDeviceMotion() {
    // For a production app, implement actual device motion using sensors
    // This would typically use platform channels or a package like sensors_plus
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();

      Future.delayed(const Duration(milliseconds: 500), () {
        _buttonController.forward();
      });
    });
  }

  void _handleScreenTap(TapDownDetails details) {
    setState(() {
      _isScreenTapped = true;
      _tapX = details.localPosition.dx;
      _tapY = details.localPosition.dy;

      // Auto-reset after animation completes
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isScreenTapped = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseController.dispose();
    _flowController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen(BuildContext context) {
    HapticFeedback.mediumImpact();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTapDown: _handleScreenTap,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            transformationController: _parallaxController,
            panEnabled: false,
            scaleEnabled: false,
            child: Stack(
              children: [
                // Dynamic background with animated gradient
                AnimatedBuilder(
                  animation: Listenable.merge([_mainAnimationController, _pulseController]),
                  builder: (context, child) {
                    return Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            math.sin(_mainAnimationController.value * math.pi * 2) * 0.2,
                            math.cos(_mainAnimationController.value * math.pi * 2) * 0.2,
                          ),
                          radius: 1.0 + (_pulseController.value * 0.3),
                          colors: [
                            Color(0xFF1E0043),
                            Color(0xFF0D0221),
                            Colors.black,
                          ],
                          stops: [0.0, 0.4 + (_pulseController.value * 0.1), 1.0],
                        ),
                      ),
                    );
                  },
                ),

                // Neural net-like background decoration
                AnimatedBuilder(
                  animation: _flowController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size.width, size.height),
                      painter: NeuralNetworkPainter(
                        animation: _flowController.value,
                        mainAnimation: _mainAnimationController.value,
                        pulseValue: _pulseController.value,
                        isScreenTapped: _isScreenTapped,
                        tapPosition: Offset(_tapX, _tapY),
                      ),
                    );
                  },
                ),

                // Floating particles
                AnimatedBuilder(
                  animation: _mainAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size.width, size.height),
                      painter: NeomorphicParticlesPainter(
                        animation: _mainAnimationController.value,
                        pulseValue: _pulseController.value,
                      ),
                    );
                  },
                ),

                // Dynamic 3D card effect with glassmorphism
                Center(
                  child: TiltContainer(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: size.width * 0.9,
                          height: size.height * 0.75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF512DA8).withOpacity(0.3 + _pulseController.value * 0.2),
                                blurRadius: 30,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Liquid-like animated border
                              AnimatedBuilder(
                                animation: _mainAnimationController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: Size(size.width * 0.9, size.height * 0.75),
                                    painter: LiquidBorderPainter(
                                      animation: _mainAnimationController.value,
                                      pulseValue: _pulseController.value,
                                      pointCount: 8,
                                    ),
                                  );
                                },
                              ),
                              // Glass card
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(30),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Animated logo
                                          AnimatedBuilder(
                                            animation: Listenable.merge([_mainAnimationController, _pulseController]),
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: _mainAnimationController.value * math.pi * 2,
                                                child: NeoLogo(
                                                  pulseValue: _pulseController.value,
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 40),

                                          // Main title with animation
                                          AnimatedBuilder(
                                            animation: _textController,
                                            builder: (context, child) {
                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0, 0.5),
                                                  end: Offset.zero,
                                                ).animate(CurvedAnimation(
                                                  parent: _textController,
                                                  curve: Curves.easeOutCubic,
                                                )),
                                                child: FadeTransition(
                                                  opacity: _textController,
                                                  child: const GlitchText(
                                                    text: 'به دنیای برنامه ریز سفر قدم بگذارید',
                                                    textStyle: TextStyle(
                                                      fontFamily: 'Vazir',
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 20),

                                          // Subtitle with character-by-character animation
                                          AnimatedBuilder(
                                            animation: _textController,
                                            builder: (context, child) {
                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0, 0.3),
                                                  end: Offset.zero,
                                                ).animate(CurvedAnimation(
                                                  parent: _textController,
                                                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                                                )),
                                                child: FadeTransition(
                                                  opacity: Tween<double>(begin: 0, end: 0.8).animate(
                                                    CurvedAnimation(
                                                      parent: _textController,
                                                      curve: const Interval(0.3, 1.0),
                                                    ),
                                                  ),
                                                  child: const TypewriterAnimatedText(
                                                    text: 'تجربه‌ای منحصر به فرد از زیبایی و عملکرد',
                                                    textStyle: TextStyle(
                                                      fontFamily: 'Vazir',
                                                      fontSize: 16,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 60),

                                          // Buttons with animated effects
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GlowingTextButton(
                                                onPressed: () => _navigateToNextScreen(context),
                                                text: 'رد کردن',
                                                isSecondary: true,
                                                animation: _buttonController,
                                                delay: 0.0,
                                              ),

                                              const SizedBox(width: 20),

                                              GlowingTextButton(
                                                onPressed: () => _navigateToNextScreen(context),
                                                text: 'آغاز سفر',
                                                isSecondary: false,
                                                animation: _buttonController,
                                                delay: 0.2,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Neural network background
class NeuralNetworkPainter extends CustomPainter {
  final double animation;
  final double mainAnimation;
  final double pulseValue;
  final bool isScreenTapped;
  final Offset tapPosition;

  NeuralNetworkPainter({
    required this.animation,
    required this.mainAnimation,
    required this.pulseValue,
    required this.isScreenTapped,
    required this.tapPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeCount = 20;
    final nodes = <Offset>[];

    // Generate nodes in a grid-like pattern
    for (int i = 0; i < nodeCount; i++) {
      final x = size.width * (0.2 + 0.6 * ((i % 4) / 3)) +
          math.sin(animation * 2 * math.pi + i) * 20;

      final y = size.height * (0.1 + 0.8 * ((i ~/ 4) / 4)) +
          math.cos(animation * 2 * math.pi + i) * 20;

      nodes.add(Offset(x, y));
    }

    // Connect nodes with animated lines
    final linePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        // Only connect some nodes for a cleaner look
        if ((i % 3 == 0 && j % 2 == 0) || (i % 4 == 0 && j % 3 == 0)) {
          final distance = (nodes[i] - nodes[j]).distance;
          final maxDistance = size.width * 0.3;

          if (distance < maxDistance) {
            final opacity = (1 - distance / maxDistance) * 0.5;

            // Add pulse effect
            final flowOffset = (animation + i * 0.05 + j * 0.03) % 1.0;
            final flowOpacity = (1 - (2 * flowOffset - 1).abs()) * 0.6;

            linePaint.color = Color.lerp(
              Color(0xFF7B2CBF),
              Color(0xFF9D4EDD),
              flowOpacity,
            )!.withOpacity(opacity * (0.4 + pulseValue * 0.2));

            // Draw the connection
            canvas.drawLine(nodes[i], nodes[j], linePaint);

            // Draw flowing data point
            if ((i + j) % 3 == 0) {
              final dataPoint = Offset.lerp(nodes[i], nodes[j], flowOffset)!;

              canvas.drawCircle(
                dataPoint,
                2 + pulseValue * 1.5,
                Paint()..color = Color(0xFFE0AAFF).withOpacity(flowOpacity * 0.8),
              );
            }
          }
        }
      }
    }

    // Draw the nodes
    for (int i = 0; i < nodes.length; i++) {
      final nodeSize = 4.0 + (i % 3) * 1.5 + pulseValue * 2.0;

      // Add special effect when screen is tapped
      if (isScreenTapped) {
        final distanceFromTap = (nodes[i] - tapPosition).distance;
        final maxEffectDistance = size.width * 0.4;

        if (distanceFromTap < maxEffectDistance) {
          final effectStrength = 1 - (distanceFromTap / maxEffectDistance);
          final expandedSize = nodeSize * (1 + effectStrength * 1.5);

          canvas.drawCircle(
            nodes[i],
            expandedSize,
            Paint()
              ..color = Color.lerp(
                Color(0xFFBB86FC),
                Color(0xFF4A36A7),
                effectStrength,
              )!.withOpacity(0.6 * effectStrength),
          );
        }
      }

      canvas.drawCircle(
        nodes[i],
        nodeSize,
        Paint()
          ..color = Color.lerp(
            Color(0xFF7B2CBF),
            Color(0xFFC77DFF),
            (math.sin(mainAnimation * 2 * math.pi + i) + 1) / 2,
          )!.withOpacity(0.7 + pulseValue * 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(NeuralNetworkPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.mainAnimation != mainAnimation ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isScreenTapped != isScreenTapped;
  }
}

// Neomorphic particles
class NeomorphicParticlesPainter extends CustomPainter {
  final double animation;
  final double pulseValue;

  NeomorphicParticlesPainter({
    required this.animation,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particleCount = 30;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 0.1;
      final animOffset = (animation + seed) % 1.0;

      // Create varied particle paths
      final pathType = i % 5;
      late double x, y;

      switch (pathType) {
        case 0: // Spiral
          final angle = animOffset * 10 * math.pi;
          final radius = size.width * 0.3 * animOffset;
          x = size.width / 2 + math.cos(angle) * radius;
          y = size.height / 2 + math.sin(angle) * radius;
          break;
        case 1: // Sine wave
          x = size.width * animOffset;
          y = size.height / 2 + math.sin(animOffset * 6 * math.pi) * (size.height * 0.2);
          break;
        case 2: // Diagonal
          x = size.width * animOffset;
          y = size.height * animOffset;
          break;
        case 3: // Circle
          final angle = animOffset * 2 * math.pi;
          final radius = size.width * 0.4;
          x = size.width / 2 + math.cos(angle) * radius;
          y = size.height / 2 + math.sin(angle) * radius;
          break;
        default: // Random float
          x = size.width * (0.2 + 0.6 * ((seed * 10) % 1.0));
          y = size.height * (0.1 + 0.8 * animOffset);
      }

      // Create particles with glows and depth effect
      final particleSize = 6.0 + (i % 3) * 2.0 + pulseValue * 3.0;
      final opacity = 0.6 + 0.4 * math.sin(animation * 2 * math.pi + i);

      // Shadow for depth
      canvas.drawCircle(
        Offset(x + 2, y + 2),
        particleSize * 0.7,
        Paint()..color = Colors.black.withOpacity(0.3),
      );

      // Base particle
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color(0xFF9D4EDD).withOpacity(opacity),
              Color(0xFF7B2CBF).withOpacity(opacity * 0.7),
            ],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: particleSize)),
      );

      // Highlight for neomorphic effect
      canvas.drawCircle(
        Offset(x - particleSize * 0.3, y - particleSize * 0.3),
        particleSize * 0.4,
        Paint()..color = Colors.white.withOpacity(0.4 * opacity),
      );

      // Optional glow effect for some particles
      if (i % 4 == 0) {
        canvas.drawCircle(
          Offset(x, y),
          particleSize * 1.8,
          Paint()
            ..color = Color(0xFFBB86FC).withOpacity(0.15 * opacity * pulseValue)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(NeomorphicParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.pulseValue != pulseValue;
  }
}

// Liquid border effect
class LiquidBorderPainter extends CustomPainter {
  final double animation;
  final double pulseValue;
  final int pointCount;

  LiquidBorderPainter({
    required this.animation,
    required this.pulseValue,
    required this.pointCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        colors: [
          Color(0xFF7B2CBF),
          Color(0xFFBB86FC),
          Color(0xFF5E60CE),
          Color(0xFF7B2CBF),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: GradientRotation(animation * 2 * math.pi),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    for (int i = 0; i <= pointCount; i++) {
      final angle = (i % pointCount) * (2 * math.pi / pointCount);

      // Add wave effect to radius for liquid animation
      final radiusVariation = math.sin(angle * 3 + animation * 2 * math.pi) *
          (10 + pulseValue * 5);

      final radiusX = (size.width / 2) - 2 + radiusVariation;
      final radiusY = (size.height / 2) - 2 + radiusVariation;

      final x = centerX + math.cos(angle) * radiusX;
      final y = centerY + math.sin(angle) * radiusY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Use quadratic bezier curves for smoother transitions
        final prevAngle = ((i - 1) % pointCount) * (2 * math.pi / pointCount);
        final prevX = centerX + math.cos(prevAngle) * ((size.width / 2) - 2 +
            math.sin(prevAngle * 3 + animation * 2 * math.pi) * (10 + pulseValue * 5));
        final prevY = centerY + math.sin(prevAngle) * ((size.height / 2) - 2 +
            math.sin(prevAngle * 3 + animation * 2 * math.pi) * (10 + pulseValue * 5));

        final controlX = (prevX + x) / 2 + math.sin(angle) * 15;
        final controlY = (prevY + y) / 2 - math.cos(angle) * 15;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    path.close();
    canvas.drawPath(path, borderPaint);

    // Add subtle glow
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Color(0xFFBB86FC).withOpacity(0.2 + pulseValue * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Add highlight dots at curve points
    for (int i = 0; i < pointCount; i++) {
      final angle = i * (2 * math.pi / pointCount);
      final radiusVariation = math.sin(angle * 3 + animation * 2 * math.pi) *
          (10 + pulseValue * 5);

      final radiusX = (size.width / 2) - 2 + radiusVariation;
      final radiusY = (size.height / 2) - 2 + radiusVariation;

      final x = centerX + math.cos(angle) * radiusX;
      final y = centerY + math.sin(angle) * radiusY;

      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(x, y),
          3.0 + pulseValue * 1.5,
          Paint()..color = Color(0xFFE0AAFF),
        );
      }
    }
  }

  @override
  bool shouldRepaint(LiquidBorderPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.pulseValue != pulseValue;
  }
}

// 3D tilt effect container
class TiltContainer extends StatefulWidget {
  final Widget child;

  const TiltContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<TiltContainer> createState() => _TiltContainerState();
}

class _TiltContainerState extends State<TiltContainer> {
  double _rotationX = 0;
  double _rotationY = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => _resetTilt(),
      onHover: (event) {
        if (!_isHovering) return;

        final size = MediaQuery.of(context).size;
        final centerX = size.width / 2;
        final centerY = size.height / 2;

        setState(() {
          _rotationY = ((event.position.dx - centerX) / centerX) * 0.03;
          _rotationX = ((centerY - event.position.dy) / centerY) * 0.03;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotationX)
          ..rotateY(_rotationY),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }

  void _resetTilt() {
    setState(() {
      _rotationX = 0;
      _rotationY = 0;
      _isHovering = false;
    });
  }
}

// Futuristic animated logo
class NeoLogo extends StatelessWidget {
  final double pulseValue;

  const NeoLogo({
    Key? key,
    required this.pulseValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7B2CBF).withOpacity(0.4 + pulseValue * 0.3),
            blurRadius: 20 + pulseValue * 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(120, 120),
        painter: FuturisticLogoPainter(pulseValue: pulseValue),
      ),
    );
  }
}

class FuturisticLogoPainter extends CustomPainter {
  final double pulseValue;

  FuturisticLogoPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer rings with dynamic glow
    for (int i = 0; i < 3; i++) {
      final ringRadius = 45.0 - (i * 10);
      final intensity = (1 - (i * 0.3)) * (0.7 + pulseValue * 0.3);

      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Color.lerp(
            Color(0xFF9D4EDD),
            Color(0xFFE0AAFF),
            intensity,
          )!.withOpacity(intensity),
      );
    }

    // Geometric design in center
    final path = Path();
    final hexRadius = 25.0 + pulseValue * 3.0;

    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3);
      final x = center.dx + hexRadius * math.cos(angle);
      final y = center.dy + hexRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Gradient fill for hexagon
    final hexPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFFBB86FC),
          Color(0xFF7B2CBF),
        ],
        radius: 0.8,
        center: Alignment(-0.2, -0.2),
      ).createShader(Rect.fromCircle(center: center, radius: hexRadius));

    canvas.drawPath(path, hexPaint);

    // Inner triangle
    final trianglePath = Path();
    final triangleRadius = 15.0 + pulseValue * 2.0;

    for (int i = 0; i < 3; i++) {
      final angle = i * (2 * math.pi / 3) + (math.pi / 6);
      final x = center.dx + triangleRadius * math.cos(angle);
      final y = center.dy + triangleRadius * math.sin(angle);

      if (i == 0) {
        trianglePath.moveTo(x, y);
      } else {
        trianglePath.lineTo(x, y);
      }
    }
    trianglePath.close();

    // Contrasting fill for triangle
    canvas.drawPath(
      trianglePath,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Draw dynamic particles around logo
    final particleCount = 8;
    for (int i = 0; i < particleCount; i++) {
      final angle = i * (2 * math.pi / particleCount);
      final particleOffset = 10.0 * pulseValue;
      final distance = 40.0 + particleOffset;

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        2.0 + pulseValue * 1.0,
        Paint()..color = Color(0xFFE0AAFF).withOpacity(0.8 + pulseValue * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(FuturisticLogoPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}

// Text with glitch effect
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const GlitchText({
    Key? key,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  late String _displayText;
  Color _glitchColor = Colors.transparent;
  double _glitchOffset = 0;
  bool _showGlitch = false;

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(_triggerGlitch);

    _glitchController.repeat();
  }

  void _triggerGlitch() {
    if (_glitchController.value > 0.9 && _glitchController.value < 0.915) {
      setState(() {
        _showGlitch = true;
        _glitchOffset = (math.Random().nextDouble() - 0.5) * 8;
        _glitchColor = Color(0xFFE0AAFF).withOpacity(0.8);
      });
    } else if (_glitchController.value > 0.925) {
      setState(() {
        _showGlitch = false;
      });
    }
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main text
        Text(
          _displayText,
          style: widget.textStyle.copyWith(
            shadows: [
              Shadow(
                color: Color(0xFF9D4EDD).withOpacity(0.8),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        // Glitch effect layers
        if (_showGlitch)
          Positioned(
            left: _glitchOffset,
            child: Text(
              _displayText,
              style: widget.textStyle.copyWith(
                color: _glitchColor,
                shadows: [
                  Shadow(
                    color: Color(0xFFBB86FC),
                    blurRadius: 5,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

        if (_showGlitch)
          Positioned(
            left: -_glitchOffset * 1.2,
            child: Text(
              _displayText,
              style: widget.textStyle.copyWith(
                color: Color(0xFF7B2CBF).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// Typewriter text animation
class TypewriterAnimatedText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const TypewriterAnimatedText({
    Key? key,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  State<TypewriterAnimatedText> createState() => _TypewriterAnimatedTextState();
}

class _TypewriterAnimatedTextState extends State<TypewriterAnimatedText> with SingleTickerProviderStateMixin {
  late AnimationController _typewriterController;
  String _displayText = "";

  @override
  void initState() {
    super.initState();

    _typewriterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * 60),
    )..addListener(_updateText);

    Future.delayed(const Duration(milliseconds: 800), () {
      _typewriterController.forward();
    });
  }

  void _updateText() {
    final progress = _typewriterController.value;
    final characterCount = (widget.text.length * progress).floor();

    setState(() {
      _displayText = widget.text.substring(0, characterCount);
    });
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _displayText,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
        if (_typewriterController.isAnimating)
          _buildCursor(),
      ],
    );
  }

  Widget _buildCursor() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        "|",
        style: widget.textStyle.copyWith(
          color: Color(0xFFBB86FC),
        ),
      ),
    );
  }
}

// Glowing button with animation
class GlowingTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSecondary;
  final Animation<double> animation;
  final double delay;

  const GlowingTextButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.isSecondary,
    required this.animation,
    required this.delay,
  }) : super(key: key);

  @override
  State<GlowingTextButton> createState() => _GlowingTextButtonState();
}

class _GlowingTextButtonState extends State<GlowingTextButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: widget.animation,
        curve: Interval(
          0.6 + widget.delay,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: widget.animation,
          curve: Interval(
            0.6 + widget.delay,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        )),
        child: MouseRegion(
          onEnter: (_) => _handleHoverChange(true),
          onExit: (_) => _handleHoverChange(false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onPressed();
            },
            child: AnimatedBuilder(
              animation: _hoverController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isSecondary ? 25 : 40,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: widget.isSecondary
                          ? Colors.transparent
                          : Color.lerp(
                        Color(0xFF7B2CBF),
                        Color(0xFF9D4EDD),
                        _hoverController.value,
                      )!.withOpacity(0.8 + _hoverController.value * 0.2),
                      border: Border.all(
                        color: widget.isSecondary
                            ? Colors.white.withOpacity(0.5)
                            : Color(0xFFBB86FC).withOpacity(0.8),
                        width: 1.5,
                      ),
                      boxShadow: widget.isSecondary
                          ? null
                          : [
                        BoxShadow(
                          color: Color(0xFF7B2CBF).withOpacity(
                            0.3 + _hoverController.value * 0.3,
                          ),
                          blurRadius: 15 + _hoverController.value * 10,
                          spreadRadius: 1 + _hoverController.value * 2,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFFBB86FC).withOpacity(
                              0.5 + _hoverController.value * 0.5,
                            ),
                            blurRadius: 5 + _hoverController.value * 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}