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

  static const String _tag = 'NotificationService';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 알림 ID 상수
  static const int _morningNotificationId = 1;
  static const int _eveningNotificationId = 2;
  static const int _testNotificationId = 99;

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
      AppLogger.i('Initializing NotificationService...', tag: _tag);

      // 타임존 초기화
      tz_data.initializeTimeZones();

      // 한국 시간대 설정
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      final service = NotificationService();
      await service._initializeNotifications();

      AppLogger.i('NotificationService initialized successfully', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.e(
        'NotificationService initialization failed',
        tag: _tag,
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
      // ✨ Foreground에서도 알림 표시
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
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
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Android 알림 채널 생성
    await _createNotificationChannel();

    _isInitialized = true;
    AppLogger.d('Notification plugin initialized', tag: _tag);
  }

  /// Android 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    AppLogger.d('Android notification channel created', tag: _tag);
  }

  /// 알림 탭 핸들러
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.i('Notification tapped: ${response.payload}', tag: _tag);
    // TODO: 알림 탭 시 특정 화면으로 이동
  }

  /// 백그라운드 알림 탭 핸들러
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // 백그라운드에서 알림 탭 처리
    debugPrint('Background notification tapped: ${response.payload}');
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
        AppLogger.d('iOS notification permission: $granted', tag: _tag);
        return granted ?? false;
      }

      // Android 권한 요청 (Android 13+)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Android 13+ 알림 권한
        final granted = await androidPlugin.requestNotificationsPermission();
        AppLogger.d('Android notification permission: $granted', tag: _tag);

        // 정확한 알림 권한도 요청
        await androidPlugin.requestExactAlarmsPermission();

        return granted ?? false;
      }

      return true;
    } catch (e) {
      AppLogger.e(
        'Failed to request notification permission',
        tag: _tag,
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
        _getNotificationDetails(isHighPriority: true),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'morning',
      );

      AppLogger.i(
        'Morning notification scheduled at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule morning notification',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 아침 알림 취소
  Future<void> cancelMorningNotification() async {
    await _notifications.cancel(_morningNotificationId);
    AppLogger.i('Morning notification cancelled', tag: _tag);
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
        _getNotificationDetails(isHighPriority: true),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'evening',
      );

      AppLogger.i(
        'Evening notification scheduled at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule evening notification',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 저녁 알림 취소
  Future<void> cancelEveningNotification() async {
    await _notifications.cancel(_eveningNotificationId);
    AppLogger.i('Evening notification cancelled', tag: _tag);
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

      AppLogger.i('Notifications scheduled from settings', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to schedule notifications from settings',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    AppLogger.i('All notifications cancelled', tag: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 테스트 알림
  // ─────────────────────────────────────────────────────────────────────────

  /// 테스트 알림 발송 (즉시)
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    await _initializeNotifications();

    // 권한 확인
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      AppLogger.w('Notification permission not granted', tag: _tag);
    }

    await _notifications.show(
      _testNotificationId,
      title,
      body,
      _getNotificationDetails(isHighPriority: true),
      payload: 'test',
    );

    AppLogger.d('Test notification shown: $title', tag: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  /// 알림 상세 설정 생성
  NotificationDetails _getNotificationDetails({bool isHighPriority = false}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: isHighPriority ? Importance.max : Importance.high,
        priority: isHighPriority ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        fullScreenIntent: false,
        autoCancel: true,
        showWhen: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        // ✨ 앱이 foreground일 때도 알림 표시
        presentBanner: true,
      ),
    );
  }

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

  /// 알림 권한 상태 확인
  Future<bool> checkPermissionStatus() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final areEnabled = await androidPlugin.areNotificationsEnabled();
        return areEnabled ?? false;
      }

      return true; // iOS는 기본적으로 true 반환
    } catch (e) {
      AppLogger.e('Failed to check permission status', tag: _tag, error: e);
      return false;
    }
  }
}
