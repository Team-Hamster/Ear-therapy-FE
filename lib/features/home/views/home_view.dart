import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/home/views/widgets/symptom_button.dart';
import 'package:ear_fe/shared/widgets/bottom_navigation.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final symptoms = [
      {'name': '감기', 'image': 'assets/icon_images/cold.png'},
      {'name': '스트레스', 'image': 'assets/icon_images/stress.png'},
      {'name': '열', 'image': 'assets/icon_images/fever.png'},
      {'name': '어지럼증', 'image': 'assets/icon_images/dizzy.png'},
      {'name': '두통', 'image': 'assets/icon_images/headache.png'},
      {'name': '집중력', 'image': 'assets/icon_images/focus.png'},
      {'name': '코피', 'image': 'assets/icon_images/nosebleed.png'},
      {'name': '생리통', 'image': 'assets/icon_images/period.png'},
      {'name': '빈뇨', 'image': 'assets/icon_images/urine.png'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.white,
              child: const Text(
                'Ear Therapy',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 32, bottom: 16),
              child: Text(
                '증상 선택',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: symptoms.length,
                itemBuilder: (context, index) {
                  return SymptomButton(
                    imagePath: symptoms[index]['image'] as String,
                    label: symptoms[index]['name'] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
} 