import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/database/database_helper.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:ear_fe/features/result/views/result_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late Future<List<Map<String, dynamic>>> _userResultsFuture;

  @override
  void initState() {
    super.initState();
    _userResultsFuture = _fetchUserResults(); // 사용자 결과를 가져오는 Future 초기화
  }

  Future<List<Map<String, dynamic>>> _fetchUserResults() async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getLastUser(); // 마지막 사용자 정보 가져오기
    if (user != null) {
      return await dbHelper.getUserResults(user['id']); // 해당 사용자의 결과 가져오기
    }
    return [];
  }

  void _refreshResults() {
    setState(() {
      _userResultsFuture = _fetchUserResults(); // 결과 새로고침
    });
  }

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primaryColor,
                    onPressed: _refreshResults, // 새로고침 기능
                  ),
                ],
              ),
            ),
            Expanded(
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '혈자리 결과 목록',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 20,
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _userResultsFuture, // 사용자 결과 가져오기
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text('진단 결과가 없습니다.'),
                                );
                              }

                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final result = snapshot.data![index];
                                  final date = DateTime.parse(result['date']);
                                  final formattedDate = DateFormat('MM.dd EEE').format(date);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResultView(resultId: result['id']),
                                          ),
                                        );
                                      },
                                      onLongPress: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('결과 삭제'),
                                            content: const Text('해당 결과를 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('삭제'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await DatabaseHelper.instance.deleteResult(result['id']);
                                          setState(() {
                                            _userResultsFuture = _fetchUserResults(); // 결과 삭제 후 데이터 새로고침
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0 ? Colors.white : AppColors.backgroundColor,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        result['symptom_name'],
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        formattedDate.toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (result['title'] != null || result['memo'] != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: Image.asset(
                                                      'assets/icon_images/note.png',
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                physics: const BouncingScrollPhysics(),
                              );
                            },
                          ),
                        ),
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