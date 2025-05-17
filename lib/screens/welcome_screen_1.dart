import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  // Controllers for various animations
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late AnimationController _morphController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonGlowAnimation;
  late Animation<double> _morphAnimation;

  // Card animations
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardScaleAnimations = [];
  final List<Animation<double>> _cardRotateAnimations = [];
  final List<Animation<Color?>> _cardColorAnimations = [];

  // Particle system
  final List<Particle> _particles = [];
  final int _particleCount = 30;

  // Theme colors - 2025 trends feature vibrant gradients and neon accents
  final Color _primaryColor = const Color(0xFF6C4AFF);
  final Color _accentColor = const Color(0xFF00F8E0);
  final Color _tertiaryColor = const Color(0xFFFF6188);
  final Color _quaternaryColor = const Color(0xFFFBEF5A);

  // Glass effect intensities
  final double _blurSigma = 15.0;
  final double _glassBorderWidth = 1.0;
  final double _glassOpacity = 0.12;

  @override
  void initState() {
    super.initState();

    // Set preferred orientation and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _primaryColor.withOpacity(0.8),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Background animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_backgroundController);

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)
      ),
    );

    // Title animation controller
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    // Card animation controller
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Button animation controller
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _buttonGlowAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Morph animation controller
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _morphAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_morphController);

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize particles
    _initializeParticles();

    // Card animations
    for (int i = 0; i < 4; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _cardControllers.add(controller);

      _cardScaleAnimations.add(
        Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        ),
      );

      _cardRotateAnimations.add(
        Tween<double>(begin: 0.05, end: 0.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
      );

      // Unique color animation for each card
      _cardColorAnimations.add(
        ColorTween(
          begin: i % 2 == 0 ? _primaryColor : _accentColor,
          end: i % 2 == 0 ? _primaryColor.withOpacity(0.7) : _accentColor.withOpacity(0.7),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
          ),
        ),
      );
    }

    // Start animations with sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _titleController.forward();
    });

    // Start card animations with cascading delay
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 800 + (i * 150)), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }

    // Start particle controller
    _particleController.repeat();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble() * 400,
          y: random.nextDouble() * 800,
          radius: random.nextDouble() * 3 + 1,
          color: [_accentColor, _tertiaryColor, _quaternaryColor][random.nextInt(3)].withOpacity(0.7),
          speedX: (random.nextDouble() - 0.5) * 0.8,
          speedY: (random.nextDouble() - 0.5) * 0.8,
        ),
      );
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      // Boundary check and reposition
      if (particle.x < 0 || particle.x > 400) {
        particle.speedX *= -1;
      }

      if (particle.y < 0 || particle.y > 800) {
        particle.speedY *= -1;
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _morphController.dispose();
    _particleController.dispose();

    for (var controller in _cardControllers) {
      controller.dispose();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  void _navigateToOnboardingScreen(BuildContext context) {
    _performButtonPressEffect(() {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        _createPageRouteTransition(const OnboardingScreen()),
      );
    });
  }

  void _navigateToLoginScreen(BuildContext context) {
    _performButtonPressEffect(() {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        _createPageRouteTransition(const LoginScreen()),
      );
    });
  }

  void _performButtonPressEffect(VoidCallback callback) {
    _buttonController.forward().then((_) {
      _buttonController.reverse().then((_) {
        callback();
      });
    });
  }

  PageRouteBuilder _createPageRouteTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;

        var offsetAnimation = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve))
            .animate(animation);

        var opacityAnimation = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: curve))
            .animate(animation);

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 30 * animation.value,
            sigmaY: 30 * animation.value,
          ),
          child: SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cardScaleAnimations[index],
        _cardRotateAnimations[index],
        _cardColorAnimations[index],
        _morphAnimation,
      ]),
      builder: (context, child) {
        // Morph factor for the card shape
        final morphFactor = math.sin(_morphAnimation.value + index * 0.5) * 0.05;

        return Transform.scale(
          scale: _cardScaleAnimations[index].value,
          child: Transform.rotate(
            angle: _cardRotateAnimations[index].value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _cardControllers[index].reverse().then((_) {
                  _cardControllers[index].forward();
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 + morphFactor * 8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _cardColorAnimations[index].value ?? _primaryColor,
                      (_cardColorAnimations[index].value ?? _accentColor).withOpacity(0.5),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_cardColorAnimations[index].value ?? _primaryColor).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24 + morphFactor * 8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: _glassBorderWidth,
                        ),
                        borderRadius: BorderRadius.circular(24 + morphFactor * 8),
                        color: Colors.white.withOpacity(_glassOpacity),
                      ),
                      child: Row(
                        children: [
                          _buildGlowingIcon(icon, index),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowingIcon(IconData icon, int index) {
    final colors = [
      _accentColor,
      _quaternaryColor,
      _tertiaryColor,
      _accentColor,
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [colors[index], Colors.white],
            tileMode: TileMode.mirror,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_buttonScaleAnimation, _buttonGlowAnimation, _morphAnimation]),
        builder: (context, child) {
          final glowOpacity = _buttonController.status == AnimationStatus.forward ? 0.5 : 0.0;
          final morphFactor = math.sin(_morphAnimation.value) * 5.0;

          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: isPrimary ? 180 : 140,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28 + morphFactor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPrimary
                      ? [_accentColor, _primaryColor.withBlue(255)]
                      : [Colors.transparent, Colors.transparent],
                ),
                border: Border.all(
                  color: isPrimary ? Colors.white.withOpacity(0.3) : _accentColor,
                  width: 1.5,
                ),
                boxShadow: isPrimary
                    ? [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.5),
                    blurRadius: 20 * _buttonGlowAnimation.value,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: _primaryColor.withOpacity(glowOpacity),
                    blurRadius: 30 * _buttonGlowAnimation.value,
                    spreadRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28 + morphFactor),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: isPrimary ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          color: isPrimary ? Colors.white : _accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          shadows: [
                            Shadow(
                              color: isPrimary ? _accentColor.withOpacity(0.5) : Colors.transparent,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Update particles on each build
    _updateParticles();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Base gradient
                    Container(
                      width: screenSize.width,
                      height: screenSize.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryColor.withOpacity(0.8),
                            _primaryColor.withBlue(190),
                          ],
                        ),
                      ),
                    ),
                    // Animated gradient overlay
                    Positioned(
                      top: -screenSize.height / 2,
                      left: -screenSize.width / 2,
                      child: Transform.rotate(
                        angle: _backgroundAnimation.value,
                        child: Container(
                          width: screenSize.width * 2,
                          height: screenSize.height * 2,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                _primaryColor.withOpacity(0.0),
                                _tertiaryColor.withOpacity(0.3),
                                _accentColor.withOpacity(0.2),
                                _primaryColor.withOpacity(0.0),
                              ],
                              stops: const [0.3, 0.6, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Mesh gradient effect
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CustomPaint(
                        painter: MeshGradientPainter(
                          color1: _accentColor,
                          color2: _primaryColor,
                          color3: _tertiaryColor,
                          color4: _quaternaryColor,
                          animValue: _backgroundAnimation.value,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Particle system
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(particles: _particles),
                  size: Size(screenSize.width, screenSize.height),
                );
              },
            ),

            // Blurred overlay for readability
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                width: screenSize.width,
                height: screenSize.height,
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with skip button and login button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _navigateToOnboardingScreen(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'رد کردن',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _navigateToLoginScreen(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'ورود',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Animated Logo
                          AnimatedBuilder(
                            animation: Listenable.merge([_logoScaleAnimation, _logoRotateAnimation]),
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _logoRotateAnimation.value,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.8),
                                          Colors.white.withOpacity(0.2),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _accentColor.withOpacity(0.5),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: _primaryColor.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _accentColor,
                                              _primaryColor,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: const Icon(
                                          Icons.explore,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Animated Title
                          AnimatedBuilder(
                            animation: Listenable.merge([_titleScaleAnimation, _titleOpacityAnimation]),
                            builder: (context, child) {
                              return Opacity(
                                opacity: _titleOpacityAnimation.value,
                                child: Transform.scale(
                                  scale: _titleScaleAnimation.value,
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.8),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'سفر هوشمند',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 0.7,
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 15,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          // Subtitle
                          AnimatedBuilder(
                            animation: _titleOpacityAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _titleOpacityAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'برنامه‌ریزی سفر خود را هوشمندانه مدیریت کنید',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),


                          const SizedBox(height: 17),

                          // Feature Cards with hover effects
                          _buildFeatureCard(
                            title: 'برنامه‌ریزی هوشمند',
                            description: 'استفاده از الگوریتم ها برای بهینه‌سازی برنامه سفر شما',
                            icon: IconlyBold.timeCircle,
                            index: 0,
                          ),
                          _buildFeatureCard(
                            title: 'مسیریابی دو‌بعدی',
                            description: 'نمایش مسیرها با واقعیت افزوده',
                            icon: IconlyBold.location,
                            index: 1,
                          ),
                          _buildFeatureCard(
                            title: 'سفر اشتراکی',
                            description: 'به اشتراک‌گذاری تجربیات سفر و برنامه‌ریزی گروهی',
                            icon: IconlyBold.user3,
                            index: 2,
                          ),
                          _buildFeatureCard(
                            title: 'دستیار صوتی سفر',
                            description: 'راهنمای صوتی هوشمند در طول مسیر سفر شما',
                            icon: IconlyBold.voice,
                            index: 3,
                          ),

                          const SizedBox(height: 50),

                          // Button row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedButton(
                                text: 'شروع کنید',
                                onPressed: () => _navigateToOnboardingScreen(context),
                                isPrimary: true,
                              ),
                              const SizedBox(width: 17),
                              _buildAnimatedButton(
                                text: 'ورود',
                                onPressed: () => _navigateToLoginScreen(context),
                                isPrimary: false,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle class
class Particle {
  double x;
  double y;
  final double radius;
  final Color color;
  double speedX;
  double speedY;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speedX,
    required this.speedY,
  });
}

// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        paint,
      );

      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// Mesh gradient painter
class MeshGradientPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final double animValue;

  MeshGradientPainter({
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Create 4 noise blobs that move around
    final blobs = List.generate(4, (index) {
      final angle = animValue + (index * math.pi / 2);
      final xOffset = math.cos(angle) * width * 0.3;
      final yOffset = math.sin(angle) * height * 0.3;

      return Offset(
        width / 2 + xOffset,
        height / 2 + yOffset,
      );
    });

    // Create gradient for each blob
    final colors = [color1, color2, color3, color4];

    for (int i = 0; i < blobs.length; i++) {
      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, 0.0),
          radius: 0.8,
          colors: [
            colors[i].withOpacity(0.7),
            colors[i].withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
          center: blobs[i],
          radius: width * 0.5,
        ))
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(
        blobs[i],
        width * 0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MeshGradientPainter oldDelegate) => true;
}