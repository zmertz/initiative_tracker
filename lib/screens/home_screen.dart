import 'package:flutter/material.dart';
import 'initiative_tracker_screen.dart';
import '../widgets/my_app_bar.dart';

class HomeScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;

  const HomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkTheme,
  }) : super(key: key);

  Route _createTrackerRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          InitiativeTrackerScreen(
            onThemeChanged: onThemeChanged,
            isDarkTheme: isDarkTheme,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: Offset(1.0, 0.0), // Slide in from right.
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

  Widget _buildTrackerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, _createTrackerRoute());
      },
      child: Text('Initiative Tracker'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Home',
        onThemeChanged: onThemeChanged,
        isDarkTheme: isDarkTheme,
      ),
      body: Center(
        child: _buildTrackerButton(context),
      ),
    );
  }
}
