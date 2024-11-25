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
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 정보 컨테이너
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            const AssetImage('assets/icon_images/profile.png'),
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
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userAge.isNotEmpty ? userAge : '나이를 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // 프로필 편집 등 컨테이너
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListRow(
                      icon: Icons.edit,
                      label: '프로필 편집',
                      onTap: () {
                        // Navigate to profile edit screen
                      },
                    ),
                    const Divider(thickness: 1, height: 1), // 구분선
                    _buildListRow(
                      icon: Icons.announcement,
                      label: '공지사항',
                      onTap: () {
                        // Navigate to notices screen
                      },
                    ),
                    const Divider(thickness: 1, height: 1), // 구분선
                    _buildListRow(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () {
                        // Navigate to settings screen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60, // 행의 높이를 증가
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'SUITE',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.chevron_right, // 오른쪽 화살표 아이콘
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
