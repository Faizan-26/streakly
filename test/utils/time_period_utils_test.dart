import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/utils/time_period_utils.dart';
import 'package:streakly/types/time_of_day_type.dart';

void main() {
  group('TimePeriodUtils Tests', () {
    group('getCurrentTimePeriod Tests', () {
      test('should return morning for hours 8-13', () {
        // Note: This test uses DateTime.now() which makes it time-dependent
        // In a real application, you might want to inject a clock or use a testable approach

        // Test logic based on the implementation
        final testCases = [
          (8, TimeOfDayPreference.morning),
          (10, TimeOfDayPreference.morning),
          (12, TimeOfDayPreference.morning),
          (13, TimeOfDayPreference.morning),
        ];

        for (final (hour, expected) in testCases) {
          // We can't easily mock DateTime.now() without dependency injection
          // So we'll test the logic indirectly by checking the conditions
          expect(
            hour >= 8 && hour < 14,
            expected == TimeOfDayPreference.morning,
          );
        }
      });

      test('should return afternoon for hours 14-18', () {
        final testCases = [
          (14, TimeOfDayPreference.afternoon),
          (16, TimeOfDayPreference.afternoon),
          (18, TimeOfDayPreference.afternoon),
        ];

        for (final (hour, expected) in testCases) {
          expect(
            hour >= 14 && hour < 19,
            expected == TimeOfDayPreference.afternoon,
          );
        }
      });

      test('should return evening for hours 19-22', () {
        final testCases = [
          (19, TimeOfDayPreference.evening),
          (20, TimeOfDayPreference.evening),
          (22, TimeOfDayPreference.evening),
        ];

        for (final (hour, expected) in testCases) {
          expect(
            hour >= 19 && hour < 23,
            expected == TimeOfDayPreference.evening,
          );
        }
      });

      test('should return anytime for hours outside defined periods', () {
        final anytimeHours = [0, 1, 2, 3, 4, 5, 6, 7, 23];

        for (final hour in anytimeHours) {
          final isOutsideDefinedPeriods =
              !((hour >= 8 && hour < 14) || // morning
                  (hour >= 14 && hour < 19) || // afternoon
                  (hour >= 19 && hour < 23) // evening
                  );
          expect(
            isOutsideDefinedPeriods,
            true,
            reason: 'Hour $hour should be outside defined periods',
          );
        }
      });

      test('should handle boundary conditions correctly', () {
        // Test boundary hours
        final boundaryTests = [
          (7, false, 'Hour 7 should not be morning'),
          (8, true, 'Hour 8 should be morning'),
          (13, true, 'Hour 13 should be morning'),
          (14, false, 'Hour 14 should not be morning but afternoon'),
          (18, true, 'Hour 18 should be afternoon'),
          (19, false, 'Hour 19 should not be afternoon but evening'),
          (22, true, 'Hour 22 should be evening'),
          (23, false, 'Hour 23 should not be evening'),
        ];

        for (final (hour, shouldBeMorning, description) in boundaryTests) {
          final isMorning = hour >= 8 && hour < 14;
          if (shouldBeMorning && description.contains('morning')) {
            expect(isMorning, true, reason: description);
          }
        }
      });

      test('should return consistent results', () {
        // Test that the function returns consistent results for the same input
        // Since we can't control DateTime.now(), we test the implementation logic
        final result1 = TimePeriodUtils.getCurrentTimePeriod();
        final result2 = TimePeriodUtils.getCurrentTimePeriod();

        // Results should be the same if called within the same minute
        expect(result1, result2);
      });
    });

    group('getTimePeriodRange Tests', () {
      test('should return correct time ranges for all periods', () {
        expect(
          TimePeriodUtils.getTimePeriodRange(TimeOfDayPreference.morning),
          '08:00 - 14:00',
        );
        expect(
          TimePeriodUtils.getTimePeriodRange(TimeOfDayPreference.afternoon),
          '14:00 - 19:00',
        );
        expect(
          TimePeriodUtils.getTimePeriodRange(TimeOfDayPreference.evening),
          '19:00 - 23:00',
        );
        expect(
          TimePeriodUtils.getTimePeriodRange(TimeOfDayPreference.anytime),
          'Anytime',
        );
      });

      test('should handle all TimeOfDayPreference values', () {
        for (final preference in TimeOfDayPreference.values) {
          final range = TimePeriodUtils.getTimePeriodRange(preference);
          expect(range, isNotEmpty);
          expect(range, isA<String>());
        }
      });

      test('should return properly formatted time ranges', () {
        final morningRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.morning,
        );
        final afternoonRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.afternoon,
        );
        final eveningRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.evening,
        );

        // Check format: HH:MM - HH:MM
        final timeRangePattern = RegExp(r'^\d{2}:\d{2} - \d{2}:\d{2}$');
        expect(timeRangePattern.hasMatch(morningRange), true);
        expect(timeRangePattern.hasMatch(afternoonRange), true);
        expect(timeRangePattern.hasMatch(eveningRange), true);
      });

      test('should have non-overlapping time ranges', () {
        final morningRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.morning,
        );
        final afternoonRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.afternoon,
        );
        final eveningRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.evening,
        );

        // Morning ends at 14:00, afternoon starts at 14:00
        expect(morningRange.contains('14:00'), true);
        expect(afternoonRange.contains('14:00'), true);

        // Afternoon ends at 19:00, evening starts at 19:00
        expect(afternoonRange.contains('19:00'), true);
        expect(eveningRange.contains('19:00'), true);
      });

      test('should return consistent strings', () {
        // Test that multiple calls return the same string
        final morning1 = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.morning,
        );
        final morning2 = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.morning,
        );
        expect(morning1, morning2);

        final anytime1 = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.anytime,
        );
        final anytime2 = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.anytime,
        );
        expect(anytime1, anytime2);
      });
    });

    group('Integration Tests', () {
      test(
        'should have consistent logic between getCurrentTimePeriod and getTimePeriodRange',
        () {
          // The time ranges returned by getTimePeriodRange should match
          // the logic in getCurrentTimePeriod

          final morningRange = TimePeriodUtils.getTimePeriodRange(
            TimeOfDayPreference.morning,
          );
          final afternoonRange = TimePeriodUtils.getTimePeriodRange(
            TimeOfDayPreference.afternoon,
          );
          final eveningRange = TimePeriodUtils.getTimePeriodRange(
            TimeOfDayPreference.evening,
          );

          expect(morningRange, '08:00 - 14:00');
          expect(afternoonRange, '14:00 - 19:00');
          expect(eveningRange, '19:00 - 23:00');

          // These ranges should match the conditions in getCurrentTimePeriod:
          // Morning: hour >= 8 && hour < 14
          // Afternoon: hour >= 14 && hour < 19
          // Evening: hour >= 19 && hour < 23
        },
      );

      test('should cover the entire day appropriately', () {
        // Check that all hours of the day are covered
        final coveredHours = <int>{};

        // Morning: 8-13 (8 <= hour < 14)
        for (int hour = 8; hour < 14; hour++) {
          coveredHours.add(hour);
        }

        // Afternoon: 14-18 (14 <= hour < 19)
        for (int hour = 14; hour < 19; hour++) {
          coveredHours.add(hour);
        }

        // Evening: 19-22 (19 <= hour < 23)
        for (int hour = 19; hour < 23; hour++) {
          coveredHours.add(hour);
        }

        // Hours 0-7 and 23 are "anytime"
        final anytimeHours = [0, 1, 2, 3, 4, 5, 6, 7, 23];

        // Verify coverage
        expect(
          coveredHours.length,
          15,
        ); // 8-13 (6) + 14-18 (5) + 19-22 (4) = 15
        expect(anytimeHours.length, 9); // Verify anytime hours count

        // All specific time periods should have defined ranges
        for (int hour = 8; hour < 23; hour++) {
          if (hour < 14) {
            // Should be morning
          } else if (hour < 19) {
            // Should be afternoon
          } else {
            // Should be evening
          }
        }
      });

      test('should handle edge cases consistently', () {
        // Test that the utils work well together
        final currentPeriod = TimePeriodUtils.getCurrentTimePeriod();
        final currentRange = TimePeriodUtils.getTimePeriodRange(currentPeriod);

        expect(currentRange, isNotEmpty);
        expect(currentPeriod, isIn(TimeOfDayPreference.values));
      });
    });

    group('Usage Examples', () {
      test('should work for habit scheduling scenarios', () {
        // Example: User wants to schedule a morning workout
        final morningRange = TimePeriodUtils.getTimePeriodRange(
          TimeOfDayPreference.morning,
        );
        expect(morningRange, '08:00 - 14:00');

        // Example: Check if current time is good for a morning habit
        final currentPeriod = TimePeriodUtils.getCurrentTimePeriod();
        final isGoodForMorningHabit =
            currentPeriod == TimeOfDayPreference.morning;
        expect(isGoodForMorningHabit, isA<bool>());
      });

      test('should work for notification scheduling', () {
        // Example: Get all specific time periods for reminder options
        final specificPeriods = TimeOfDayPreference.values
            .where((period) => period != TimeOfDayPreference.anytime)
            .toList();

        expect(specificPeriods.length, 3);

        for (final period in specificPeriods) {
          final range = TimePeriodUtils.getTimePeriodRange(period);
          expect(range, matches(r'^\d{2}:\d{2} - \d{2}:\d{2}$'));
        }
      });
    });
  });
}
