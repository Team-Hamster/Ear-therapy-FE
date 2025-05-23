import 'package:flutter/material.dart';
import 'package:ear_fe/core/constants/colors.dart';
import 'package:ear_fe/features/main/views/main_screen.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final List<Map<String, String>> allImages = const [
    {'name': '감기', 'image': 'assets/search_images/cold.jpg'},
    {'name': '스트레스', 'image': 'assets/search_images/stress.jpg'},
    {'name': '열', 'image': 'assets/search_images/fever.jpg'},
    {'name': '어지럼증', 'image': 'assets/search_images/dizzy.jpg'},
    {'name': '두통', 'image': 'assets/search_images/headache.jpg'},
    {'name': '집중력', 'image': 'assets/search_images/focus.jpg'},
    {'name': '코피', 'image': 'assets/search_images/nosebleed.jpg'},
    {'name': '생리통', 'image': 'assets/search_images/period.jpg'},
    {'name': '빈뇨', 'image': 'assets/search_images/urine.jpg'},
  ];

  List<Map<String, String>> searchResults = [];
  bool hasSearched = false;
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
        hasSearched = false;
      } else {
        searchResults = allImages
            .where((image) => image['name'] == query)
            .toList();
        hasSearched = true;
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      searchResults = [];
      hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (hasSearched || _searchController.text.isNotEmpty) {
          _resetSearch(); // 검색 초기화
          return false; // 뒤로가기 동작 차단
        } else {
          // 홈 화면으로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          return false; // 뒤로가기로 더 이상 SearchView를 볼 수 없도록 설정
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        resizeToAvoidBottomInset: false, // 키보드가 올라와도 레이아웃 재조정 방지
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단바
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                color: AppColors.white,
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 검색창
              Padding(
                padding: const EdgeInsets.only(
                  top: 25,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '증상을 검색하세요',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    onChanged: _performSearch,
                  ),
                ),
              ),
              // 추천 검색어 섹션
              if (!hasSearched)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32,
                    right: 20,
                    top: 32,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '추천 검색어',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: allImages.map((image) => GestureDetector(
                          onTap: () {
                            _searchController.text = image['name']!;
                            _performSearch(image['name']!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              image['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontFamily: 'SUITE',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                )
              else if (searchResults.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            searchResults[0]['image']!,
                            width: 400,
                            height: 400,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
