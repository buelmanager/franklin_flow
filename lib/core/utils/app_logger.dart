// lib/core/utils/app_logger.dart

import 'package:flutter/foundation.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 로그 유틸리티
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   AppLogger.d('디버그 메시지');
///   AppLogger.i('정보 메시지');
///   AppLogger.w('경고 메시지');
///   AppLogger.e('에러 메시지', error: e, stackTrace: st);
///
/// 특정 태그 사용:
///   AppLogger.d('메시지', tag: 'HomeScreen');
///
/// 출력 예시:
///   [DEBUG] [HomeScreen] 메시지
///   [ERROR] [TaskService] 에러 발생 | Error: ... | StackTrace: ...
/// ═══════════════════════════════════════════════════════════════════════════

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._(); // 인스턴스화 방지

  /// 로그 출력 여부 (릴리즈 모드에서 비활성화)
  static bool _enabled = kDebugMode;

  /// 최소 로그 레벨
  static LogLevel _minLevel = LogLevel.debug;

  /// 기본 태그
  static const String _defaultTag = 'FranklinFlow';

  // ─────────────────────────────────────────────────────────────────────────
  // 설정 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// 로그 활성화/비활성화
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 최소 로그 레벨 설정
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 로그 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// Debug 로그 (개발 중 상세 정보)
  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info 로그 (일반 정보)
  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning 로그 (경고, 주의 필요)
  static void w(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  /// Error 로그 (에러, 예외)
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 특수 로그 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// API 요청 로그
  static void api(
    String method,
    String endpoint, {
    Map<String, dynamic>? params,
  }) {
    if (!_enabled) return;
    final paramStr = params != null ? ' | Params: $params' : '';
    _log(LogLevel.info, '[$method] $endpoint$paramStr', tag: 'API');
  }

  /// API 응답 로그
  static void apiResponse(String endpoint, int statusCode, {dynamic data}) {
    if (!_enabled) return;
    final dataStr = data != null
        ? ' | Data: ${_truncate(data.toString(), 200)}'
        : '';
    _log(LogLevel.info, '[$statusCode] $endpoint$dataStr', tag: 'API');
  }

  /// UI 이벤트 로그
  static void ui(String event, {String? screen, Map<String, dynamic>? params}) {
    if (!_enabled) return;
    final screenStr = screen != null ? '[$screen] ' : '';
    final paramStr = params != null ? ' | $params' : '';
    _log(LogLevel.debug, '$screenStr$event$paramStr', tag: 'UI');
  }

  /// 네비게이션 로그
  static void nav(String from, String to) {
    if (!_enabled) return;
    _log(LogLevel.debug, '$from → $to', tag: 'NAV');
  }

  /// 성능 측정 로그
  static void perf(String operation, Duration duration) {
    if (!_enabled) return;
    _log(
      LogLevel.info,
      '$operation completed in ${duration.inMilliseconds}ms',
      tag: 'PERF',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 성능 측정 헬퍼
  // ─────────────────────────────────────────────────────────────────────────

  /// 작업 시간 측정
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await task();
      stopwatch.stop();
      perf(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      perf('$operation (failed)', stopwatch.elapsed);
      rethrow;
    }
  }

  /// 동기 작업 시간 측정
  static T measureSync<T>(String operation, T Function() task) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = task();
      stopwatch.stop();
      perf(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      perf('$operation (failed)', stopwatch.elapsed);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 내부 메서드
  // ─────────────────────────────────────────────────────────────────────────

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (level.index < _minLevel.index) return;

    final levelStr = _getLevelString(level);
    final tagStr = tag ?? _defaultTag;
    final timestamp = _getTimestamp();

    final buffer = StringBuffer();
    buffer.write('$timestamp [$levelStr] [$tagStr] $message');

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }

    // 컬러 출력 (터미널에서)
    final output = buffer.toString();
    switch (level) {
      case LogLevel.debug:
        debugPrint('\x1B[37m$output\x1B[0m'); // 회색
        break;
      case LogLevel.info:
        debugPrint('\x1B[34m$output\x1B[0m'); // 파랑
        break;
      case LogLevel.warning:
        debugPrint('\x1B[33m$output\x1B[0m'); // 노랑
        break;
      case LogLevel.error:
        debugPrint('\x1B[31m$output\x1B[0m'); // 빨강
        break;
    }
  }

  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
