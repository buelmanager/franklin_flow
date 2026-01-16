// lib/core/providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/daily_record_service.dart';
import '../../services/goal_service.dart';
import '../../services/task_service.dart';
import '../../services/category_service.dart';
import '../../services/focus_service.dart';
import '../../services/local_storage_service.dart';
import '../../shared/models/daily_record_model.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/task_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/focus_session_model.dart';
import '../utils/app_logger.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow Providers
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Riverpod를 사용한 상태관리
/// - 서비스 싱글톤 제공
/// - 반응형 UI 업데이트
/// ═══════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────
// Services
// ─────────────────────────────────────────────────────────────────────────

/// LocalStorageService Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// TaskService Provider
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

/// CategoryService Provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

/// FocusService Provider
final focusServiceProvider = Provider<FocusService>((ref) {
  return FocusService();
});

// ─────────────────────────────────────────────────────────────────────────
// State Providers (반응형)
// ─────────────────────────────────────────────────────────────────────────

/// Task 리스트 Provider (반응형)
final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((
  ref,
) {
  final taskService = ref.watch(taskServiceProvider);
  return TaskListNotifier(taskService);
});

/// Task 리스트 Notifier
class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskService _taskService;

  TaskListNotifier(this._taskService) : super(_taskService.tasks);

  /// 리스트 새로고침
  void refresh() {
    state = _taskService.tasks;
  }

  /// Task 추가
  Future<Task> addTask({
    required String title,
    required int timeInMinutes,
    required String categoryId,
  }) async {
    final task = await _taskService.addTask(
      title: title,
      timeInMinutes: timeInMinutes,
      categoryId: categoryId,
    );
    refresh();
    return task;
  }

  /// Task 업데이트
  Future<bool> updateTask(Task task) async {
    final success = await _taskService.updateTask(task);
    if (success) refresh();
    return success;
  }

  /// Task 삭제
  Future<bool> deleteTask(int taskId) async {
    final success = await _taskService.deleteTask(taskId);
    if (success) refresh();
    return success;
  }

  /// Task 상태 변경
  Future<bool> changeTaskStatus(int taskId, String newStatus) async {
    final success = await _taskService.changeTaskStatus(taskId, newStatus);
    if (success) refresh();
    return success;
  }

  /// Task 진행도 업데이트
  Future<bool> updateTaskProgress(int taskId, int progress) async {
    final success = await _taskService.updateTaskProgress(taskId, progress);
    if (success) refresh();
    return success;
  }
}

/// Category 리스트 Provider (반응형)
final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, List<Category>>((ref) {
      final categoryService = ref.watch(categoryServiceProvider);
      return CategoryListNotifier(categoryService);
    });

/// Category 리스트 Notifier
class CategoryListNotifier extends StateNotifier<List<Category>> {
  final CategoryService _categoryService;

  CategoryListNotifier(this._categoryService)
    : super(_categoryService.getCategories());

  /// 리스트 새로고침
  void refresh() {
    state = _categoryService.getCategories();
  }

  /// Category 추가
  Future<Category> addCategory({
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    final category = await _categoryService.addCategory(
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
    );
    refresh();
    return category;
  }

  /// Category 삭제
  Future<bool> deleteCategory(String categoryId) async {
    final success = await _categoryService.deleteCategory(categoryId);
    if (success) refresh();
    return success;
  }
}

/// Focus Session Provider (반응형)
final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSession?>((ref) {
      final focusService = ref.watch(focusServiceProvider);
      return FocusSessionNotifier(focusService, ref);
    });

/// Focus Session Notifier
class FocusSessionNotifier extends StateNotifier<FocusSession?> {
  final FocusService _focusService;
  final Ref _ref;

  FocusSessionNotifier(this._focusService, this._ref)
    : super(_focusService.currentSession);

  /// 세션 시작
  Future<FocusSession> startSession(Task task) async {
    final session = await _focusService.startSession(task);
    state = session;

    // Task 리스트 갱신
    _ref.read(taskListProvider.notifier).refresh();

    return session;
  }

  /// 일시정지
  Future<void> pauseSession() async {
    await _focusService.pauseSession();
    state = _focusService.currentSession;
  }

  /// 재개
  Future<void> resumeSession() async {
    await _focusService.resumeSession();
    state = _focusService.currentSession;
  }

  /// 완료
  Future<void> completeSession() async {
    await _focusService.completeSession();
    state = null;

    // Task 리스트 갱신 (진행도가 업데이트되었으므로)
    _ref.read(taskListProvider.notifier).refresh();
  }

  /// 취소
  Future<void> cancelSession() async {
    await _focusService.cancelSession();
    state = null;

    // Task 리스트 갱신
    _ref.read(taskListProvider.notifier).refresh();
  }

  /// 세션 복원
  Future<void> restoreSession() async {
    await _focusService.restoreSession();
    state = _focusService.currentSession;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Computed Providers (파생 데이터)
// ─────────────────────────────────────────────────────────────────────────

/// 완료된 Task 리스트
final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isCompleted).toList();
});

/// 진행중인 Task 리스트
final inProgressTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isInProgress).toList();
});

/// 대기중인 Task 리스트
final pendingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isPending).toList();
});

/// 완료율
final completionRateProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return 0;

  final completed = tasks.where((t) => t.isCompleted).length;
  return ((completed / tasks.length) * 100).round();
});

/// 오늘 완료한 Focus Session 개수
final todaySessionsProvider = Provider<int>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  return focusService.getTodayCompletedSessions();
});

/// 오늘 총 집중 시간
final todayFocusMinutesProvider = Provider<int>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  return focusService.getTodayFocusMinutes();
});

/// GoalService Provider
final goalServiceProvider = Provider<GoalService>((ref) {
  return GoalService();
});

/// Goal 리스트 Provider (반응형)
final goalListProvider = StateNotifierProvider<GoalListNotifier, List<Goal>>((
  ref,
) {
  final goalService = ref.watch(goalServiceProvider);
  return GoalListNotifier(goalService);
});

/// Goal 리스트 Notifier
class GoalListNotifier extends StateNotifier<List<Goal>> {
  final GoalService _goalService;

  GoalListNotifier(this._goalService) : super(_goalService.getGoals());

  /// 리스트 새로고침
  void refresh() {
    state = _goalService.getGoals();
  }

  /// Goal 추가
  Future<Goal> addGoal({
    required String emoji,
    required String title,
    required int total,
    required int colorValue,
    int current = 0,
  }) async {
    final goal = await _goalService.addGoal(
      emoji: emoji,
      title: title,
      total: total,
      colorValue: colorValue,
      current: current,
    );
    refresh();
    return goal;
  }

  /// Goal 업데이트
  Future<bool> updateGoal(Goal goal) async {
    final success = await _goalService.updateGoal(goal);
    if (success) refresh();
    return success;
  }

  /// Goal 삭제
  Future<bool> deleteGoal(int goalId) async {
    final success = await _goalService.deleteGoal(goalId);
    if (success) refresh();
    return success;
  }

  /// Goal 진행도 증가
  Future<bool> incrementGoal(int goalId) async {
    final success = await _goalService.incrementGoal(goalId);
    if (success) refresh();
    return success;
  }

  /// Goal 진행도 감소
  Future<bool> decrementGoal(int goalId) async {
    final success = await _goalService.decrementGoal(goalId);
    if (success) refresh();
    return success;
  }

  /// Goal 진행도 직접 설정
  Future<bool> setGoalProgress(int goalId, int current) async {
    final success = await _goalService.setGoalProgress(goalId, current);
    if (success) refresh();
    return success;
  }

  /// 주간 목표 초기화
  Future<void> resetWeeklyGoals() async {
    await _goalService.resetWeeklyGoals();
    refresh();
  }
}

/// 이번 주 목표만
final currentWeekGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalListProvider);
  return goals.where((g) => g.isCurrentWeek).toList();
});

/// 완료된 목표
final completedGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalListProvider);
  return goals.where((g) => g.isCompleted).toList();
});

/// 이번 주 완료율
final weekCompletionRateProvider = Provider<int>((ref) {
  final weekGoals = ref.watch(currentWeekGoalsProvider);
  if (weekGoals.isEmpty) return 0;

  final completed = weekGoals.where((g) => g.isCompleted).length;
  return ((completed / weekGoals.length) * 100).round();
});

// ─────────────────────────────────────────────────────────────────────────
// DailyRecord Providers (Today's Good)
// ─────────────────────────────────────────────────────────────────────────

/// DailyRecordService Provider
final dailyRecordServiceProvider = Provider<DailyRecordService>((ref) {
  return DailyRecordService();
});

/// 오늘의 DailyRecord Provider (반응형)
final todayRecordProvider =
    StateNotifierProvider<TodayRecordNotifier, DailyRecord?>((ref) {
  final service = ref.watch(dailyRecordServiceProvider);
  return TodayRecordNotifier(service, ref);
});

/// TodayRecord Notifier
class TodayRecordNotifier extends StateNotifier<DailyRecord?> {
  static const String _tag = 'TodayRecordNotifier';

  final DailyRecordService _service;

  TodayRecordNotifier(this._service, Ref ref) : super(null) {
    // 초기 로드
    _loadTodayRecord();
  }

  /// 오늘의 기록 로드
  void _loadTodayRecord() {
    try {
      state = _service.getTodayRecord();
      AppLogger.d(
        'Today record loaded: ${state?.id}, intentions: ${state?.totalIntentionCount}',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.e('Failed to load today record', tag: _tag, error: e);
      state = DailyRecord.forToday();
    }
  }

  /// 새로고침
  void refresh() {
    _loadTodayRecord();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 의도 관련
  // ─────────────────────────────────────────────────────────────────────────

  /// Task 의도 토글
  Future<bool> toggleTaskIntention(int taskId) async {
    try {
      final record = state ?? DailyRecord.forToday();

      // 최대 3개 제한 체크
      if (!record.selectedTaskIds.contains(taskId) &&
          record.totalIntentionCount >= 3) {
        AppLogger.w('Max intentions reached (3)', tag: _tag);
        return false;
      }

      record.toggleSelectedTaskId(taskId);
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.d(
        'Task intention toggled: $taskId, total: ${record.totalIntentionCount}',
        tag: _tag,
      );
      return true;
    } catch (e) {
      AppLogger.e('Failed to toggle task intention', tag: _tag, error: e);
      return false;
    }
  }

  /// 자유 의도 추가
  Future<bool> addFreeIntention(String intention) async {
    try {
      if (intention.trim().isEmpty) return false;

      final record = state ?? DailyRecord.forToday();

      // 최대 3개 제한 체크
      if (record.totalIntentionCount >= 3) {
        AppLogger.w('Max intentions reached (3)', tag: _tag);
        return false;
      }

      record.addFreeIntention(intention);
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.d('Free intention added: $intention', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to add free intention', tag: _tag, error: e);
      return false;
    }
  }

  /// 자유 의도 제거
  Future<bool> removeFreeIntention(int index) async {
    try {
      final record = state;
      if (record == null) return false;

      record.removeFreeIntention(index);
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.d('Free intention removed at index: $index', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to remove free intention', tag: _tag, error: e);
      return false;
    }
  }

  /// 자유 의도 완료 토글
  Future<bool> toggleFreeIntentionCompleted(int index) async {
    try {
      final record = state;
      if (record == null) return false;

      record.toggleFreeIntentionCompleted(index);
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.d('Free intention toggled at index: $index', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to toggle free intention', tag: _tag, error: e);
      return false;
    }
  }

  /// 아침 의도 완료 처리
  Future<bool> completeMorningIntention() async {
    try {
      final record = state;
      if (record == null) return false;

      record.completeMorningIntention();
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.i('Morning intention completed', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to complete morning intention', tag: _tag, error: e);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 관련
  // ─────────────────────────────────────────────────────────────────────────

  /// 저녁 성찰 저장
  Future<bool> saveEveningReflection(String reflection, int rating) async {
    try {
      final record = state;
      if (record == null) return false;

      record.setEveningReflection(reflection, rating);
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.d('Evening reflection saved with rating: $rating', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to save evening reflection', tag: _tag, error: e);
      return false;
    }
  }

  /// 저녁 성찰 완료 처리
  Future<bool> completeEveningReflection() async {
    try {
      final record = state;
      if (record == null) return false;

      record.completeEveningReflection();
      await _service.saveRecord(record);
      state = record.copyWith();

      AppLogger.i('Evening reflection completed', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.e('Failed to complete evening reflection', tag: _tag, error: e);
      return false;
    }
  }
}

/// 연속 기록 일수 Provider
final streakDaysProvider = Provider<int>((ref) {
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getStreakDays();
});

/// 평균 만족도 Provider (최근 7일)
final averageSatisfactionProvider = Provider<double>((ref) {
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getAverageSatisfaction(days: 7);
});

/// 완료된 일수 Provider (최근 30일)
final completedDaysProvider = Provider<int>((ref) {
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getCompletedDays(days: 30);
});
