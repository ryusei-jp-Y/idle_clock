import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import '../audio/collision_sound_player.dart';
import '../theme/app_theme.dart';
import 'bounce_motion.dart';

class BouncingVisual extends StatefulWidget {
  const BouncingVisual({
    super.key,
    required this.objectCount,
    this.soundPlayer,
  });

  final int objectCount;
  final CollisionSoundPlayer? soundPlayer;

  @override
  State<BouncingVisual> createState() => _BouncingVisualState();
}

class _BouncingVisualState extends State<BouncingVisual>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _objectSize = Size.square(72);
  static const _objectRadius = 36.0;
  static const _wallCollisionOutset = 6.0;
  static const _rippleDurationSeconds = 1.2;
  static const _colorShiftDurationSeconds = 0.9;
  static const _maximumRipples = 18;

  late final Ticker _ticker;
  late final CollisionSoundPlayer _soundPlayer;
  late final bool _ownsSoundPlayer;
  final List<_MovingObject> _objects = [];
  final List<_Ripple> _ripples = [];
  final ValueNotifier<int> _repaintTick = ValueNotifier(0);
  Duration _elapsed = Duration.zero;
  Duration? _previousTick;
  Size _areaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsSoundPlayer = widget.soundPlayer == null;
    _soundPlayer = widget.soundPlayer ?? CollisionSoundPlayer();
    _ensureObjectCount(widget.objectCount);
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didUpdateWidget(BouncingVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.objectCount != oldWidget.objectCount) {
      _ensureObjectCount(widget.objectCount);
    }
  }

  void _ensureObjectCount(int objectCount) {
    while (_objects.length < objectCount) {
      _objects.add(_createObject(_objects.length));
    }
    if (_objects.length > objectCount) {
      _objects.removeRange(objectCount, _objects.length);
    }
  }

  _MovingObject _createObject(int index) {
    const positions = [
      Offset(24, 36),
      Offset(220, 84),
      Offset(96, 210),
      Offset(360, 180),
      Offset(520, 72),
    ];
    const velocities = [
      Offset(76, 58),
      Offset(-64, 72),
      Offset(82, -54),
      Offset(-72, -62),
      Offset(58, 82),
    ];

    final hue = (index * 68 + 210) % 360;
    return _MovingObject(
      motion: BounceState(
        position: positions[index % positions.length],
        velocity: velocities[index % velocities.length],
      ),
      previousHue: hue.toDouble(),
      hue: hue.toDouble(),
      colorChangedAtSeconds: -_colorShiftDurationSeconds,
    );
  }

  void _tick(Duration elapsed) {
    if (_areaSize.isEmpty) {
      _previousTick = elapsed;
      return;
    }

    final previous = _previousTick;
    _previousTick = elapsed;
    if (previous == null) {
      return;
    }

    final seconds = (elapsed - previous).inMicroseconds / 1000000;
    final clampedSeconds = seconds.clamp(0, 0.05).toDouble();
    _elapsed += Duration(
      microseconds: (clampedSeconds * Duration.microsecondsPerSecond).round(),
    );
    final elapsedSeconds = _elapsed.inMicroseconds / 1000000;

    for (final object in _objects) {
      final previousMotion = object.motion;
      final nextMotion = advanceBounce(
        state: object.motion,
        elapsedSeconds: clampedSeconds,
        areaSize: _areaSize,
        objectSize: _objectSize,
        boundaryOutset: _wallCollisionOutset,
      );
      object.motion = nextMotion;
      _addWallRipplesForCollision(
        object: object,
        previousMotion: previousMotion,
        nextMotion: nextMotion,
        elapsedSeconds: elapsedSeconds,
      );
    }

    _resolveObjectCollisions(elapsedSeconds);
    _ripples.removeWhere((ripple) {
      return elapsedSeconds - ripple.startedAtSeconds > _rippleDurationSeconds;
    });
    _repaintTick.value += 1;
  }

  void _addWallRipplesForCollision({
    required _MovingObject object,
    required BounceState previousMotion,
    required BounceState nextMotion,
    required double elapsedSeconds,
  }) {
    final hitVerticalEdge = _changedDirection(
      previousMotion.velocity.dx,
      nextMotion.velocity.dx,
    );
    final hitHorizontalEdge = _changedDirection(
      previousMotion.velocity.dy,
      nextMotion.velocity.dy,
    );

    if (!hitVerticalEdge && !hitHorizontalEdge) {
      return;
    }

    object.shiftColor(elapsedSeconds);
    _soundPlayer.playRandom(elapsedSeconds);
    final center =
        nextMotion.position + const Offset(_objectRadius, _objectRadius);
    final edgeX = previousMotion.velocity.dx > 0 ? _areaSize.width : 0.0;
    final edgeY = previousMotion.velocity.dy > 0 ? _areaSize.height : 0.0;

    if (hitVerticalEdge && hitHorizontalEdge) {
      _addRipple(Offset(edgeX, edgeY), elapsedSeconds);
      return;
    }

    if (hitVerticalEdge) {
      _addRipple(Offset(edgeX, center.dy), elapsedSeconds);
    }
    if (hitHorizontalEdge) {
      _addRipple(Offset(center.dx, edgeY), elapsedSeconds);
    }
  }

  void _resolveObjectCollisions(double elapsedSeconds) {
    for (var a = 0; a < _objects.length; a += 1) {
      for (var b = a + 1; b < _objects.length; b += 1) {
        _resolvePairCollision(_objects[a], _objects[b], elapsedSeconds);
      }
    }
  }

  void _resolvePairCollision(
    _MovingObject first,
    _MovingObject second,
    double elapsedSeconds,
  ) {
    final firstCenter = first.center;
    final secondCenter = second.center;
    final delta = secondCenter - firstCenter;
    final distance = delta.distance;
    final minimumDistance = _objectRadius * 2;

    if (distance == 0 || distance >= minimumDistance) {
      return;
    }

    final normal = delta / distance;
    final relativeVelocity = second.motion.velocity - first.motion.velocity;
    if (_dot(relativeVelocity, normal) >= 0) {
      _separateObjects(first, second, normal, minimumDistance - distance);
      return;
    }

    final firstNormalVelocity = _dot(first.motion.velocity, normal);
    final secondNormalVelocity = _dot(second.motion.velocity, normal);
    final firstTangentVelocity =
        first.motion.velocity - normal * firstNormalVelocity;
    final secondTangentVelocity =
        second.motion.velocity - normal * secondNormalVelocity;

    first.motion = BounceState(
      position: first.motion.position,
      velocity: firstTangentVelocity + normal * secondNormalVelocity,
    );
    second.motion = BounceState(
      position: second.motion.position,
      velocity: secondTangentVelocity + normal * firstNormalVelocity,
    );
    _separateObjects(first, second, normal, minimumDistance - distance);

    final collisionPoint = Offset.lerp(firstCenter, secondCenter, 0.5)!;
    first.shiftColor(elapsedSeconds);
    second.shiftColor(elapsedSeconds);
    _soundPlayer.playRandom(elapsedSeconds);
    _addRipple(collisionPoint, elapsedSeconds);
  }

  void _separateObjects(
    _MovingObject first,
    _MovingObject second,
    Offset normal,
    double overlap,
  ) {
    final offset = normal * (overlap / 2 + 0.1);
    first.motion = BounceState(
      position: _clampPosition(first.motion.position - offset),
      velocity: first.motion.velocity,
    );
    second.motion = BounceState(
      position: _clampPosition(second.motion.position + offset),
      velocity: second.motion.velocity,
    );
  }

  Offset _clampPosition(Offset position) {
    const min = -_wallCollisionOutset;
    final maxX = (_areaSize.width - _objectSize.width + _wallCollisionOutset)
        .clamp(0.0, double.infinity);
    final maxY = (_areaSize.height - _objectSize.height + _wallCollisionOutset)
        .clamp(0.0, double.infinity);

    return Offset(position.dx.clamp(min, maxX), position.dy.clamp(min, maxY));
  }

  double _dot(Offset a, Offset b) {
    return a.dx * b.dx + a.dy * b.dy;
  }

  bool _changedDirection(double previousVelocity, double nextVelocity) {
    return previousVelocity != 0 &&
        nextVelocity != 0 &&
        previousVelocity.sign != nextVelocity.sign;
  }

  void _addRipple(Offset origin, double elapsedSeconds) {
    _ripples.add(_Ripple(origin: origin, startedAtSeconds: elapsedSeconds));
    if (_ripples.length > _maximumRipples) {
      _ripples.removeRange(0, _ripples.length - _maximumRipples);
    }
  }

  void _resetVisualState({required bool resetObjects}) {
    _elapsed = Duration.zero;
    _previousTick = null;
    _ripples.clear();
    if (resetObjects) {
      _objects.clear();
      _ensureObjectCount(widget.objectCount);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resetVisualState(resetObjects: true);
        unawaited(_soundPlayer.stop());
        _ticker.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _ticker.stop();
        _resetVisualState(resetObjects: false);
        unawaited(_soundPlayer.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaintTick.dispose();
    if (_ownsSoundPlayer) {
      unawaited(_soundPlayer.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _areaSize = constraints.biggest;
        for (final object in _objects) {
          object.motion = advanceBounce(
            state: object.motion,
            elapsedSeconds: 0,
            areaSize: _areaSize,
            objectSize: _objectSize,
            boundaryOutset: _wallCollisionOutset,
          );
        }

        return RepaintBoundary(
          child: CustomPaint(
            key: const ValueKey('bouncing-visual'),
            painter: _VisualPainter(
              repaint: _repaintTick,
              visualTheme: clockVisualThemeOf(context),
              objects: _objects,
              ripples: _ripples,
              elapsedSeconds: _elapsed.inMicroseconds / 1000000,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _VisualPainter extends CustomPainter {
  const _VisualPainter({
    required super.repaint,
    required this.visualTheme,
    required this.objects,
    required this.ripples,
    required this.elapsedSeconds,
  });

  final ClockVisualTheme visualTheme;
  final List<_MovingObject> objects;
  final List<_Ripple> ripples;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRipples(canvas);
    for (final object in objects) {
      _paintObject(canvas, object);
    }
  }

  void _paintObject(Canvas canvas, _MovingObject object) {
    final center = object.center;
    final color = object.colorAt(elapsedSeconds, visualTheme);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: visualTheme.objectGlowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(
      center,
      _BouncingVisualState._objectRadius * 0.76,
      glowPaint,
    );

    final fillPaint = Paint()
      ..color = color.withValues(alpha: visualTheme.objectAlpha);
    canvas.drawCircle(
      center,
      _BouncingVisualState._objectRadius * 0.42,
      fillPaint,
    );

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color.withValues(alpha: visualTheme.objectOutlineAlpha);
    canvas.drawCircle(
      center,
      _BouncingVisualState._objectRadius * 0.78,
      outlinePaint,
    );
  }

  void _paintRipples(Canvas canvas) {
    const durationSeconds = _BouncingVisualState._rippleDurationSeconds;

    for (final ripple in ripples) {
      final progress =
          ((elapsedSeconds - ripple.startedAtSeconds) / durationSeconds).clamp(
            0.0,
            1.0,
          );
      final easedProgress = Curves.easeOutCubic.transform(progress);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final radius = 10 + easedProgress * 80;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = visualTheme.rippleColor.withValues(alpha: opacity * 0.32);

      canvas.drawCircle(ripple.origin, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_VisualPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds ||
        oldDelegate.objects.length != objects.length ||
        oldDelegate.ripples.length != ripples.length ||
        oldDelegate.visualTheme != visualTheme;
  }
}

class _MovingObject {
  _MovingObject({
    required this.motion,
    required this.previousHue,
    required this.hue,
    required this.colorChangedAtSeconds,
  });

  BounceState motion;
  double previousHue;
  double hue;
  double colorChangedAtSeconds;

  Offset get center {
    return motion.position +
        const Offset(
          _BouncingVisualState._objectRadius,
          _BouncingVisualState._objectRadius,
        );
  }

  void shiftColor(double elapsedSeconds) {
    previousHue = hue;
    hue = (hue + 74 + math.Random(hue.round()).nextInt(32)) % 360;
    colorChangedAtSeconds = elapsedSeconds;
  }

  Color colorAt(double elapsedSeconds, ClockVisualTheme visualTheme) {
    final progress =
        ((elapsedSeconds - colorChangedAtSeconds) /
                _BouncingVisualState._colorShiftDurationSeconds)
            .clamp(0.0, 1.0);
    final easedProgress = Curves.easeOutCubic.transform(progress);
    final startColor = HSVColor.fromAHSV(
      1,
      previousHue,
      visualTheme.objectSaturation,
      visualTheme.objectValue,
    ).toColor();
    final endColor = HSVColor.fromAHSV(
      1,
      hue,
      visualTheme.objectSaturation,
      visualTheme.objectValue,
    ).toColor();

    return Color.lerp(startColor, endColor, easedProgress)!;
  }
}

class _Ripple {
  const _Ripple({required this.origin, required this.startedAtSeconds});

  final Offset origin;
  final double startedAtSeconds;
}
