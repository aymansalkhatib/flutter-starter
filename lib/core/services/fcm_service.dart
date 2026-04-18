import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/hive/storage_keys.dart';
import '../storage/hive/hive_boxes.dart';
import '../utils/app_logger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background message handler — must be a top-level function
// ─────────────────────────────────────────────────────────────────────────────

/// Handles FCM messages when the app is in the background or terminated.
///
/// NOTE: Pass [DefaultFirebaseOptions.currentPlatform] if you use
/// `flutterfire configure`, otherwise Firebase reads from
/// google-services.json / GoogleService-Info.plist automatically.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info(
    'Background message: ${message.messageId}',
    tag: 'FcmService',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FcmService
// ─────────────────────────────────────────────────────────────────────────────

/// Manages Firebase Cloud Messaging (FCM) for the application.
///
/// Handles:
/// - FCM token management (fetch, refresh, persist, delete)
/// - Topic subscriptions/unsubscriptions
/// - Foreground, background & terminated message streams
/// - Notification permission requests
///
/// Usage:
/// ```dart
/// await FcmService().initialize();
///
/// // Listen to foreground messages
/// FcmService().onMessage.listen((message) {
///   showOverlaySnackbar(message.notification?.title ?? '');
/// });
///
/// // Subscribe to a topic
/// await FcmService().subscribeToTopic('news');
/// ```
class FcmService {
  factory FcmService() => _instance;
  FcmService._internal();
  static final FcmService _instance = FcmService._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool _initialized = false;
  String? _fcmToken;

  /// Stores a notification message received when the app was terminated.
  /// Consumed once by [NotificationNavigator.handlePending] after the
  /// navigator is ready.
  RemoteMessage? _pendingInitialMessage;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();

  StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  bool get isInitialized => _initialized;

  /// The current FCM token. Available after [initialize].
  String? get fcmToken => _fcmToken;

  /// The notification message that launched the app from a terminated state.
  ///
  /// Call [consumePendingMessage] after reading to prevent handling it twice.
  RemoteMessage? get pendingInitialMessage => _pendingInitialMessage;

  /// Clears [pendingInitialMessage] after it has been handled.
  void consumePendingMessage() => _pendingInitialMessage = null;

  /// Stream of messages received while the app is in the foreground.
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  /// Stream of messages that caused the app to open from background/terminated.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Initializes FCM and sets up all messaging listeners.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) {
      return;
    }

    await Firebase.initializeApp(options: options);
    await _setupMessaging();

    _initialized = true;
    AppLogger.info('FcmService initialized', tag: 'FcmService');
  }

  Future<void> _setupMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundMessageHandler);

    await _requestPermission();
    await _fetchAndSaveToken();

    // Save subscription to allow cancellation in dispose()
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      AppLogger.info(
        'Foreground message: ${message.messageId}',
        tag: 'FcmService',
      );
      _onMessageController.add(message);
    });

    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppLogger.info(
        'Message opened app: ${message.messageId}',
        tag: 'FcmService',
      );
      _onMessageOpenedAppController.add(message);
    });

    // App launched from terminated state via notification tap.
    // Stored instead of emitted — the navigator isn't ready yet at this point.
    // Call FcmService().pendingInitialMessage after the first frame to handle it.
    _pendingInitialMessage = await _messaging.getInitialMessage();
    if (_pendingInitialMessage != null) {
      AppLogger.info(
        'Terminated launch message stored: ${_pendingInitialMessage!.messageId}',
        tag: 'FcmService',
      );
    }

    // iOS/web only — controls how foreground notifications are presented.
    // On Android, foreground display is handled via flutter_local_notifications.
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ─── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission();
    AppLogger.info(
      'Notification permission: ${settings.authorizationStatus}',
      tag: 'FcmService',
    );
  }

  /// Returns the current notification permission status.
  Future<AuthorizationStatus> getPermissionStatus() async {
    _ensureInitialized();
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  // ─── Token ─────────────────────────────────────────────────────────────────

  /// Returns the FCM token. Returns the cached value if available,
  /// otherwise reads from local storage.
  Future<String?> getToken() async {
    _ensureInitialized();
    if (_fcmToken != null) {
      return _fcmToken;
    }
    return HiveBoxes.appBox.get(StorageKeys.fcmToken) as String?;
  }

  /// Deletes the FCM token from Firebase and local storage.
  Future<void> deleteToken() async {
    _ensureInitialized();
    try {
      await _messaging.deleteToken();
      await _clearToken();
      AppLogger.info('FCM Token deleted', tag: 'FcmService');
    } catch (e) {
      AppLogger.info('Failed to delete FCM token: $e', tag: 'FcmService');
    }
  }

  Future<void> _fetchAndSaveToken() async {
    try {
      // On iOS, APNS token must be available before FCM can issue a token.
      // If not ready yet, skip — the token will arrive via onTokenRefresh.
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          AppLogger.info(
            'APNS token not ready, skipping FCM token fetch',
            tag: 'FcmService',
          );
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      AppLogger.info('Failed to get FCM token: $e', tag: 'FcmService');
    }
  }

  Future<void> _onTokenRefresh(String newToken) async {
    await _saveToken(newToken);
    AppLogger.info('FCM Token refreshed: $newToken', tag: 'FcmService');
  }

  Future<void> _saveToken(String token) async {
    _fcmToken = token;
    await HiveBoxes.appBox.put(StorageKeys.fcmToken, token);
    AppLogger.info('FCM Token saved: $token', tag: 'FcmService');
  }

  Future<void> _clearToken() async {
    _fcmToken = null;
    await HiveBoxes.appBox.delete(StorageKeys.fcmToken);
  }

  // ─── Topics ────────────────────────────────────────────────────────────────

  /// Subscribes to a notification topic.
  ///
  /// Example: `subscribeToTopic('news')`
  Future<void> subscribeToTopic(String topic) async {
    _ensureInitialized();
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic', tag: 'FcmService');
    } catch (e) {
      AppLogger.info(
        'Failed to subscribe to $topic: $e',
        tag: 'FcmService',
      );
    }
  }

  /// Unsubscribes from a notification topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    _ensureInitialized();
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info(
        'Unsubscribed from topic: $topic',
        tag: 'FcmService',
      );
    } catch (e) {
      AppLogger.info(
        'Failed to unsubscribe from $topic: $e',
        tag: 'FcmService',
      );
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Cancels all listeners and resets the service so [initialize] can be
  /// called again.
  ///
  /// Typical use: user logout — stop receiving notifications, then
  /// re-initialize on the next login.
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();

    await _onMessageController.close();
    await _onMessageOpenedAppController.close();

    // Recreate controllers so the streams are usable after re-initialization.
    _onMessageController = StreamController<RemoteMessage>.broadcast();
    _onMessageOpenedAppController = StreamController<RemoteMessage>.broadcast();

    _initialized = false;
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('FcmService not initialized. Call initialize() first.');
    }
  }
}
