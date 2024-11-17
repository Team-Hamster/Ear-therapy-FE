import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:ear_fe/database/database_helper.dart';

class AnalysisView extends StatefulWidget {
  final String symptomName;
  final File analysisImage;

  const AnalysisView({
    super.key,
    required this.symptomName,
    required this.analysisImage,
  });

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
      final resultId = await DatabaseHelper.instance.insertResult(
        symptomName: widget.symptomName,
        date: DateTime.now().toIso8601String(),
        memo: null,
        photo: null, // TODO: 분석 결과 이미지 경로로 대체
      );

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // 업로드 화면으로 돌아가기 위해 한 번 더 pop
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결과 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: 300, // 업로드 화면과 동일한 높이
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.symptomName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateFormat.format(analysisDate),
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!_isSaving)
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: TextButton(
                                  onPressed: _saveResult,
                                  child: const Text(
                                    '저장하기',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (_isSaving)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          color: Colors.grey,
                          height: 15,
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                widget.analysisImage,
                                fit: BoxFit.contain, // 사진 크기는 컨테이너에 맞추기
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // TODO: 분석 결과 텍스트 표시
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}