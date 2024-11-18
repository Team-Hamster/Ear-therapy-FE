import 'package:flutter/material.dart';
import 'package:ear_fe/features/home/views/home_view.dart'; // 홈 화면으로 이동

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedAge; // 초기값 명확히 설정
  String? selectedGender; // 초기값 명확히 설정

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 숨기기
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2043),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ᆞ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '이침요법',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDDC2E9),
                          ),
                        ),
                        TextSpan(
                          text: '으로 관리하는 건강 라이프ᆞ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 70, // 높이 조정
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0, top: 8.0), // 패딩 조정
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: nameController,
                          style: const TextStyle(
                            fontSize: 20, // 텍스트 크기 키움
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'name',
                            hintStyle: const TextStyle(
                              color: Colors.grey, // 힌트 텍스트 색상 변경
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus(); // 키보드 숨기기
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 70, // 높이 조정
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0), // 왼쪽 패딩 추가
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonFormField<String>(
                          isDense: false, // 텍스트 밀도를 낮춤
                          value: selectedAge,
                          hint: const Align(
                            alignment: Alignment.centerLeft, // 왼쪽 정렬
                            child: Text(
                              'age',
                              style: TextStyle(
                                color: Colors.grey, // 힌트 텍스트 색상 변경
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          items: List.generate(100, (index) => (index + 1).toString())
                              .map(
                                (age) => DropdownMenuItem(
                                  value: age,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0), // 아이템 여유 공간
                                    child: Text(
                                      age,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20, // 텍스트 크기 키움
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAge = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black87),
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 70, // 높이 조정
                        padding: const EdgeInsets.only(left: 24.0, right: 16.0), // 왼쪽 패딩 추가
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonFormField<String>(
                          isDense: false, // 텍스트 밀도를 낮춤
                          value: selectedGender,
                          hint: const Align(
                            alignment: Alignment.centerLeft, // 왼쪽 정렬
                            child: Text(
                              'gender',
                              style: TextStyle(
                                color: Colors.grey, // 힌트 텍스트 색상 변경
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          items: ['남성', '여성']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0), // 아이템 여유 공간
                                    child: Text(
                                      gender,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20, // 텍스트 크기 키움
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black87),
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // 홈 화면으로 이동
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomeView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B46D0),
                        ),
                        child: const Text(
                          '시작하기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
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
