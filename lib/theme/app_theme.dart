import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const String themeKey = 'isDarkTheme';

  static ThemeData darkTheme(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return ThemeData.dark().copyWith(
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[900],
      colorScheme: ThemeData.dark().colorScheme.copyWith(
            secondary: Colors.deepPurpleAccent,
          ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ).copyWith(
        bodyLarge: GoogleFonts.roboto(fontSize: 16 * scaleFactor),
        bodyMedium: GoogleFonts.roboto(fontSize: 14 * scaleFactor),
        bodySmall: GoogleFonts.roboto(fontSize: 12 * scaleFactor),
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.grey[200],
      colorScheme: ThemeData.light().colorScheme.copyWith(
            secondary: Colors.blueAccent,
          ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ).copyWith(
        bodyLarge: GoogleFonts.roboto(fontSize: 16 * scaleFactor),
        bodyMedium: GoogleFonts.roboto(fontSize: 14 * scaleFactor),
        bodySmall: GoogleFonts.roboto(fontSize: 12 * scaleFactor),
      ),
    );
  }

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
