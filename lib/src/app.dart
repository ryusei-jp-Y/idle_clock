import 'package:flutter/material.dart';

import 'home/idle_clock_screen.dart';

class IdleClockApp extends StatelessWidget {
  const IdleClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8C7BFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const IdleClockScreen(),
    );
  }
}
