import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/types/time_of_day_type.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitState habitState;
  final bool isDark;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onStartGoal;
  final VoidCallback? onFinishGoal;

  const HabitCard({
    super.key,
    required this.habit,
    required this.habitState,
    required this.isDark,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    this.onStartGoal,
    this.onFinishGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habitState.isHabitCompletedToday(habit.id);
    final streakCount = habitState.getStreakCount(habit.id);
    final hasGoal = habit.goalDuration != null || habit.goalCount != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
          margin: EdgeInsets.only(
            bottom: _getCardSpacing(screenWidth),
            left: 1,
            right: 1,
            top: index == 0 ? 4 : 0,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(screenWidth < 375 ? 16 : 20),
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(screenWidth < 375 ? 16 : 20),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(screenWidth < 375 ? 16 : 20),
                decoration: BoxDecoration(
                  color: _getHabitCardColor(isCompleted),
                  borderRadius: BorderRadius.circular(
                    screenWidth < 375 ? 16 : 20,
                  ),
                  border: Border.all(
                    color: _getBorderColor(isCompleted),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isDark ? 6 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main habit row
                    Row(
                      children: [
                        // Icon
                        Container(
                          width: screenWidth < 375 ? 40 : 48,
                          height: screenWidth < 375 ? 40 : 48,
                          decoration: BoxDecoration(
                            color: habit.color.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(
                              screenWidth < 375 ? 12 : 16,
                            ),
                            border: Border.all(
                              color: habit.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            habit.icon,
                            color: habit.color,
                            size: screenWidth < 375 ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: screenWidth < 375 ? 12 : 16),

                        // Title and details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth < 375 ? 15 : 16,
                                ),
                              ),
                              if (habit.timeOfDay != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      _getFilterIcon(habit.timeOfDay!),
                                      size: screenWidth < 375 ? 12 : 14,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: screenWidth < 375 ? 4 : 6),
                                    Text(
                                      habit.timeOfDay!.name.toUpperCase(),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey.shade600,
                                        fontSize: screenWidth < 375 ? 10 : 11,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Completion check and streak
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Completion indicator
                            Container(
                              width: screenWidth < 375 ? 24 : 28,
                              height: screenWidth < 375 ? 24 : 28,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? habit.color
                                    : (isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(
                                  screenWidth < 375 ? 8 : 10,
                                ),
                                border: Border.all(
                                  color: isCompleted
                                      ? habit.color
                                      : (isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade300),
                                  width: 1,
                                ),
                              ),
                              child: isCompleted
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: screenWidth < 375 ? 14 : 16,
                                    )
                                  : null,
                            ),
                            if (streakCount > 0) ...[
                              SizedBox(height: screenWidth < 375 ? 4 : 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: habit.color,
                                    size: screenWidth < 375 ? 12 : 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$streakCount',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: habit.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth < 375 ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    // Expandable goal section
                    if (hasGoal) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: isExpanded ? null : 0,
                        child: isExpanded
                            ? _buildExpandedGoalSection(screenWidth)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 100),
          duration: 400.ms,
        )
        .slideY(begin: 0.3, end: 0);
  }

  double _getCardSpacing(double screenWidth) {
    return screenWidth < 375 ? 12 : 16;
  }

  Color _getHabitCardColor(bool isCompleted) {
    if (isCompleted) {
      return isDark
          ? const Color(0xFF1E1E1E) // More minimal dark gray
          : habit.color.withOpacity(0.05);
    } else {
      return isDark
          ? const Color(0xFF2A2A2A) // Professional neutral dark
          : Colors.white;
    }
  }

  Color _getBorderColor(bool isCompleted) {
    if (isCompleted) {
      return isDark
          ? habit.color.withOpacity(0.4)
          : habit.color.withOpacity(0.2);
    } else {
      return isDark
          ? const Color(0xFF3A3A3A) // Subtle border for dark mode
          : Colors.grey.shade200;
    }
  }

  Widget _buildExpandedGoalSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(top: screenWidth < 375 ? 12 : 16),
      padding: EdgeInsets.all(screenWidth < 375 ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A1A) // More minimal dark background
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(screenWidth < 375 ? 12 : 16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF333333) // Subtle dark border
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal display
          if (habit.goalDuration != null) ...[
            Text(
              'Target: ${habit.goalDuration!.inMinutes} minutes',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontSize: screenWidth < 375 ? 13 : 14,
              ),
            ),
          ] else if (habit.goalCount != null) ...[
            Text(
              'Target: ${habit.goalCount} times',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontSize: screenWidth < 375 ? 13 : 14,
              ),
            ),
          ],

          SizedBox(height: screenWidth < 375 ? 12 : 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStartGoal,
                  icon: Icon(
                    Icons.play_arrow,
                    size: screenWidth < 375 ? 16 : 18,
                  ),
                  label: Text(
                    'Start',
                    style: TextStyle(fontSize: screenWidth < 375 ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: habit.color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth < 375 ? 8 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        screenWidth < 375 ? 8 : 12,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth < 375 ? 8 : 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFinishGoal,
                  icon: Icon(
                    Icons.check_circle_outline,
                    size: screenWidth < 375 ? 16 : 18,
                  ),
                  label: Text(
                    'Finish',
                    style: TextStyle(fontSize: screenWidth < 375 ? 12 : 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: habit.color,
                    side: BorderSide(color: habit.color),
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth < 375 ? 8 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        screenWidth < 375 ? 8 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(TimeOfDayPreference filter) {
    switch (filter) {
      case TimeOfDayPreference.morning:
        return Icons.wb_sunny_outlined;
      case TimeOfDayPreference.afternoon:
        return Icons.brightness_high_outlined;
      case TimeOfDayPreference.evening:
        return Icons.brightness_3_outlined;
      case TimeOfDayPreference.anytime:
        return Icons.schedule_outlined;
    }
  }
}
