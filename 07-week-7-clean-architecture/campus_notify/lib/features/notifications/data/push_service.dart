import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/network/api_errors.dart';
import '../../../routes.dart';

class PushService {
  PushService({
    required this.dio,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const _topic = 'pengumuman-kampus';
  static const _channel = AndroidNotificationChannel(
    'pengumuman-kampus',
    'Pengumuman Kampus',
    description: 'Notifikasi pengumuman kampus',
    importance: Importance.high,
  );

  final Dio dio;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  void Function(String route)? _navigate;
  bool _initialized = false;

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<String?> getToken() => _messaging.getToken();

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }
    return settings.authorizationStatus;
  }

  Future<void> initialize({
    required void Function(String route) navigate,
  }) async {
    if (_initialized) return;
    _navigate = navigate;

    await requestPermission();
    await _initializeLocalNotifications();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForeground,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _navigateMessage,
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(_registerDevice(token));
    });

    final token = await _messaging.getToken();
    if (token != null) await _registerDevice(token);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _navigateMessage(initialMessage);
    _initialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) _navigate?.call(route);
      },
    );
  }

  Future<void> _registerDevice(String token) async {
    if (dio.options.baseUrl.isEmpty) {
      debugPrint('FCM device registration skipped: API_BASE_URL is not set.');
      return;
    }

    try {
      await dio.post<void>('/devices', data: {'token': token});
    } on DioException catch (error) {
      debugPrint('FCM device registration failed: ${apiErrorMessage(error)}');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman Kampus',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pengumuman-kampus',
          'Pengumuman Kampus',
          channelDescription: 'Notifikasi pengumuman kampus',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: routeFromMessage(message.data),
    );
  }

  void _navigateMessage(RemoteMessage message) {
    _navigate?.call(routeFromMessage(message.data));
  }

  Future<void> subscribeToAnnouncements() =>
      _messaging.subscribeToTopic(_topic);

  Future<void> unsubscribeFromAnnouncements() =>
      _messaging.unsubscribeFromTopic(_topic);

  void dispose() {
    unawaited(_tokenSubscription?.cancel());
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
