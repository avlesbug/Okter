import 'package:flutter/material.dart';
import 'package:okter/utils/color_pallet.dart';

import 'utils/color_utils.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

class MyTheme {
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: themeColorPallet['grey dark'],
      scaffoldBackgroundColor: themeColorPallet['grey dark'],
      appBarTheme: AppBarTheme(
        backgroundColor: themeColorPallet['grey dark'],
      ));

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: themeColorPallet['grey dark'],
      scaffoldBackgroundColor: themeColorPallet['grey dark'],
      appBarTheme: AppBarTheme(
        backgroundColor: themeColorPallet['grey dark'],
      ));
}
