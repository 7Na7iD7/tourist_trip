import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';
import 'dart:ui';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final Function(String) onSuggestedQuestionTap;
  // دریافت پارامترهای استایل
  final Color userBubbleColor;
  final Color botBubbleColor;
  final Color textColor;
  final Color linkTextColor;
  final double textSize;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.onSuggestedQuestionTap,
    required this.userBubbleColor,
    required this.botBubbleColor,
    required this.textColor,
    required this.linkTextColor,
    required this.textSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    // تعیین تراز و رنگ بر اساس فرستنده
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser ? userBubbleColor : botBubbleColor;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ClipRRect( // برای اعمال Blur radius
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4), // نوک حباب
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18), // نوک حباب
          ),
          child: BackdropFilter( // اعمال گلاسمورفیسم
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // شدت Blur
            child: Container(
              decoration: BoxDecoration(
                  color: bubbleColor.withOpacity(0.6), // رنگ حباب با شفافیت
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                  border: Border.all( // بوردر ظریف
                    color: bubbleColor.withOpacity(0.3),
                    width: 1.0,
                  ),
                  boxShadow: [ // سایه ظریف
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // پدینگ داخلی حباب
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: textSize, // استفاده از اندازه فونت دریافتی
                      color: textColor, // استفاده از رنگ متن دریافتی
                    ),
                    textDirection: ui.TextDirection.rtl, // جهت متن
                  ),
                  if (message.suggestedQuestions != null && message.suggestedQuestions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap( // نمایش سوالات پیشنهادی در Wrap برای مدیریت فضای بهتر
                        alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
                        spacing: 8.0, // فاصله بین چیپ‌ها
                        runSpacing: 4.0, // فاصله عمودی بین ردیف‌های چیپ
                        children: message.suggestedQuestions!.map((question) {
                          return ActionChip( // استفاده از ActionChip برای سوالات پیشنهادی
                            label: Text(
                              question,
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: textSize * 0.85, // فونت کمی کوچکتر از متن اصلی
                                color: linkTextColor, // استفاده از رنگ لینک دریافتی
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            avatar: Icon(Icons.lightbulb_outline, size: textSize * 0.9, color: linkTextColor), // آیکون لامپ
                            onPressed: () => onSuggestedQuestionTap(question),
                            backgroundColor: linkTextColor.withOpacity(0.1), // پس زمینه شفاف با رنگ لینک
                            shape: RoundedRectangleBorder( // شکل rounded
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: linkTextColor.withOpacity(0.3), width: 1.0), // بوردر ظریف
                            ),
                            elevation: 2.0, // سایه ظریف
                            shadowColor: linkTextColor.withOpacity(0.3),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // اندازه تپ کوچکتر
                            // اضافه کردن انیمیشن یا افکت هاور با AnimatedContainer یا GestureDetector+setState در صورت نیاز
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}