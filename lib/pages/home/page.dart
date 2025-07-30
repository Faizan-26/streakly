import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGrey,
        centerTitle: false,
        title: ValueListenableBuilder<DateTime>(
          valueListenable: selectedDate,
          builder: (context, date, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: getDateString(date),
                        style: AppTypography.headlineMedium.copyWith(
                          color: darkGreen,
                        ),
                      ),
                      TextSpan(text: '\n'),
                      TextSpan(
                        text: DateFormat('EEEE').format(date),
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [StreakIndicator(count: "1")],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: lightGrey,
              child: horizontalCalender(
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
                progressMap: {},
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('assets/fire.png', width: 24, height: 24),
      SizedBox(width: 2),
      Text(count, style: AppTypography.headlineSmall),
    ],
  );
}
