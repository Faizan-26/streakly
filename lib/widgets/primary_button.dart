import 'package:flutter/material.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:streakly/theme/app_typography.dart';

Widget primaryButton({
  required String text,
  required VoidCallback onPressed,
  Color? color,
  Color? textColor,
  double? width,
  double? height,
  double? fontSize,
  EdgeInsetsGeometry? padding,
  BorderRadius? borderRadius,
  bool isDisabled = false,
}) {
  final bool isEnabled = !isDisabled;
  final Color buttonColor = isEnabled ? (color ?? green) : Colors.grey.shade400;
  final Color buttonTextColor = isEnabled
      ? (textColor ?? darkGreen)
      : Colors.grey.shade600;

  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? 56.0,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: buttonTextColor,
        backgroundColor: buttonColor,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16.0),
        elevation: isEnabled ? 3 : 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16.0),
        ),
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
      ),
      onPressed: isEnabled
          ? () {
              HapticFeedback.mediumImpact();
              onPressed();
            }
          : null,
      child: Text(
        text,
        style: AppTypography.labelLarge.copyWith(
          fontSize: fontSize ?? 16.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: buttonTextColor,
        ),
      ),
    ),
  );
}
