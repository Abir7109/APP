import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum LiveNotificationAction { allow, deny }

class LiveNotificationEvent {
  const LiveNotificationEvent({this.action, this.payload});

  final LiveNotificationAction? action;
  final String? payload;
}

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<LiveNotificationEvent> _events =
      StreamController<LiveNotificationEvent>.broadcast();

  bool _initialized = false;
  bool _permissionRequested = false;
  LiveNotificationEvent? _launchEvent;

  Stream<LiveNotificationEvent> get events => _events.stream;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const android = AndroidInitializationSettings('@drawable/ic_stat_heart');
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          'live_distance',
          actions: [
            DarwinNotificationAction.plain(
              'live_allow',
              'Allow',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              'live_deny',
              'Not now',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );
    final settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final event = LiveNotificationEvent(
            action: _actionFor(response.actionId),
            payload: response.payload,
          );
          if (event.action != null || event.payload != null) {
            _events.add(event);
          }
        },
      );

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final response = launch!.notificationResponse;
        if (response != null) {
          _launchEvent = LiveNotificationEvent(
            action: _actionFor(response.actionId),
            payload: response.payload,
          );
        }
      }
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  LiveNotificationEvent? takeLaunchEvent() {
    final event = _launchEvent;
    _launchEvent = null;
    return event;
  }

  Future<void> ensurePermission() async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (_) {
      // Notifications are a nice-to-have; the in-app prompt still works.
    }
  }

  Future<void> showLiveRequest({required String requesterName}) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();
    const androidDetails = AndroidNotificationDetails(
      'live_distance',
      'Live distance',
      channelDescription: 'A little ping when your person wants to see you.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_stat_heart',
      actions: [
        AndroidNotificationAction(
          'live_allow',
          'Allow',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'live_deny',
          'Not now',
          showsUserInterface: true,
        ),
      ],
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(categoryIdentifier: 'live_distance'),
      macOS: DarwinNotificationDetails(categoryIdentifier: 'live_distance'),
    );
    try {
      await _plugin.show(
        id: 4101,
        title: '$requesterName misses you',
        body: 'Tap Allow to share your location for a little while.',
        notificationDetails: details,
        payload: 'live',
      );
    } catch (_) {
      // The in-app prompt is the primary experience.
    }
  }

  Future<void> cancelLiveRequest() async {
    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.cancel(id: 4101);
    } catch (_) {
      // Nothing to cancel.
    }
  }

  LiveNotificationAction? _actionFor(String? actionId) {
    return switch (actionId) {
      'live_allow' => LiveNotificationAction.allow,
      'live_deny' => LiveNotificationAction.deny,
      _ => null,
    };
  }
}
