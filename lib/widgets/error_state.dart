import 'package:flutter/material.dart';
import 'package:streakly/theme/app_typography.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final bool isDark;

  const ErrorState({super.key, required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
