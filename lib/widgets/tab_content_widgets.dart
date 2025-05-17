import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tourist_planner_model.dart';
import '../utils/color_utils.dart';
import 'common_widgets.dart';

Widget buildTabContentWidget(
    BuildContext context,
    // اضافه کردن BuildContext به پارامترها
    TouristPlannerModel model,
    int selectedTabIndex,
    TextEditingController timeController) {
  switch (selectedTabIndex) {
    case 0:
      return _buildTimeInput(
          context, model, timeController); // پاس دادن context
    case 1:
      return _buildPlacesTable(model);
    case 2:
      return _buildDistancesTable(model);
    case 3:
      return _buildResultSection(model, timeController);
    default:
      return Container();
  }
}

Widget _buildTimeInput(
    BuildContext context, // اضافه کردن context به پارامترها
    TouristPlannerModel model,
    TextEditingController timeController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildSectionTitle('اطلاعات سفر', Icons.timer),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'محدودیت زمانی سفر',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لطفاً کل زمان در دسترس برای بازدید از مکان‌ها را وارد کنید.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'زمان (دقیقه)',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.access_time),
                suffixText: 'دقیقه',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  model.calculateOptimalTour(int.parse(timeController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('مسیر بهینه با موفقیت محاسبه شد!'),
                      backgroundColor: const Color(0xFF5B8CFF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'مشاهده',
                        textColor: Colors.white,
                        onPressed: () {
                          model.notifyListeners(); // Trigger UI update
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('محاسبه مسیر بهینه'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'اطلاعات کلی',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            buildInfoCard(
              'تعداد مکان‌های موجود',
              '${model.places.length} مکان',
              Icons.place,
              const Color(0xFFE6F0FF),
              const Color(0xFF5B8CFF),
            ),
            const SizedBox(height: 12),
            buildInfoCard(
              'میانگین زمان بازدید',
              '${model.getAvgVisitTime()} دقیقه',
              Icons.access_time_filled,
              const Color(0xFFE6FFF8),
              const Color(0xFF6FE7C8),
            ),
            const SizedBox(height: 12),
            buildInfoCard(
              'میانگین فاصله بین مکان‌ها',
              '${model.getAvgDistance()} دقیقه',
              Icons.directions_car,
              const Color(0xFFFFEEEA),
              const Color(0xFFFFA48E),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildPlacesTable(TouristPlannerModel model) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildSectionTitle('جدول مکان‌های گردشگری', Icons.place),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اطلاعات زمان بازدید از هر مکان گردشگری',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'این جدول زمان مورد نیاز برای بازدید از هر مکان را نشان می‌دهد.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8CFF),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8CFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'کد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'نام مکان',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'زمان بازدید',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                  for (var i = 0; i < model.places.length; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                        border: i < model.places.length - 1
                            ? Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: getPlaceColor(model.places[i]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  model.places[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                model.placeNames[model.places[i]] ??
                                    model.places[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getVisitTimeColor(
                                          model.visitTimes[model.places[i]] ??
                                              0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${model.visitTimes[model.places[i]]} دقیقه',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildDistancesTable(TouristPlannerModel model) {
  double cellWidth = (WidgetsBinding.instance.window.physicalSize.width /
              WidgetsBinding.instance.window.devicePixelRatio -
          32) /
      (model.places.length + 1);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildSectionTitle('جدول فاصله بین مکان‌ها', Icons.map),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فاصله زمانی بین مکان‌های گردشگری',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'این جدول نشان‌دهنده زمان سفر (به دقیقه) بین هر دو مکان است.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 2.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: cellWidth,
                            height: cellWidth,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF5B8CFF), Color(0xFF6FE7C8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'از/به',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          ...model.places.map((place) {
                            return Container(
                              width: cellWidth,
                              height: cellWidth,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5B8CFF),
                                    Color(0xFF6FE7C8)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: place == model.places.last
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                      )
                                    : null,
                                border: place != model.places.last
                                    ? const Border(
                                        right: BorderSide(
                                            color: Colors.white, width: 1),
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  place,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      for (var i = 0; i < model.places.length; i++)
                        Row(
                          children: [
                            Container(
                              width: cellWidth,
                              height: cellWidth,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5B8CFF),
                                    Color(0xFF6FE7C8)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: i == model.places.length - 1
                                    ? const BorderRadius.only(
                                        bottomRight: Radius.circular(12),
                                      )
                                    : null,
                                border: i != model.places.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                            color: Colors.white, width: 1),
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  model.places[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            ...model.places.map((place) {
                              final distance =
                                  model.distances[model.places[i]]?[place] ?? 0;
                              final isSelf = model.places[i] == place;
                              final isLastColumn = place == model.places.last;
                              final isLastRow = i == model.places.length - 1;

                              return Container(
                                width: cellWidth,
                                height: cellWidth,
                                decoration: BoxDecoration(
                                  color: isSelf
                                      ? Colors.grey.shade100
                                      : (i % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.shade50),
                                  borderRadius: isLastColumn && isLastRow
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                        )
                                      : null,
                                  border: Border(
                                    bottom: isLastRow
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Colors.grey.shade200),
                                    right: isLastColumn
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Colors.grey.shade200),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isSelf
                                      ? const Text(
                                          '—',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getDistanceColor(distance),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$distance',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildResultSection(
    TouristPlannerModel model, TextEditingController timeController) {
  final timeLimit = int.tryParse(timeController.text) ?? 180;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildSectionTitle('نتیجه محاسبه مسیر بهینه', Icons.route),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مسیر بهینه برای بازدید',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'محدودیت زمانی: $timeLimit دقیقه',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF5B8CFF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF5B8CFF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'کل زمان مسیر: ${model.optimalTourTime} دقیقه',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B8CFF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place,
                          color: Color(0xFF5B8CFF), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تعداد مکان‌های بازدید شده: ${model.optimalTour.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B8CFF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            model.optimalTour.isEmpty
                ? const Center(
                    child: Text(
                      'هیچ مسیری با این محدودیت زمانی یافت نشد!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ترتیب بازدید از مکان‌ها:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTourPath(model),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'جزئیات مسیر:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTourDetails(model),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTourPath(TouristPlannerModel model) {
  final ScrollController _tourPathScrollController = ScrollController();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _tourPathScrollController.jumpTo(0); // اصلاح jumpto به jumpTo
  });

  return SingleChildScrollView(
    controller: _tourPathScrollController,
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          for (int i = 0; i < model.optimalTour.length; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getPlaceColor(model.optimalTour[i]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: getPlaceColor(model.optimalTour[i]).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  model.optimalTour[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (i < model.optimalTour.length - 1) ...[
              Container(
                width: 15,
                height: 2,
                color: Colors.grey.shade400,
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF5B8CFF),
                size: 20,
              ),
              Container(
                width: 15,
                height: 2,
                color: Colors.grey.shade400,
              ),
            ],
          ],
        ],
      ),
    ),
  );
}

Widget _buildTourDetails(TouristPlannerModel model) {
  int cumulativeTime = 0;
  String prevPlace = model.optimalTour.first;

  return Column(
    children: [
      for (int i = 0; i < model.optimalTour.length; i++) ...[
        () {
          final place = model.optimalTour[i];
          final visitTime = model.visitTimes[place] ?? 0;
          final travelTime =
              i > 0 ? (model.distances[prevPlace]?[place] ?? 0) : 0;

          if (i == 0) {
            cumulativeTime = visitTime;
          } else {
            cumulativeTime += travelTime + visitTime;
          }

          if (i < model.optimalTour.length - 1) {
            prevPlace = place;
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: getPlaceColor(place),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.placeNames[place] ?? place,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.watch_later,
                                  size: 16, color: Color(0xFF5B8CFF)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'زمان بازدید: $visitTime دقیقه',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (i > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.directions,
                                    size: 16, color: Color(0xFFFFA48E)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'زمان سفر از ${model.optimalTour[i - 1]}: $travelTime دقیقه',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            i == 0
                                ? 'شروع'
                                : '+${travelTime + visitTime} دقیقه',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6FE7C8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'کل: $cumulativeTime دقیقه',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < model.optimalTour.length - 1) ...[
                Container(
                  width: 2,
                  height: 24,
                  color: Colors.grey.shade300,
                ),
              ],
            ],
          );
        }(),
      ],
    ],
  );
}
