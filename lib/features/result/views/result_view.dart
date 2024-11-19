import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/database/database_helper.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:io';

class ResultView extends StatefulWidget {
  final int resultId;

  const ResultView({Key? key, required this.resultId}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  late Map<String, dynamic> result;
  late String memo;
  bool isEditing = false; // 수정 모드 여부

  @override
  void initState() {
    super.initState();
    _loadResultData();
  }

  Future<void> _loadResultData() async {
    final data = await DatabaseHelper.instance.getResultDetail(widget.resultId);
    if (data != null) {
      setState(() {
        result = data;
        memo = result['memo'] ?? ''; // MEMO 초기화
      });
    }
  }

  Future<void> _saveMemo() async {
    await DatabaseHelper.instance.updateResultMemo(widget.resultId, memo); // MEMO 업데이트
    setState(() {
      isEditing = false; // 수정 모드 종료
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(result['date']);
    final formattedDate = DateFormat('yy.MM.dd EEE').format(date);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
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
                    'Result',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isEditing) // 수정 중일 때만 저장 버튼 표시
                    IconButton(
                      icon: const Icon(Icons.save, color: AppColors.primaryColor),
                      onPressed: _saveMemo,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  result['symptom_name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Divider(
                            color: Colors.grey,
                            height: 20,
                            thickness: 1,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: result['photo'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(result['photo']),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.photo,
                                      color: Colors.grey,
                                      size: 100,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MEMO',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: TextField(
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '메모를 입력하세요...',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () {
                                      // 수정 모드 활성화
                                      setState(() {
                                        isEditing = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        memo = value; // MEMO 업데이트
                                      });
                                    },
                                    controller: TextEditingController(text: memo), // 초기값 설정
                                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
