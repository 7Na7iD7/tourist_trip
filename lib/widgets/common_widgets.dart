import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/tourist_planner_model.dart';

void showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('راهنمای برنامه', textAlign: TextAlign.center),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'به برنامه‌ریز سفر گردشگری خوش آمدید!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'این برنامه به شما کمک می‌کند بهترین مسیر بازدید از مکان‌های گردشگری را با توجه به محدودیت زمانی انتخاب کنید.',
            ),
            SizedBox(height: 12),
            Text('راهنما:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• محدودیت زمانی خود را به دقیقه وارد کنید.'),
            Text(
                '• می‌توانید با دکمه تولید داده‌های جدید، مکان‌های تصادفی ایجاد کنید.'),
            Text('• در هر زمان با زدن دکمه محاسبه، مسیر بهینه را دریافت کنید.'),
            SizedBox(height: 12),
            Text('با استفاده از تب‌ها، بین بخش‌های مختلف برنامه جابجا شوید.'),
            SizedBox(height: 12),
            Text(
              'این برنامه از الگوریتم فلوید-وارشال و برنامه‌ریزی پویا برای یافتن بهینه‌ترین مسیر با توجه به محدودیت زمانی استفاده می‌کند.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('متوجه شدم'),
        ),
      ],
    ),
  );
}

void showGenerateDataDialog(BuildContext context, TextEditingController timeController) {
  final TextEditingController placesController =
  TextEditingController(text: '5');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تولید داده‌های جدید', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('تعداد مکان‌های گردشگری را مشخص کنید:'),
          const SizedBox(height: 16),
          TextField(
            controller: placesController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'تعداد مکان‌ها (حداکثر 10)',
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
            final places = int.tryParse(placesController.text) ?? 5;
            final model =
            Provider.of<TouristPlannerModel>(context, listen: false);
            model.generateRandomData(min(max(places, 2), 10));
            model.calculateOptimalTour(int.parse(timeController.text));
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${min(max(places, 2), 10)} مکان گردشگری با موفقیت ایجاد شد!'),
                backgroundColor: const Color(0xFF5B8CFF),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B8CFF),
            foregroundColor: Colors.white,
          ),
          child: const Text('تولید'),
        ),
      ],
    ),
  );
}