import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/fcm_service.dart';
import '../utils/app_logger.dart';

enum NotificationType {
  unknown('');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String? type) {
    return NotificationType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => NotificationType.unknown,
    );
  }
}

abstract class NotificationNavigator {
  /// Handles a notification that was tapped while the app was in the
  /// background or foreground.
  static void handle(RemoteMessage message) {
    final data = message.data;
    final type = NotificationType.fromString(data['type'] as String?);

    AppLogger.info(
      'Notification tapped — type: ${type.value}, data: $data',
      tag: 'NotificationNavigator',
    );

    switch (type) {
      // Add cases here as your project grows:
      //
      // case NotificationType.orderDetails:
      //   final id = data['id'] as String?;
      //   if (id == null) break;
      //   NavigationService.push(AppRoute.orderDetailsScreen, arguments: {'id': id});

      case NotificationType.unknown:
        AppLogger.info(
          'Unhandled notification type: ${data['type']}',
          tag: 'NotificationNavigator',
        );
    }
  }

  /// Handles a notification that launched the app from a **terminated** state.
  ///
  /// Must be called after the first frame so the navigator is ready.
  /// Reads the stored message from [FcmService] and consumes it to prevent
  /// handling it twice.
  static void handlePending() {
    final pending = FcmService().pendingInitialMessage;
    if (pending == null) {
      return;
    }
    FcmService().consumePendingMessage();
    AppLogger.info(
      'Handling terminated-state notification: ${pending.messageId}',
      tag: 'NotificationNavigator',
    );
    handle(pending);
  }
}
