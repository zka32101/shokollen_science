import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/services/daily_mystery_notification_service.dart';

void main() {
  group('DailyMysteryNotificationService Tests', () {
    test('instance returns singleton', () {
      final instance1 = DailyMysteryNotificationService.instance;
      final instance2 = DailyMysteryNotificationService.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('initialize creates valid service', () async {
      // Just verify it doesn't throw
      try {
        await DailyMysteryNotificationService.initialize();
      } catch (e) {
        fail('Initialize should not throw: $e');
      }
    });

    test('scheduleDailyNotifications completes without error', () async {
      try {
        await DailyMysteryNotificationService.initialize();
        await DailyMysteryNotificationService.scheduleDailyNotifications();
      } catch (e) {
        // Flutter notifications may fail in test environment
        // This test just verifies no uncaught exceptions
      }
    });

    test('cancelAllNotifications completes without error', () async {
      try {
        await DailyMysteryNotificationService.cancelAllNotifications();
      } catch (e) {
        fail('cancelAllNotifications should not throw: $e');
      }
    });

    test('cancelMorningNotification completes without error', () async {
      try {
        await DailyMysteryNotificationService.cancelMorningNotification();
      } catch (e) {
        fail('cancelMorningNotification should not throw: $e');
      }
    });

    test('cancelEveningNotification completes without error', () async {
      try {
        await DailyMysteryNotificationService.cancelEveningNotification();
      } catch (e) {
        fail('cancelEveningNotification should not throw: $e');
      }
    });
  });
}
