import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/daily_mystery_notification_service.dart';

final dailyMysteryNotificationProvider = Provider<DailyMysteryNotificationService>((ref) {
  return DailyMysteryNotificationService();
});

final notificationInitializedProvider = FutureProvider<void>((ref) async {
  await DailyMysteryNotificationService.initialize();
});

final notificationsScheduledProvider = FutureProvider<void>((ref) async {
  await ref.watch(notificationInitializedProvider.future);
  await DailyMysteryNotificationService.scheduleDailyNotifications();
});
