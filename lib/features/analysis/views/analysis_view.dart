import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:ear_fe/database/database_helper.dart';

class AnalysisView extends StatefulWidget {
  final String symptomName;
  final File analysisImage;

  const AnalysisView({
    Key? key,
    required this.symptomName,
    required this.analysisImage,
  }) : super(key: key);

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  bool _isSaving = false;

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await DatabaseHelper.instance.insertResult(
        symptomName: widget.symptomName,
        date: DateTime.now().toIso8601String(),
        memo: null,
        photo: widget.analysisImage.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결과가 성공적으로 저장되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결과 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
@override
Widget build(BuildContext context) {
  final analysisDate = DateTime.now();
  final dateFormat = DateFormat('yy.MM.dd EEE');

  return Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: AppColors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '분석결과',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 450, // 명시적으로 높이 지정
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 16),
                        _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: _saveResult,
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor, // 버튼 배경색
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 버튼 안쪽 여백
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white, // 텍스트 색상
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 224,
                            height: 224,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                widget.analysisImage,
                                width: 224,
                                height: 224,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            widget.symptomName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dateFormat.format(analysisDate),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center( // 텍스트를 컨테이너의 중앙에 정렬
              child: Text(
                '해당 이혈 포인트에\n지압 패치를 붙이거나 혈자리를 자극해주세요',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center, // 텍스트 자체 중앙 정렬
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}