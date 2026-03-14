import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';
import '../theme/app_theme.dart';

/// Success animation overlay with circular confetti burst and checkmark
class SuccessAnimationOverlay extends StatefulWidget {
  final String? message;
  final VoidCallback? onDismiss;
  final Duration? duration;

  const SuccessAnimationOverlay({
    super.key,
    this.message,
    this.onDismiss,
    this.duration,
  });

  @override
  State<SuccessAnimationOverlay> createState() => _SuccessAnimationOverlayState();

  /// Show the success overlay as a full-screen overlay
  static void show(
    BuildContext context, {
    String? message,
    VoidCallback? onDismiss,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => SuccessAnimationOverlay(
        message: message,
        onDismiss: () {
          overlayEntry.remove();
          onDismiss?.call();
        },
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _SuccessAnimationOverlayState extends State<SuccessAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? const Duration(milliseconds: 2000);

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    // Scale animation for circle
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: AnimationCurves.emphasized),
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: AnimationCurves.easeOut),
    ));

    // Checkmark draw animation
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: AnimationCurves.easeOut),
    ));

    // Confetti burst animation
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: AnimationCurves.easeOut),
    ));

    _controller.forward();

    // Auto-dismiss after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onDismiss?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success circle with checkmark
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.successColor.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Confetti particles
                          if (_confettiAnimation.value > 0)
                            ..._buildConfetti(),
                          // Checkmark
                          _CheckmarkPainter(
                            progress: _checkmarkAnimation.value,
                          ),
                        ],
                      );
                    },
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final confettiCount = 12;
    final List<Widget> confetti = [];

    for (int i = 0; i < confettiCount; i++) {
      final angle = (i / confettiCount) * 2 * math.pi;
      final distance = 60 * _confettiAnimation.value;

      confetti.add(
        Positioned(
          left: 50 + math.cos(angle) * distance - 8,
          top: 50 + math.sin(angle) * distance - 8,
          child: Transform.rotate(
            angle: angle + _controller.value * math.pi * 2,
            child: Opacity(
              opacity: (1 - _confettiAnimation.value).clamp(0.0, 1.0),
              child: Container(
                width: 8,
                height: 16,
                decoration: BoxDecoration(
                  color: _getConfettiColor(i),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return confetti;
  }

  Color _getConfettiColor(int index) {
    final colors = [
      AppTheme.successColor,
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.warningColor,
    ];
    return colors[index % colors.length];
  }
}

/// Custom checkmark painter with stroke animation
class _CheckmarkPainter extends StatelessWidget {
  final double progress;

  const _CheckmarkPainter({required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: _CheckmarkPaint(progress: progress),
    );
  }
}

class _CheckmarkPaint extends CustomPainter {
  final double progress;

  _CheckmarkPaint({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Checkmark path: starts at left-bottom, goes to middle, then to right-top
    final startPoint = Offset(size.width * 0.25, size.height * 0.5);
    final middlePoint = Offset(size.width * 0.45, size.height * 0.7);
    final endPoint = Offset(size.width * 0.75, size.height * 0.3);

    // Total length approximation for animation
    final totalLength = 100.0;
    final drawLength = totalLength * progress;

    if (drawLength > 0) {
      // First segment: start to middle (40% of total)
      final firstSegmentLength = 40.0;
      if (drawLength <= firstSegmentLength) {
        final t = drawLength / firstSegmentLength;
        final currentPoint = Offset(
          startPoint.dx + (middlePoint.dx - startPoint.dx) * t,
          startPoint.dy + (middlePoint.dy - startPoint.dy) * t,
        );
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(middlePoint.dx, middlePoint.dy);

        // Second segment: middle to end (60% of total)
        final secondSegmentLength = 60.0;
        final remainingLength = drawLength - firstSegmentLength;
        final t = (remainingLength / secondSegmentLength).clamp(0.0, 1.0);
        final currentPoint = Offset(
          middlePoint.dx + (endPoint.dx - middlePoint.dx) * t,
          middlePoint.dy + (endPoint.dy - middlePoint.dy) * t,
        );
        path.lineTo(currentPoint.dx, currentPoint.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Compact success indicator for inline use (not full overlay)
class CompactSuccessIndicator extends StatefulWidget {
  final double size;
  final Duration? duration;

  const CompactSuccessIndicator({
    super.key,
    this.size = 40,
    this.duration,
  });

  @override
  State<CompactSuccessIndicator> createState() => _CompactSuccessIndicatorState();
}

class _CompactSuccessIndicatorState extends State<CompactSuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? AnimationDurations.normal;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.emphasized,
    ));

    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: AnimationCurves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.size * 0.2),
                child: CustomPaint(
                  painter: _CheckmarkPaint(progress: _checkmarkAnimation.value),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
