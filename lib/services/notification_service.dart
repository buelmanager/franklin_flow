// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../core/utils/app_logger.dart';
import 'local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// NotificationService - 로컬 알림 서비스
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 아침/저녁 알림 스케줄링 및 관리
///
/// 사용법:
///   await NotificationService.init();
///   final service = NotificationService();
///   await service.scheduleMorningNotification(TimeOfDay(hour: 6, minute: 0));
/// ═══════════════════════════════════════════════════════════════════════════

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 알림 ID 상수
  static const int _morningNotificationId = 1;
  static const int _eveningNotificationId = 2;

  // 알림 채널 설정
  static const String _channelId = 'franklin_flow_reminders';
  static const String _channelName = 'Franklin Flow 알림';
  static const String _channelDescription = '아침/저녁 루틴 알림';

  // ─────────────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────────────

  /// 알림 서비스 초기화
  static Future<void> init() async {
    try {
      AppLogger.i(
        'Initializing NotificationService...',
        tag: 'NotificationService',
      );

      // 타임존 초기화
      tz_data.initializeTimeZones();

      final service = NotificationService();
      await service._initializeNotifications();

      AppLogger.i(
        'NotificationService initialized successfully',
        tag: 'NotificationService',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'NotificationService initialization failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 알림 플러그인 초기화
  Future<void> _initializeNotifications() async {
    if (_isInitialized) return;

    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 초기화 설정
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 초기화
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
    AppLogger.d('Notification plugin initialized', tag: 'NotificationService');
  }

  /// 알림 탭 핸들러
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.i(
      'Notification tapped: ${response.payload}',
      tag: 'NotificationService',
    );
    // TODO: 알림 탭 시 특정 화면으로 이동
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 권한 요청
  // ─────────────────────────────────────────────────────────────────────────

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    try {
      // iOS 권한 요청
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        AppLogger.d(
          'iOS notification permission: $granted',
          tag: 'NotificationService',
        );
        return granted ?? false;
      }

      // Android 권한 요청 (Android 13+)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        AppLogger.d(
          'Android notification permission: $granted',
          tag: 'NotificationService',
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      AppLogger.e(
        'Failed to request notification permission',
        tag: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 알림
  // ─────────────────────────────────────────────────────────────────────────

  /// 아침 알림 스케줄링
  Future<void> scheduleMorningNotification(TimeOfDay time) async {
    try {
      await _initializeNotifications();

      final scheduledTime = _nextInstanceOfTime(time);

      await _notifications.zonedSchedule(
        _morningNotificationId,
        '☀️ Good Morning!',
        '오늘 하루를 어떻게 보낼지 계획해보세요',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
        payload: 'morning',
      );

      AppLogger.i(
        'Morning notification scheduled at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        tag: 'NotificationService',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule morning notification',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 아침 알림 취소
  Future<void> cancelMorningNotification() async {
    await _notifications.cancel(_morningNotificationId);
    AppLogger.i('Morning notification cancelled', tag: 'NotificationService');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 알림
  // ─────────────────────────────────────────────────────────────────────────

  /// 저녁 알림 스케줄링
  Future<void> scheduleEveningNotification(TimeOfDay time) async {
    try {
      await _initializeNotifications();

      final scheduledTime = _nextInstanceOfTime(time);

      await _notifications.zonedSchedule(
        _eveningNotificationId,
        '🌙 Good Evening!',
        '오늘 하루를 돌아보며 성찰해보세요',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
        payload: 'evening',
      );

      AppLogger.i(
        'Evening notification scheduled at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        tag: 'NotificationService',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule evening notification',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 저녁 알림 취소
  Future<void> cancelEveningNotification() async {
    await _notifications.cancel(_eveningNotificationId);
    AppLogger.i('Evening notification cancelled', tag: 'NotificationService');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 설정 기반 알림 관리
  // ─────────────────────────────────────────────────────────────────────────

  /// 저장된 설정으로 알림 스케줄링
  Future<void> scheduleFromSettings() async {
    try {
      final storage = LocalStorageService();

      // 아침 알림
      final morningEnabled =
          storage.getSetting<bool>('morningAlarmEnabled') ?? false;
      if (morningEnabled) {
        final hour = storage.getSetting<int>('morningReminderHour') ?? 6;
        final minute = storage.getSetting<int>('morningReminderMinute') ?? 0;
        await scheduleMorningNotification(
          TimeOfDay(hour: hour, minute: minute),
        );
      } else {
        await cancelMorningNotification();
      }

      // 저녁 알림
      final eveningEnabled =
          storage.getSetting<bool>('eveningAlarmEnabled') ?? false;
      if (eveningEnabled) {
        final hour = storage.getSetting<int>('eveningReminderHour') ?? 21;
        final minute = storage.getSetting<int>('eveningReminderMinute') ?? 0;
        await scheduleEveningNotification(
          TimeOfDay(hour: hour, minute: minute),
        );
      } else {
        await cancelEveningNotification();
      }

      AppLogger.i(
        'Notifications scheduled from settings',
        tag: 'NotificationService',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule notifications from settings',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    AppLogger.i('All notifications cancelled', tag: 'NotificationService');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  /// 다음 해당 시간 계산
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 이미 지난 시간이면 다음 날로
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 대기 중인 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 테스트 알림 발송
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    await _initializeNotifications();

    await _notifications.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    AppLogger.d('Test notification shown: $title', tag: 'NotificationService');
  }
}
