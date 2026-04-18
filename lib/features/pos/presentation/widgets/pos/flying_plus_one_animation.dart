import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Flying Plus One Animation - Shows +1 animation when adding to cart
class FlyingPlusOneAnimation extends StatefulWidget {
  final Offset startPosition;
  final VoidCallback onAnimationComplete;

  const FlyingPlusOneAnimation({
    super.key,
    required this.startPosition,
    required this.onAnimationComplete,
  });

  @override
  State<FlyingPlusOneAnimation> createState() =>
      _FlyingPlusOneAnimationState();
}

class _FlyingPlusOneAnimationState extends State<FlyingPlusOneAnimation> {
  @override
  void initState() {
    super.initState();
    // Trigger animation complete after animation finishes (150+100+200=450)
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: Material(
        color: Colors.transparent,
        child:
            Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.successShadow(0.4),
                  ),
                  child: const Center(
                    child: Text(
                      '+1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1.2, 1.2),
                  duration: 150.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 100.ms,
                  curve: Curves.easeOut,
                )
                .then()
                .fadeOut(duration: 200.ms),
      ),
    );
  }
}
