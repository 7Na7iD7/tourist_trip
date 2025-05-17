import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/chat_message_model.dart';
import '../../services/chatbot_service.dart';
import 'message_bubble.dart';
import 'package:provider/provider.dart';

class MessageList extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final ScrollController scrollController;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool showScrollToBottom;
  final bool showTypingIndicator;

  const MessageList({
    Key? key,
    required this.messages,
    required this.scrollController,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showScrollToBottom = true,
    this.showTypingIndicator = true,
  }) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with SingleTickerProviderStateMixin {
  bool _showScrollButton = false;
  bool _isScrolling = false;
  Timer? _scrollDebounce;
  late AnimationController _fadeController;
  final double _scrollThreshold = 200.0;

  // Used for optimistic message states
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(isInitial: true);
      _setupScrollListener();
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _typingTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      // Show scroll button when user scrolls up
      final showButton = _isUserScrolledUp();

      if (showButton != _showScrollButton) {
        setState(() => _showScrollButton = showButton);

        if (showButton) {
          _fadeController.forward();
        } else {
          _fadeController.reverse();
        }
      }

      // Track when user is manually scrolling
      if (!_isScrolling) {
        setState(() => _isScrolling = true);

        // Debounce scroll events
        _scrollDebounce?.cancel();
        _scrollDebounce = Timer(Duration(milliseconds: 100), () {
          if (mounted) setState(() => _isScrolling = false);
        });
      }
    });
  }

  bool _isUserScrolledUp() {
    if (!widget.scrollController.hasClients) return false;

    final position = widget.scrollController.position;
    return position.pixels < position.maxScrollExtent - _scrollThreshold;
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle new messages
    if (widget.messages.length > oldWidget.messages.length) {
      // Only auto-scroll if user is near bottom
      final isNearBottom = !_isUserScrolledUp();
      if (isNearBottom && !_isScrolling) {
        _scrollToBottom();
      } else if (widget.showScrollToBottom && !_showScrollButton) {
        // If we don't auto-scroll, show the scroll button
        setState(() => _showScrollButton = true);
        _fadeController.forward();
      }

      // Show optimistic typing indicator when waiting for AI response
      final lastMessage = widget.messages.last;
      // Check if the last message is from user based on its sender type
      final isLastMessageFromUser = lastMessage.sender == 'user';
      if (isLastMessageFromUser) {
        _simulateTyping();
      }
    }
  }

  void _simulateTyping() {
    if (!widget.showTypingIndicator) return;

    setState(() => _isTyping = true);

    // Clear any existing timer
    _typingTimer?.cancel();

    // Auto-clear typing indicator after 20 seconds (fallback)
    _typingTimer = Timer(Duration(seconds: 20), () {
      if (mounted) setState(() => _isTyping = false);
    });
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    if (_isTyping && mounted) {
      setState(() => _isTyping = false);
    }
  }

  void _scrollToBottom({bool isInitial = false, bool animated = true}) {
    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position.maxScrollExtent;

    if (animated && widget.enableAnimation) {
      widget.scrollController.animateTo(
        position,
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.scrollController.jumpTo(position);
    }

    // Hide scroll button when we scroll to bottom
    if (_showScrollButton) {
      setState(() => _showScrollButton = false);
      _fadeController.reverse();
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FadeTransition(
        opacity: _fadeController,
        child: FloatingActionButton.small(
          heroTag: "scrollToBottom",
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          onPressed: () => _scrollToBottom(),
          child: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatbotService = Provider.of<ChatbotService>(context, listen: false);

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          itemCount: widget.messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // Show typing indicator as the last item if needed
            if (_isTyping && index == widget.messages.length) {
              return _buildTypingIndicator();
            }

            // Get the actual message
            final message = widget.messages[index];

            // When a bot message appears, stop the typing indicator
            // Check if the message is from user based on its sender type or role
            final isUserMessage = message.sender == 'user';
            if (!isUserMessage && _isTyping) {
              _stopTyping();
            }

            return AnimatedMessageBubble(
              message: message,
              onSuggestedQuestionTap: (question) {
                chatbotService.addUserMessage(question);
              },
              isNew: index == widget.messages.length - 1 && !_isInitialBuild,
              animationEnabled: widget.enableAnimation,
            );
          },
        ),

        // Scroll to bottom button
        if (widget.showScrollToBottom)
          _buildScrollToBottomButton(),
      ],
    );
  }

  // Track if this is the initial build to avoid animations on first load
  bool _isInitialBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isInitialBuild = false;
  }
}

// Enhanced message bubble with animation
class AnimatedMessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final Function(String) onSuggestedQuestionTap;
  final bool isNew;
  final bool animationEnabled;

  const AnimatedMessageBubble({
    Key? key,
    required this.message,
    required this.onSuggestedQuestionTap,
    this.isNew = false,
    this.animationEnabled = true,
  }) : super(key: key);

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    if (widget.isNew && widget.animationEnabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on message sender (example)
    final isUserMessage = widget.message.sender == 'user'; // Assuming 'user' is the sender identifier for user messages
    final userBubbleColor = Theme.of(context).colorScheme.primary; // Example color
    final botBubbleColor = Theme.of(context).colorScheme.surfaceVariant; // Example color
    final textColor = Theme.of(context).colorScheme.onSurface; // Example color
    final linkTextColor = Theme.of(context).colorScheme.secondary; // Example color
    final textSize = 16.0; // Example size

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(_scaleAnimation),
        child: MessageBubble(
          message: widget.message,
          onSuggestedQuestionTap: widget.onSuggestedQuestionTap,
          // Pass the required color parameters
          userBubbleColor: userBubbleColor,
          botBubbleColor: botBubbleColor,
          textColor: textColor,
          linkTextColor: linkTextColor,
          textSize: textSize,
        ),
      ),
    );
  }
}