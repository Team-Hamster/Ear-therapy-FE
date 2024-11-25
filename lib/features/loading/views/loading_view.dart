import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ear_fe/core/constants/colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Center( // 전체 중앙 정렬
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용만 차지하도록 설정
          mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
          children: [
            Lottie.asset(
              'assets/animations/animation.json', // 로티 파일 경로
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30), // 애니메이션과 텍스트 사이 간격
            const Text(
              '혈자리 분석 중 입니다...',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black54
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
