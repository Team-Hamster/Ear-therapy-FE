import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/upload/views/upload_view.dart';

class SymptomButton extends StatelessWidget {
  final String imagePath;
  final String label;

  const SymptomButton({
    super.key,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadView(symptomName: label),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              width: 55,
              height: 55,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
} 