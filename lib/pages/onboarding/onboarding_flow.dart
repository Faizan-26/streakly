import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/primary_button.dart';

class OnBoardingFlow extends ConsumerStatefulWidget {
  const OnBoardingFlow({super.key});

  @override
  ConsumerState<OnBoardingFlow> createState() => _OnBoardingFlowState();
}

class _OnBoardingFlowState extends ConsumerState<OnBoardingFlow> {
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
      Navigator.pushReplacementNamed(context, '/home');
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
    final backgroundColor = isDark ? const Color(0xFF2A2D3F) : lightGrey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and navigation
            _buildHeader(),

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
                  _buildCategoryPage(),
                  _buildWakeUpTimePage(),
                  _buildSleepTimePage(),
                  _buildHabitSelectionPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Navigation row
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 0)
                    IconButton(
                      onPressed: previousPage,
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : darkGreen,
                        size: 22,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? darkSurface : darkGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                  final themeController = ref.watch(
                    themeControllerProvider.notifier,
                  );
                  final isDark = themeController.isDarkMode(context);

                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= currentPage
                            ? (isDark ? green : darkGreen)
                            : (isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300),
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

  Widget _buildCategoryPage() {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

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
            spacing: 16,
            runSpacing: 16,
            children: categories.asMap().entries.map((entry) {
              int index = entry.key;
              String category = entry.value;
              bool isSelected = selectedCategories.contains(category);

              return GestureDetector(
                    onTap: () => toggleCategory(category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? green.withOpacity(0.2) : green)
                            : (isDark ? darkSurface : Colors.grey.shade50),
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
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? (isDark ? Colors.white : darkGreen)
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

          primaryButton(
                text: "Next",
                onPressed: nextPage,
                isDisabled: selectedCategories.isEmpty,
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 800.ms)
              .fadeIn(duration: 800.ms, delay: 800.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWakeUpTimePage() {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
                'What time do you usually get up?',
                textAlign: TextAlign.center,
                style: AppTypography.onboardingTimeDisplay.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 16),
          Text(
                'Choose the time you usually start a new day',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.4,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
              .fadeIn(duration: 800.ms, delay: 400.ms),

          const SizedBox(height: 72),

          // Time picker
          _buildTimePicker(
            hour: wakeUpHour,
            minute: wakeUpMinute,
            onHourChanged: (hour) => setState(() => wakeUpHour = hour),
            onMinuteChanged: (minute) => setState(() => wakeUpMinute = minute),
          ),

          const Spacer(),

          primaryButton(text: "Next", onPressed: nextPage)
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 800.ms)
              .fadeIn(duration: 800.ms, delay: 800.ms),

          const SizedBox(height: 48),

          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // Handle restore data
            },
            child: Column(
              children: [
                Text(
                  'Already using TICK IT?',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: 160,
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Restore existing data',
                  style: TextStyle(
                    color: isDark ? Colors.white : darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSleepTimePage() {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
                'What time do you usually end your day?',
                textAlign: TextAlign.center,
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.4,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
              .fadeIn(duration: 800.ms, delay: 400.ms),

          const SizedBox(height: 72),

          // Time picker
          _buildTimePicker(
            hour: sleepHour,
            minute: sleepMinute,
            onHourChanged: (hour) => setState(() => sleepHour = hour),
            onMinuteChanged: (minute) => setState(() => sleepMinute = minute),
          ),

          const Spacer(),

          primaryButton(text: "Next", onPressed: nextPage)
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 800.ms)
              .fadeIn(duration: 800.ms, delay: 800.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHabitSelectionPage() {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
                'Choose the first habit that you\'d like to build',
                style: AppTypography.headlineLarge.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 40),

          // Habit options
          ...habits.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> habit = entry.value;
            bool isSelected = selectedHabit == habit['title'];

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
                            ? (isDark
                                  ? green.withOpacity(0.15)
                                  : green.withOpacity(0.1))
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (habit['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                habit['icon'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              habit['title'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: green,
                                borderRadius: BorderRadius.circular(12),
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
                .fadeIn(duration: 600.ms, delay: (400 + (index * 100)).ms);
          }),

          const SizedBox(height: 32),

          // Divider with text
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Or type your own',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
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
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your first habit is...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
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

          const Spacer(),

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
                              ? Colors.white
                              : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                      isDisabled: selectedHabit == null && customHabit.isEmpty,
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
    );
  }

  Widget _buildTimePicker({
    required int hour,
    required int minute,
    required Function(int) onHourChanged,
    required Function(int) onMinuteChanged,
  }) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    return Container(
          height: 220,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour picker
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: hour,
                  ),
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    onHourChanged(index);
                  },
                  children: List.generate(24, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Text(
                ':',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Minute picker
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: minute,
                  ),
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    onMinuteChanged(index);
                  },
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
