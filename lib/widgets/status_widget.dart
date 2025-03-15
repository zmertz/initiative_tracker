// lib/widgets/shake_widget.dart
import 'package:flutter/material.dart';

class StatusWidget extends StatefulWidget {
  final Widget child;

  const StatusWidget({Key? key, required this.child}) : super(key: key);

  @override
  StatusWidgetState createState() => StatusWidgetState();
}

class StatusWidgetState extends State<StatusWidget> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _offsetAnimation;
  late AnimationController _glowController;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: Duration(milliseconds: 600), // Longer for a smooth glow
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _glowAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.greenAccent.withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  void shake() {
    _shakeController.forward(from: 0.0);
  }

  void glow() {
    _glowController.forward(from: 0.0).then((_) => _glowController.reverse()); // Glow effect
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_offsetAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: Container(
            color: _glowAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
