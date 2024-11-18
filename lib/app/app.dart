// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/main/views/main_screen.dart';
import 'package:ear_fe/features/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ear Therapy',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        useMaterial3: true,
        fontFamily: 'SejongHospital',
      ),
      home: SplashScreen(),
    );
  }
}