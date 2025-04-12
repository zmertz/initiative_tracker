import 'package:flutter/material.dart';
import 'dart:async';
import 'initiative_tracker_screen.dart';
import 'character_template_screen.dart';
import '../widgets/my_app_bar.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;

  const HomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkTheme,
  }) : super(key: key);

  // Custom page transition for InitiativeTrackerScreen
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
          begin: Offset(1.0, 0.0), // Slide in from the right
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

// Custom page transition for CharacterTemplateScreen
  Route _createTemplateRoute() {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) =>
        CharacterTemplateScreen(
          onThemeChanged: onThemeChanged,
          isDarkTheme: isDarkTheme,
        ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: Offset(1.0, 0.0), // Slide in from the right
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


  // Background image
  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        //'assets/images/castle_background.png',
        //'assets/images/dragon-castle-simple.jpg',
        'assets/images/dragon-castle.jpg',
        //'assets/images/dragon-castle-realistic.jpg',
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width, // Adjust width based on screen size
        height: MediaQuery.of(context).size.height,
      ),
    );
  }

  // Title at the top of the screen
  Widget _buildTitle() {
    return Positioned(
      top: 40, // Adjust as needed
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "D&D Pal",
          style: TextStyle(
            fontFamily: 'AlmendraSC',
            fontSize: 48,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the tracker button with animation
  Widget _buildTrackerButtonWithGlint(BuildContext context) {
    return _GlintButton(
      onPressed: () {
        Navigator.push(context, _createTrackerRoute());
      },
      label: "Initiative Tracker"
    );
  }

  Widget _buildCharacterTemplateButton(BuildContext context) {
    return _GlintButton(
      onPressed: () {
        Navigator.push(context, _createTemplateRoute());
      },
      label: "Character Templates",
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
      body: Stack(
        children: [
          _buildBackground(context),
          _buildTitle(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.8, // 80% of the screen width
                  child: _buildTrackerButtonWithGlint(context),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: _buildCharacterTemplateButton(context),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ==========================
// 🏆 Glint Effect Button 🏆
// ==========================
class _GlintButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const _GlintButton({Key? key, required this.onPressed, required this.label}) : super(key: key);

  @override
  _GlintButtonState createState() => _GlintButtonState();
}

class _GlintButtonState extends State<_GlintButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1200), // Smooth animation
      vsync: this,
    );

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startRandomGlintLoop();
  }

  void _startRandomGlintLoop() {
    // Wait a random time before starting the first glint (0-5 seconds)
    Future.delayed(Duration(milliseconds: _random.nextInt(5000)), () {
      _triggerGlint();

      // Then start a periodic timer with slight randomness (e.g. every 6–10 sec)
      _timer = Timer.periodic(
        Duration(seconds: 6 + _random.nextInt(5)),
        (_) => _triggerGlint(),
      );
    });
  }

  void _triggerGlint() {
    if (mounted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.infinity),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(48), // Ensures consistent height
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AlmendraSC',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: [
                          _animation.value - 0.3,
                          _animation.value,
                          _animation.value + 0.3,
                        ],
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


