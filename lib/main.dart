// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/character.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CharacterAdapter());
  await Hive.openBox<Character>('characters');
  await Hive.openBox('settings'); // For storing user settings like theme

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<ThemeData> themeNotifier;
  final settingsBox = Hive.box('settings');
  bool _isDark = false; // local state for theme

  @override
  void initState() {
    super.initState();
    // Default to light theme (false) if no setting exists.
    _isDark = settingsBox.get('isDarkTheme', defaultValue: false);
    themeNotifier =
        ValueNotifier(_isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void updateTheme(bool isDark) {
    setState(() {
      _isDark = isDark;
      settingsBox.put('isDarkTheme', isDark);
      themeNotifier.value = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'DnD Initiative Tracker',
          theme: currentTheme,
          home: HomeScreen(
            onThemeChanged: updateTheme,
            isDarkTheme: _isDark,
          ),
        );
      },
    );
  }
}
