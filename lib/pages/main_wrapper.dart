// lib/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/navigation/navbar.dart';
import 'package:streakly/pages/home/page.dart';
import 'package:streakly/pages/ai_agent/page.dart';
import 'package:streakly/pages/stats/page.dart';
import 'package:streakly/pages/profile/page.dart';

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
    // Handle FAB click - e.g., show add habit dialog/page
    print('FAB clicked - Add new habit');
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
