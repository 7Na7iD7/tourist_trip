import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/tourist_planner_model.dart';
import 'services/chatbot_service.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TouristPlannerModel()),
        ChangeNotifierProvider(create: (context) => ChatbotService()), // اضافه کردن ChatbotService
      ],
      child: MaterialApp(
        title: 'برنامه‌ریز سفر',
        theme: ThemeData(
            primaryColor: const Color(0xFF5B8CFF),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B8CFF),
              secondary: Color(0xFF6FE7C8),
              tertiary: Color(0xFFFFA48E),
              surface: Colors.white,
              onSurface: Color(0xFF2D3142),
              background: Color(0xFFF5F7FA),
              error: Colors.redAccent,

            ),
            fontFamily: 'Vazir',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              shadowColor: const Color(0x1A000000),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey.shade300;
                      }
                      return const Color(0xFF5B8CFF);
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey.shade600; // رنگ متن دکمه غیرفعال
                        }
                        return Colors.white;
                      }
                  ),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14)), // پدینگ عمودی بیشتر
                  elevation: const WidgetStatePropertyAll(2),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                  textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold, fontSize: 15))
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontFamily: 'Vazir', color: Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 32),
              headlineMedium: TextStyle(fontFamily: 'Vazir', color: Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 24), // برای عناوین صفحه
              titleLarge: TextStyle(fontFamily: 'Vazir', color: Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 18), // برای عناوین بخش‌ها
              bodyLarge: TextStyle(fontFamily: 'Vazir', color: Color(0xFF2D3142), fontSize: 15, height: 1.5), // متن اصلی خواناتر
              bodyMedium: TextStyle(fontFamily: 'Vazir', color: Color(0xFF555B6E), fontSize: 13.5, height: 1.4), // متن فرعی خواناتر
              labelLarge: TextStyle(fontFamily: 'Vazir', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), // برای متن روی دکمه‌ها
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white, // پس‌زمینه سفید برای فیلدهای ورودی
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.5), // فونت و رنگ بهتر برای hint
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300), // بوردر پیش‌فرض
              ),
              enabledBorder: OutlineInputBorder( // بوردر در حالت عادی
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF5B8CFF), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF5B8CFF).withOpacity(0.1),
              disabledColor: Colors.grey.withOpacity(0.5),
              selectedColor: const Color(0xFF5B8CFF),
              secondarySelectedColor: const Color(0xFF5B8CFF),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // پدینگ بهتر
              labelStyle: TextStyle(fontFamily: 'Vazir', color: const Color(0xFF5B8CFF), fontSize: 12.5, fontWeight: FontWeight.w500),
              secondaryLabelStyle: TextStyle(fontFamily: 'Vazir', color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
              brightness: Brightness.light,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // گردی بیشتر برای چیپ‌ها
                  side: BorderSide(color: const Color(0xFF5B8CFF).withOpacity(0.3))
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white, // پس‌زمینه سفید برای دیالوگ‌ها
              titleTextStyle: TextStyle(fontFamily: 'Vazir', color: const Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 18),
              contentTextStyle: TextStyle(fontFamily: 'Vazir', color: const Color(0xFF2D3142), fontSize: 15, height: 1.5),
            ),
            // تنظیمات بیشتر برای BottomSheetTheme برای هماهنگی با مودال چت‌بات
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.white, // یا Theme.of(context).colorScheme.surface
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              elevation: 5,
              modalBackgroundColor: Colors.transparent, // برای اینکه DraggableScrollableSheet بتواند پس‌زمینه خودش را نشان دهد
            )
        ),
        // نام صفحه شروع را به ModernWelcomeScreen تغییر می‌دهیم
        home: const ModernWelcomeScreen(), // صفحه شروع پروژه شما اکنون ModernWelcomeScreen است
        // home: const TouristPlannerScreen(), // برای تست مستقیم صفحه اصلی
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}