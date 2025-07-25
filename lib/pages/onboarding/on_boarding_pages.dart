import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/primary_button.dart';

class OnBoardingPages extends ConsumerStatefulWidget {
  const OnBoardingPages({super.key});

  @override
  ConsumerState<OnBoardingPages> createState() => _OnBoardingPagesState();
}

class _OnBoardingPagesState extends ConsumerState<OnBoardingPages> {
  int currentPage = 0;
  PageController pageController = PageController();

  // Page 1 data
  List<String> selectedCategories = [];
  final List<String> categories = [
    'Health',
    'Focus',
    'Productivity',
    'Mindfulness',
    'Sleep',
  ];

  // Page 2 & 3 data
  int wakeUpHour = 8;
  int wakeUpMinute = 0;
  int sleepHour = 23;
  int sleepMinute = 0;

  // Page 4 data
  String? selectedHabit;
  String customHabit = '';
  final List<Map<String, dynamic>> habits = [
    {'icon': '😴', 'title': 'Sleep over 8h', 'color': Colors.blue},
    {'icon': '🍎', 'title': 'Have a healthy meal', 'color': Colors.purple},
    {'icon': '💧', 'title': 'Drink 8 cups of water', 'color': Colors.orange},
    {'icon': '💪', 'title': 'Workout', 'color': Colors.cyan},
    {'icon': '🚶', 'title': 'Walking', 'color': Colors.green},
  ];

  void nextPage() {
    HapticFeedback.lightImpact();
    if (currentPage < 3) {
      setState(() {
        currentPage++;
      });
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      print('Onboarding completed!');
    }
  }

  void previousPage() {
    HapticFeedback.lightImpact();
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleCategory(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);
    final backgroundColor = (isDark ? const Color(0xFF2A2D3F) : lightGrey);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and navigation
            _buildHeader(isDark),

            // Page content
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                children: [
                  _buildCategoryPage(isDark),
                  _buildWakeUpTimePage(isDark),
                  _buildSleepTimePage(isDark),
                  _buildHabitSelectionPage(isDark),
                ],
              ),
            ),
            currentPage < 3
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child:
                        primaryButton(
                              text: "Next",
                              onPressed: nextPage,
                              isDisabled: currentPage == 0
                                  ? selectedCategories.isEmpty
                                  : false,
                            )
                            .animate()
                            .slideY(begin: 1, duration: 800.ms, delay: 800.ms)
                            .fadeIn(duration: 800.ms, delay: 800.ms),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Navigation row
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (currentPage == 0) {
                        Navigator.of(context).pop();
                      } else {
                        previousPage();
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : darkGreen,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      print('Skip pressed');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : darkGreen,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .slideY(begin: -1, duration: 600.ms)
              .fadeIn(duration: 600.ms),

          const SizedBox(height: 20),

          // Progress indicator
          Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= currentPage
                            ? (isDark ? Colors.white : darkGreen)
                            : (isDark ? Colors.white24 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: -1, duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildCategoryPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
                'What do you want to improve?',
                style: AppTypography.onboardingTitle.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 48),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.asMap().entries.map((entry) {
              int index = entry.key;
              String category = entry.value;
              bool isSelected = selectedCategories.contains(category);

              return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      toggleCategory(category);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? green
                            : (isDark ? darkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isSelected
                              ? green
                              : (isDark ? darkCard : Colors.grey.shade200),
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        category,
                        style: AppTypography.cardTitle.copyWith(
                          color: isSelected
                              ? darkGreen
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: -0.5,
                    duration: 600.ms,
                    delay: (400 + (index * 100)).ms,
                  )
                  .fadeIn(duration: 600.ms, delay: (400 + (index * 100)).ms);
            }).toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWakeUpTimePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text(
                'What time do you usually get up?',
                style: AppTypography.onboardingTitle.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 16),
          Text(
                'Choose the time you usually start a new day',
                textAlign: TextAlign.left,
                style: AppTypography.onboardingSubtitle.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
              .fadeIn(duration: 800.ms, delay: 400.ms),

          const SizedBox(height: 64),

          // Time picker
          _buildTimePicker(
            hour: wakeUpHour,
            minute: wakeUpMinute,
            onHourChanged: (hour) {
              HapticFeedback.selectionClick();
              setState(() => wakeUpHour = hour);
            },
            onMinuteChanged: (minute) {
              HapticFeedback.selectionClick();
              setState(() => wakeUpMinute = minute);
            },
            isDark: isDark,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSleepTimePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Text(
                'What time do you usually end your day?',
                textAlign: TextAlign.left,
                style: AppTypography.onboardingTimeDisplay.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 16),
          Text(
                'We\'ll remind you to finish your checklist before that',
                textAlign: TextAlign.left,
                style: AppTypography.onboardingSubtitle.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
              .fadeIn(duration: 800.ms, delay: 400.ms),

          const SizedBox(height: 64),

          // Time picker
          _buildTimePicker(
            hour: sleepHour,
            minute: sleepMinute,
            onHourChanged: (hour) {
              HapticFeedback.selectionClick();
              setState(() => sleepHour = hour);
            },
            onMinuteChanged: (minute) {
              HapticFeedback.selectionClick();
              setState(() => sleepMinute = minute);
            },
            isDark: isDark,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHabitSelectionPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
                'Choose the first habit that you\'d like to build',
                style: AppTypography.headlineLarge.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 24),

          // Habit options - Make scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Habit list
                  ...habits.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> habit = entry.value;
                    bool isSelected = selectedHabit == habit['title'];

                    // Map habit titles to appropriate Flutter icons
                    IconData getHabitIcon(String title) {
                      switch (title.toLowerCase()) {
                        case 'sleep over 8h':
                          return Icons.bedtime;
                        case 'have a healthy meal':
                          return Icons.restaurant;
                        case 'drink 8 cups of water':
                          return Icons.water_drop;
                        case 'workout':
                          return Icons.fitness_center;
                        case 'walking':
                          return Icons.directions_walk;
                        default:
                          return Icons.check_circle_outline;
                      }
                    }

                    return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedHabit = habit['title'];
                                customHabit = '';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? green.withOpacity(0.15)
                                    : (isDark ? darkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? green
                                      : (isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade200),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: (habit['color'] as Color)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      getHabitIcon(habit['title']),
                                      color: habit['color'] as Color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      habit['title'],
                                      style: AppTypography.cardTitle.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: green,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .slideX(
                          begin: -0.5,
                          duration: 600.ms,
                          delay: (400 + (index * 100)).ms,
                        )
                        .fadeIn(
                          duration: 600.ms,
                          delay: (400 + (index * 100)).ms,
                        );
                  }),

                  const SizedBox(height: 24),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Or type your own',
                          style: AppTypography.cardSubtitle.copyWith(
                            color: isDark
                                ? Colors.white60
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                  const SizedBox(height: 24),

                  // Custom habit input
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: customHabit.isNotEmpty
                                ? green
                                : (isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade200),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.1,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                style: AppTypography.cardTitle.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Your first habit is...',
                                  hintStyle: AppTypography.cardTitle.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    customHabit = value;
                                    if (value.isNotEmpty) {
                                      selectedHabit = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(begin: 1, duration: 600.ms, delay: 1000.ms)
                      .fadeIn(duration: 600.ms, delay: 1000.ms),

                  const SizedBox(height: 32),

                  // Bottom buttons
                  Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? darkSurface
                                      : Colors.grey.shade200,
                                  foregroundColor: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  print('Skip pressed');
                                },
                                child: Text(
                                  'SKIP',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: primaryButton(
                              text: "Complete",
                              height: 56,
                              onPressed: nextPage,
                              isDisabled:
                                  selectedHabit == null && customHabit.isEmpty,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .slideY(begin: 1, duration: 800.ms, delay: 1200.ms)
                      .fadeIn(duration: 800.ms, delay: 1200.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required int hour,
    required int minute,
    required Function(int) onHourChanged,
    required Function(int) onMinuteChanged,
    required bool isDark,
  }) {
    return Container(
          height: 240,
          decoration: BoxDecoration(
            color: isDark
                ? darkSurface.withOpacity(0.5)
                : lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: hour,
                  ),
                  itemExtent: 60,
                  squeeze: 1.1,
                  diameterRatio: 1.5,
                  onSelectedItemChanged: onHourChanged,
                  children: List.generate(24, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: AppTypography.onboardingTimeDisplay.copyWith(
                          color: isDark ? Colors.white : darkGreen,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: AppTypography.displayMedium.copyWith(
                    color: isDark ? green : darkGreen,
                  ),
                ),
              ),

              // Minute picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: minute,
                  ),
                  itemExtent: 60,
                  squeeze: 1.1,
                  diameterRatio: 1.5,
                  onSelectedItemChanged: onMinuteChanged,
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: AppTypography.onboardingTimeDisplay.copyWith(
                          color: isDark ? Colors.white : darkGreen,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(begin: const Offset(0.9, 0.9), duration: 800.ms, delay: 600.ms)
        .fadeIn(duration: 800.ms, delay: 600.ms);
  }
}
