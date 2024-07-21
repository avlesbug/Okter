import 'package:flutter/material.dart';

import 'utils/color_utils.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

class MyTheme {
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: hexStringtoColor("7C77B9"),
      appBarTheme: AppBarTheme(
        backgroundColor: hexStringtoColor("5d8076"),
      ));

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: hexStringtoColor("0bc9cd"),
      appBarTheme: AppBarTheme(
        backgroundColor: hexStringtoColor("5d8076"),
      ));
}
