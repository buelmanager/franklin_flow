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
// Theme Provider (다크 모드)
// ─────────────────────────────────────────────────────────────────────────

/// Theme Mode Provider (다크 모드 상태 관리)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

/// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<bool> {
  static const String _tag = 'ThemeModeNotifier';

  ThemeModeNotifier() : super(false) {
    _loadTheme();
  }

  /// 저장된 테마 로드
  Future<void> _loadTheme() async {
    try {
      final storage = LocalStorageService();
      final isDarkMode = storage.getSetting<bool>('isDarkMode') ?? false;
      state = isDarkMode;
      AppLogger.d('Theme loaded: isDarkMode=$isDarkMode', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to load theme', tag: _tag, error: e);
    }
  }

  /// 다크 모드 토글
  Future<void> toggle() async {
    state = !state;
    await _saveTheme();
  }

  /// 다크 모드 설정
  Future<void> setDarkMode(bool isDark) async {
    if (state == isDark) return;
    state = isDark;
    await _saveTheme();
  }

  /// 테마 저장
  Future<void> _saveTheme() async {
    try {
      final storage = LocalStorageService();
      await storage.saveSetting('isDarkMode', state);
      AppLogger.i('Theme saved: isDarkMode=$state', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save theme', tag: _tag, error: e);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// User Name Provider (사용자 이름)
// ─────────────────────────────────────────────────────────────────────────

/// User Name Provider (사용자 이름 상태 관리)
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier();
});

/// User Name Notifier
class UserNameNotifier extends StateNotifier<String> {
  static const String _tag = 'UserNameNotifier';

  UserNameNotifier() : super('') {
    _loadUserName();
  }

  /// 저장된 이름 로드
  Future<void> _loadUserName() async {
    try {
      final storage = LocalStorageService();
      final userName = storage.getSetting<String>('userName') ?? '';
      state = userName;
      AppLogger.d('User name loaded: $userName', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to load user name', tag: _tag, error: e);
    }
  }

  /// 이름 설정
  Future<void> setUserName(String name) async {
    if (state == name) return;
    state = name;
    await _saveUserName();
  }

  /// 이름 저장
  Future<void> _saveUserName() async {
    try {
      final storage = LocalStorageService();
      await storage.saveSetting('userName', state);
      AppLogger.i('User name saved: $state', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save user name', tag: _tag, error: e);
    }
  }
}

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
  return TaskListNotifier(taskService, ref);
});

/// Task 리스트 Notifier
class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskService _taskService;
  final Ref _ref;

  TaskListNotifier(this._taskService, this._ref) : super(_taskService.tasks);

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
    if (success) {
      // DailyRecord에서도 해당 Task ID 제거
      _ref.read(todayRecordProvider.notifier).removeTaskFromIntention(taskId);
      refresh();
    }
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
    required int iconCodePoint,
    required String title,
    required int total,
    required int colorValue,
    int current = 0,
  }) async {
    final goal = await _goalService.addGoal(
      iconCodePoint: iconCodePoint,
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

  /// Task가 삭제될 때 selectedTaskIds에서도 제거
  Future<void> removeTaskFromIntention(int taskId) async {
    try {
      final record = state;
      if (record == null) return;

      // selectedTaskIds에 해당 taskId가 있으면 제거
      if (record.selectedTaskIds.contains(taskId)) {
        record.selectedTaskIds.remove(taskId);
        await _service.saveRecord(record);
        state = record.copyWith();

        AppLogger.d(
          'Removed deleted task from intention: $taskId',
          tag: _tag,
        );
      }
    } catch (e) {
      AppLogger.e('Failed to remove task from intention', tag: _tag, error: e);
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
  // todayRecordProvider를 watch하여 DailyRecord 변경 시 리빌드
  ref.watch(todayRecordProvider);
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getStreakDays();
});

/// 평균 만족도 Provider (최근 7일)
final averageSatisfactionProvider = Provider<double>((ref) {
  // todayRecordProvider를 watch하여 DailyRecord 변경 시 리빌드
  ref.watch(todayRecordProvider);
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getAverageSatisfaction(days: 7);
});

/// 완료된 일수 Provider (최근 30일)
final completedDaysProvider = Provider<int>((ref) {
  // todayRecordProvider를 watch하여 DailyRecord 변경 시 리빌드
  ref.watch(todayRecordProvider);
  final service = ref.watch(dailyRecordServiceProvider);
  return service.getCompletedDays(days: 30);
});

// ─────────────────────────────────────────────────────────────────────────
// Analytics Providers (분석 화면)
// ─────────────────────────────────────────────────────────────────────────

/// 총 완료한 Task 수 Provider
final totalCompletedTasksProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isCompleted).length;
});

/// 총 집중 시간 Provider (분)
final totalFocusMinutesProvider = Provider<int>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  final sessions = focusService.getAllSessions();
  return sessions.fold(0, (sum, s) => sum + s.actualMinutes);
});

/// 최고 스트릭 Provider
final bestStreakProvider = Provider<int>((ref) {
  // todayRecordProvider를 watch하여 DailyRecord 변경 시 리빌드
  ref.watch(todayRecordProvider);
  final service = ref.watch(dailyRecordServiceProvider);
  final records = service.getAllRecords();

  if (records.isEmpty) return 0;

  // 날짜 순으로 정렬
  records.sort((a, b) => a.date.compareTo(b.date));

  int bestStreak = 0;
  int currentStreak = 0;
  DateTime? lastDate;

  for (final record in records) {
    if (!record.isDayCompleted) {
      currentStreak = 0;
      lastDate = null;
      continue;
    }

    final recordDate = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
    );

    if (lastDate == null) {
      currentStreak = 1;
    } else {
      final diff = recordDate.difference(lastDate).inDays;
      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        currentStreak = 1;
      }
      // diff == 0이면 같은 날짜 (무시)
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    lastDate = recordDate;
  }

  // 현재 스트릭과 비교
  final currentStreakDays = service.getStreakDays();
  return bestStreak > currentStreakDays ? bestStreak : currentStreakDays;
});

/// 주간 완료율 데이터 Provider (최근 7일)
final weeklyCompletionDataProvider = Provider<List<double>>((ref) {
  // todayRecordProvider를 watch하여 DailyRecord 변경 시 리빌드
  ref.watch(todayRecordProvider);
  final tasks = ref.watch(taskListProvider);
  final dailyRecordService = ref.watch(dailyRecordServiceProvider);

  final List<double> weeklyData = [];
  final now = DateTime.now();

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final record = dailyRecordService.getRecordByDate(date);

    if (record == null) {
      weeklyData.add(0.0);
      continue;
    }

    // 해당 날짜의 의도한 Task 중 완료된 비율
    final totalIntentions =
        record.selectedTaskIds.length + record.freeIntentions.length;

    if (totalIntentions == 0) {
      // 의도가 없으면 0
      weeklyData.add(0.0);
      continue;
    }

    // Task 완료 개수 계산
    int completedCount = 0;
    for (final taskId in record.selectedTaskIds) {
      final task = tasks.where((t) => t.id == taskId).firstOrNull;
      if (task != null && task.isCompleted) {
        completedCount++;
      }
    }

    // 자유 의도 완료 개수
    completedCount +=
        record.freeIntentionCompleted.where((c) => c).length;

    weeklyData.add(completedCount / totalIntentions);
  }

  return weeklyData;
});

/// 카테고리별 분석 데이터 Provider
final categoryAnalyticsProvider = Provider<Map<String, double>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final categories = ref.watch(categoryListProvider);

  if (tasks.isEmpty) return {};

  final Map<String, int> categoryCount = {};
  int totalTasks = 0;

  // 완료된 Task만 카운트
  for (final task in tasks.where((t) => t.isCompleted)) {
    final categoryId = task.categoryId;
    categoryCount[categoryId] = (categoryCount[categoryId] ?? 0) + 1;
    totalTasks++;
  }

  if (totalTasks == 0) return {};

  // 카테고리 이름으로 매핑하고 비율 계산
  final Map<String, double> result = {};

  for (final entry in categoryCount.entries) {
    final category = categories.where((c) => c.id == entry.key).firstOrNull;
    final categoryName = category?.name ?? '기타';
    result[categoryName] = entry.value / totalTasks;
  }

  // 비율 순으로 정렬
  final sorted = result.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Map.fromEntries(sorted);
});

/// 할일/다짐 상세 분석 데이터 Provider
final taskIntentionAnalyticsProvider =
    Provider<Map<String, dynamic>>((ref) {
  ref.watch(todayRecordProvider);
  final tasks = ref.watch(taskListProvider);
  final dailyRecordService = ref.watch(dailyRecordServiceProvider);

  // 총 할일 통계
  final totalTasks = tasks.length;
  final completedTasks = tasks.where((t) => t.isCompleted).length;
  final pendingTasks = tasks.where((t) => t.isPending).length;
  final inProgressTasks = tasks.where((t) => t.isInProgress).length;

  // 오늘의 다짐 통계 (최근 7일)
  int totalIntentionDays = 0; // 다짐을 설정한 날
  int totalIntentions = 0; // 총 다짐 개수
  int completedIntentions = 0; // 완료한 다짐 개수
  int totalFreeIntentions = 0; // 자유 다짐 개수
  int completedFreeIntentions = 0; // 완료한 자유 다짐

  final now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final record = dailyRecordService.getRecordByDate(date);

    if (record == null) continue;

    final dayIntentions =
        record.selectedTaskIds.length + record.freeIntentions.length;
    if (dayIntentions > 0) {
      totalIntentionDays++;
      totalIntentions += dayIntentions;
      totalFreeIntentions += record.freeIntentions.length;

      // 완료된 Task 다짐 카운트
      for (final taskId in record.selectedTaskIds) {
        final task = tasks.where((t) => t.id == taskId).firstOrNull;
        if (task != null && task.isCompleted) {
          completedIntentions++;
        }
      }

      // 완료된 자유 다짐 카운트
      completedFreeIntentions +=
          record.freeIntentionCompleted.where((c) => c).length;
    }
  }

  completedIntentions += completedFreeIntentions;

  return {
    'totalTasks': totalTasks,
    'completedTasks': completedTasks,
    'pendingTasks': pendingTasks,
    'inProgressTasks': inProgressTasks,
    'taskCompletionRate':
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
    'totalIntentionDays': totalIntentionDays,
    'totalIntentions': totalIntentions,
    'completedIntentions': completedIntentions,
    'totalFreeIntentions': totalFreeIntentions,
    'completedFreeIntentions': completedFreeIntentions,
    'intentionCompletionRate': totalIntentions > 0
        ? (completedIntentions / totalIntentions * 100).round()
        : 0,
  };
});

/// 주 목표 분석 데이터 Provider
final goalAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final goals = ref.watch(goalListProvider);
  final weekGoals = ref.watch(currentWeekGoalsProvider);

  if (goals.isEmpty) {
    return {
      'totalGoals': 0,
      'weekGoals': 0,
      'completedGoals': 0,
      'inProgressGoals': 0,
      'goalCompletionRate': 0,
      'totalProgress': 0,
      'averageProgress': 0.0,
      'goalDetails': <Map<String, dynamic>>[],
    };
  }

  final completedGoals = weekGoals.where((g) => g.isCompleted).length;
  final inProgressGoals = weekGoals.where((g) => !g.isCompleted).length;

  // 전체 진행률 계산
  int totalCurrent = 0;
  int totalTarget = 0;
  for (final goal in weekGoals) {
    totalCurrent += goal.current;
    totalTarget += goal.total;
  }

  final totalProgress =
      totalTarget > 0 ? (totalCurrent / totalTarget * 100).round() : 0;
  final averageProgress = weekGoals.isNotEmpty
      ? weekGoals.map((g) => (g.progress * 100).round()).reduce((a, b) => a + b) /
          weekGoals.length
      : 0.0;

  // 개별 목표 상세
  final goalDetails = weekGoals.map((g) {
    return {
      'iconCodePoint': g.iconCodePoint,
      'title': g.title,
      'current': g.current,
      'total': g.total,
      'progress': (g.progress * 100).round(),
      'isCompleted': g.isCompleted,
    };
  }).toList();

  return {
    'totalGoals': goals.length,
    'weekGoals': weekGoals.length,
    'completedGoals': completedGoals,
    'inProgressGoals': inProgressGoals,
    'goalCompletionRate':
        weekGoals.isNotEmpty ? (completedGoals / weekGoals.length * 100).round() : 0,
    'totalProgress': totalProgress,
    'averageProgress': averageProgress,
    'goalDetails': goalDetails,
  };
});
