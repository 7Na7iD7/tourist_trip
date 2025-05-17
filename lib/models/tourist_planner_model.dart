import 'dart:math';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class TouristPlannerModel extends ChangeNotifier {
  final Random _random = Random();
  final List<String> _places = [];
  final Map<String, String> _placeNames = {};
  final Map<String, int> _visitTimes = {};
  final Map<String, Map<String, int>> _distances = {};
  List<String> _optimalTour = [];
  int _optimalTourTime = 0;
  final Logger logger = Logger();

  List<String> get places => _places;
  Map<String, String> get placeNames => _placeNames;
  Map<String, int> get visitTimes => _visitTimes;
  Map<String, Map<String, int>> get distances => _distances;
  List<String> get optimalTour => _optimalTour;
  int get optimalTourTime => _optimalTourTime;

  TouristPlannerModel() {
    _initializeData();
  }

  get lastCalculatedTimeLimit => null;

  void _initializeData() {
    _places.clear();
    _placeNames.clear();
    _visitTimes.clear();
    _distances.clear();
    _optimalTour = [];
    _optimalTourTime = 0;

    _places.addAll(['A', 'B', 'C', 'D', 'E']);
    _placeNames['A'] = 'موزه';
    _placeNames['B'] = 'پارک';
    _placeNames['C'] = 'بازار';
    _placeNames['D'] = 'کاخ';
    _placeNames['E'] = 'معبد';

    _visitTimes['A'] = 60;
    _visitTimes['B'] = 40;
    _visitTimes['C'] = 80;
    _visitTimes['D'] = 60;
    _visitTimes['E'] = 30;

    for (var place in _places) {
      _distances[place] = {};
      for (var otherPlace in _places) {
        _distances[place]![otherPlace] = place == otherPlace ? 0 : 999999;
      }
    }

    _distances['A']!['B'] = 10;
    _distances['A']!['C'] = 25;
    _distances['A']!['D'] = 50;
    _distances['A']!['E'] = 15;
    _distances['B']!['A'] = 10;
    _distances['B']!['C'] = 20;
    _distances['B']!['D'] = 40;
    _distances['B']!['E'] = 5;
    _distances['C']!['A'] = 25;
    _distances['C']!['B'] = 20;
    _distances['C']!['D'] = 30;
    _distances['C']!['E'] = 15;
    _distances['D']!['A'] = 50;
    _distances['D']!['B'] = 40;
    _distances['D']!['C'] = 30;
    _distances['D']!['E'] = 35;
    _distances['E']!['A'] = 15;
    _distances['E']!['B'] = 5;
    _distances['E']!['C'] = 15;
    _distances['E']!['D'] = 35;

    _applyFloydWarshall();
    notifyListeners();
  }

  void generateRandomData(int count) {
    _places.clear();
    _placeNames.clear();
    _visitTimes.clear();
    _distances.clear();
    _optimalTour = [];
    _optimalTourTime = 0;

    final touristPlaces = [
      ' پارک ملی ',
      ' موزه هنر ',
      ' بازار سنتی ',
      ' کاخ تاریخی ',
      ' مرکز خرید ',
      ' پارک آبی ',
      ' موزه تاریخ ',
      ' گالری عکس ',
      ' آکواریوم ',
      ' رصدخانه ',
    ];

    for (var i = 0; i < count; i++) {
      var place = String.fromCharCode(65 + i);
      _places.add(place);
      _placeNames[place] = touristPlaces[i % touristPlaces.length];
      _visitTimes[place] = 10 + _random.nextInt(50);
      _distances[place] = {};
    }

    for (var i = 0; i < _places.length; i++) {
      for (var j = 0; j < _places.length; j++) {
        if (i != j) {
          int distance = 5 + _random.nextInt(30);
          _distances[_places[i]]![_places[j]] = distance;
        } else {
          _distances[_places[i]]![_places[j]] = 0;
        }
      }
    }

    _applyFloydWarshall();
    notifyListeners();
  }

  void _applyFloydWarshall() {
    int n = _places.length;
    var dist = Map<String, Map<String, int>>.from(_distances);

    for (var k = 0; k < n; k++) {
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          var placeI = _places[i];
          var placeJ = _places[j];
          var placeK = _places[k];
          if (dist[placeI]![placeK]! + dist[placeK]![placeJ]! <
              dist[placeI]![placeJ]!) {
            dist[placeI]![placeJ] =
                dist[placeI]![placeK]! + dist[placeK]![placeJ]!;
          }
        }
      }
    }

    _distances.clear();
    _distances.addAll(dist);
  }

  int getAvgVisitTime() {
    if (_visitTimes.isEmpty) return 0;
    int sum = _visitTimes.values.fold(0, (prev, time) => prev + time);
    return sum ~/ _visitTimes.length;
  }

  int getAvgDistance() {
    if (_distances.isEmpty) return 0;
    int sum = 0;
    int count = 0;
    if (_distances.containsKey('B') && _distances['B']!.containsKey('A')) {
      sum += _distances['B']!['A']!;
      count++;
    }
    if (_distances.containsKey('B') && _distances['B']!.containsKey('E')) {
      sum += _distances['B']!['E']!;
      count++;
    }
    if (_distances.containsKey('E') && _distances['E']!.containsKey('A')) {
      sum += _distances['E']!['A']!;
      count++;
    }
    return count > 0 ? sum ~/ count : 0;
  }

  void calculateOptimalTour(int timeLimit) {
    if (_places.isEmpty) {
      _optimalTour = [];
      _optimalTourTime = 0;
      notifyListeners();
      return;
    }

    List<String> bestTour = [];
    int bestTime = 0;
    int bestVisitedCount = 0;

    for (var startPlace in _places) {
      var result = _dpSolve(startPlace, timeLimit);
      var tour = result['tour'] as List<String>;
      var time = result['time'] as int;

      if (tour.length > bestVisitedCount ||
          (tour.length == bestVisitedCount && time < bestTime)) {
        bestTour = tour;
        bestTime = time;
        bestVisitedCount = tour.length;
      }
    }

    _optimalTour = bestTour;
    _optimalTourTime = bestTime;

    logger.d("Optimal Tour: $_optimalTour");
    logger.d("Total Time: $_optimalTourTime minutes");

    notifyListeners();
  }

  Map<String, dynamic> _dpSolve(String startPlace, int timeLimit) {
    int n = _places.length;
    var dp = List.generate(n, (i) => List.generate(1 << n, (j) => 999999));
    var parent =
        List.generate(n, (i) => List.generate(1 << n, (j) => <String>[]));

    int startIdx = _places.indexOf(startPlace);
    int startMask = 1 << startIdx;
    dp[startIdx][startMask] = _visitTimes[startPlace]!;

    for (int mask = 1; mask < (1 << n); mask++) {
      for (int curr = 0; curr < n; curr++) {
        if (dp[curr][mask] == 999999) continue;
        for (int next = 0; next < n; next++) {
          if ((mask & (1 << next)) != 0) continue;
          int newMask = mask | (1 << next);
          int travelTime = _distances[_places[curr]]![_places[next]]!;
          int visitTime = _visitTimes[_places[next]]!;
          int newTime = dp[curr][mask] + travelTime + visitTime;

          if (newTime <= timeLimit && newTime < dp[next][newMask]) {
            dp[next][newMask] = newTime;
            parent[next]
                [newMask] = List.from(parent[curr][mask])..add(_places[curr]);
          }
        }
      }
    }

    int minTime = 999999;
    int lastPlace = -1;
    int finalMask = -1;
    int maxVisited = 0;

    for (int mask = 1; mask < (1 << n); mask++) {
      int visitedCount = _countBits(mask);
      for (int curr = 0; curr < n; curr++) {
        if (dp[curr][mask] != 999999 &&
            (visitedCount > maxVisited ||
                (visitedCount == maxVisited && dp[curr][mask] < minTime))) {
          minTime = dp[curr][mask];
          lastPlace = curr;
          finalMask = mask;
          maxVisited = visitedCount;
        }
      }
    }

    List<String> tour = [];
    if (lastPlace != -1) {
      tour = List.from(parent[lastPlace][finalMask])..add(_places[lastPlace]);
    }

    return {
      'tour': tour,
      'time': minTime != 999999 ? minTime : 0,
    };
  }

  int _countBits(int mask) {
    int count = 0;
    while (mask > 0) {
      count += mask & 1;
      mask >>= 1;
    }
    return count;
  }
}
