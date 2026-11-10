// TODO Implement this library.
import 'package:flutter/material.dart';

Color primaryAppColor = const Color(0xFFEAE6E0);
// Color primaryAppColor = const Color(0xFF806640);
Color primaryPurpleLite = const Color(0xff8E7BFF);
Color primaryPurpleMedium = const Color(0xff6A5CFF);
Color primaryPurpleDark = const Color(0xFF121E51);
Color primaryButtonColor = const Color(0xFF306149);
Color primaryRedButtonColor = const Color(0xFFC1333E);


class AppColors {
  static const List<Color> colors = [
    Color(0xFFE57373), // Red
    Color(0xFF64B5F6), // Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFF06292), // Pink
  ];

  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}