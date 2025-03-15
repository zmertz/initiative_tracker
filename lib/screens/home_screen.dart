import 'package:flutter/material.dart';
import 'dart:async';
import 'initiative_tracker_screen.dart';
import '../widgets/my_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Background image
  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/castle_background.png',
        fit: BoxFit.cover,
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
          style: GoogleFonts.almendraSc(
            textStyle: TextStyle(
              fontSize: 48,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black54,
                  offset: Offset(2.0, 2.0),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  // Builds the tracker button with animation
  Widget _buildTrackerButtonWithGlint(BuildContext context) {
    return _GlintButton(onPressed: () {
      Navigator.push(context, _createTrackerRoute());
    });
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
          _buildBackground(),
          _buildTitle(),
          Center(child: _buildTrackerButtonWithGlint(context)),
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
  const _GlintButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  _GlintButtonState createState() => _GlintButtonState();
}

class _GlintButtonState extends State<_GlintButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

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

    // Trigger glint effect every 8 seconds
    _timer = Timer.periodic(Duration(seconds: 8), (timer) {
      _controller.forward(from: 0);
    });
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
      onTap: widget.onPressed, // Ensure tap is handled
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Button with border and theme styling
          ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary, // Border
                  width: 2,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              "Initiative Tracker",
              style: GoogleFonts.almendraSc(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Diagonal Glint Effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomLeft,  // Starts from bottom-left
                      end: Alignment.topRight,    // Moves to top-right
                      stops: [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9), // Stronger highlight
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
                  color: Colors.white.withOpacity(0.15), // Subtle glow effect
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


