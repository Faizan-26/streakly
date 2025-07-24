import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/types/habit_frequency_types.dart';

void main() {
  group('FrequencyType Tests', () {
    test('should have correct enum values', () {
      expect(FrequencyType.values.length, 5);
      expect(FrequencyType.values, contains(FrequencyType.daily));
      expect(FrequencyType.values, contains(FrequencyType.weekly));
      expect(FrequencyType.values, contains(FrequencyType.monthly));
      expect(FrequencyType.values, contains(FrequencyType.yearly));
      expect(FrequencyType.values, contains(FrequencyType.longTerm));
    });

    test('should have correct index values', () {
      expect(FrequencyType.daily.index, 0);
      expect(FrequencyType.weekly.index, 1);
      expect(FrequencyType.monthly.index, 2);
      expect(FrequencyType.yearly.index, 3);
      expect(FrequencyType.longTerm.index, 4);
    });
  });

  group('FrequencyTypeExtension Tests', () {
    test('should return correct names for all frequency types', () {
      expect(FrequencyType.daily.name, 'Daily');
      expect(FrequencyType.weekly.name, 'Weekly');
      expect(FrequencyType.monthly.name, 'Monthly');
      expect(FrequencyType.yearly.name, 'Yearly');
      expect(FrequencyType.longTerm.name, 'Long Term');
    });
  });

  group('FrequencyTypeStringExtension Tests', () {
    test('should convert valid string to frequency type', () {
      expect('Daily'.toFrequencyType(), FrequencyType.daily);
      expect('Weekly'.toFrequencyType(), FrequencyType.weekly);
      expect('Monthly'.toFrequencyType(), FrequencyType.monthly);
      expect('Yearly'.toFrequencyType(), FrequencyType.yearly);
      expect('Long Term'.toFrequencyType(), FrequencyType.longTerm);
    });

    test('should throw ArgumentError for invalid strings', () {
      expect(() => 'Invalid'.toFrequencyType(), throwsA(isA<ArgumentError>()));
      expect(
        () => 'daily'.toFrequencyType(), // lowercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'DAILY'.toFrequencyType(), // uppercase
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => ''.toFrequencyType(), // empty string
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => 'Long term'.toFrequencyType(), // different case
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError with correct message', () {
      expect(
        () => 'Invalid'.toFrequencyType(),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'Unknown frequency type: Invalid',
          ),
        ),
      );
    });
  });

  group('FrequencyType Round-Trip Tests', () {
    test('should maintain consistency in name to type conversion', () {
      for (final frequencyType in FrequencyType.values) {
        final name = frequencyType.name;
        final convertedBack = name.toFrequencyType();
        expect(convertedBack, frequencyType);
      }
    });

    test('should handle all enum values consistently', () {
      final testCases = [
        (FrequencyType.daily, 'Daily'),
        (FrequencyType.weekly, 'Weekly'),
        (FrequencyType.monthly, 'Monthly'),
        (FrequencyType.yearly, 'Yearly'),
        (FrequencyType.longTerm, 'Long Term'),
      ];

      for (final (type, name) in testCases) {
        expect(type.name, name);
        expect(name.toFrequencyType(), type);
      }
    });
  });

  group('Edge Cases', () {
    test('should handle enum comparison correctly', () {
      expect(FrequencyType.daily == FrequencyType.daily, true);
      expect(FrequencyType.daily == FrequencyType.weekly, false);
      expect(FrequencyType.daily != FrequencyType.weekly, true);
    });

    test('should work with switch statements', () {
      String getDescription(FrequencyType type) {
        switch (type) {
          case FrequencyType.daily:
            return 'Every day';
          case FrequencyType.weekly:
            return 'Every week';
          case FrequencyType.monthly:
            return 'Every month';
          case FrequencyType.yearly:
            return 'Every year';
          case FrequencyType.longTerm:
            return 'Long term goal';
        }
      }

      expect(getDescription(FrequencyType.daily), 'Every day');
      expect(getDescription(FrequencyType.weekly), 'Every week');
      expect(getDescription(FrequencyType.monthly), 'Every month');
      expect(getDescription(FrequencyType.yearly), 'Every year');
      expect(getDescription(FrequencyType.longTerm), 'Long term goal');
    });

    test('should work in collections', () {
      final frequencies = <FrequencyType>[
        FrequencyType.daily,
        FrequencyType.weekly,
        FrequencyType.monthly,
      ];

      expect(frequencies.contains(FrequencyType.daily), true);
      expect(frequencies.contains(FrequencyType.yearly), false);
      expect(frequencies.length, 3);
    });

    test('should work in maps', () {
      final frequencyMap = <FrequencyType, String>{
        FrequencyType.daily: 'Daily habit',
        FrequencyType.weekly: 'Weekly habit',
      };

      expect(frequencyMap[FrequencyType.daily], 'Daily habit');
      expect(frequencyMap[FrequencyType.weekly], 'Weekly habit');
      expect(frequencyMap[FrequencyType.monthly], isNull);
    });
  });
}
