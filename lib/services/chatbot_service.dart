import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import '../models/chat_message_model.dart'; // مطمئن شوید این مسیر صحیح است

class ChatbotService extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [];
  bool _isBotTyping = false;
  final Uuid _uuid = Uuid();
  late SharedPreferences _prefs;
  bool _prefsInitialized = false;
  bool _isActiveLearningMode = false;
  String? _pendingQuestionForLearning;
  List<String> _pendingSuggestions = [];
  int _activeLearningAttempts = 0;
  static const int _maxActiveLearningAttempts = 3;
  final Map<String, (String?, double)> _similarityCache = <String, (String?, double)>{};

  // List of key terms for boosted matching
  static const List<String> _keyTerms = [
    'الگوریتم',
    'مسیر',
    'زمان',
    'داده',
    'فاصله',
    'مکان',
    'تور',
    'بهینه',
    'برنامه‌ریزی',
    'پویا'
  ];

  final Map<String, Map<String, dynamic>> _knowledgeBase = {
    'data': {
      'داده‌های اولیه اپ از کجا میان؟': {
        'answer': 'داده‌های اولیه به صورت خودکار توسط متد _initializeData تولید می‌شن. این تابع با استفاده از تابع کمکی _generateRandomData یک سری مکان توریستی با نام، زمان بازدید و فاصله‌های تصادفی بین آن‌ها ایجاد می‌کنه.',
        'suggestions': ['چرا از حروف A تا E برای مکان‌ها استفاده شده؟', 'زمان بازدید هر مکان رو چطور تعیین می‌کنید؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'چرا از حروف A تا E برای مکان‌ها استفاده شده؟': {
        'answer': 'در تولید اولیه داده‌ها، برای سادگی و تست راحت‌تر، نام مکان‌ها به صورت A، B، C، D و E تنظیم شده‌اند. این کار کمک می‌کنه راحت‌تر آن‌ها را در الگوریتم‌ها شناسایی کنیم.',
        'suggestions': ['چطور اسم مکان‌ها مثل "موزه" و "پارک" تنظیم می‌شن؟', 'داده‌های اولیه اپ از کجا میان؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'چطور اسم مکان‌ها مثل "موزه" و "پارک" تنظیم می‌شن؟': {
        'answer': 'در نسخه فعلی، نام‌ها از لیست حروف انگلیسی انتخاب می‌شن. اما می‌شه این قسمت رو به‌راحتی طوری توسعه داد که از اسامی واقعی مثل "پارک" یا "موزه" هم پشتیبانی کنه.',
        'suggestions': ['چرا از حروف A تا E برای مکان‌ها استفاده شده؟', 'داده‌های اولیه اپ از کجا میان؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'زمان بازدید هر مکان رو چطور تعیین می‌کنید؟': {
        'answer': 'در متد _generateRandomData، زمان بازدید هر مکان به صورت عدد تصادفی بین 10 تا 60 دقیقه تولید می‌شه.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'داده‌های اولیه اپ از کجا میان؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'فاصله بین مکان‌ها چطور مقداردهی می‌شه؟': {
        'answer': 'برای هر زوج مکان، فاصله‌ای تصادفی بین 5 تا 100 دقیقه درنظر گرفته می‌شه. این مقادیر به صورت Map<String, Map<String, int>> ذخیره می‌شن.',
        'suggestions': ['چرا مقدار پیش‌فرض فاصله‌ها 999999 هست؟', 'زمان بازدید هر مکان رو چطور تعیین می‌کنید؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'چرا مقدار پیش‌فرض فاصله‌ها 999999 هست؟': {
        'answer': 'این مقدار معادل "بی‌نهایت" فرضی در الگوریتم‌های گراف است، یعنی بین دو مکان خاص فاصله مستقیمی وجود ندارد یا هنوز مقداردهی نشده‌اند.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'داده‌های اولیه اپ از کجا میان؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'تابع _initializeData چه کاری انجام می‌دهد؟': {
        'answer': 'این تابع داده‌های جدید تولید کرده، آن‌ها را در متغیرهای داخلی مدل ذخیره می‌کند، و سپس با استفاده از notifyListeners() رابط کاربری را بروزرسانی می‌کند.',
        'suggestions': ['داده‌های اولیه اپ از کجا میان؟', 'تولید داده‌های جدید چطوریه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'تولید داده‌های جدید چطوریه؟': {
        'answer': 'با زدن دکمه "تولید داده‌های جدید" (آیکون رفرش)، می‌توانید تعداد مکان‌های گردشگری را مشخص کنید. سپس برنامه به صورت تصادفی مکان‌هایی با نام، زمان بازدید و فاصله‌های مختلف ایجاد می‌کند تا بتوانید عملکرد الگوریتم را با داده‌های متفاوت تست کنید.',
        'suggestions': ['تابع _initializeData چه کاری انجام می‌دهد؟', 'داده‌های اولیه اپ از کجا میان؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'آیا می‌تونم تعداد مکان‌ها رو تغییر بدم؟': {
        'answer': 'بله، فقط کافیه آرگومان ورودی به تابع _generateRandomData رو تغییر بدی.',
        'suggestions': ['تولید داده‌های جدید چطوریه؟', 'آیا نام و زمان بازدید مکان‌ها قابل شخصی‌سازی هستند؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'آیا نام و زمان بازدید مکان‌ها قابل شخصی‌سازی هستند؟': {
        'answer': 'در این نسخه خیر، ولی می‌شه فرم ورودی براش طراحی کرد تا دستی وارد بشن.',
        'suggestions': ['آیا می‌تونم تعداد مکان‌ها رو تغییر بدم؟', 'چطور اسم مکان‌ها مثل "موزه" و "پارک" تنظیم می‌شن؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'داده‌ها دائمی هستند یا موقتی؟': {
        'answer': 'فعلاً موقتی‌اند و با بستن برنامه از بین می‌رن.',
        'suggestions': ['اگر برنامه بسته بشه، داده‌ها ذخیره می‌شن؟', 'آیا امکان ثبت مکان جدید به صورت دستی وجود داره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'اگر برنامه بسته بشه، داده‌ها ذخیره می‌شن؟': {
        'answer': 'خیر، چون از هیچ local storage یا database استفاده نشده.',
        'suggestions': ['داده‌ها دائمی هستند یا موقتی؟', 'آیا امکان ثبت مکان جدید به صورت دستی وجود داره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'امکان ثبت مکان جدید به صورت دستی وجود داره؟': {
        'answer': 'فعلاً نه، اما پیاده‌سازی اون با یک فرم ورودی ساده قابل انجامه.',
        'suggestions': ['آیا نام و زمان بازدید مکان‌ها قابل شخصی‌سازی هستند؟', 'داده‌ها دائمی هستند یا موقتی؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'آیا امکان استفاده از مکان‌های واقعی و فاصله‌های GPS هست؟': {
        'answer': 'بله، با ترکیب API نقشه مثل Google Maps می‌شه فاصله‌های واقعی رو وارد کرد.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'امکان ثبت مکان جدید به صورت دستی وجود داره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'چرا از Map<String, Map<String, int>> برای فاصله استفاده شده؟': {
        'answer': 'چون فاصله بین هر دو مکان ممکنه متفاوت باشه، و با این ساختار می‌شه سریع مقداردهی یا بازیابی کرد.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'چرا مقدار پیش‌فرض فاصله‌ها 999999 هست؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'اگر فاصله بین دو مکان مشخص نشده باشه چی میشه؟': {
        'answer': 'اگر distances[a]?[b] مقدار نداشته باشه، مقدار پیش‌فرض 999999 برمی‌گرده تا اون مسیر غیرقابل انتخاب بشه.',
        'suggestions': ['چرا مقدار پیش‌فرض فاصله‌ها 999999 هست؟', 'فاصله بین مکان‌ها چطور مقداردهی می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'آیا امکان داره فاصله بین مکان A به B با B به A فرق داشته باشه؟': {
        'answer': 'در پیاده‌سازی فعلی بله، چون هر فاصله به طور جداگانه مقداردهی شده و تقارن تضمین نشده.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'چرا از Map<String, Map<String, int>> برای فاصله استفاده شده؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'چرا از List<String> برای places استفاده شده و نه کلاس؟': {
        'answer': 'برای سادگی و تمرکز روی الگوریتم، به جای تعریف کلاس برای مکان، از رشته‌ها استفاده شده. اما توسعه آینده می‌تونه PlaceModel داشته باشه.',
        'suggestions': ['کلاس TouristPlannerModel چه نقشی داره؟', 'آیا نام و زمان بازدید مکان‌ها قابل شخصی‌سازی هستند؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      }
    },
    'algorithms': {
      'الگوریتم انتخاب مسیر بهینه چیه؟': {
        'answer': 'از الگوریتم برنامه‌ریزی پویا مشابه فروشنده دوره‌گرد (TSP) با محدودیت زمانی استفاده می‌شود که با استفاده از تابع _dpSolve پیاده‌سازی شده.',
        'suggestions': ['چرا از برنامه‌ریزی پویا استفاده کردید؟', 'تابع _dpSolve چطور کار می‌کنه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.9}
      },
      'چرا از برنامه‌ریزی پویا استفاده کردید؟': {
        'answer': 'چون می‌خوایم بهترین مجموعه مکان‌ها رو در زمان محدود پیدا کنیم. brute-force خیلی کند می‌شه، ولی DP با ذخیره حالت‌های تکراری، سرعت رو خیلی بالا می‌بره.',
        'suggestions': ['الگوریتم انتخاب مسیر بهینه چیه؟', 'پیچیدگی زمانی تابع _dpSolve چقدره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'تابع calculateOptimalTour دقیقا چه‌کاری می‌کنه؟': {
        'answer': 'این تابع برای هر مکان به عنوان شروع، تابع _dpSolve را صدا می‌زند و بهترین تور حاصل از همه‌ مکان‌های شروع ممکن را انتخاب و ذخیره می‌کند.',
        'suggestions': ['تابع _dpSolve چطور کار می‌کنه؟', 'الگوریتم انتخاب مسیر بهینه چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'تابع _dpSolve چطور کار می‌کنه؟': {
        'answer': 'این تابع از جدول DP استفاده می‌کند که کلید آن وضعیت مکان فعلی و مجموعه مکان‌های بازدید شده (با ماسک بیت‌مانی) است. سپس تمام حالت‌ها را بررسی و بهترین مسیر را انتخاب می‌کند.',
        'suggestions': ['از چه ساختار داده‌ای برای DP استفاده شده؟', 'پیچیدگی زمانی تابع _dpSolve چقدره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'از چه ساختار داده‌ای برای DP استفاده شده؟': {
        'answer': 'از Map<String, Map<int, int>> برای ذخیره حالت‌های DP استفاده شده است. این ساختار زمان رسیدن به هر وضعیت خاص را ذخیره می‌کند.',
        'suggestions': ['تابع _dpSolve چطور کار می‌کنه؟', 'پیچیدگی زمانی تابع _dpSolve چقدره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'پیچیدگی زمانی تابع _dpSolve چقدره؟': {
        'answer': 'پیچیدگی آن حدوداً O(N×2^N) است که برای تعداد کم مکان‌ها قابل قبول است.',
        'suggestions': ['تابع _dpSolve چطور کار می‌کنه؟', 'چرا از برنامه‌ریزی پویا استفاده کردید؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'آیا امکان داره مسیر پیدا نشه؟ اگه آره، چه میشه؟': {
        'answer': 'بله، اگر هیچ ترکیب مکانی در زمان مجاز قرار نگیره، تابع لیست خالی برمی‌گردونه.',
        'suggestions': ['الگوریتم انتخاب مسیر بهینه چیه؟', 'تابع _dpSolve چطور کار می‌کنه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'تابع floydWarshall کجاست؟': {
        'answer': 'در این نسخه‌ی کد، الگوریتم فلوید-وارشال پیاده‌سازی نشده. اگر لازم باشه می‌تونیم اون رو هم اضافه کنیم تا فاصله‌های بهینه بین تمام جفت مکان‌ها حساب بشه.',
        'suggestions': ['الگوریتم‌هاش چیه؟', 'چطور مسیر بهینه محاسبه می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      }
    },
    'ui': {
      'کلاس TouristPlannerModel چه نقشی داره؟': {
        'answer': 'این کلاس داده‌های مربوط به مکان‌ها، الگوریتم مسیر‌یابی و متدهای تعامل با UI رو نگهداری می‌کنه و پایه معماری MVVM برنامه است.',
        'suggestions': ['چرا این کلاس از ChangeNotifier استفاده می‌کنه؟', 'داده‌های تور بهینه چطور به UI فرستاده می‌شن؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'چرا این کلاس از ChangeNotifier استفاده می‌کنه؟': {
        'answer': 'برای این‌که وقتی داده‌ها عوض شدن، UI از طریق notifyListeners() بروزرسانی بشه.',
        'suggestions': ['کلاس TouristPlannerModel چه نقشی داره؟', 'چه زمانی UI بروزرسانی می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'چه زمانی UI بروزرسانی می‌شه؟': {
        'answer': 'هر بار که متدهایی مثل calculateOptimalTour یا initializeData اجرا می‌شن و داده‌ها تغییر می‌کنن.',
        'suggestions': ['چرا این کلاس از ChangeNotifier استفاده می‌کنه؟', 'داده‌های تور بهینه چطور به UI فرستاده می‌شن؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'داده‌های تور بهینه چطور به UI فرستاده می‌شن؟': {
        'answer': 'با استفاده از getter optimalTour که از ChangeNotifier میاد و در UI با Consumer یا Selector شنود می‌شه.',
        'suggestions': ['کلاس TouristPlannerModel چه نقشی داره؟', 'چه زمانی UI بروزرسانی می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'دکمه «تولید داده‌های جدید» چی کار می‌کنه؟': {
        'answer': 'دکمه FloatingActionButton در UI متد initializeData رو صدا می‌زنه و داده‌ها رو از نو تولید می‌کنه.',
        'suggestions': ['تابع _initializeData چه کاری انجام می‌دهد؟', 'تولید داده‌های جدید چطوریه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'متغیر places, visitTimes, distances و ... به چه دردی می‌خورن؟': {
        'answer': 'places: لیست مکان‌ها\nvisitTimes: زمان لازم برای هر مکان\ndistances: فاصله‌ها بین مکان‌ها\noptimalTour: لیست تور بهینه خروجی\ntotalTime: زمان کل تور انتخاب‌شده',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'زمان بازدید هر مکان رو چطور تعیین می‌کنید؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'آیا UI از انیمیشن یا افکت خاصی استفاده می‌کنه؟': {
        'answer': 'خیر، UI بسیار ساده و مینیماله و فقط از ListView و FloatingActionButton استفاده شده.',
        'suggestions': ['چه Widget‌هایی در UI اصلی استفاده شده؟', 'چه زمانی UI بروزرسانی می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'چه Widget‌هایی در UI اصلی استفاده شده؟': {
        'answer': 'Scaffold\nAppBar\nConsumer<TouristPlannerModel>\nListView.builder\nFloatingActionButton',
        'suggestions': ['آیا UI از انیمیشن یا افکت خاصی استفاده می‌کنه؟', 'داده‌های تور بهینه چطور به UI فرستاده می‌شن؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'آیا ترتیب بازدید مکان‌ها در تور خروجی مهمه؟': {
        'answer': 'بله، ترتیب در optimalTour دقیقاً نشون می‌ده که کاربر باید کجاها و به چه ترتیبی بره.',
        'suggestions': ['داده‌های تور بهینه چطور به UI فرستاده می‌شن؟', 'الگوریتم انتخاب مسیر بهینه چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'چطور بفهمیم که الگوریتم بهینه کار کرده؟': {
        'answer': 'مقدار totalTime و ترتیب optimalTour باید نشون بده که بیشترین مکان ممکن در محدودیت زمانی بازدید شده.',
        'suggestions': ['الگوریتم انتخاب مسیر بهینه چیه؟', 'داده‌های تور بهینه چطور به UI فرستاده می‌شن؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      }
    },
    'general': {
      'سلام': {
        'answer': 'سلام! من دستیار برنامه‌ریز سفر هستم. چطور می‌توانم به شما در مورد اپلیکیشن و الگوریتم‌های آن کمک کنم؟',
        'suggestions': ['این اپلیکیشن چه مشکلی رو حل می‌کنه؟', 'کاربرد اصلی این سیستم چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.9}
      },
      'خداحافظ': {
        'answer': 'خوشحال شدم کمکتون کردم! سفر خوبی داشته باشید.',
        'suggestions': ['این اپلیکیشن چه مشکلی رو حل می‌کنه؟', 'کاربرد اصلی این سیستم چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.6}
      },
      'این اپلیکیشن چه مشکلی رو حل می‌کنه؟': {
        'answer': 'به کاربر کمک می‌کنه در زمان محدود، بیشترین تعداد مکان‌های گردشگری رو بازدید کنه.',
        'suggestions': ['کاربرد اصلی این سیستم چیه؟', 'مزیت این الگوریتم نسبت به الگوریتم‌های ساده‌تر چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.9}
      },
      'کاربرد اصلی این سیستم چیه؟': {
        'answer': 'برنامه‌ریزی بهینه تور سفر با توجه به محدودیت زمانی.',
        'suggestions': ['این اپلیکیشن چه مشکلی رو حل می‌کنه؟', 'مزیت این الگوریتم نسبت به الگوریتم‌های ساده‌تر چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.9}
      },
      'مزیت این الگوریتم نسبت به الگوریتم‌های ساده‌تر چیه؟': {
        'answer': 'با استفاده از برنامه‌ریزی پویا، ترکیب‌های زیادی از مکان‌ها بررسی می‌شن ولی با سرعت بالا و بدون تکرار غیر ضروری.',
        'suggestions': ['چرا از برنامه‌ریزی پویا استفاده کردید؟', 'الگوریتم انتخاب مسیر بهینه چیه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'چرا این طراحی مدل رو انتخاب کردی؟': {
        'answer': 'چون معماری MVVM همراه با Provider در Flutter باعث جدا شدن منطق برنامه از UI و افزایش مقیاس‌پذیری کد می‌شه.',
        'suggestions': ['کلاس TouristPlannerModel چه نقشی داره؟', 'چرا از Flutter استفاده شده؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'چرا از Flutter استفاده شده؟': {
        'answer': 'چون Flutter امکان ساخت رابط کاربری سریع، زیبا و کراس‌پلتفرم رو فراهم می‌کنه.',
        'suggestions': ['چرا این طراحی مدل رو انتخاب کردی؟', 'کلاس TouristPlannerModel چه نقشی داره؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.8}
      },
      'چرا از Logger استفاده کردید؟ کاربردش چیه؟': {
        'answer': 'برای لاگ‌گیری و اشکال‌زدایی راحت‌تر هنگام توسعه. خروجی‌هایی مثل زمان اجرای الگوریتم یا وضعیت داده‌ها رو چاپ می‌کنه.',
        'suggestions': ['چرا این طراحی مدل رو انتخاب کردی؟', 'چه زمانی UI بروزرسانی می‌شه؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      },
      'آیا می‌شه به جای دقیقه، از ساعت یا کیلومتر استفاده کرد؟': {
        'answer': 'بله، فقط باید واحد فاصله‌ها و زمان‌ها رو یکسان‌سازی و در UI یا پردازش تطبیق بدی.',
        'suggestions': ['فاصله بین مکان‌ها چطور مقداردهی می‌شه؟', 'زمان بازدید هر مکان رو چطور تعیین می‌کنید؟'],
        'metadata': {'added_at': '2025-05-16', 'source': 'predefined', 'priority': 0.7}
      }
    }
  };

  final Map<String, int> _unansweredQuestions = {};
  final Map<String, Map<String, int>> _responsesFeedback = {};

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isBotTyping => _isBotTyping;

  ChatbotService() {
    _initPreferences();
    _greetUser();
  }

  /// Initializes SharedPreferences and loads saved data.
  Future<void> _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _prefsInitialized = true;
      await Future.wait([
        _loadKnowledgeBase(),
        _loadUnansweredQuestions(),
        _loadResponsesFeedback(),
      ]);
    } catch (e) {
      _handleError('initializing preferences', e, fallbackMessage: 'مشکلی در راه‌اندازی پیش اومد.');
    }
  }

  /// Loads knowledge base from SharedPreferences.
  Future<void> _loadKnowledgeBase() async {
    try {
      final String? storedKnowledgeBase = _prefs.getString('knowledgeBase');
      if (storedKnowledgeBase != null) {
        final Map<String, dynamic> decoded = json.decode(storedKnowledgeBase);
        decoded.forEach((category, questions) {
          if (_knowledgeBase.containsKey(category)) {
            _knowledgeBase[category]!.addAll(Map<String, dynamic>.from(questions));
          } else {
            _knowledgeBase[category] = Map<String, dynamic>.from(questions);
          }
        });
      }
    } catch (e) {
      await _handleError('loading knowledge base', e);
    }
  }

  /// Loads unanswered questions from SharedPreferences.
  Future<void> _loadUnansweredQuestions() async {
    try {
      final String? storedUnansweredQuestions = _prefs.getString('unansweredQuestions');
      if (storedUnansweredQuestions != null) {
        final Map<String, dynamic> decodedMap = json.decode(storedUnansweredQuestions);
        _unansweredQuestions.clear();
        decodedMap.forEach((key, value) {
          if (value is int) _unansweredQuestions[key] = value;
        });
      }
    } catch (e) {
      await _handleError('loading unanswered questions', e);
    }
  }

  /// Loads feedback data from SharedPreferences.
  Future<void> _loadResponsesFeedback() async {
    try {
      final String? storedFeedback = _prefs.getString('responsesFeedback');
      if (storedFeedback != null) {
        final Map<String, dynamic> decodedMap = json.decode(storedFeedback);
        _responsesFeedback.clear();
        decodedMap.forEach((questionKey, feedbackData) {
          if (feedbackData is Map) {
            _responsesFeedback[questionKey] = Map<String, int>.from(feedbackData.map((key, value) =>
                MapEntry(key, value is int ? value : 0)));
          }
        });
      }
    } catch (e) {
      await _handleError('loading feedback data', e);
    }
  }

  /// Handles errors with optional fallback message.
  Future<void> _handleError(String operation, dynamic error, {String? fallbackMessage}) async {
    debugPrint('Error in $operation: $error');
    if (fallbackMessage != null) {
      _addBotMessageInternal(fallbackMessage);
      notifyListeners();
    }
  }

  /// Saves knowledge base to SharedPreferences.
  void _saveKnowledgeBase() {
    if (_prefsInitialized) {
      _prefs.setString('knowledgeBase', json.encode(_knowledgeBase));
    }
  }

  /// Saves unanswered questions to SharedPreferences.
  void _saveUnansweredQuestions() {
    if (_prefsInitialized) {
      _prefs.setString('unansweredQuestions', json.encode(_unansweredQuestions));
    }
  }

  /// Saves feedback data to SharedPreferences.
  void _saveResponsesFeedback() {
    if (_prefsInitialized) {
      _prefs.setString('responsesFeedback', json.encode(_responsesFeedback));
    }
  }

  /// Sends a greeting message based on the time of day.
  void _greetUser() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'صبح بخیر!'
        : hour < 18
        ? 'ظهر بخیر!'
        : 'شب بخیر!';
    final greetingData = _knowledgeBase['general']?['سلام'];
    if (greetingData != null) {
      _addBotMessageInternal(
        '$greeting ${greetingData['answer']}',
        suggestedQuestions: List<String>.from(greetingData['suggestions'] ?? []),
      );
    } else {
      _addBotMessageInternal('$greeting چطور می‌توانم کمکتان کنم؟');
    }
  }

  /// Adds a user message and processes it.
  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageModel(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    if (_isActiveLearningMode) {
      _handleActiveLearningResponse(text);
    } else {
      _processUserMessage(text);
    }
  }

  /// Adds a bot message to the conversation.
  void _addBotMessageInternal(String text, {List<String>? suggestedQuestions}) {
    final botMessage = ChatMessageModel(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      suggestedQuestions: suggestedQuestions,
    );
    _messages.add(botMessage);
  }

  /// Normalizes Persian text for consistent matching.
  String _normalizeText(String text) {
    String normalizedText = text
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ة', 'ه')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ی')
        .replaceAll('\u200C', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[،؛؟!.:،,;?]'), '');
    return normalizedText.trim();
  }

  /// Determines the most relevant category for a query based on key terms.
  String _getQueryCategory(String normalizedQuery) {
    for (var term in _keyTerms) {
      if (normalizedQuery.contains(term)) {
        if (['الگوریتم', 'برنامه‌ریزی', 'پویا', 'مسیر', 'بهینه'].contains(term)) {
          return 'algorithms';
        } else if (['داده', 'فاصله', 'مکان', 'زمان'].contains(term)) {
          return 'data';
        } else if (['تور'].contains(term)) {
          return 'ui';
        }
      }
    }
    return 'general';
  }

  /// Finds the most similar question in the knowledge base using string similarity.
  /// Returns a tuple of (bestMatchKey, highestSimilarity).
  (String?, double) _findMostSimilarQuestion(String userQuery) {
    String normalizedUserQuery = _normalizeText(userQuery);

    if (_similarityCache.containsKey(normalizedUserQuery)) {
      return _similarityCache[normalizedUserQuery]!;
    }

    String? bestMatchKey;
    double highestSimilarity = 0.0;
    String targetCategory = _getQueryCategory(normalizedUserQuery);

    const double exactMatchWeight = 1.0;
    const double similarityWeight = 0.7;
    const double keywordMatchWeight = 0.5;
    const double keyTermBoost = 0.2;

    for (String category in _knowledgeBase.keys) {
      // Prioritize the target category
      if (category != targetCategory && highestSimilarity >= 0.6) continue;

      for (String key in _knowledgeBase[category]!.keys) {
        String normalizedKey = _normalizeText(key);
        double currentScore = 0.0;

        if (normalizedUserQuery == normalizedKey) {
          currentScore += exactMatchWeight;
        }

        double similarityScore = normalizedUserQuery.similarityTo(normalizedKey);
        currentScore += similarityScore * similarityWeight;

        List<String> userQueryWords = normalizedUserQuery.split(' ');
        List<String> keyWords = normalizedKey.split(' ');
        int matchedWords = 0;
        int matchedKeyTerms = 0;
        for (String word in userQueryWords) {
          if (word.length > 2) {
            if (keyWords.contains(word)) {
              matchedWords++;
            }
            if (_keyTerms.contains(word)) {
              matchedKeyTerms++;
            }
          }
        }
        if (userQueryWords.isNotEmpty) {
          double keywordMatchScore = matchedWords / userQueryWords.length;
          currentScore += keywordMatchScore * keywordMatchWeight;
          currentScore += (matchedKeyTerms / userQueryWords.length) * keyTermBoost;
        }

        double priority = _knowledgeBase[category]![key]['metadata']['priority']?.toDouble() ?? 0.5;
        currentScore *= priority;

        if (currentScore > highestSimilarity) {
          highestSimilarity = currentScore;
          bestMatchKey = key;
        }
      }
    }

    if (bestMatchKey != null && highestSimilarity > 0.4) {
      _similarityCache[normalizedUserQuery] = (bestMatchKey, highestSimilarity);
      if (_similarityCache.length > 100) {
        _similarityCache.remove(_similarityCache.keys.first);
      }
    }

    return (bestMatchKey, highestSimilarity);
  }

  /// Adds user feedback for a specific question.
  void addUserFeedback(String questionKey, String feedbackType) {
    if (!_responsesFeedback.containsKey(questionKey)) {
      _responsesFeedback[questionKey] = {'positive': 0, 'negative': 0};
    }
    if (feedbackType == 'positive') {
      _responsesFeedback[questionKey]!['positive'] = (_responsesFeedback[questionKey]!['positive'] ?? 0) + 1;
    } else if (feedbackType == 'negative') {
      _responsesFeedback[questionKey]!['negative'] = (_responsesFeedback[questionKey]!['negative'] ?? 0) + 1;
    }
    _saveResponsesFeedback();
    _reviewFeedbackAndUpdateKnowledgeBase();
  }

  /// Validates a user-provided answer.
  bool _validateAnswer(String answer) {
    if (answer.length < 10 || answer.length > 500) return false;
    if (answer.split(' ').length < 5) return false;
    if (answer.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return !_knowledgeBase.values.any((category) =>
        category.values.any((entry) => entry['answer'] == answer));
  }

  /// Prompts the user to provide an answer for an unanswered question.
  void _suggestUserToAddAnswer(String question) {
    _isActiveLearningMode = true;
    _pendingQuestionForLearning = question;
    _pendingSuggestions.clear();
    _activeLearningAttempts = 0;
    _addBotMessageInternal(
      'سوال جالبی پرسیدید! ($question) می‌تونید جوابش رو برام بنویسید تا دفعه بعد بهتر کمک کنم؟',
      suggestedQuestions: ['بله، جواب می‌دم', 'نه، مرسی'],
    );
  }

  /// Handles responses during active learning mode.
  void _handleActiveLearningResponse(String userResponse) async {
    if (_pendingQuestionForLearning == null) {
      _isActiveLearningMode = false;
      _processUserMessage(userResponse);
      return;
    }

    _activeLearningAttempts++;

    if (userResponse.contains('نه') ||
        userResponse.contains('مرسی') ||
        _activeLearningAttempts > _maxActiveLearningAttempts) {
      _addBotMessageInternal('باشه، مرسی که اطلاع دادید! اگه سوال دیگه‌ای دارید بپرسید.');
      _isActiveLearningMode = false;
      _pendingQuestionForLearning = null;
      _pendingSuggestions.clear();
      _activeLearningAttempts = 0;
      notifyListeners();
      return;
    }

    if (userResponse.contains('بله')) {
      _addBotMessageInternal('عالیه! لطفاً جواب سوال رو بنویسید:');
      notifyListeners();
      return;
    }

    if (_pendingSuggestions.isEmpty) {
      if (!_validateAnswer(userResponse)) {
        String errorMessage = _activeLearningAttempts < _maxActiveLearningAttempts
            ? 'جواب باید حداقل 5 کلمه و حداکثر 500 کاراکتر باشه و نباید تکراری یا شامل کاراکترهای خاص باشه. لطفاً دوباره بنویسید:'
            : 'متأسفم، تعداد تلاش‌ها به پایان رسید. اگه سوال دیگه‌ای دارید بپرسید.';
        _addBotMessageInternal(errorMessage);
        if (_activeLearningAttempts >= _maxActiveLearningAttempts) {
          _isActiveLearningMode = false;
          _pendingQuestionForLearning = null;
          _pendingSuggestions.clear();
          _activeLearningAttempts = 0;
        }
        notifyListeners();
        return;
      }

      _addBotMessageInternal(
        'ممنون! حالا اگه سوالات پیشنهادی مرتبط با این موضوع دارید بنویسید (مثلاً "سوال 1، سوال 2") یا بنویسید "ندارم":',
      );
      _pendingSuggestions.add(userResponse);
      notifyListeners();
      return;
    }

    if (userResponse.toLowerCase().contains('ندارم')) {
      _pendingSuggestions = [];
    } else {
      _pendingSuggestions = userResponse
          .split('،')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length > 3)
          .toList();
    }

    Map<String, dynamic> newEntry = {
      'answer': _pendingSuggestions[0],
      'metadata': {
        'added_at': DateTime.now().toIso8601String(),
        'source': 'user_contributed',
        'priority': 0.5,
      }
    };
    if (_pendingSuggestions.length > 1) {
      newEntry['suggestions'] = _pendingSuggestions.sublist(1);
    }

    String category = _getQueryCategory(_pendingQuestionForLearning!);
    if (!_knowledgeBase.containsKey(category)) {
      _knowledgeBase[category] = {};
    }
    _knowledgeBase[category]![_pendingQuestionForLearning!] = newEntry;
    _saveKnowledgeBase();
    _unansweredQuestions.remove(_pendingQuestionForLearning);
    _saveUnansweredQuestions();

    _addBotMessageInternal('ممنون از کمکتون! این سوال و جوابش رو به دانشم اضافه کردم. سوالی دیگه دارید؟');
    _isActiveLearningMode = false;
    _pendingQuestionForLearning = null;
    _pendingSuggestions.clear();
    _activeLearningAttempts = 0;
    notifyListeners();
  }

  /// Adds a new question to the knowledge base manually.
  void addNewQuestionToKnowledgeBase(String question, String answer, List<String>? suggestions, {String category = 'general'}) {
    if (question.trim().isEmpty || answer.trim().isEmpty || !_validateAnswer(answer)) return;

    Map<String, dynamic> newEntry = {
      'answer': answer,
      'metadata': {
        'added_at': DateTime.now().toIso8601String(),
        'source': 'manual',
        'priority': 0.5,
      }
    };
    if (suggestions != null && suggestions.isNotEmpty) {
      newEntry['suggestions'] = suggestions.where((s) => s.length > 3).toList();
    }

    if (!_knowledgeBase.containsKey(category)) {
      _knowledgeBase[category] = {};
    }
    _knowledgeBase[category]![question] = newEntry;
    _saveKnowledgeBase();
  }

  /// Reviews feedback and removes low-quality responses.
  void _reviewFeedbackAndUpdateKnowledgeBase() {
    _responsesFeedback.forEach((questionKey, feedback) {
      int positive = feedback['positive'] ?? 0;
      int negative = feedback['negative'] ?? 0;
      if (negative > positive + 5) {
        for (var category in _knowledgeBase.keys) {
          if (_knowledgeBase[category]!.containsKey(questionKey)) {
            _knowledgeBase[category]!.remove(questionKey);
            break;
          }
        }
        _responsesFeedback.remove(questionKey);
        debugPrint('Removed low-quality response for: $questionKey');
      }
    });
    _saveResponsesFeedback();
  }

  /// Generates dynamic suggestions based on matched question or feedback.
  List<String> _generateDynamicSuggestions(String? matchedQuestionKey) {
    if (matchedQuestionKey != null) {
      for (var category in _knowledgeBase.keys) {
        if (_knowledgeBase[category]!.containsKey(matchedQuestionKey)) {
          var matchedData = _knowledgeBase[category]![matchedQuestionKey];
          if (matchedData != null && matchedData['suggestions'] != null) {
            return List<String>.from(matchedData['suggestions']);
          }
          break;
        }
      }
    }

    List<String> popularQuestions = _responsesFeedback.entries
        .where((entry) => (entry.value['positive'] ?? 0) > (entry.value['negative'] ?? 0))
        .map((entry) => entry.key)
        .take(3)
        .toList();
    return popularQuestions.isNotEmpty
        ? popularQuestions
        : ['سلام', 'این اپلیکیشن چه مشکلی رو حل می‌کنه؟'];
  }

  /// Processes a user message and generates a response.
  Future<void> _processUserMessage(String userMessage) async {
    _isBotTyping = true;
    notifyListeners();

    final delayMs = (300 + userMessage.length * 10).clamp(300, 1000);
    await Future.delayed(Duration(milliseconds: delayMs));

    String responseText =
        'متاسفم، سوال شما را متوجه نشدم. می‌توانید از سوالات پیشنهادی استفاده کنید یا سوال خود را به شکل دیگری بپرسید.';
    List<String>? nextSuggestions;

    final (bestMatchKey, highestSimilarity) = _findMostSimilarQuestion(userMessage);

    if (bestMatchKey != null && highestSimilarity > 0.4) {
      for (var category in _knowledgeBase.keys) {
        if (_knowledgeBase[category]!.containsKey(bestMatchKey)) {
          final matchedData = _knowledgeBase[category]![bestMatchKey];
          responseText = matchedData['answer'] as String? ?? 'پاسخی برای این مورد یافت نشد.';
          nextSuggestions = _generateDynamicSuggestions(bestMatchKey);
          break;
        }
      }
    } else {
      String normalizedQuestion = _normalizeText(userMessage);
      if (normalizedQuestion.length > 3) {
        _unansweredQuestions[normalizedQuestion] = (_unansweredQuestions[normalizedQuestion] ?? 0) + 1;
        if (_unansweredQuestions[normalizedQuestion]! >= 3) {
          _suggestUserToAddAnswer(normalizedQuestion);
          _isBotTyping = false;
          notifyListeners();
          return;
        }
        _saveUnansweredQuestions();
      }
      nextSuggestions = _generateDynamicSuggestions(null);
    }

    _addBotMessageInternal(responseText, suggestedQuestions: nextSuggestions);
    _isBotTyping = false;
    notifyListeners();
  }

  /// Searches for questions matching a query.
  List<String> searchQuestions(String query) {
    String normalizedQuery = _normalizeText(query);
    List<String> results = [];
    for (var category in _knowledgeBase.keys) {
      results.addAll(_knowledgeBase[category]!
          .keys
          .where((key) => _normalizeText(key).contains(normalizedQuery)));
    }
    return results;
  }

  /// Gets suggested questions for a specific category.
  List<String> getCategorySuggestions(String category) {
    return _knowledgeBase[category]?.keys.toList() ?? [];
  }

  /// Returns frequent unanswered questions.
  List<MapEntry<String, int>> getFrequentUnansweredQuestions({int limit = 10}) {
    final sortedEntries = _unansweredQuestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).toList();
  }

  /// Returns feedback statistics.
  Map<String, Map<String, int>> getFeedbackStats() {
    return Map.from(_responsesFeedback);
  }

  /// Clears old unanswered questions based on age.
  void clearOldUnansweredQuestions({Duration maxAge = const Duration(days: 30)}) {
    final now = DateTime.now();
    _unansweredQuestions.removeWhere((key, value) {
      for (var category in _knowledgeBase.keys) {
        final metadata = _knowledgeBase[category]?[key]?['metadata'];
        if (metadata != null && metadata['added_at'] != null) {
          final addedAt = DateTime.parse(metadata['added_at']);
          return now.difference(addedAt) > maxAge;
        }
      }
      return false;
    });
    _saveUnansweredQuestions();
  }

  /// Clears the conversation history and sends a greeting.
  void clearConversationHistory() {
    _messages.clear();
    _greetUser();
    notifyListeners();
  }
}