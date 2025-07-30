import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';

class StreakIndicator extends StatelessWidget {
  final String count;
  final bool isDark;

  const StreakIndicator({super.key, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : darkGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? green.withOpacity(0.15) : green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: green.withOpacity(isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/fire.png', width: 20, height: 20, color: green),
          const SizedBox(width: 4),
          Text(
                count,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .then(delay: 1000.ms)
              .shimmer(duration: 1500.ms, color: green.withOpacity(0.5)),
        ],
      ),
    );
  }
}
