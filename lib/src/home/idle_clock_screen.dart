import 'package:flutter/material.dart';

import '../bounce/bouncing_visual.dart';
import '../clock/clock_view.dart';

class IdleClockScreen extends StatelessWidget {
  const IdleClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            BouncingVisual(),
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: FittedBox(fit: BoxFit.scaleDown, child: ClockView()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
