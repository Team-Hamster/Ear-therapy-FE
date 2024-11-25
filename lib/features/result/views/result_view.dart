import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:io' show File, Platform;

class ResultView extends StatefulWidget {
  final int resultId;

  const ResultView({Key? key, required this.resultId}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  Map<String, dynamic>? result;
  late String memo;
  TextEditingController? _memoController;
  bool isEditing = false;

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
        memo = result!['memo'] ?? '';
        _memoController = TextEditingController(text: memo);
      });
    }
  }

  Future<void> _saveMemo() async {
    if (_memoController != null) {
      await DatabaseHelper.instance.updateResultMemo(widget.resultId, _memoController!.text);
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메모가 저장되었습니다!')),
      );
      Navigator.pop(context, true); // 메모가 변경되었음을 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null || _memoController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final date = DateTime.parse(result!['date']).toLocal();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, isEditing), // 변경 사항 반환
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
                  if (isEditing)
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
                                  result!['symptom_name'],
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
                            child: _buildImageWidget(),
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
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '메모를 입력하세요...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    controller: _memoController,
                                    onTap: () {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      memo = value;
                                    },
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

  Widget _buildImageWidget() {
    final photoUrl = result!['photo'];

    if (photoUrl == null) {
      return const Center(
        child: Icon(
          Icons.photo,
          color: Colors.grey,
          size: 100,
        ),
      );
    }

    if (photoUrl.startsWith('http')) {
      // 네트워크 URL 처리
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
        ),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      // 모바일 환경에서 로컬 파일 처리
      if (File(photoUrl).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(photoUrl),
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return const Center(
      child: Icon(
        Icons.photo,
        color: Colors.grey,
        size: 100,
      ),
    );
  }

  @override
  void dispose() {
    _memoController?.dispose();
    super.dispose();
  }
}
