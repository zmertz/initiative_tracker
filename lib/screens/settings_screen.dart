import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;

  const SettingsScreen({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkTheme
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkTheme;

  @override
  void initState() {
    super.initState();
    isDarkTheme = AppTheme.isDarkMode(); // Fetches the correct theme on open
  }

  void _toggleTheme(bool val) {
    setState(() {
      isDarkTheme = val;
    });
    AppTheme.setDarkMode(val); // Saves the preference
    widget.onThemeChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: Text("Dark Theme"),
          value: isDarkTheme,
          onChanged: _toggleTheme,
        ),
      ),
    );
  }
}
