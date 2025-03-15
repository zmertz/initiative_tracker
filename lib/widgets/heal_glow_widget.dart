import 'package:flutter/material.dart';

class HealGlowWidget extends StatefulWidget {
  final Widget child;

  const HealGlowWidget({Key? key, required this.child}) : super(key: key);

  @override
  HealGlowWidgetState createState() => HealGlowWidgetState();
}

class HealGlowWidgetState extends State<HealGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: Duration(milliseconds: 600), // Longer for a smooth glow
      vsync: this,
    );

    _glowAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.greenAccent.withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  void glow() {
    _glowController.forward(from: 0.0).then((_) => _glowController.reverse()); // Fade out after glowing
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: _glowAnimation.value ?? Colors.transparent,
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
