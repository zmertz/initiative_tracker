import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(bool)? onThemeChanged;
  final bool? isDarkTheme;

  const MyAppBar({
    Key? key,
    required this.title,
    this.onThemeChanged,
    this.isDarkTheme,
  }) : super(key: key);

  Route _createSettingsRoute(BuildContext context) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(
        onThemeChanged: onThemeChanged ?? (bool val) {},
        isDarkTheme: AppTheme.isDarkMode(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: Offset(0.0, 1.0), // Slide in from bottom.
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSettingsIcon(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Navigator.push(context, _createSettingsRoute(context));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [_buildSettingsIcon(context)],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
