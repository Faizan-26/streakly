import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/table_calender_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  @override
  void dispose() {
    selectedDate.dispose();
    super.dispose();
  }

  String getDateString(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return "Today";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else if (diff.inDays == -1) {
      return "Tomorrow";
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? darkSurface : lightGrey;
    final textColor = isDark ? Colors.white : darkGreen;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Container(
          decoration: BoxDecoration(color: appBarColor),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: ValueListenableBuilder<DateTime>(
              valueListenable: selectedDate,
              builder: (context, date, child) {
                return Column(
                      key: ValueKey(date.day),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: getDateString(date),
                                style: AppTypography.headlineSmall.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMMM d').format(date),
                          style: AppTypography.bodyMedium.copyWith(
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .rotate(
                      begin: 0.02,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StreakIndicator(count: "1")
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: appBarColor),
              child: HorizontalCalender(
                selectedDate: selectedDate,
                onDaySelected: (p0) {
                  selectedDate.value = p0;
                },
                perfectDays: {
                  DateTime.now(),

                  DateTime.now().add(const Duration(days: 1)),
                  DateTime.now().add(const Duration(days: 2)),
                  DateTime.now().subtract(const Duration(days: 1)),
                  DateTime.now().subtract(const Duration(days: 2)),
                  DateTime.now().subtract(const Duration(days: 3)),
                  DateTime.now().subtract(const Duration(days: 4)),
                  DateTime.now().subtract(const Duration(days: 5)),
                  DateTime.now().subtract(const Duration(days: 6)),

                  DateTime.now().subtract(const Duration(days: 7)),
                },
                progressMap: {
                  DateTime.now(): 0.8,
                  DateTime.now().add(const Duration(days: 3)): 0.6,
                  DateTime.now().subtract(const Duration(days: 12)): 0.4,
                  DateTime.now().subtract(const Duration(days: 10)): 0.2,
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SHOW FILTER TABBAR HERE IN LIST UI LIKE ANYTIME, MORNING that will filter TimeOfDayPreference

                    // SHOW HABIT TILES BASED ON CURRENT DATE AND FILTERS APPLIED
                    
                    // Add your habit list or other content here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget StreakIndicator({required String count}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : darkGreen;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? green.withOpacity(0.2) : green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: green.withOpacity(0.3), width: 1),
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
    },
  );
}
