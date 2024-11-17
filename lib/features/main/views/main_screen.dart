
import 'package:flutter/material.dart';
import 'package:ear_fe/features/home/views/home_view.dart';
import 'package:ear_fe/features/search/views/search_view.dart';
import 'package:ear_fe/features/history/views/history_view.dart';
import 'package:ear_fe/features/profile/views/profile_view.dart';
import 'package:ear_fe/features/main/widgets/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const SearchView(),
    const HistoryView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}