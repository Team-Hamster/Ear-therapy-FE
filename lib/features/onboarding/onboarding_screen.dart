import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/main/views/main_screen.dart';
import 'package:ear_fe/database/database_helper.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedAge;
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 숨기기
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // 배경색 변경
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
                children: [
                  const SizedBox(height: 40), // 전체적으로 아래로 이동
                  // 환영합니다 텍스트
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0), // 왼쪽 여백 추가
                    child: Align(
                      alignment: Alignment.centerLeft, // 왼쪽 정렬
                      child: Text(
                        '환영합니다',
                        style: TextStyle(
                          fontSize: 32, // 더 큰 폰트 크기
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // 검은색 텍스트
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 설명 텍스트
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // 왼쪽 여백 추가
                    child: Align(
                      alignment: Alignment.centerLeft, // 왼쪽 정렬
                      child: RichText(
                        textAlign: TextAlign.left, // 텍스트도 왼쪽 정렬
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'ᆞ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '이침요법',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor
                              ),
                            ),
                            TextSpan(
                              text: '으로 관리하는 건강 라이프ᆞ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50), // 추가 여백
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 이름 입력
                      Container(
                        width: double.infinity,
                        height: 70,
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0, top: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: nameController,
                          style: const TextStyle(fontSize: 20, color: Colors.black87),
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 나이 선택
                      Container(
                        width: double.infinity,
                        height: 70,
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedAge,
                          hint: const Text(
                            'Age',
                            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          items: List.generate(70 - 15 + 1, (index) => (index + 15).toString())
                              .map((age) => DropdownMenuItem(
                                    value: age,
                                    child: Text(
                                      age,
                                      style: const TextStyle(fontSize: 20, color: Colors.black87),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAge = value;
                            });
                          },
                          decoration: const InputDecoration(border: InputBorder.none),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 성별 선택
                      Container(
                        width: double.infinity,
                        height: 70,
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          hint: const Text(
                            'Gender',
                            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          items: ['여성','남성']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: const TextStyle(fontSize: 20, color: Colors.black87),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                          decoration: const InputDecoration(border: InputBorder.none),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // 시작하기 버튼
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty && selectedAge != null && selectedGender != null) {
                            final dbHelper = DatabaseHelper.instance;
                            final genderValue = selectedGender == '남성' ? 'M' : 'F';

                            await dbHelper.insertUser(
                              name: nameController.text,
                              age: int.parse(selectedAge!),
                              gender: genderValue,
                            );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('모든 정보를 입력하세요.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(double.infinity, 60), // 버튼 너비를 화면 너비로 설정
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '시작하기',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 30), // 버튼 아래 여백 추가
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
