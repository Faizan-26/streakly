import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/icon_library_bottomsheet.dart';
import 'package:streakly/widgets/primary_button.dart';
import 'package:streakly/widgets/loading_indicator.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';

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
  IconData customHabitIcon =
      FontAwesomeIcons.solidStar; // Default icon for custom habit
  final List<Map<String, dynamic>> habits = [
    {
      'icon': FontAwesomeIcons.bed,
      'title': 'Sleep over 8h',
      'color': Colors.blue,
    },
    {
      'icon': FontAwesomeIcons.appleWhole,
      'title': 'Have a healthy meal',
      'color': Colors.purple,
    },
    {
      'icon': FontAwesomeIcons.droplet,
      'title': 'Drink 8 cups of water',
      'color': Colors.orange,
    },
    {
      'icon': FontAwesomeIcons.dumbbell,
      'title': 'Workout',
      'color': Colors.cyan,
    },
    {
      'icon': FontAwesomeIcons.personWalking,
      'title': 'Walking',
      'color': Colors.green,
    },
  ];

  // Page 5 data - Goal setting
  String goalType = 'minutes'; // only minutes
  int goalValue = 30;

  void nextPage() {
    HapticFeedback.lightImpact();
    if (currentPage < 4) {
      setState(() {
        currentPage++;
      });
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      _completeOnboarding();
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

  void _completeOnboarding() {
    // Show loading page first
    _showLoadingAndCreateHabit();
  }

  void _showLoadingAndCreateHabit() {
    final habitData = _getSelectedHabitData();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoadingIndicatorPage(
          title: 'Generating your habit plan...',
          subtitle:
              'Setting up your "${habitData['name']}" habit and daily reminders',
          icon: habitData['icon'] as IconData,
          iconColor: green,
          duration: const Duration(seconds: 3),
          onComplete: () {
            // After loading animation completes:
            // 1. Create the habit with user's selected goals and preferences
            // 2. Create and store daily notifications (wake up & sleep time)
            // 3. Save notification settings for future management in settings
            _createHabitAndNotifications();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _createHabitAndNotifications() async {
    try {
      final habitData = _getSelectedHabitData();

      // Create the habit
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: habitData['name'],
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        timeOfDay: null, // Not specified during onboarding
        goalDuration: _getGoalDuration(),
        goalCount: _getGoalCount(),
        hasReminder: false, // Individual habit reminders are disabled
        reminderTime: null, // Will use daily start/end notifications instead
        color: green,
        icon: habitData['icon'] as IconData,
        category: selectedCategories.isNotEmpty
            ? selectedCategories.first
            : null,
        createdAt: DateTime.now(),
      );

      // Add habit to controller
      final habitController = ref.read(habitControllerProvider.notifier);
      await habitController.addHabit(habit);

      // Create daily notifications for start and end of day
      await _createDailyNotifications();

      // Navigate to main app
      _navigateToMainApp();
    } catch (e) {
      print('Error creating habit: $e');
      // Show error and navigate anyway
      _navigateToMainApp();
    }
  }

  Duration? _getGoalDuration() {
    return Duration(minutes: goalValue);
  }

  int? _getGoalCount() {
    return null; // No count-based goals
  }

  Future<void> _createDailyNotifications() async {
    // Save notification settings to local storage for future management
    await NotificationService.saveDailyNotificationSettings(
      startOfDayEnabled: true, // Enabled by default during onboarding
      endOfDayEnabled: true, // Enabled by default during onboarding
      wakeUpHour: wakeUpHour,
      wakeUpMinute: wakeUpMinute,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
    );

    // Create start of day notification
    await NotificationService.scheduleDailyReminder(
      id: 'daily_start',
      title: '🌅 Good Morning!',
      body: 'Ready to start your day? Check your habits and make today count!',
      hour: wakeUpHour,
      minute: wakeUpMinute,
      type: 'start_of_day',
    );

    // Create end of day notification
    await NotificationService.scheduleDailyReminder(
      id: 'daily_end',
      title: '🌙 Day Review',
      body:
          'How did you do today? Mark your completed habits and prepare for tomorrow!',
      hour: sleepHour,
      minute: sleepMinute,
      type: 'end_of_day',
    );
  }

  void _navigateToMainApp() {
    // Pop the loading page and navigate to main app
    // Navigator.of(context).pop(); // Remove loading page
    Navigator.of(context).pop(); // Remove onboarding

    // Navigate to main app (home page)
    Navigator.pushReplacementNamed(context, '/home');
  }

  Map<String, dynamic> _getSelectedHabitData() {
    if (customHabit.isNotEmpty) {
      return {'name': customHabit, 'icon': customHabitIcon, 'isCustom': true};
    } else if (selectedHabit != null) {
      final habit = habits.firstWhere((h) => h['title'] == selectedHabit);
      return {'name': selectedHabit!, 'icon': habit['icon'], 'isCustom': false};
    }
    return {
      'name': 'Default Habit',
      'icon': FontAwesomeIcons.solidStar,
      'isCustom': false,
    };
  }

  bool _isNextButtonDisabled() {
    switch (currentPage) {
      case 0:
        return selectedCategories.isEmpty;
      case 3:
        return selectedHabit == null && customHabit.isEmpty;
      default:
        return false;
    }
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
                physics: NeverScrollableScrollPhysics(),
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
                  _buildGoalSettingPage(isDark),
                ],
              ),
            ),
            currentPage < 4
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child:
                        primaryButton(
                              text: "Next",
                              onPressed: nextPage,
                              isDisabled: _isNextButtonDisabled(),
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
                  currentPage != 0
                      ? IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            previousPage();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: isDark ? Colors.white : darkGreen,
                            size: 22,
                          ),
                        )
                      : SizedBox.shrink(),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // navigate to home
                      // Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/home');
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
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            context: context,
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
            context: context,
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
                                    child: Center(
                                      child: FaIcon(
                                        habit['icon'] as IconData,
                                        color: habit['color'] as Color,
                                        size: 28,
                                      ),
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
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                showIconLibraryBottomSheet(
                                  context,
                                  selectedIcon: customHabitIcon,
                                  onIconSelected: (icon) {
                                    setState(() {
                                      customHabitIcon = icon;
                                      selectedHabit = null;
                                    });
                                  },
                                  isDark: isDark,
                                );
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    customHabitIcon,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                    size: 24,
                                  ),
                                ),
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
    required BuildContext context,
  }) {
    return SizedBox(
          height: 0.22 * MediaQuery.of(context).size.height,
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
                  looping: true,
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
                  looping: true,
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

  Widget _buildGoalSettingPage(bool isDark) {
    final habitData = _getSelectedHabitData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit name and icon at the top
          Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        habitData['icon'] as IconData,
                        color: green,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      habitData['name'],
                      style: AppTypography.cardTitle.copyWith(
                        color: isDark ? Colors.white : darkGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .slideY(begin: -1, duration: 800.ms, delay: 200.ms)
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 40),

          Text(
                'Set a daily goal',
                style: AppTypography.headlineLarge.copyWith(
                  color: isDark ? Colors.white : darkGreen,
                ),
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
              .fadeIn(duration: 800.ms, delay: 400.ms),

          const SizedBox(height: 32),

          SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: goalValue - 1, // Convert to 0-based index
                  ),
                  itemExtent: 50,
                  squeeze: 1.5,
                  diameterRatio: 1.4,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      goalValue = index + 1; // Convert back to 1-based value
                    });
                    HapticFeedback.selectionClick();
                  },
                  magnification: 1,
                  looping: true,
                  useMagnifier: true,
                  // selectionOverlay: Container(
                  //   // height: 30,
                  //   // width: 30,
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //       top: BorderSide(
                  //         color: isDark ? Colors.white : darkGreen,
                  //         width: 1.2,
                  //       ),
                  //       bottom: BorderSide(
                  //         color: isDark ? Colors.white : darkGreen,
                  //         width: 1.2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  children: List.generate(
                    120, // Max 120 minutes
                    (index) {
                      return Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.cardTitle.copyWith(
                            color: isDark ? Colors.white : darkGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.9, 0.9),
                duration: 800.ms,
                delay: 600.ms,
              )
              .fadeIn(duration: 800.ms, delay: 600.ms),

          const Spacer(),

          // Skip and Finish buttons
          Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _completeOnboarding();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Skip',
                            style: AppTypography.bodyLarge.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: primaryButton(
                      text: "Finish",
                      onPressed: _completeOnboarding,
                    ),
                  ),
                ],
              )
              .animate()
              .slideY(begin: 1, duration: 800.ms, delay: 1000.ms)
              .fadeIn(duration: 800.ms, delay: 1000.ms),
        ],
      ),
    );
  }
}
