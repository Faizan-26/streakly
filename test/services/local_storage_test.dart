import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streakly/services/local_storage.dart';
import 'dart:convert';

void main() {
  group('LocalStorage Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load string data', () async {
      const key = 'test_string';
      const value = 'Hello, World!';

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isA<String>());
    });

    test('should save and load integer data', () async {
      const key = 'test_int';
      const value = 42;

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isA<int>());
    });

    test('should save and load boolean data', () async {
      const key = 'test_bool';
      const value = true;

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isA<bool>());

      // Test false value
      await LocalStorage.saveData(key, false);
      final loadedFalseValue = await LocalStorage.loadData(key);
      expect(loadedFalseValue, false);
    });

    test('should save and load double data', () async {
      const key = 'test_double';
      const value = 3.14159;

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isA<double>());
    });

    test('should save and load string list data', () async {
      const key = 'test_string_list';
      const value = ['apple', 'banana', 'cherry'];

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isA<List<String>>());
    });

    test('should save and load complex object as JSON', () async {
      const key = 'test_object';
      final value = {
        'name': 'John Doe',
        'age': 30,
        'isActive': true,
        'scores': [95, 87, 92],
        'address': {
          'street': '123 Main St',
          'city': 'Anytown',
          'zipCode': '12345',
        },
      };

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);
      final decodedValue = json.decode(loadedValue as String);

      expect(decodedValue, value);
      expect(decodedValue['name'], 'John Doe');
      expect(decodedValue['age'], 30);
      expect(decodedValue['isActive'], true);
      expect(decodedValue['scores'], [95, 87, 92]);
      expect(decodedValue['address']['city'], 'Anytown');
    });

    test('should save and load list of objects', () async {
      const key = 'test_object_list';
      final value = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
        {'id': 3, 'name': 'Item 3'},
      ];

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);
      final decodedValue = json.decode(loadedValue as String);

      expect(decodedValue, value);
      expect(decodedValue.length, 3);
      expect(decodedValue[0]['name'], 'Item 1');
    });

    test('should remove data correctly', () async {
      const key = 'test_remove';
      const value = 'data to be removed';

      // Save data first
      await LocalStorage.saveData(key, value);
      final savedValue = await LocalStorage.loadData(key);
      expect(savedValue, value);

      // Remove data
      await LocalStorage.removeData(key);
      final removedValue = await LocalStorage.loadData(key);
      expect(removedValue, isNull);
    });

    test('should return null for non-existent key', () async {
      const key = 'non_existent_key';
      final value = await LocalStorage.loadData(key);
      expect(value, isNull);
    });

    test('should handle empty string', () async {
      const key = 'empty_string';
      const value = '';

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, '');
    });

    test('should handle zero values', () async {
      // Test zero integer
      const intKey = 'zero_int';
      const intValue = 0;
      await LocalStorage.saveData(intKey, intValue);
      final loadedIntValue = await LocalStorage.loadData(intKey);
      expect(loadedIntValue, 0);

      // Test zero double
      const doubleKey = 'zero_double';
      const doubleValue = 0.0;
      await LocalStorage.saveData(doubleKey, doubleValue);
      final loadedDoubleValue = await LocalStorage.loadData(doubleKey);
      expect(loadedDoubleValue, 0.0);
    });

    test('should handle empty list', () async {
      const key = 'empty_list';
      const value = <String>[];

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect(loadedValue, isEmpty);
    });

    test('should handle special characters in strings', () async {
      const key = 'special_chars';
      const value = 'Hello! @#\$%^&*()_+-={}[]|\\:";\'<>?,./ 你好 🎉';

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
    });

    test('should handle large data', () async {
      const key = 'large_data';
      final value = 'x' * 10000; // 10,000 character string

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);

      expect(loadedValue, value);
      expect((loadedValue as String).length, 10000);
    });

    test('should handle nested complex objects', () async {
      const key = 'nested_object';
      final value = {
        'level1': {
          'level2': {
            'level3': {
              'data': 'deep nested value',
              'numbers': [1, 2, 3],
              'nested_array': [
                {'id': 1, 'active': true},
                {'id': 2, 'active': false},
              ],
            },
          },
        },
      };

      await LocalStorage.saveData(key, value);
      final loadedValue = await LocalStorage.loadData(key);
      final decodedValue = json.decode(loadedValue as String);

      expect(
        decodedValue['level1']['level2']['level3']['data'],
        'deep nested value',
      );
      expect(decodedValue['level1']['level2']['level3']['numbers'], [1, 2, 3]);
      expect(
        decodedValue['level1']['level2']['level3']['nested_array'][0]['active'],
        true,
      );
    });

    test('should overwrite existing data', () async {
      const key = 'overwrite_test';
      const firstValue = 'first value';
      const secondValue = 'second value';

      // Save first value
      await LocalStorage.saveData(key, firstValue);
      final firstLoadedValue = await LocalStorage.loadData(key);
      expect(firstLoadedValue, firstValue);

      // Overwrite with second value
      await LocalStorage.saveData(key, secondValue);
      final secondLoadedValue = await LocalStorage.loadData(key);
      expect(secondLoadedValue, secondValue);
      expect(secondLoadedValue, isNot(firstValue));
    });

    test('should handle multiple keys independently', () async {
      const key1 = 'key1';
      const key2 = 'key2';
      const key3 = 'key3';
      const value1 = 'value1';
      const value2 = 42;
      const value3 = true;

      await LocalStorage.saveData(key1, value1);
      await LocalStorage.saveData(key2, value2);
      await LocalStorage.saveData(key3, value3);

      final loadedValue1 = await LocalStorage.loadData(key1);
      final loadedValue2 = await LocalStorage.loadData(key2);
      final loadedValue3 = await LocalStorage.loadData(key3);

      expect(loadedValue1, value1);
      expect(loadedValue2, value2);
      expect(loadedValue3, value3);

      // Remove one key and verify others remain
      await LocalStorage.removeData(key2);
      final removedValue = await LocalStorage.loadData(key2);
      final stillExistingValue1 = await LocalStorage.loadData(key1);
      final stillExistingValue3 = await LocalStorage.loadData(key3);

      expect(removedValue, isNull);
      expect(stillExistingValue1, value1);
      expect(stillExistingValue3, value3);
    });
  });
}
