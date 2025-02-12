// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/initiative_tracker_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark();
    return MaterialApp(
      title: 'DnD Initiative Tracker',
      theme: darkTheme.copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        colorScheme: darkTheme.colorScheme.copyWith(
          secondary: AppColors.secondary,
        ),
        textTheme: darkTheme.textTheme.apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitiativeTrackerScreen(),
    );
  }
}
