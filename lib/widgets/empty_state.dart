import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/types/time_of_day_type.dart';

class EmptyState extends StatelessWidget {
  final TimeOfDayPreference selectedTimeFilter;
  final bool isDark;

  const EmptyState({
    super.key,
    required this.selectedTimeFilter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 40,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            selectedTimeFilter == TimeOfDayPreference.anytime
                ? 'No habits yet'
                : 'No ${selectedTimeFilter.name.toLowerCase()} habits',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            'Tap the + button to create your first habit!',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade500,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
