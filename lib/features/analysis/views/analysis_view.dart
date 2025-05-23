import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:ear_fe/database/database_helper.dart';
import 'package:ear_fe/features/main/views/main_screen.dart';

class AnalysisView extends StatefulWidget {
  final String symptomName; // 증상 이름
  final String analysisImageUrl; // AI 분석 이미지 URL

  const AnalysisView({
    Key? key,
    required this.symptomName,
    required this.analysisImageUrl,
  }) : super(key: key);

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  bool _isSaving = false; // 저장 중 상태 관리

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 사용자 정보 가져오기
      final lastUser = await DatabaseHelper.instance.getLastUser();
      if (lastUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사용자 정보가 없습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final userId = lastUser['id']; // 사용자 ID
      final currentDate = DateTime.now().toLocal().toIso8601String(); // 현재 날짜

      // 결과 데이터 저장
      await DatabaseHelper.instance.insertResult(
        userId: userId,
        symptomName: widget.symptomName,
        date: currentDate, // 로컬 시간 저장
        photo: widget.analysisImageUrl,
        memo: "", // 빈값으로 메모 저장
      );

      // 성공 메시지 및 화면 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결과가 성공적으로 저장되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );

        // 메인 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결과 저장 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 2),
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
            // 상단 바
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '저장하기',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // 분석 결과 이미지, 증상명, 날짜 컨테이너
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 분석 이미지
                            Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.analysisImageUrl,
                                  width: 224,
                                  height: 224,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 증상 이름과 날짜
                            Text(
                              '${widget.symptomName}에 좋은 혈자리입니다',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              dateFormat.format(analysisDate),
                              style: const TextStyle(
                                color: AppColors.accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // 추가 안내 문구
                      Text(
                        '해당 이혈 포인트에\n지압 패치를 붙이거나 혈자리를 자극해주세요',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
