import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/theme/app_typography.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
    this.onUncomplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitControllerProvider);
    final isCompleted = habitState.isHabitCompletedToday(habit.id);
    final streakCount = habitState.getStreakCount(habit.id);

    return Card(
      elevation: 0,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? habit.color : Colors.transparent,
          width: isCompleted ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, title, and completion button
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(habit.icon, color: habit.color, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: AppTypography.cardTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getHabitTypeText(habit.type),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Completion button
                  _buildCompletionButton(isCompleted),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom row with streak and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Streak counter
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: streakCount > 0
                            ? Colors.orange
                            : Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakCount day${streakCount != 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: streakCount > 0
                              ? Colors.orange
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Reminder time
                  if (habit.hasReminder && habit.reminderTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(habit.reminderTime!),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(bool isCompleted) {
    return GestureDetector(
      onTap: isCompleted ? onUncomplete : onComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isCompleted ? habit.color : Colors.transparent,
          border: Border.all(color: habit.color, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: isCompleted
            ? Icon(
                _getCompletionIcon(habit.type),
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  IconData _getCompletionIcon(HabitType type) {
    switch (type) {
      case HabitType.regular:
        return Icons.check;
      case HabitType.negative:
        return Icons.block;
      case HabitType.oneTime:
        return Icons.flag;
    }
  }

  String _getHabitTypeText(HabitType type) {
    switch (type) {
      case HabitType.regular:
        return 'Regular';
      case HabitType.negative:
        return 'Avoid';
      case HabitType.oneTime:
        return 'Goal';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
