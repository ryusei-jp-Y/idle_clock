import 'dart:ui';

class BounceState {
  const BounceState({required this.position, required this.velocity});

  final Offset position;
  final Offset velocity;
}

BounceState advanceBounce({
  required BounceState state,
  required double elapsedSeconds,
  required Size areaSize,
  required Size objectSize,
}) {
  final maxX = (areaSize.width - objectSize.width).clamp(0.0, double.infinity);
  final maxY = (areaSize.height - objectSize.height).clamp(
    0.0,
    double.infinity,
  );
  final x = _advanceAxis(
    position: state.position.dx.clamp(0.0, maxX),
    velocity: state.velocity.dx,
    elapsedSeconds: elapsedSeconds,
    maximum: maxX,
  );
  final y = _advanceAxis(
    position: state.position.dy.clamp(0.0, maxY),
    velocity: state.velocity.dy,
    elapsedSeconds: elapsedSeconds,
    maximum: maxY,
  );

  return BounceState(
    position: Offset(x.position, y.position),
    velocity: Offset(x.velocity, y.velocity),
  );
}

_AxisState _advanceAxis({
  required double position,
  required double velocity,
  required double elapsedSeconds,
  required double maximum,
}) {
  if (maximum == 0) {
    return const _AxisState(position: 0, velocity: 0);
  }

  var nextPosition = position + velocity * elapsedSeconds;
  var nextVelocity = velocity;

  while (nextPosition < 0 || nextPosition > maximum) {
    if (nextPosition < 0) {
      nextPosition = -nextPosition;
      nextVelocity = nextVelocity.abs();
    } else {
      nextPosition = maximum - (nextPosition - maximum);
      nextVelocity = -nextVelocity.abs();
    }
  }

  return _AxisState(position: nextPosition, velocity: nextVelocity);
}

class _AxisState {
  const _AxisState({required this.position, required this.velocity});

  final double position;
  final double velocity;
}
