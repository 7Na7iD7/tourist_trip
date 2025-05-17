import 'package:flutter/material.dart';

Color getPlaceColor(String place) {
  final colors = [
    const Color(0xFF5B8CFF),
    const Color(0xFF6FE7C8),
    const Color(0xFFFFA48E),
    const Color(0xFFAC6DDE),
    const Color(0xFFFFC107),
    const Color(0xFF4CAF50),
    const Color(0xFFFF5722),
    const Color(0xFF607D8B),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
  ];

  final index = place.hashCode % colors.length;
  return colors[index.abs()];
}

Color getVisitTimeColor(int time) {
  if (time <= 20) return const Color(0xFF6FE7C8);
  if (time <= 40) return const Color(0xFF5B8CFF);
  if (time <= 60) return const Color(0xFFFFA48E);
  return const Color(0xFFAC6DDE);
}

Color getDistanceColor(int distance) {
  if (distance <= 10) return const Color(0xFF6FE7C8);
  if (distance <= 20) return const Color(0xFF5B8CFF);
  if (distance <= 30) return const Color(0xFFFFA48E);
  return const Color(0xFFAC6DDE);
}
