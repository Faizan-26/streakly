import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:streakly/services/notification_service.dart';

void main() {
  group('Notification System Integration Tests', () {
    testWidgets('should initialize notification system without errors', (
      WidgetTester tester,
    ) async {
      // Test that the notification system can be initialized
      expect(() async {
        await NotificationService.initialize();
        await NotificationManager.initialize();
        await NotificationManager.setupIsolateListener();
      }, returnsNormally);
    });

    test('should handle app lifecycle for notifications', () async {
      // Initialize the system
      await NotificationService.initialize();
      await NotificationManager.initialize();
      await NotificationManager.setupIsolateListener();

      // Test permissions request
      expect(() => NotificationService.requestPermissions(), returnsNormally);

      // Test cleanup
      expect(() => NotificationManager.dispose(), returnsNormally);
    });

    test(
      'should be ready for production use with awesome_notifications v0.10.1',
      () {
        // Verify that all required methods exist and work with the new API

        // Test data serialization compatibility
        final testActionData = {
          'id': 123,
          'channelKey': 'test_channel',
          'actionDate': DateTime.now().toIso8601String(),
          'buttonKeyPressed': 'test_button',
          'actionLifeCycle': 'Foreground',
          'payload': {'test_key': 'test_value'},
        };

        // This should work with the new awesome_notifications v0.10.1 API
        final action = ReceivedAction().fromMap(testActionData);
        expect(action.id, 123);
        expect(action.buttonKeyPressed, 'test_button');

        // Test serialization back (for sendPort communication)
        final serialized = action.toMap();
        expect(serialized, isA<Map<String, dynamic>>());
        expect(serialized['id'], 123);

        // Test that NotificationService can handle the action
        expect(
          () => NotificationService.handleNotificationAction(action),
          returnsNormally,
        );
      },
    );
  });
}
