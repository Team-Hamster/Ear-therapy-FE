import 'package:flutter/material.dart';
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
                    children: [
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
                          items: List.generate(100, (index) => (index + 1).toString())
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
                          items: ['남성', '여성']
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
                      const SizedBox(height: 30),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B46D0)),
                        child: const Text(
                          '시작하기',
                          style: TextStyle(color: Colors.white),
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