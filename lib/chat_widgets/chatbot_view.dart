import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart' as record_package;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chatbot_service.dart';
import '../chat_widgets/message_list.dart';
import '../chat_widgets/message_input_bar.dart';
import 'dart:math' as math;

class ChatbotView extends StatefulWidget {
  final ScrollController? scrollControllerForModal;

  const ChatbotView({Key? key, this.scrollControllerForModal}) : super(key: key);

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _typingAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _messageScrollController = ScrollController();
  final ScrollController _featuresScrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final record_package.AudioRecorder _audioRecorder = record_package.AudioRecorder();
  final SpeechToText _speech = SpeechToText();
  bool _isInputFocused = false;
  bool _isRecording = false;
  bool _isSpeechInitialized = false;
  String _currentTheme = 'primary';
  String _realTimeText = '';
  bool _showGuideOverlay = false;
  int _guideStep = 0;
  double _responseSpeed = 1.0;
  String _selectedLanguage = 'fa_IR';
  bool _hapticFeedbackEnabled = true;
  double _textSize = 16.0;

  final Map<String, Map<String, Color>> _themeColors = {
    'primary': {
      'primary': const Color(0xFF4869F0),
      'secondary': const Color(0xFF6E8BFD),
      'accent': const Color(0xFF93AFFD),
      'background': Colors.white,
      'cardBg': Colors.white,
      'textPrimary': const Color(0xFF2C3550),
      'textSecondary': const Color(0xFF606A88),
    },
    'night': {
      'primary': const Color(0xFF2B3148),
      'secondary': const Color(0xFF444B6E),
      'accent': const Color(0xFF5B638C),
      'background': const Color(0xFF1A1E2D),
      'cardBg': const Color(0xFF272C3F),
      'textPrimary': Colors.white,
      'textSecondary': const Color(0xFFB8BFD4),
    },
    'nature': {
      'primary': const Color(0xFF2E7D32),
      'secondary': const Color(0xFF4CAF50),
      'accent': const Color(0xFF81C784),
      'background': const Color(0xFFF1F8E9),
      'cardBg': Colors.white,
      'textPrimary': const Color(0xFF33691E),
      'textSecondary': const Color(0xFF558B2F),
    },
    'sunset': {
      'primary': const Color(0xFFD84315),
      'secondary': const Color(0xFFFF7043),
      'accent': const Color(0xFFFFAB91),
      'background': const Color(0xFFFBE9E7),
      'cardBg': Colors.white,
      'textPrimary': const Color(0xFFBF360C),
      'textSecondary': const Color(0xFFE64A19),
    },
  };

  final List<Map<String, dynamic>> _specialFeatures = [
    {
      'icon': Icons.flight_takeoff_rounded,
      'title': 'پیشنهاد سفر',
      'prompt': 'لطفا یک سفر سه روزه به سنندج با بودجه محدود پیشنهاد بده'
    },
    {
      'icon': Icons.restaurant_menu_rounded,
      'title': 'پیشنهاد غذا',
      'prompt': 'چهار غذای محلی سنندج را معرفی کن که در سفر باید امتحان کنم'
    },
    {
      'icon': Icons.attractions_rounded,
      'title': 'جاذبه‌های دیدنی',
      'prompt': 'معروف‌ترین جاذبه‌های دیدنی سنندج را به ترتیب اهمیت معرفی کن'
    },
    {
      'icon': Icons.hotel_rounded,
      'title': 'پیشنهاد اقامت',
      'prompt': 'بهترین گزینه‌های اقامتی اقتصادی در سنندج را معرفی کن'
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'title': 'سوغاتی‌ها',
      'prompt': 'معروف‌ترین سوغاتی‌های شهر سنندج را نام ببر'
    },
    {
      'icon': Icons.hiking_rounded,
      'title': 'مسیرهای پیاده‌روی',
      'prompt': 'بهترین مسیرهای پیاده‌روی و کوهنوردی سنندج را معرفی کن'
    },
  ];

  final List<Map<String, dynamic>> _guideSteps = [
    {
      'title': 'هدر دستیار',
      'description': 'از اینجا می‌توانید تم برنامه را تغییر دهید یا به تنظیمات و راهنما دسترسی پیدا کنید.',
      'target': 'header',
    },
    {
      'title': 'ورودی پیام',
      'description': 'پیام خود را اینجا بنویسید یا از میکروفون برای ضبط صدا استفاده کنید.',
      'target': 'input',
    },
    {
      'title': 'ویژگی‌های ویژه',
      'description': 'با کلیک روی این کارت‌ها، پیشنهادات آماده‌ای برای سفر دریافت کنید.',
      'target': 'features',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _focusNode.addListener(() {
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
      });
    });

    _initSpeech();
    _checkMicPermission();
    _loadSettings();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_featuresScrollController.hasClients) {
        _featuresScrollController.animateTo(
          20.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuint,
        );
      }
    });

    _messageScrollController.addListener(() {
      if (_messageScrollController.position.pixels <
          _messageScrollController.position.maxScrollExtent - 50) {
        setState(() {});
      }
    });
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTheme = prefs.getString('theme') ?? 'primary';
      _responseSpeed = prefs.getDouble('responseSpeed') ?? 1.0;
      _selectedLanguage = prefs.getString('language') ?? 'fa_IR';
      _hapticFeedbackEnabled = prefs.getBool('hapticFeedback') ?? true;
      _textSize = prefs.getDouble('textSize') ?? 16.0;
    });
    _animationController.forward();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _currentTheme);
    await prefs.setDouble('responseSpeed', _responseSpeed);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('hapticFeedback', _hapticFeedbackEnabled);
    await prefs.setDouble('textSize', _textSize);
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isRecording = false;
            _waveAnimationController.stop();
            _realTimeText = '';
            _textController.clear();
          });
        }
      },
      onError: (error) {
        setState(() {
          _isRecording = false;
          _waveAnimationController.stop();
          _realTimeText = '';
          _textController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در تشخیص صدا: ${error.errorMsg}')),
          );
        }
      },
    );
    if (available) {
      setState(() {
        _isSpeechInitialized = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تشخیص صدا در دسترس نیست')),
        );
      }
    }
  }

  void _checkMicPermission() async {
    bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً دسترسی میکروفون را فعال کنید')),
      );
    }
  }

  void _startRecording(ChatbotService chatbotService) async {
    if (!_isSpeechInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تشخیص صدا آماده نیست')),
        );
      }
      return;
    }

    bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً دسترسی میکروفون را فعال کنید')),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _realTimeText = '';
      _textController.clear();
      _waveAnimationController.repeat();
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _realTimeText = result.recognizedWords;
          _textController.text = _realTimeText;
        });
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          chatbotService.addUserMessage(result.recognizedWords);
          if (mounted) {
            setState(() {
              _isRecording = false;
              _waveAnimationController.stop();
              _realTimeText = '';
              _textController.clear();
            });
          }
        }
      },
      localeId: _selectedLanguage,
      partialResults: true,
    );
  }

  void _stopRecording() async {
    if (_isRecording) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _waveAnimationController.stop();
          _realTimeText = '';
          _textController.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();
    _focusNode.dispose();
    _messageScrollController.dispose();
    _featuresScrollController.dispose();
    _textController.dispose();
    _speech.stop();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_messageScrollController.hasClients) {
      final position = _messageScrollController.position;
      if (position.pixels < position.maxScrollExtent - 50 && mounted) {
        _messageScrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatbotService = Provider.of<ChatbotService>(context);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final currentColors = _themeColors[_currentTheme] ?? _themeColors['primary']!;

    if (chatbotService.isBotTyping) {
      _typingAnimationController.repeat();
    } else {
      _typingAnimationController.stop();
    }

    if (chatbotService.messages.isNotEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return SafeArea(
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.85,
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: currentColors['background'],
                borderRadius: widget.scrollControllerForModal != null
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                )
                    : null,
                boxShadow: widget.scrollControllerForModal != null
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, -3),
                  )
                ]
                    : [],
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildEnhancedHeader(currentColors),
                    if (chatbotService.messages.isEmpty)
                      _buildSpecialFeatures(currentColors, chatbotService),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildBackgroundWithEffects(currentColors),
                            ),
                            MessageList(
                              messages: chatbotService.messages,
                              scrollController: widget.scrollControllerForModal ?? _messageScrollController,
                            ),
                            if (_messageScrollController.hasClients &&
                                _messageScrollController.position.pixels <
                                    _messageScrollController.position.maxScrollExtent - 50 &&
                                mounted)
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: _buildScrollToBottomButton(currentColors),
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: chatbotService.isBotTyping && mounted
                          ? _buildEnhancedTypingIndicator(currentColors)
                          : const SizedBox(height: 0),
                    ),
                    _buildEnhancedInputBar(currentColors, chatbotService),
                  ],
                ),
              ),
            ),
            if (_showGuideOverlay)
              _buildInteractiveGuideOverlay(currentColors),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton(Map<String, Color> colors) {
    return ScaleTransition(
      scale: _pulseAnimationController
          .drive(Tween(begin: 0.95, end: 1.05))
          .drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors['primary'],
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors['primary']!.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _scrollToBottom,
            borderRadius: BorderRadius.circular(22),
            child: const Center(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundWithEffects(Map<String, Color> colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors['background'],
        image: const DecorationImage(
          image: AssetImage('assets/images/chat_pattern.png'),
          opacity: 0.04,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.grey,
            BlendMode.srcATop,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(Map<String, Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors['primary']!,
            colors['secondary']!,
          ],
        ),
        borderRadius: widget.scrollControllerForModal != null
            ? const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.scrollControllerForModal != null)
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              children: [
                _buildEnhancedAvatarIcon(colors),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'دستیار هوشمند',
                            style: TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(duration: 600.ms),
                          const SizedBox(width: 6),
                          _buildStatusBadge('برنامه‌ریز سفر', Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildPulsatingDot(),
                          const SizedBox(width: 6),
                          Text(
                            'آنلاین | آماده راهنمایی شما',
                            style: TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildHeaderActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsatingDot() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withOpacity(0.5 + 0.5 * _pulseAnimationController.value),
                blurRadius: 4 + 4 * _pulseAnimationController.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Vazir',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildThemeToggleButton(),
        const SizedBox(width: 8),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildThemeToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
            _showThemeSelector(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              _getThemeIcon(),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon() {
    switch (_currentTheme) {
      case 'night':
        return Icons.dark_mode_rounded;
      case 'nature':
        return Icons.eco_rounded;
      case 'sunset':
        return Icons.wb_sunny_rounded;
      default:
        return Icons.palette_rounded;
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'انتخاب تم ظاهری',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildThemeOption('primary', 'استاندارد', Icons.color_lens_rounded, const Color(0xFF4869F0)),
                    _buildThemeOption('night', 'شب', Icons.dark_mode_rounded, const Color(0xFF2B3148)),
                    _buildThemeOption('nature', 'طبیعت', Icons.eco_rounded, const Color(0xFF2E7D32)),
                    _buildThemeOption('sunset', 'غروب', Icons.wb_sunny_rounded, const Color(0xFFD84315)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String themeKey, String label, IconData icon, Color color) {
    final isSelected = _currentTheme == themeKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _animationController.reset();
            _currentTheme = themeKey;
            _animationController.forward();
            _saveSettings();
          });
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                  )
                ]
                    : [],
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAvatarIcon(Map<String, Color> colors) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                colors['primary']!,
                colors['secondary']!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
          _showOptionsMenu(context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.more_vert,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildEnhancedMenuOption(
                context: context,
                icon: Icons.save_rounded,
                label: 'ذخیره گفتگوها',
                onTap: () {
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('گفتگوها در گالری ذخیره شد'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                badgeText: 'جدید',
                badgeColor: Colors.green,
              ),
              _buildEnhancedMenuOption(
                context: context,
                icon: Icons.delete_outline_rounded,
                label: 'پاک کردن گفتگو',
                onTap: () {
                  Navigator.pop(context);
                  _showConfirmDialog(context);
                },
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
              _buildEnhancedMenuOption(
                context: context,
                icon: Icons.settings_outlined,
                label: 'تنظیمات دستیار',
                onTap: () {
                  Navigator.pop(context);
                  _showSettingsPage(context);
                },
              ),
              _buildEnhancedMenuOption(
                context: context,
                icon: Icons.help_outline_rounded,
                label: 'راهنمای استفاده',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _showGuideOverlay = true;
                    _guideStep = 0;
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    String? badgeText,
    Color? badgeColor,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 15,
                      color: textColor ?? defaultColor,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor ?? theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  void _showConfirmDialog(BuildContext context) {
    final chatbotService = Provider.of<ChatbotService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'حذف گفتگو',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'آیا از حذف کامل تاریخچه گفتگو اطمینان دارید؟ این عمل قابل بازگشت نیست.',
            style: TextStyle(
              fontFamily: 'Vazir',
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'انصراف',
                style: TextStyle(
                  fontFamily: 'Vazir',
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'حذف کن',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                chatbotService.clearConversationHistory();
                Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تاریخچه گفتگو با موفقیت حذف شد'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsPage(BuildContext context) {
    final currentColors = _themeColors[_currentTheme] ?? _themeColors['primary']!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: currentColors['cardBg'],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'تنظیمات دستیار هوشمند',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: currentColors['textPrimary'],
                      ),
                    ),
                  ),
                  _buildSettingsSection(
                    title: 'سرعت پاسخگویی',
                    icon: Icons.speed_rounded,
                    child: Slider(
                      value: _responseSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      label: '${_responseSpeed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setState(() {
                          _responseSpeed = value;
                          _saveSettings();
                        });
                      },
                      activeColor: currentColors['primary'],
                      inactiveColor: currentColors['textSecondary']!.withOpacity(0.2),
                    ),
                  ),
                  _buildSettingsSection(
                    title: 'زبان تشخیص صدا',
                    icon: Icons.language_rounded,
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      items: [
                        DropdownMenuItem(value: 'fa_IR', child: Text('فارسی', style: TextStyle(fontFamily: 'Vazir'))),
                        DropdownMenuItem(value: 'en_US', child: Text('انگلیسی', style: TextStyle(fontFamily: 'Vazir'))),
                        DropdownMenuItem(value: 'ar_SA', child: Text('عربی', style: TextStyle(fontFamily: 'Vazir'))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                            _saveSettings();
                          });
                        }
                      },
                      isExpanded: true,
                      underline: Container(
                        height: 1,
                        color: currentColors['textSecondary']!.withOpacity(0.3),
                      ),
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        color: currentColors['textPrimary'],
                      ),
                    ),
                  ),
                  _buildSettingsSection(
                    title: 'بازخورد لمسی',
                    icon: Icons.vibration_rounded,
                    child: Switch(
                      value: _hapticFeedbackEnabled,
                      onChanged: (value) {
                        setState(() {
                          _hapticFeedbackEnabled = value;
                          _saveSettings();
                          if (value) HapticFeedback.lightImpact();
                        });
                      },
                      activeColor: currentColors['primary'],
                    ),
                  ),
                  _buildSettingsSection(
                    title: 'اندازه فونت',
                    icon: Icons.text_fields_rounded,
                    child: Slider(
                      value: _textSize,
                      min: 12.0,
                      max: 20.0,
                      divisions: 8,
                      label: _textSize.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _textSize = value;
                          _saveSettings();
                        });
                      },
                      activeColor: currentColors['primary'],
                      inactiveColor: currentColors['textSecondary']!.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final currentColors = _themeColors[_currentTheme] ?? _themeColors['primary']!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentColors['background']!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: currentColors['primary']!.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: currentColors['primary'],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: currentColors['textPrimary'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildInteractiveGuideOverlay(Map<String, Color> colors) {
    final currentStep = _guideSteps[_guideStep];
    final isFirstStep = _guideStep == 0;
    final isLastStep = _guideStep == _guideSteps.length - 1;

    return GestureDetector(
      onTap: () {
        if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
        setState(() {
          _showGuideOverlay = false;
          _guideStep = 0;
        });
      },
      child: Material(
        color: Colors.black.withOpacity(0.6),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(),
              ),
            ),
            Positioned(
              top: currentStep['target'] == 'header' ? 50.0 : null,
              right: currentStep['target'] == 'header' ? 20.0 : null,
              bottom: currentStep['target'] == 'input' ? 100.0 : null,
              left: currentStep['target'] == 'input' ? 20.0 : null,
              child: _buildGuideTooltip(
                title: currentStep['title'],
                description: currentStep['description'],
                colors: colors,
                onNext: () {
                  if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
                  if (!isLastStep) {
                    setState(() {
                      _guideStep++;
                    });
                  } else {
                    setState(() {
                      _showGuideOverlay = false;
                      _guideStep = 0;
                    });
                  }
                },
                onPrevious: isFirstStep
                    ? null
                    : () {
                  if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
                  setState(() {
                    _guideStep--;
                  });
                },
                onClose: () {
                  if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
                  setState(() {
                    _showGuideOverlay = false;
                    _guideStep = 0;
                  });
                },
                isLastStep: isLastStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideTooltip({
    required String title,
    required String description,
    required Map<String, Color> colors,
    required VoidCallback onNext,
    VoidCallback? onPrevious,
    required VoidCallback onClose,
    bool isLastStep = false,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['cardBg'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Lottie.asset(
                'assets/animations/guide_animation.json',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.info_outline, color: Colors.blue);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors['textPrimary'],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: colors['textSecondary'],
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              color: colors['textSecondary'],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onPrevious != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors['textSecondary']!.withOpacity(0.1),
                    foregroundColor: colors['textPrimary'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onPrevious,
                  child: const Text(
                    'قبلی',
                    style: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['primary'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onNext,
                child: Text(
                  isLastStep ? 'پایان' : 'بعدی',
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0.0);
  }

  Widget _buildSpecialFeatures(Map<String, Color> colors, ChatbotService chatbotService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'امکانات ویژه دستیار هوشمند',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors['textPrimary'],
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            controller: _featuresScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _specialFeatures.length,
            itemBuilder: (context, index) {
              final feature = _specialFeatures[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFeatureCard(
                  colors,
                  feature['icon'],
                  feature['title'],
                  feature['prompt'],
                  chatbotService,
                  index,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);
  }

  Widget _buildFeatureCard(
      Map<String, Color> colors,
      IconData icon,
      String title,
      String prompt,
      ChatbotService chatbotService,
      int index,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_hapticFeedbackEnabled) HapticFeedback.mediumImpact();
          chatbotService.addUserMessage(prompt);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colors['cardBg'],
            boxShadow: [
              BoxShadow(
                color: colors['primary']!.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: colors['primary']!.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: colors['primary'],
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors['textPrimary'],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (300 + index * 100).ms);
  }

  Widget _buildEnhancedTypingIndicator(Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colors['cardBg'],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Lottie.asset(
              'assets/animations/typing_animation.json',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "دستیار در حال پاسخگویی...",
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors['textPrimary'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "در حال تحلیل اطلاعات و آماده‌سازی پاسخ",
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 11,
                  color: colors['textSecondary'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInputBar(Map<String, Color> colors, ChatbotService chatbotService) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: _isInputFocused || _isRecording ? 16.0 : 12.0,
      ),
      decoration: BoxDecoration(
        color: colors['cardBg'],
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildInputButton(
            icon: Icons.attach_file_rounded,
            color: colors['textSecondary']!,
            onTap: () {
              if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
            },
            isRecording: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors['textSecondary']!.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isInputFocused || _isRecording
                      ? colors['primary']!.withOpacity(0.5)
                      : colors['textSecondary']!.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: MessageInputBar(
                focusNode: _focusNode,
                controller: _textController,
                onSendMessage: (text) {
                  if (_hapticFeedbackEnabled) HapticFeedback.mediumImpact();
                  chatbotService.addUserMessage(text);
                  _textController.clear();
                },
                hintText: _isRecording ? 'در حال ضبط...' : 'پیام خود را بنویسید...',
                buttonStyle: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isInputFocused || _isRecording
                        ? colors['primary']
                        : colors['primary']!.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _isInputFocused || _isRecording
                        ? [
                      BoxShadow(
                        color: colors['primary']!.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ]
                        : [],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildInputButton(
            icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: _isRecording ? Colors.red : colors['textSecondary']!,
            onTap: () {
              if (_hapticFeedbackEnabled) HapticFeedback.lightImpact();
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording(chatbotService);
              }
            },
            isRecording: _isRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildInputButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isRecording,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isRecording)
              Container(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: _waveAnimationController.value,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ).animate().scale(
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            if (isRecording)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate().scale(
                duration: 1000.ms,
                curve: Curves.easeInOut,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              ),
          ],
        ),
      ),
    );
  }
}