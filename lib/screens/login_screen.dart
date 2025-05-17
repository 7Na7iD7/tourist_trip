import 'dart:math';
import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tourist_planner_screen.dart'; // Assuming this screen exists

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // Animation Controllers
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonShadowAnimation;

  final Map<String, AnimationController> _fieldAnimationControllers = {};
  final Map<String, Animation<double>> _fieldScaleAnimations = {};
  final Map<String, Animation<Offset>> _fieldTranslateAnimations = {};

  late AnimationController _backgroundAnimationController;
  // اینها در didChangeDependencies مقداردهی می‌شوند
  late Animation<Color?> _backgroundGradientColor1Tween;
  late Animation<Color?> _backgroundGradientColor2Tween;

  late AnimationController _logoRingRotationController;
  late Animation<double> _logoRingRotationAnimation;

  late AnimationController _formEntryAnimationController;
  late Animation<double> _formEntryScaleAnimation;
  late Animation<Offset> _formEntryTranslateAnimation;
  late Animation<double> _formEntryFadeAnimation;

  late AnimationController _socialButtonsEntryAnimationController;


  @override
  void initState() {
    super.initState();

    // --- Background Animation Controller ---
    // فقط کنترلر اینجا مقداردهی اولیه می‌شود
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Duration for gradient color change
    )..repeat(reverse: true); // Repeat animation back and forth

    // Animation Tweens که نیاز به Context دارند به didChangeDependencies منتقل می‌شوند


    // --- Button Animation ---
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _buttonShadowAnimation = Tween<double>(begin: 8.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // --- Form Entry Animation ---
    _formEntryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward(); // Start animation on screen load

    _formEntryScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _formEntryAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _formEntryTranslateAnimation = Tween<Offset>(begin: const Offset(0, 50), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _formEntryAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _formEntryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formEntryAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // --- Logo Ring Rotation Animation ---
    _logoRingRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower rotation
    )..repeat(); // Repeat indefinitely

    _logoRingRotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _logoRingRotationController, curve: Curves.linear),
    );


    // --- Social Buttons Entry Animation ---
    _socialButtonsEntryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // --- Background Animation Tweens (انتقال یافته از initState) ---
    _backgroundGradientColor1Tween = ColorTween(
      begin: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      end: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
    ).animate(_backgroundAnimationController);

    _backgroundGradientColor2Tween = ColorTween(
      begin: Theme.of(context).colorScheme.secondary,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_backgroundAnimationController);

    // --- Field Animations (انتقال بخش مقداردهی اولیه کنترلرها به اینجا) ---
    // اطمینان حاصل کنید که کلیدهای این مپ‌ها یونیک هستند
    ['email', 'password', 'rememberMeCheckbox', 'forgotPasswordButton'].forEach((field) { // تغییر کلیدها برای وضوح بیشتر
      if (!_fieldAnimationControllers.containsKey(field)) { // اگر از قبل مقداردهی نشده
        _fieldAnimationControllers[field] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        );
        _fieldScaleAnimations[field] = Tween<double>(begin: 1.0, end: 1.02).animate( // Subtle scale
          CurvedAnimation(
            parent: _fieldAnimationControllers[field]!,
            curve: Curves.easeInOut,
          ),
        );
        _fieldTranslateAnimations[field] = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -3)).animate( // Subtle upward translation
          CurvedAnimation(
            parent: _fieldAnimationControllers[field]!,
            curve: Curves.easeInOut,
          ),
        );
      }
    });

    // همچنین، برای دکمه‌های شبکه‌های اجتماعی نیز کنترلرهای انیمیشن را اینجا مقداردهی اولیه می‌کنیم
    // از icon.codePoint.toString() به عنوان کلید استفاده می‌کنیم، همانطور که در _buildAnimatedSocialButton انجام می‌شود
    [Icons.g_mobiledata_rounded, Icons.facebook, Icons.apple].forEach((iconData) {
      String key = iconData.codePoint.toString();
      if (!_fieldAnimationControllers.containsKey(key)) { // اگر از قبل مقداردهی نشده
        _fieldAnimationControllers[key] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        );
        _fieldScaleAnimations[key] = Tween<double>(begin: 1.0, end: 1.02).animate(
          CurvedAnimation(
            parent: _fieldAnimationControllers[key]!,
            curve: Curves.easeInOut,
          ),
        );
        _fieldTranslateAnimations[key] = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -3)).animate(
          CurvedAnimation(
            parent: _fieldAnimationControllers[key]!,
            curve: Curves.easeInOut,
          ),
        );
      }
    });
  }


  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _fieldAnimationControllers.forEach((_, controller) => controller.dispose());
    _backgroundAnimationController.dispose();
    _logoRingRotationController.dispose();
    _formEntryAnimationController.dispose();
    _socialButtonsEntryAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _getPasswordStrength() {
    String password = _passwordController.text;
    if (password.isEmpty) return 0;

    double strength = 0;

    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength > 1.0 ? 1.0 : strength;
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return Colors.redAccent;
    if (strength < 0.7) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              const Text('در حال ورود...'),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        // Using a more dynamic transition
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const TouristPlannerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              var fadeTween = Tween(begin: 0.0, end: 1.0);
              var fadeAnimation = animation.drive(fadeTween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      });
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('بازیابی رمز عبور', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('لطفاً ایمیل خود را وارد کنید تا لینک بازیابی رمز عبور برای شما ارسال شود.'),
            const SizedBox(height: 16),
            TextField(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('لینک بازیابی رمز عبور ارسال شد!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ارسال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background to transparent to see the container gradient
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: _backgroundAnimationController,
          builder: (context, child) {
            // استفاده از Tween ها که حالا در didChangeDependencies مقداردهی شده‌اند
            final color1 = _backgroundGradientColor1Tween.value ?? Theme.of(context).colorScheme.primary.withOpacity(0.8);
            final color2 = _backgroundGradientColor2Tween.value ?? Theme.of(context).colorScheme.secondary;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color1,
                    color2,
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Animated Logo
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            double clampedValue = value.clamp(0.0, 1.0);
                            return Opacity(
                              opacity: clampedValue,
                              child: Transform.scale(
                                scale: clampedValue,
                                child: Hero(
                                  tag: 'logo',
                                  child: Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9), // Slightly transparent white
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4 * clampedValue), // Animate shadow opacity
                                          spreadRadius: 2 * clampedValue,
                                          blurRadius: 20 * clampedValue,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _logoRingRotationController,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _logoRingRotationAnimation.value, // Use the continuous rotation animation
                                              child: CustomPaint(
                                                size: const Size(110, 110),
                                                painter: LogoRingPainter(
                                                  progress: 1.0, // Keep rings full
                                                  color: Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0, end: 1),
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.elasticOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Icon(
                                                Icons.map_rounded,
                                                size: 65,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
                                child: Column(
                                  children: [
                                    Text(
                                      'خوش آمدید',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'لطفا برای ادامه وارد حساب خود شوید',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Glassmorphism Form Container
                        AnimatedBuilder(
                          animation: _formEntryAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _formEntryFadeAnimation.value,
                              child: Transform.translate(
                                offset: _formEntryTranslateAnimation.value,
                                child: Transform.scale(
                                  scale: _formEntryScaleAnimation.value,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: (Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[900]
                                              : Colors.white)!.withOpacity(0.3), // Semi-transparent color
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: (Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black)!.withOpacity(0.1), // Subtle border
                                            width: 1.0,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(24),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Email Field
                                              MouseRegion(
                                                onEnter: (_) => _fieldAnimationControllers['email']?.forward(),
                                                onExit: (_) => _fieldAnimationControllers['email']?.reverse(),
                                                child: AnimatedBuilder(
                                                  animation: Listenable.merge([_fieldScaleAnimations['email']!, _fieldTranslateAnimations['email']!]), // اضافه کردن !
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale: _fieldScaleAnimations['email']?.value ?? 1.0,
                                                      child: Transform.translate(
                                                        offset: _fieldTranslateAnimations['email']?.value ?? Offset.zero,
                                                        child: TextFormField(
                                                          controller: _emailController,
                                                          keyboardType: TextInputType.emailAddress,
                                                          textDirection: TextDirection.ltr,
                                                          style: TextStyle(
                                                            color: Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.white70
                                                                : Colors.black87,
                                                          ),
                                                          decoration: InputDecoration(
                                                            labelText: 'ایمیل',
                                                            hintText: 'example@email.com',
                                                            prefixIcon: const Icon(Icons.email_outlined),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            filled: true,
                                                            fillColor: Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.white.withOpacity(0.1) // Use semi-transparent fill
                                                                : Colors.black.withOpacity(0.05),
                                                            contentPadding: const EdgeInsets.symmetric(
                                                              vertical: 16,
                                                              horizontal: 20,
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'لطفا ایمیل خود را وارد کنید';
                                                            }
                                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                                .hasMatch(value)) {
                                                              return 'لطفا یک ایمیل معتبر وارد کنید';
                                                            }
                                                            return null;
                                                          },
                                                          onTap: () {
                                                            HapticFeedback.selectionClick();
                                                            _fieldAnimationControllers['email']?.forward();
                                                          },
                                                          onEditingComplete: () {
                                                            _fieldAnimationControllers['email']?.reverse();
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              // Password Field
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  MouseRegion(
                                                    onEnter: (_) => _fieldAnimationControllers['password']?.forward(),
                                                    onExit: (_) => _fieldAnimationControllers['password']?.reverse(),
                                                    child: AnimatedBuilder(
                                                      animation: Listenable.merge([_fieldScaleAnimations['password']!, _fieldTranslateAnimations['password']!]), // اضافه کردن !
                                                      builder: (context, child) {
                                                        return Transform.scale(
                                                          scale: _fieldScaleAnimations['password']?.value ?? 1.0,
                                                          child: Transform.translate(
                                                            offset: _fieldTranslateAnimations['password']?.value ?? Offset.zero,
                                                            child: TextFormField(
                                                              controller: _passwordController,
                                                              textDirection: TextDirection.ltr,
                                                              obscureText: !_isPasswordVisible,
                                                              style: TextStyle(
                                                                color: Theme.of(context).brightness == Brightness.dark
                                                                    ? Colors.white70
                                                                    : Colors.black87,
                                                              ),
                                                              onChanged: (value) {
                                                                setState(() {}); // Update to show password strength
                                                              },
                                                              decoration: InputDecoration(
                                                                labelText: 'رمز عبور',
                                                                hintText: '********',
                                                                prefixIcon: const Icon(Icons.lock_outline),
                                                                suffixIcon: AnimatedSwitcher(
                                                                  duration: const Duration(milliseconds: 300),
                                                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                                                    return RotationTransition(
                                                                      turns: animation,
                                                                      child: FadeTransition(opacity: animation, child: child),
                                                                    );
                                                                  },
                                                                  child: IconButton(
                                                                    key: ValueKey<bool>(_isPasswordVisible),
                                                                    icon: Icon(
                                                                      _isPasswordVisible
                                                                          ? Icons.visibility_outlined
                                                                          : Icons.visibility_off_outlined,
                                                                    ),
                                                                    onPressed: () {
                                                                      HapticFeedback.lightImpact();
                                                                      setState(() {
                                                                        _isPasswordVisible = !_isPasswordVisible;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  borderSide: BorderSide.none,
                                                                ),
                                                                filled: true,
                                                                fillColor: Theme.of(context).brightness == Brightness.dark
                                                                    ? Colors.white.withOpacity(0.1)
                                                                    : Colors.black.withOpacity(0.05),
                                                                contentPadding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                  horizontal: 20,
                                                                ),
                                                              ),
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'لطفا رمز عبور خود را وارد کنید';
                                                                }
                                                                if (value.length < 8) {
                                                                  return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
                                                                }
                                                                return null;
                                                              },
                                                              onTap: () {
                                                                HapticFeedback.selectionClick();
                                                                _fieldAnimationControllers['password']?.forward();
                                                              },
                                                              onEditingComplete: () {
                                                                _fieldAnimationControllers['password']?.reverse();
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  if (_passwordController.text.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'قدرت رمز عبور:',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.white70
                                                                  : Colors.grey[700],
                                                            ),
                                                          ),
                                                          const SizedBox(height: 6),
                                                          TweenAnimationBuilder<double>(
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeOutCubic,
                                                            tween: Tween<double>(
                                                              begin: 0,
                                                              end: _getPasswordStrength(),
                                                            ),
                                                            builder: (context, value, _) {
                                                              return Stack(
                                                                children: [
                                                                  Container(
                                                                    height: 4,
                                                                    width: double.infinity,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.grey.withOpacity(0.3), // Slightly more visible track
                                                                      borderRadius: BorderRadius.circular(2),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 4,
                                                                    width: MediaQuery.of(context).size.width * 0.7 * value, // Adjust width based on screen size if needed
                                                                    decoration: BoxDecoration(
                                                                      color: _getPasswordStrengthColor(value),
                                                                      borderRadius: BorderRadius.circular(2),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Remember Me and Forgot Password
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  MouseRegion(
                                                    onEnter: (_) => _fieldAnimationControllers['rememberMeCheckbox']?.forward(), // استفاده از کلید جدید
                                                    onExit: (_) => _fieldAnimationControllers['rememberMeCheckbox']?.reverse(), // استفاده از کلید جدید
                                                    child: AnimatedBuilder(
                                                      animation: Listenable.merge([_fieldScaleAnimations['rememberMeCheckbox']!, _fieldTranslateAnimations['rememberMeCheckbox']!]), // اضافه کردن ! و استفاده از کلید جدید
                                                      builder: (context, child) {
                                                        return Transform.scale(
                                                          scale: _fieldScaleAnimations['rememberMeCheckbox']?.value ?? 1.0,
                                                          child: Transform.translate(
                                                            offset: _fieldTranslateAnimations['rememberMeCheckbox']?.value ?? Offset.zero,
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  height: 24,
                                                                  width: 24,
                                                                  child: Theme(
                                                                    data: Theme.of(context).copyWith(
                                                                      unselectedWidgetColor: Theme.of(context).colorScheme.primary.withOpacity(0.7), // More visible checkbox
                                                                    ),
                                                                    child: Checkbox(
                                                                      value: _rememberMe,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          _rememberMe = value ?? false;
                                                                        });
                                                                        HapticFeedback.lightImpact();
                                                                      },
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(4),
                                                                      ),
                                                                      checkColor: Colors.white,
                                                                      activeColor: Theme.of(context).colorScheme.primary,
                                                                      fillColor: MaterialStateProperty.resolveWith((states) { // Animated fill color
                                                                        if (states.contains(MaterialState.selected)) {
                                                                          return Theme.of(context).colorScheme.primary;
                                                                        }
                                                                        return Theme.of(context).colorScheme.primary.withOpacity(0.2);
                                                                      }),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  'مرا به خاطر بسپار',
                                                                  style: TextStyle(
                                                                    color: Theme.of(context).brightness == Brightness.dark
                                                                        ? Colors.white70
                                                                        : Colors.grey[700],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  MouseRegion(
                                                    onEnter: (_) => _fieldAnimationControllers['forgotPasswordButton']?.forward(), // استفاده از کلید جدید
                                                    onExit: (_) => _fieldAnimationControllers['forgotPasswordButton']?.reverse(), // استفاده از کلید جدید
                                                    child: AnimatedBuilder(
                                                      animation: Listenable.merge([_fieldScaleAnimations['forgotPasswordButton']!, _fieldTranslateAnimations['forgotPasswordButton']!]), // اضافه کردن ! و استفاده از کلید جدید
                                                      builder: (context, child) {
                                                        return Transform.scale(
                                                          scale: _fieldScaleAnimations['forgotPasswordButton']?.value ?? 1.0,
                                                          child: Transform.translate(
                                                            offset: _fieldTranslateAnimations['forgotPasswordButton']?.value ?? Offset.zero,
                                                            child: TextButton(
                                                              onPressed: _forgotPassword,
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Theme.of(context).colorScheme.primary,
                                                              ),
                                                              child: Text(
                                                                'فراموشی رمز عبور؟',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  decoration: TextDecoration.underline,
                                                                  decorationThickness: 2,
                                                                  decorationColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              // Login Button
                                              MouseRegion(
                                                onEnter: (_) => _buttonAnimationController.forward(),
                                                onExit: (_) => _buttonAnimationController.reverse(),
                                                child: GestureDetector(
                                                  onTapDown: (_) => _buttonAnimationController.forward(),
                                                  onTapUp: (_) => _buttonAnimationController.reverse(),
                                                  onTapCancel: () => _buttonAnimationController.reverse(),
                                                  onTap: _login,
                                                  child: AnimatedBuilder(
                                                    animation: Listenable.merge([_buttonScaleAnimation, _buttonShadowAnimation]),
                                                    builder: (context, child) {
                                                      double scaleValue = _buttonScaleAnimation.value.clamp(0.95, 1.0);
                                                      double shadowBlur = _buttonShadowAnimation.value;
                                                      return Transform.scale(
                                                        scale: scaleValue,
                                                        child: Container(
                                                          width: double.infinity,
                                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12),
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                              colors: [
                                                                Theme.of(context).colorScheme.primary,
                                                                Theme.of(context).colorScheme.secondary,
                                                              ],
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6), // Slightly more opaque shadow
                                                                blurRadius: shadowBlur, // Animated blur radius
                                                                offset: const Offset(0, 8),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Text(
                                                                'ورود',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Icon(
                                                                Icons.arrow_forward,
                                                                color: Colors.white.withOpacity(0.9), // More visible icon
                                                                size: 20,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              // OR Separator
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                duration: const Duration(milliseconds: 800),
                                                curve: Curves.easeOutCubic,
                                                builder: (context, value, child) {
                                                  double clampedValue = value.clamp(0.0, 1.0);
                                                  return Opacity(
                                                    opacity: clampedValue,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Transform.scale(
                                                            scaleX: clampedValue,
                                                            alignment: Alignment.centerRight,
                                                            child: Divider(
                                                              color: Colors.grey[500], // Slightly darker divider
                                                              thickness: 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                            decoration: BoxDecoration(
                                                              color: (Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.grey[800]
                                                                  : Colors.grey[300])!.withOpacity(0.5), // Semi-transparent background
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Text(
                                                              'یا',
                                                              style: TextStyle(
                                                                color: Theme.of(context).brightness == Brightness.dark
                                                                    ? Colors.white70
                                                                    : Colors.grey[800], // Darker text in light mode
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Transform.scale(
                                                            scaleX: clampedValue,
                                                            alignment: Alignment.centerLeft,
                                                            child: Divider(
                                                              color: Colors.grey[500],
                                                              thickness: 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              // Social Login Buttons
                                              AnimatedBuilder(
                                                animation: _socialButtonsEntryAnimationController,
                                                builder: (context, child) {
                                                  double value = _socialButtonsEntryAnimationController.value;
                                                  return Opacity(
                                                    opacity: value.clamp(0.0, 1.0),
                                                    child: Transform.translate(
                                                      offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          _buildAnimatedSocialButton(
                                                            icon: Icons.g_mobiledata_rounded,
                                                            color: Colors.redAccent, // Brighter red
                                                            interval: const Interval(0.0, 0.6, curve: Curves.elasticOut), // Staggered animation
                                                            onPressed: () {
                                                              HapticFeedback.mediumImpact();
                                                            },
                                                          ),
                                                          const SizedBox(width: 20),
                                                          _buildAnimatedSocialButton(
                                                            icon: Icons.facebook,
                                                            color: Colors.blueAccent, // Brighter blue
                                                            interval: const Interval(0.2, 0.8, curve: Curves.elasticOut), // Staggered animation
                                                            onPressed: () {
                                                              HapticFeedback.mediumImpact();
                                                            },
                                                          ),
                                                          const SizedBox(width: 20),
                                                          _buildAnimatedSocialButton(
                                                            icon: Icons.apple,
                                                            color: Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.white
                                                                : Colors.black87, // Slightly softer black
                                                            interval: const Interval(0.4, 1.0, curve: Curves.elasticOut), // Staggered animation
                                                            onPressed: () {
                                                              HapticFeedback.mediumImpact();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
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
                        const SizedBox(height: 24),
                        // Sign Up Link
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            double clampedValue = value.clamp(0.0, 1.0);
                            return Opacity(
                              opacity: clampedValue,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - clampedValue)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'حساب کاربری ندارید؟',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.2),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: TextButton(
                                        onPressed: () {
                                          HapticFeedback.mediumImpact();
                                          // TODO: Implement sign-up logic
                                        },
                                        child: ShaderMask(
                                          shaderCallback: (bounds) => LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Theme.of(context).colorScheme.secondary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                          blendMode: BlendMode.srcIn,
                                          child: const Text(
                                            'ثبت نام',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: TextDecoration.underline,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedSocialButton({
    required IconData icon,
    required Color color,
    required Interval interval,
    required VoidCallback onPressed,
  }) {
    String key = icon.codePoint.toString(); // استفاده از کد پوینت آیکون به عنوان کلید

    // اطمینان حاصل کنید که کنترلر انیمیشن برای این کلید موجود است
    final animationController = _fieldAnimationControllers[key];
    final scaleAnimation = _fieldScaleAnimations[key];
    final translateAnimation = _fieldTranslateAnimations[key];


    return FadeTransition( // Fade in the buttons
      opacity: CurvedAnimation(parent: _socialButtonsEntryAnimationController, curve: interval),
      child: SlideTransition( // Slide up the buttons
        position: Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
          CurvedAnimation(parent: _socialButtonsEntryAnimationController, curve: interval),
        ),
        child: MouseRegion(
          onEnter: (_) => animationController?.forward(), // استفاده از کنترلر مربوطه
          onExit: (_) => animationController?.reverse(), // استفاده از کنترلر مربوطه
          child: AnimatedBuilder(
            // استفاده از انیمیشن‌های مربوط به این کلید
            animation: Listenable.merge([scaleAnimation!, translateAnimation!]), // اضافه کردن !
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation?.value ?? 1.0,
                child: Transform.translate(
                  offset: translateAnimation?.value ?? Offset.zero,
                  child: Material(
                    elevation: 8,
                    shadowColor: color.withOpacity(0.4), // Slightly more prominent shadow
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onPressed,
                      splashColor: color.withOpacity(0.3), // More visible splash
                      child: Ink(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1) // Semi-transparent background
                              : Colors.black.withOpacity(0.05),
                          border: Border.all(
                            color: color.withOpacity(0.3), // Border matching icon color
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Logo Rings
class LogoRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  LogoRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final startAngle = -pi / 2 + (i * 2 * pi / 3);
      // Keep sweepAngle full for continuous rotation effect
      final sweepAngle = 2 * pi / 3;

      // Vary opacity for a layered effect
      paint.color = color.withOpacity(0.4 + (i * 0.2)); // Adjusted opacity

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (i * 4)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LogoRingPainter oldDelegate) {
    // Repaint continuously for the rotation animation
    return true; // oldDelegate.progress != progress; // Change this to true for continuous rotation
  }
}