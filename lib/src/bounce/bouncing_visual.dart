import 'package:flutter/material.dart';

import 'bounce_motion.dart';

class BouncingVisual extends StatefulWidget {
  const BouncingVisual({super.key});

  @override
  State<BouncingVisual> createState() => _BouncingVisualState();
}

class _BouncingVisualState extends State<BouncingVisual>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _visualSize = Size(104, 64);
  static const _initialVelocity = Offset(118, 92);

  late final AnimationController _controller;
  BounceState _motion = const BounceState(
    position: Offset(24, 36),
    velocity: _initialVelocity,
  );
  Duration? _lastElapsed;
  Size _areaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_advance)
          ..repeat();
  }

  void _advance() {
    final elapsed = _controller.lastElapsedDuration;
    if (elapsed == null || _areaSize.isEmpty) {
      return;
    }

    final previous = _lastElapsed;
    _lastElapsed = elapsed;
    if (previous == null) {
      return;
    }

    final seconds = (elapsed - previous).inMicroseconds / 1000000;
    _motion = advanceBounce(
      state: _motion,
      elapsedSeconds: seconds.clamp(0, 0.05),
      areaSize: _areaSize,
      objectSize: _visualSize,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastElapsed = null;
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _areaSize = constraints.biggest;
        _motion = advanceBounce(
          state: _motion,
          elapsedSeconds: 0,
          areaSize: _areaSize,
          objectSize: _visualSize,
        );

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                key: const ValueKey('bouncing-visual'),
                painter: _VisualPainter(
                  position: _motion.position,
                  visualSize: _visualSize,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        );
      },
    );
  }
}

class _VisualPainter extends CustomPainter {
  const _VisualPainter({required this.position, required this.visualSize});

  final Offset position;
  final Size visualSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = position & visualSize;
    final shape = Path()
      ..moveTo(rect.left + rect.width * 0.18, rect.top)
      ..lineTo(rect.right - rect.width * 0.12, rect.top)
      ..quadraticBezierTo(
        rect.right,
        rect.top,
        rect.right,
        rect.top + rect.height * 0.25,
      )
      ..lineTo(rect.right - rect.width * 0.18, rect.bottom)
      ..lineTo(rect.left + rect.width * 0.12, rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.bottom - rect.height * 0.25,
      )
      ..close();

    final glowPaint = Paint()
      ..color = const Color(0x668C7BFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFA997FF), Color(0xFF5DE1E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawPath(shape, glowPaint);
    canvas.drawPath(shape, fillPaint);

    final inset = rect.deflate(10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(12)),
      Paint()..color = const Color(0x33090A0F),
    );
  }

  @override
  bool shouldRepaint(_VisualPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
