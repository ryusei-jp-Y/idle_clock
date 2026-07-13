import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:idle_clock/src/bounce/bounce_motion.dart';

void main() {
  const areaSize = Size(300, 200);
  const objectSize = Size(100, 50);

  test('moves without changing direction before a collision', () {
    final result = advanceBounce(
      state: const BounceState(
        position: Offset(20, 30),
        velocity: Offset(100, 50),
      ),
      elapsedSeconds: 0.5,
      areaSize: areaSize,
      objectSize: objectSize,
    );

    expect(result.position, const Offset(70, 55));
    expect(result.velocity, const Offset(100, 50));
  });

  test('reflects at the right and bottom edges', () {
    final result = advanceBounce(
      state: const BounceState(
        position: Offset(190, 145),
        velocity: Offset(100, 50),
      ),
      elapsedSeconds: 0.2,
      areaSize: areaSize,
      objectSize: objectSize,
    );

    expect(result.position, const Offset(190, 145));
    expect(result.velocity, const Offset(-100, -50));
  });

  test('allows a small boundary outset before reflecting', () {
    final result = advanceBounce(
      state: const BounceState(
        position: Offset(202, 30),
        velocity: Offset(100, 0),
      ),
      elapsedSeconds: 0.08,
      areaSize: areaSize,
      objectSize: objectSize,
      boundaryOutset: 6,
    );

    expect(result.position, const Offset(202, 30));
    expect(result.velocity, const Offset(-100, 0));
  });

  test('clamps the visual inside a resized area', () {
    final result = advanceBounce(
      state: const BounceState(
        position: Offset(180, 120),
        velocity: Offset(100, 50),
      ),
      elapsedSeconds: 0,
      areaSize: const Size(160, 100),
      objectSize: objectSize,
    );

    expect(result.position, const Offset(60, 50));
  });
}
