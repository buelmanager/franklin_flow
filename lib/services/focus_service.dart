// lib/services/focus_service.dart

import '../core/utils/app_logger.dart';
import '../shared/models/focus_session_model.dart';
import '../shared/models/task_model.dart';
import 'local_storage_service.dart';
import 'task_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FocusService - Focus Session 관리 비즈니스 로직
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Task 기반 집중 세션 관리
/// - 세션 시작/일시정지/재개/완료
/// - Task 진행도 자동 업데이트
/// - 히스토리 관리
/// ═══════════════════════════════════════════════════════════════════════════

class FocusService {
  FocusService._();
  static final FocusService _instance = FocusService._();
  factory FocusService() => _instance;

  final _storage = LocalStorageService();
  final _taskService = TaskService();

  /// 현재 활성 세션
  FocusSession? _currentSession;

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  /// 현재 세션
  FocusSession? get currentSession => _currentSession;

  /// 현재 세션이 있는지
  bool get hasActiveSession => _currentSession != null;

  /// 오늘 완료한 세션 개수
  int getTodayCompletedSessions() {
    final today = DateTime.now();
    final sessions = _storage.getFocusSessions();

    return sessions.where((s) {
      return s.isCompleted &&
          s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day;
    }).length;
  }

  /// 오늘 총 집중 시간 (분)
  int getTodayFocusMinutes() {
    final today = DateTime.now();
    final sessions = _storage.getFocusSessions();

    return sessions
        .where(
          (s) =>
              s.startTime.year == today.year &&
              s.startTime.month == today.month &&
              s.startTime.day == today.day,
        )
        .fold(0, (sum, s) => sum + s.actualMinutes);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Focus Session 시작
  Future<FocusSession> startSession(Task task) async {
    // 기존 세션이 있으면 자동 완료
    if (_currentSession != null) {
      await completeSession();
    }

    final newId = _storage.getNextFocusSessionId();

    _currentSession = FocusSession(
      id: newId,
      taskId: task.id,
      taskTitle: task.title,
      startTime: DateTime.now(),
      targetMinutes: task.timeInMinutes,
      status: 'active',
    );

    await _storage.saveFocusSession(_currentSession!);

    // Task를 in-progress로 변경
    if (task.isPending) {
      await _taskService.changeTaskStatus(task.id, 'in-progress');
    }

    AppLogger.i(
      'Focus session started: ${task.title} (${task.timeInMinutes}분)',
      tag: 'FocusService',
    );

    return _currentSession!;
  }

  /// 일시정지
  Future<void> pauseSession() async {
    if (_currentSession == null || !_currentSession!.isActive) return;

    _currentSession = _currentSession!.copyWith(
      status: 'paused',
      pausedAt: DateTime.now(),
    );

    await _storage.saveFocusSession(_currentSession!);

    AppLogger.d('Session paused', tag: 'FocusService');
  }

  /// 재개
  Future<void> resumeSession() async {
    if (_currentSession == null || !_currentSession!.isPaused) return;

    // 일시정지된 시간 계산
    if (_currentSession!.pausedAt != null) {
      final pausedDuration = DateTime.now().difference(
        _currentSession!.pausedAt!,
      );
      final pausedMinutes = pausedDuration.inMinutes;

      _currentSession = _currentSession!.copyWith(
        status: 'active',
        totalPausedMinutes: _currentSession!.totalPausedMinutes + pausedMinutes,
        pausedAt: null,
      );
    } else {
      _currentSession = _currentSession!.copyWith(
        status: 'active',
        pausedAt: null,
      );
    }

    await _storage.saveFocusSession(_currentSession!);

    AppLogger.d('Session resumed', tag: 'FocusService');
  }

  /// 세션 완료
  Future<void> completeSession() async {
    if (_currentSession == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentSession!.startTime);
    final actualMinutes =
        (elapsed.inMinutes - _currentSession!.totalPausedMinutes).clamp(
          0,
          _currentSession!.targetMinutes * 2,
        ); // 최대 목표의 2배

    _currentSession = _currentSession!.copyWith(
      status: 'completed',
      endTime: now,
      actualMinutes: actualMinutes,
    );

    await _storage.saveFocusSession(_currentSession!);

    // Task 진행도 업데이트
    await _updateTaskProgress(_currentSession!);

    AppLogger.i('Session completed: ${actualMinutes}분 집중', tag: 'FocusService');

    _currentSession = null;
  }

  /// 세션 취소
  Future<void> cancelSession() async {
    if (_currentSession == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentSession!.startTime);
    final actualMinutes =
        (elapsed.inMinutes - _currentSession!.totalPausedMinutes).clamp(
          0,
          _currentSession!.targetMinutes,
        );

    _currentSession = _currentSession!.copyWith(
      status: 'cancelled',
      endTime: now,
      actualMinutes: actualMinutes,
    );

    await _storage.saveFocusSession(_currentSession!);

    // 일부라도 진행했으면 Task 진행도 업데이트
    if (actualMinutes > 0) {
      await _updateTaskProgress(_currentSession!);
    }

    AppLogger.w('Session cancelled', tag: 'FocusService');

    _currentSession = null;
  }

  /// Task 진행도 업데이트
  Future<void> _updateTaskProgress(FocusSession session) async {
    final task = _taskService.getTaskById(session.taskId);
    if (task == null) return;

    // 실제 집중한 시간 비율로 진행도 계산
    final progressIncrease =
        (session.actualMinutes / session.targetMinutes * 100).round();
    final newProgress = (task.progress + progressIncrease).clamp(0, 100);

    await _taskService.updateTaskProgress(task.id, newProgress);

    AppLogger.d(
      'Task progress updated: ${task.title} → $newProgress%',
      tag: 'FocusService',
    );
  }

  /// 앱 시작 시 미완료 세션 복원
  Future<void> restoreSession() async {
    final sessions = _storage.getFocusSessions();

    // 가장 최근의 active 또는 paused 세션 찾기
    try {
      _currentSession = sessions.lastWhere(
        (s) => s.status == 'active' || s.status == 'paused',
      );

      AppLogger.i(
        'Session restored: ${_currentSession!.taskTitle}',
        tag: 'FocusService',
      );
    } catch (e) {
      _currentSession = null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // History & Statistics
  // ─────────────────────────────────────────────────────────────────────────

  /// 특정 날짜의 세션 히스토리
  List<FocusSession> getSessionHistory(DateTime date) {
    final sessions = _storage.getFocusSessions();

    return sessions.where((s) {
      return s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day;
    }).toList();
  }

  /// 전체 히스토리
  List<FocusSession> getAllSessions() {
    return _storage.getFocusSessions();
  }
}
