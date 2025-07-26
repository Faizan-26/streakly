import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'package:streakly/theme/app_colors.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    this.onTap,
    this.indexSelected = 0,
    this.onFabClick,
  });

  final ValueChanged<int>? onTap;
  final VoidCallback? onFabClick;
  final int indexSelected;

  static const List<({IconData icon, String label})> _items = [
    (icon: FontAwesomeIcons.house, label: 'Home'),
    (icon: FontAwesomeIcons.robot, label: 'AI Agent'),
    (icon: FontAwesomeIcons.chartLine, label: 'Stats'),
    (icon: FontAwesomeIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,

      children: [
        GlassmorphicContainer(
          // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          height: 90,
          borderRadius: 30,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    darkBackground.withOpacity(0.7),
                    darkBackground.withOpacity(0.5),
                  ]
                : [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.5),
                  ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.white.withOpacity(0.1), darkCard.withOpacity(0.3)]
                : [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.4),
                  ],
          ),
        ),
        // FAB cutout overlay
        // Positioned.fill(
        //   child: CustomPaint(painter: CutoutPainter(isDark: isDark)),
        // ),
        // Navigation items
        Positioned(
          left: 10,
          right: 5,
          top: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < _items.length; i++)
                _buildNavItem(i, _items[i].icon, _items[i].label, isDark),
            ],
          ),
        ),
        // FAB positioned above the navbar
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildAddButton(isDark)],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = indexSelected == index;
    final iconColor = isSelected
        ? (isDark ? green : darkGreen)
        : (isDark
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.7));

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call(index);
          },
          // customBorder: const StadiumBorder(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.1 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: isDark
                                ? green.withOpacity(0.2)
                                : darkGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: FaIcon(
                      icon,
                      color: iconColor,
                      size: isSelected ? 22 : 20,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                        label,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    final buttonColor = isDark ? green : darkGreen;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onFabClick?.call();
      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(color: buttonColor, shape: BoxShape.circle),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}

class CutoutPainter extends CustomPainter {
  final bool isDark;

  CutoutPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? darkBackground : Colors.white
      ..style = PaintingStyle.fill;

    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width / 2, 0), radius: 35));

    final backgroundPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(30),
        ),
      );

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Draw a more opaque background for better visibility
    canvas.drawPath(finalPath, paint..color = paint.color.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(CutoutPainter oldDelegate) => isDark != oldDelegate.isDark;
}
