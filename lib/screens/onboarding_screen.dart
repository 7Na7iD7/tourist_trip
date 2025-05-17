import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'dart:ui';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  // Controller for background animation
  late AnimationController _backgroundController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Colors for gradient background
  final List<Color> _gradientColors = [
    const Color(0xFF4776E6),
    const Color(0xFF8E54E9),
    const Color(0xFF00BFA6),
    const Color(0xFFFF7676),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Add listener to ensure animation updates are reflected on screen
    _backgroundController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Custom button widget
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isPrimary ? 150 : 120,
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
          colors: [Color(0xFF6FE7C8), Color(0xFF5B8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: const Color(0xFF5B8CFF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
            : null,
        border: isPrimary ? null : Border.all(color: const Color(0xFF5B8CFF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Vazir',
                color: isPrimary ? Colors.white : const Color(0xFF5B8CFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _gradientColors[(_currentPage) % _gradientColors.length],
                        _gradientColors[(_currentPage + 1) % _gradientColors.length],
                      ],
                      stops: [
                        0,
                        _backgroundController.value,
                      ],
                    ).scale(0.1), // Scale opacity to 0.1
                  ),
                );
              },
            ),

            // Floating shapes in background
            ...List.generate(10, (index) {
              final top = (index * 70) % screenSize.height;
              final left = (index * 40) % screenSize.width;

              return Positioned(
                left: left,
                top: top,
                child: AnimatedContainer(
                  duration: Duration(seconds: 2 + index),
                  width: 80 + (index * 5),
                  height: 80 + (index * 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(index % 2 == 0 ? 40 : 20),
                    color: _gradientColors[index % _gradientColors.length].withOpacity(0.05),
                  ),
                ),
              );
            }),

            // Blurred glass effect container
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button and progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "رد کردن",
                            style: TextStyle(
                              fontFamily: 'Vazir',
                              color: Color(0xFF5B8CFF),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF5B8CFF)
                                    : const Color(0xFFD8D8D8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildPage(
                          title: "خوش آمدید!",
                          subtitle: "با برنامه‌ریز سفر، بهترین مسیرهای گردشگری را کشف کنید",
                          description: "به راحتی مکان‌های گردشگری را پیدا کنید و با استفاده از نقشه و راهنمای سفر، تجربه‌ای لذت‌بخش داشته باشید.",
                          iconData: IconlyBold.discovery,
                          backgroundColor: const Color(0xFF5B8CFF).withOpacity(0.1),
                          iconColor: const Color(0xFF5B8CFF),
                        ),
                        _buildPage(
                          title: "مسیر بهینه",
                          subtitle: "زمان خود را وارد کنید و مسیر بهینه را دریافت کنید",
                          description: "سفر خود را با برنامه‌ریزی دقیق و کارآمد لذت بخش‌تر کنید و از هر لحظه آن نهایت استفاده را ببرید.",
                          iconData: IconlyBold.location,
                          backgroundColor: const Color(0xFF6FE7C8).withOpacity(0.1),
                          iconColor: const Color(0xFF6FE7C8),
                        ),
                        _buildPage(
                          title: "شروع کنید!",
                          subtitle: "همین حالا وارد شوید و برنامه‌ریزی سفر خود را آغاز کنید",
                          description: "با ما همراه شوید و سفری به یاد ماندنی را تجربه کنید.",
                          iconData: IconlyBold.login,
                          backgroundColor: const Color(0xFFFFA48E).withOpacity(0.1),
                          iconColor: const Color(0xFFFFA48E),
                          isLastPage: true,
                        ),
                      ],
                    ),
                  ),

                  // Bottom navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentPage > 0
                            ? _buildButton(
                          text: "قبلی",
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          isPrimary: false,
                        )
                            : const SizedBox(width: 120),
                        _currentPage < 2
                            ? _buildButton(
                          text: "بعدی",
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          isPrimary: true,
                        )
                            : _buildButton(
                          text: "شروع",
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          isPrimary: true,
                        ),
                      ],
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

  Widget _buildPage({
    required String title,
    required String subtitle,
    required String description,
    required IconData iconData,
    required Color backgroundColor,
    required Color iconColor,
    bool isLastPage = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with animation
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(bottom: 40),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  iconData,
                  size: 100,
                  color: iconColor,
                ),
              ),
            ),
          ),

          // Title with animated underline
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, iconColor, Colors.transparent],
                      begin: Alignment.centerLeft,
                       end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3142).withOpacity(0.8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                color: const Color(0xFF2D3142).withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ),

          // Call to action for last page
          if (isLastPage)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconlyLight.arrowDown, color: Color(0xFF5B8CFF)),
                    SizedBox(width: 8),
                    Text(
                      "برای شروع به پایین بروید",
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        color: Color(0xFF5B8CFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Extension for scaling LinearGradient opacity
extension GradientOpacity on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      begin: begin ?? Alignment.centerLeft,
      end: end ?? Alignment.centerRight,
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      stops: stops,
    );
  }
}