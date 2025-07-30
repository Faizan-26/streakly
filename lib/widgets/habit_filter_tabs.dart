import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/types/time_of_day_type.dart';

class HabitFilterTabs extends StatelessWidget {
  final TimeOfDayPreference selectedFilter;
  final ValueChanged<TimeOfDayPreference> onFilterChanged;
  final bool isDark;

  const HabitFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: TimeOfDayPreference.values.map((filter) {
            final isSelected = selectedFilter == filter;
            final filterIcon = _getFilterIcon(filter);

            return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onFilterChanged(filter),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 375 ? 16 : 20,
                          vertical: screenWidth < 375 ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (!isDark
                                    ? darkGreen.withOpacity(0.15)
                                    : lightGreen.withOpacity(0.1))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (!isDark ? darkGreen : lightGreen)
                                : (!isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filterIcon,
                              size: screenWidth < 375 ? 16 : 18,
                              color: isSelected
                                  ? (!isDark ? darkGreen : lightGreen)
                                  : (!isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600),
                            ),
                            SizedBox(width: screenWidth < 375 ? 6 : 8),
                            Text(
                              filter.name.toUpperCase(),
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected
                                    ? (!isDark ? darkGreen : lightGreen)
                                    : (!isDark
                                          ? Colors.white60
                                          : Colors.grey.shade600),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: screenWidth < 375 ? 10 : 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: Duration(
                    milliseconds:
                        TimeOfDayPreference.values.indexOf(filter) * 100,
                  ),
                  duration: 300.ms,
                )
                .slideX(begin: 0.3, end: 0);
          }).toList(),
        ),
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
