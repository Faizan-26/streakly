import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/types/habit_type.dart';

void main() {
  group('HabitType Tests', () {
    test('should have correct enum values', () {
      expect(HabitType.values.length, 3);
      expect(HabitType.values, contains(HabitType.regular));
      expect(HabitType.values, contains(HabitType.negative));
      expect(HabitType.values, contains(HabitType.oneTime));
    });

    test('should have correct index values', () {
      expect(HabitType.regular.index, 0);
      expect(HabitType.negative.index, 1);
      expect(HabitType.oneTime.index, 2);
    });
  });

  group('HabitTypeExtension Tests', () {
    test('should return correct names for all habit types', () {
      expect(HabitType.regular.name, 'Regular');
      expect(HabitType.negative.name, 'Negative');
      expect(HabitType.oneTime.name, 'One Time');
    });
  });

  group('HabitTypeStringExtension Tests', () {
    test('should convert valid string to habit type', () {
      expect('Regular'.toHabitType(), HabitType.regular);
      expect('Negative'.toHabitType(), HabitType.negative);
      expect('One Time'.toHabitType(), HabitType.oneTime);
    });

    test('should throw ArgumentError for invalid strings', () {
      expect(() => 'Invalid'.toHabitType(), throwsA(isA<ArgumentError>()));
      expect(
        () => 'regular'.toHabitType(), // lowercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'REGULAR'.toHabitType(), // uppercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => ''.toHabitType(), // empty string
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'one time'.toHabitType(), // different case
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'OneTime'.toHabitType(), // different format
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError with correct message', () {
      expect(
        () => 'Invalid'.toHabitType(),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'Unknown habit type: Invalid',
          ),
        ),
      );
    });
  });

  group('HabitType Round-Trip Tests', () {
    test('should maintain consistency in name to type conversion', () {
      for (final habitType in HabitType.values) {
        final name = habitType.name;
        final convertedBack = name.toHabitType();
        expect(convertedBack, habitType);
      }
    });

    test('should handle all enum values consistently', () {
      final testCases = [
        (HabitType.regular, 'Regular'),
        (HabitType.negative, 'Negative'),
        (HabitType.oneTime, 'One Time'),
      ];

      for (final (type, name) in testCases) {
        expect(type.name, name);
        expect(name.toHabitType(), type);
      }
    });
  });

  group('Business Logic Tests', () {
    test('should represent different habit categories correctly', () {
      // Regular habits are positive recurring habits
      expect(HabitType.regular.name, 'Regular');

      // Negative habits are habits to break/avoid
      expect(HabitType.negative.name, 'Negative');

      // One-time habits are goals to achieve once
      expect(HabitType.oneTime.name, 'One Time');
    });

    test('should work with switch statements for business logic', () {
      String getHabitDescription(HabitType type) {
        switch (type) {
          case HabitType.regular:
            return 'A habit to build and maintain regularly';
          case HabitType.negative:
            return 'A habit to break or reduce';
          case HabitType.oneTime:
            return 'A goal to achieve once';
        }
      }

      expect(
        getHabitDescription(HabitType.regular),
        'A habit to build and maintain regularly',
      );
      expect(
        getHabitDescription(HabitType.negative),
        'A habit to break or reduce',
      );
      expect(getHabitDescription(HabitType.oneTime), 'A goal to achieve once');
    });

    test('should work with habit tracking logic', () {
      bool shouldTrackStreak(HabitType type) {
        switch (type) {
          case HabitType.regular:
            return true; // Track consecutive days
          case HabitType.negative:
            return true; // Track days without the habit
          case HabitType.oneTime:
            return false; // Only track completion
        }
      }

      expect(shouldTrackStreak(HabitType.regular), true);
      expect(shouldTrackStreak(HabitType.negative), true);
      expect(shouldTrackStreak(HabitType.oneTime), false);
    });
  });

  group('Edge Cases', () {
    test('should handle enum comparison correctly', () {
      expect(HabitType.regular == HabitType.regular, true);
      expect(HabitType.regular == HabitType.negative, false);
      expect(HabitType.regular != HabitType.negative, true);
    });

    test('should work in collections', () {
      final habitTypes = <HabitType>[HabitType.regular, HabitType.negative];

      expect(habitTypes.contains(HabitType.regular), true);
      expect(habitTypes.contains(HabitType.oneTime), false);
      expect(habitTypes.length, 2);
    });

    test('should work in maps', () {
      final habitTypeMap = <HabitType, String>{
        HabitType.regular: 'Build this habit',
        HabitType.negative: 'Break this habit',
        HabitType.oneTime: 'Complete this goal',
      };

      expect(habitTypeMap[HabitType.regular], 'Build this habit');
      expect(habitTypeMap[HabitType.negative], 'Break this habit');
      expect(habitTypeMap[HabitType.oneTime], 'Complete this goal');
    });

    test('should work with filtering', () {
      final allTypes = HabitType.values;
      final recurringTypes = allTypes
          .where(
            (type) => type == HabitType.regular || type == HabitType.negative,
          )
          .toList();

      expect(recurringTypes.length, 2);
      expect(recurringTypes.contains(HabitType.regular), true);
      expect(recurringTypes.contains(HabitType.negative), true);
      expect(recurringTypes.contains(HabitType.oneTime), false);
    });
  });
}
