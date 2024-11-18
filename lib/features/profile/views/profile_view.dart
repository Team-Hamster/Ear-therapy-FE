import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/database/database_helper.dart'; // DatabaseHelper 가져오기

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String userName = '';
  String userGender = '';
  String userAge = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getLastUser(); // 마지막 사용자 정보 가져오기

    if (user != null) {
      setState(() {
        userName = user['name'];
        userGender = user['gender'] == 'M' ? '남성' : '여성'; // 성별 변환
        userAge = user['age'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: AppColors.white,
              child: const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/icon_images/profile.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userName.isNotEmpty ? userName : '이름을 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userGender.isNotEmpty ? userGender : '성별을 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userAge.isNotEmpty ? userAge : '나이를 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: AppColors.accentColor,
                        ),
                        title: const Text('프로필 편집'),
                        onTap: () {
                          // Navigate to profile edit screen
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.announcement,
                          color: AppColors.accentColor,
                        ),
                        title: const Text('공지사항'),
                        onTap: () {
                          // Navigate to notices screen
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: AppColors.accentColor,
                        ),
                        title: const Text('Settings'),
                        onTap: () {
                          // Navigate to settings screen
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}