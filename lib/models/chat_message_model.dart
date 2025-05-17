abstract class MessageContent {
  String get contentId;
}

// محتوای متنی پیام
class TextMessageContent implements MessageContent {
  final String text;
  final String contentId;

  TextMessageContent({required this.text, required this.contentId});
}

// انواع محتوای چندرسانه‌ای را می‌توان اضافه کرد (عکس، ویدیو، فایل و غیره)
// مثال برای محتوای تصویر:
class ImageMessageContent implements MessageContent {
  final String imageUrl;
  final String? caption;
  final String contentId;

  ImageMessageContent({required this.imageUrl, this.caption, required this.contentId});
}

// برای نمایش وضعیت ارسال پیام
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

// برای نمایش وضعیت فعالیت کاربر
enum UserActivityStatus {
  online,
  offline,
  typing,
  lastSeen,
}

// انواع واکنش‌های ممکن
class Reaction {
  final String id;
  final String emoji;
  final String userId;
  final DateTime timestamp;

  Reaction({
    required this.id,
    required this.emoji,
    required this.userId,
    required this.timestamp,
  });
}

// تعریف مدل پیام با قابلیت‌های پیشرفته
class EnhancedChatMessageModel {
  final String id;
  final MessageContent content;
  final MessageSender sender;
  final String senderId;
  final DateTime timestamp;

  // وضعیت ارسال پیام
  final MessageStatus status;

  // وضعیت ویرایش شدن
  final bool isEdited;
  final DateTime? lastEditedAt;
  final List<MessageContent>? editHistory;

  // پاسخ به پیام خاص (Reply To)
  final String? replyToMessageId;

  // واکنش‌ها
  final List<Reaction> reactions;

  // نشانه‌گذاری
  final bool isBookmarked;
  final DateTime? bookmarkedAt;

  // وضعیت فعالیت کاربر
  final UserActivityStatus? senderActivityStatus;
  final DateTime? lastStatusChange;

  // محتوای قابل جستجو - کلمات کلیدی یا متادیتا
  final List<String> searchTags;

  // پیشنهادات سوال
  final List<String>? suggestedQuestions;

  EnhancedChatMessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.senderId,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.isEdited = false,
    this.lastEditedAt,
    this.editHistory,
    this.replyToMessageId,
    this.reactions = const [],
    this.isBookmarked = false,
    this.bookmarkedAt,
    this.senderActivityStatus,
    this.lastStatusChange,
    this.searchTags = const [],
    this.suggestedQuestions,
  });

  // متدی برای ایجاد نسخه ویرایش شده پیام
  EnhancedChatMessageModel copyWithEdit(MessageContent newContent) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: newContent,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: this.status,
      isEdited: true,
      lastEditedAt: DateTime.now(),
      editHistory: [
        ...?this.editHistory,
        this.content,
      ],
      replyToMessageId: this.replyToMessageId,
      reactions: this.reactions,
      isBookmarked: this.isBookmarked,
      bookmarkedAt: this.bookmarkedAt,
      senderActivityStatus: this.senderActivityStatus,
      lastStatusChange: this.lastStatusChange,
      searchTags: this.searchTags,
      suggestedQuestions: this.suggestedQuestions,
    );
  }

  // متدی برای اضافه کردن واکنش به پیام
  EnhancedChatMessageModel addReaction(Reaction reaction) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: this.content,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: this.status,
      isEdited: this.isEdited,
      lastEditedAt: this.lastEditedAt,
      editHistory: this.editHistory,
      replyToMessageId: this.replyToMessageId,
      reactions: [...this.reactions, reaction],
      isBookmarked: this.isBookmarked,
      bookmarkedAt: this.bookmarkedAt,
      senderActivityStatus: this.senderActivityStatus,
      lastStatusChange: this.lastStatusChange,
      searchTags: this.searchTags,
      suggestedQuestions: this.suggestedQuestions,
    );
  }

  // متدی برای نشانه‌گذاری پیام
  EnhancedChatMessageModel toggleBookmark() {
    return EnhancedChatMessageModel(
      id: this.id,
      content: this.content,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: this.status,
      isEdited: this.isEdited,
      lastEditedAt: this.lastEditedAt,
      editHistory: this.editHistory,
      replyToMessageId: this.replyToMessageId,
      reactions: this.reactions,
      isBookmarked: !this.isBookmarked,
      bookmarkedAt: !this.isBookmarked ? DateTime.now() : null,
      senderActivityStatus: this.senderActivityStatus,
      lastStatusChange: this.lastStatusChange,
      searchTags: this.searchTags,
      suggestedQuestions: this.suggestedQuestions,
    );
  }

  // متدی برای به‌روز کردن وضعیت پیام
  EnhancedChatMessageModel updateStatus(MessageStatus newStatus) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: this.content,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: newStatus,
      isEdited: this.isEdited,
      lastEditedAt: this.lastEditedAt,
      editHistory: this.editHistory,
      replyToMessageId: this.replyToMessageId,
      reactions: this.reactions,
      isBookmarked: this.isBookmarked,
      bookmarkedAt: this.bookmarkedAt,
      senderActivityStatus: this.senderActivityStatus,
      lastStatusChange: this.lastStatusChange,
      searchTags: this.searchTags,
      suggestedQuestions: this.suggestedQuestions,
    );
  }

  // متدی برای به‌روز کردن وضعیت فعالیت کاربر
  EnhancedChatMessageModel updateActivityStatus(UserActivityStatus newStatus) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: this.content,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: this.status,
      isEdited: this.isEdited,
      lastEditedAt: this.lastEditedAt,
      editHistory: this.editHistory,
      replyToMessageId: this.replyToMessageId,
      reactions: this.reactions,
      isBookmarked: this.isBookmarked,
      bookmarkedAt: this.bookmarkedAt,
      senderActivityStatus: newStatus,
      lastStatusChange: DateTime.now(),
      searchTags: this.searchTags,
      suggestedQuestions: this.suggestedQuestions,
    );
  }

  // متدی برای اضافه کردن تگ‌های قابل جستجو
  EnhancedChatMessageModel addSearchTags(List<String> newTags) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: this.content,
      sender: this.sender,
      senderId: this.senderId,
      timestamp: this.timestamp,
      status: this.status,
      isEdited: this.isEdited,
      lastEditedAt: this.lastEditedAt,
      editHistory: this.editHistory,
      replyToMessageId: this.replyToMessageId,
      reactions: this.reactions,
      isBookmarked: this.isBookmarked,
      bookmarkedAt: this.bookmarkedAt,
      senderActivityStatus: this.senderActivityStatus,
      lastStatusChange: this.lastStatusChange,
      searchTags: [...this.searchTags, ...newTags],
      suggestedQuestions: this.suggestedQuestions,
    );
  }
}

// همان enum اصلی برای سازگاری با کد قبلی
enum MessageSender { user, bot }

// کلاس اصلی قبلی حفظ شده و با کلاس جدید سازگار است
class ChatMessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestedQuestions;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestedQuestions,
  });

  // متدی برای تبدیل به مدل پیشرفته
  EnhancedChatMessageModel toEnhanced({String? senderId}) {
    return EnhancedChatMessageModel(
      id: this.id,
      content: TextMessageContent(text: this.text, contentId: "${this.id}_text"),
      sender: this.sender,
      senderId: senderId ?? "unknown",
      timestamp: this.timestamp,
      suggestedQuestions: this.suggestedQuestions,
    );
  }
}

// مثال استفاده
void example() {
  // ایجاد پیام ساده
  final simpleMessage = ChatMessageModel(
    id: "msg1",
    text: "سلام، چطوری؟",
    sender: MessageSender.user,
    timestamp: DateTime.now(),
  );

  // تبدیل به مدل پیشرفته
  final enhancedMessage = simpleMessage.toEnhanced(senderId: "user123");

  // ویرایش پیام
  final editedMessage = enhancedMessage.copyWithEdit(
      TextMessageContent(text: "سلام، حالت چطوره؟", contentId: "${enhancedMessage.id}_text_edited")
  );

  // اضافه کردن واکنش
  final messageWithReaction = editedMessage.addReaction(
      Reaction(
        id: "reaction1",
        emoji: "👍",
        userId: "user456",
        timestamp: DateTime.now(),
      )
  );

  // نشانه‌گذاری پیام
  final bookmarkedMessage = messageWithReaction.toggleBookmark();

  // به‌روز کردن وضعیت پیام
  final deliveredMessage = bookmarkedMessage.updateStatus(MessageStatus.delivered);

  // به‌روز کردن وضعیت فعالیت
  final withActivityStatus = deliveredMessage.updateActivityStatus(UserActivityStatus.typing);

  // اضافه کردن تگ‌های قابل جستجو
  final withSearchTags = withActivityStatus.addSearchTags(["گفتگو", "احوالپرسی"]);
}