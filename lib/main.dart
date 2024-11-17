import 'package:flutter/material.dart';
import 'package:ear_fe/app/app.dart';
import 'package:ear_fe/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱 최초 실행시에만 데이터베이스 리셋
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('first_run') ?? true;
  
  if (isFirstRun) {
    await DatabaseHelper.instance.resetDatabase();  // 데이터베이스 초기화 및 초기 데이터 삽입
    await prefs.setBool('first_run', false);  // 최초 실행 표시
  }
  
  runApp(const App());
}