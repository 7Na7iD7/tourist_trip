import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final FocusNode? focusNode;
  final String hintText;
  final Widget? buttonStyle;
  final TextEditingController controller;

  const MessageInputBar({
    Key? key,
    required this.onSendMessage,
    this.focusNode,
    this.hintText = 'پیام خود را وارد کنید...',
    this.buttonStyle,
    required this.controller,
  }) : super(key: key);

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> with SingleTickerProviderStateMixin {
  bool _canSend = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _onTextChanged() {
    setState(() {
      _canSend = widget.controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    if (_canSend) {
      final message = widget.controller.text.trim();
      widget.onSendMessage(message);
      widget.controller.clear();
      setState(() {
        _canSend = false;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          // فیلد متنی
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? const Color(0xFFF1F5FB)
                    : const Color(0xFF2A2D37),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFE0E6F0)
                      : const Color(0xFF414557),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: ui.TextDirection.rtl,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 15,
                            color: theme.hintColor,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  // دکمه میکروفون یا ضبط صدا
                  _buildVoiceButton(theme),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // دکمه ارسال با انیمیشن
          GestureDetector(
            onTapDown: (_) => _animController.forward(),
            onTapUp: (_) => _animController.reverse(),
            onTapCancel: () => _animController.reverse(),
            onTap: _handleSend,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: widget.buttonStyle ?? _defaultSendButton(_canSend, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // اینجا کد ضبط صدا را فعال کنید
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Icon(
          Icons.mic_none_rounded,
          color: theme.colorScheme.secondary.withOpacity(0.7),
          size: 20,
        ),
      ),
    );
  }

  Widget _defaultSendButton(bool canSend, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: canSend
            ? theme.colorScheme.primary
            : theme.disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.send,
        color: canSend
            ? Colors.white
            : theme.disabledColor,
        size: 20,
      ),
    );
  }
}