// lib/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/navigation/navbar.dart';
import 'package:streakly/pages/home/page.dart';
import 'package:streakly/pages/ai_agent/page.dart';
import 'package:streakly/pages/stats/page.dart';
import 'package:streakly/pages/profile/page.dart';
import 'package:streakly/pages/add_habit/page.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AIAgentPage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleFabClick() {
    // Navigate to Add Habit page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitPage()),
    ).then((result) {
      // The habit is already saved in AddHabitPage using the controller
      if (result != null) {
        // Show confirmation or refresh data if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit "${result.title}" created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: NavBar(
              onTap: _handleNavigation,
              onFabClick: _handleFabClick,
              indexSelected: _currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}
