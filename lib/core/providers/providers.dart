// lib/core/providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/task_service.dart';
import '../../services/category_service.dart';
import '../../services/focus_service.dart';
import '../../services/local_storage_service.dart';
import '../../shared/models/task_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/focus_session_model.dart';

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
