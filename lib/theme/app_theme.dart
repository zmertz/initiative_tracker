import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppTheme {
  static const String themeKey = 'isDarkTheme';

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          secondary: Colors.deepPurpleAccent,
        ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey[200],
    colorScheme: ThemeData.light().colorScheme.copyWith(
          secondary: Colors.blueAccent,
        ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
  );

  /// Retrieves the stored theme preference from Hive
  static bool isDarkMode() {
    var box = Hive.box('settings');
    return box.get(themeKey, defaultValue: false);
  }

  /// Saves the theme preference to Hive
  static void setDarkMode(bool isDark) {
    var box = Hive.box('settings');
    box.put(themeKey, isDark);
  }
}
