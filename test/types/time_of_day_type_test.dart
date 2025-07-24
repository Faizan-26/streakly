import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/types/time_of_day_type.dart';

void main() {
  group('TimeOfDayPreference Tests', () {
    test('should have correct enum values', () {
      expect(TimeOfDayPreference.values.length, 4);
      expect(TimeOfDayPreference.values, contains(TimeOfDayPreference.anytime));
      expect(TimeOfDayPreference.values, contains(TimeOfDayPreference.morning));
      expect(
        TimeOfDayPreference.values,
        contains(TimeOfDayPreference.afternoon),
      );
      expect(TimeOfDayPreference.values, contains(TimeOfDayPreference.evening));
    });

    test('should have correct index values', () {
      expect(TimeOfDayPreference.anytime.index, 0);
      expect(TimeOfDayPreference.morning.index, 1);
      expect(TimeOfDayPreference.afternoon.index, 2);
      expect(TimeOfDayPreference.evening.index, 3);
    });
  });

  group('TimeOfDayPreferenceExtension Tests', () {
    test('should return correct names for all time preferences', () {
      expect(TimeOfDayPreference.anytime.name, 'Anytime');
      expect(TimeOfDayPreference.morning.name, 'Morning');
      expect(TimeOfDayPreference.afternoon.name, 'Afternoon');
      expect(TimeOfDayPreference.evening.name, 'Evening');
    });
  });

  group('TimeOfDayPreferenceStringExtension Tests', () {
    test('should convert valid string to time of day preference', () {
      expect('Anytime'.toTimeOfDayPreference(), TimeOfDayPreference.anytime);
      expect('Morning'.toTimeOfDayPreference(), TimeOfDayPreference.morning);
      expect(
        'Afternoon'.toTimeOfDayPreference(),
        TimeOfDayPreference.afternoon,
      );
      expect('Evening'.toTimeOfDayPreference(), TimeOfDayPreference.evening);
    });

    test('should throw ArgumentError for invalid strings', () {
      expect(
        () => 'Invalid'.toTimeOfDayPreference(),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'morning'.toTimeOfDayPreference(), // lowercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'MORNING'.toTimeOfDayPreference(), // uppercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => ''.toTimeOfDayPreference(), // empty string
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'Night'.toTimeOfDayPreference(), // not in enum
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'any time'.toTimeOfDayPreference(), // space variation
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError with correct message', () {
      expect(
        () => 'Invalid'.toTimeOfDayPreference(),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'Unknown time of day preference: Invalid',
          ),
        ),
      );
    });
  });

  group('TimeOfDayPreference Round-Trip Tests', () {
    test('should maintain consistency in name to type conversion', () {
      for (final timePreference in TimeOfDayPreference.values) {
        final name = timePreference.name;
        final convertedBack = name.toTimeOfDayPreference();
        expect(convertedBack, timePreference);
      }
    });

    test('should handle all enum values consistently', () {
      final testCases = [
        (TimeOfDayPreference.anytime, 'Anytime'),
        (TimeOfDayPreference.morning, 'Morning'),
        (TimeOfDayPreference.afternoon, 'Afternoon'),
        (TimeOfDayPreference.evening, 'Evening'),
      ];

      for (final (type, name) in testCases) {
        expect(type.name, name);
        expect(name.toTimeOfDayPreference(), type);
      }
    });
  });

  group('Business Logic Tests', () {
    test('should represent different time periods correctly', () {
      expect(TimeOfDayPreference.anytime.name, 'Anytime');
      expect(TimeOfDayPreference.morning.name, 'Morning');
      expect(TimeOfDayPreference.afternoon.name, 'Afternoon');
      expect(TimeOfDayPreference.evening.name, 'Evening');
    });

    test('should work with habit scheduling logic', () {
      String getSchedulingAdvice(TimeOfDayPreference preference) {
        switch (preference) {
          case TimeOfDayPreference.anytime:
            return 'Schedule this habit at any convenient time';
          case TimeOfDayPreference.morning:
            return 'Best scheduled in the morning for energy and consistency';
          case TimeOfDayPreference.afternoon:
            return 'Good for midday activities and lunch breaks';
          case TimeOfDayPreference.evening:
            return 'Perfect for winding down and reflection';
        }
      }

      expect(
        getSchedulingAdvice(TimeOfDayPreference.anytime),
        'Schedule this habit at any convenient time',
      );
      expect(
        getSchedulingAdvice(TimeOfDayPreference.morning),
        'Best scheduled in the morning for energy and consistency',
      );
      expect(
        getSchedulingAdvice(TimeOfDayPreference.afternoon),
        'Good for midday activities and lunch breaks',
      );
      expect(
        getSchedulingAdvice(TimeOfDayPreference.evening),
        'Perfect for winding down and reflection',
      );
    });

    test('should work with reminder timing logic', () {
      bool isFlexibleTiming(TimeOfDayPreference preference) {
        return preference == TimeOfDayPreference.anytime;
      }

      expect(isFlexibleTiming(TimeOfDayPreference.anytime), true);
      expect(isFlexibleTiming(TimeOfDayPreference.morning), false);
      expect(isFlexibleTiming(TimeOfDayPreference.afternoon), false);
      expect(isFlexibleTiming(TimeOfDayPreference.evening), false);
    });

    test('should work with habit categorization', () {
      List<TimeOfDayPreference> getStructuredTimes() {
        return TimeOfDayPreference.values
            .where((time) => time != TimeOfDayPreference.anytime)
            .toList();
      }

      final structuredTimes = getStructuredTimes();
      expect(structuredTimes.length, 3);
      expect(structuredTimes.contains(TimeOfDayPreference.morning), true);
      expect(structuredTimes.contains(TimeOfDayPreference.afternoon), true);
      expect(structuredTimes.contains(TimeOfDayPreference.evening), true);
      expect(structuredTimes.contains(TimeOfDayPreference.anytime), false);
    });
  });

  group('Edge Cases', () {
    test('should handle enum comparison correctly', () {
      expect(TimeOfDayPreference.morning == TimeOfDayPreference.morning, true);
      expect(TimeOfDayPreference.morning == TimeOfDayPreference.evening, false);
      expect(TimeOfDayPreference.morning != TimeOfDayPreference.evening, true);
    });

    test('should work in collections', () {
      final timePreferences = <TimeOfDayPreference>[
        TimeOfDayPreference.morning,
        TimeOfDayPreference.evening,
      ];

      expect(timePreferences.contains(TimeOfDayPreference.morning), true);
      expect(timePreferences.contains(TimeOfDayPreference.afternoon), false);
      expect(timePreferences.length, 2);
    });

    test('should work in maps', () {
      final timePreferenceMap = <TimeOfDayPreference, String>{
        TimeOfDayPreference.anytime: 'Flexible timing',
        TimeOfDayPreference.morning: 'Early bird special',
        TimeOfDayPreference.afternoon: 'Midday momentum',
        TimeOfDayPreference.evening: 'Evening routine',
      };

      expect(timePreferenceMap[TimeOfDayPreference.anytime], 'Flexible timing');
      expect(
        timePreferenceMap[TimeOfDayPreference.morning],
        'Early bird special',
      );
      expect(
        timePreferenceMap[TimeOfDayPreference.afternoon],
        'Midday momentum',
      );
      expect(timePreferenceMap[TimeOfDayPreference.evening], 'Evening routine');
    });

    test('should work with sorting and ordering', () {
      final unorderedPreferences = [
        TimeOfDayPreference.evening,
        TimeOfDayPreference.anytime,
        TimeOfDayPreference.morning,
        TimeOfDayPreference.afternoon,
      ];

      final sortedByIndex = unorderedPreferences.toList()
        ..sort((a, b) => a.index.compareTo(b.index));

      expect(sortedByIndex[0], TimeOfDayPreference.anytime);
      expect(sortedByIndex[1], TimeOfDayPreference.morning);
      expect(sortedByIndex[2], TimeOfDayPreference.afternoon);
      expect(sortedByIndex[3], TimeOfDayPreference.evening);
    });

    test('should work with filtering', () {
      final allPreferences = TimeOfDayPreference.values;
      final specificTimes = allPreferences
          .where((pref) => pref != TimeOfDayPreference.anytime)
          .toList();

      expect(specificTimes.length, 3);
      expect(specificTimes.contains(TimeOfDayPreference.morning), true);
      expect(specificTimes.contains(TimeOfDayPreference.afternoon), true);
      expect(specificTimes.contains(TimeOfDayPreference.evening), true);
      expect(specificTimes.contains(TimeOfDayPreference.anytime), false);
    });
  });
}
