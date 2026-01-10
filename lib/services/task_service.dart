// lib/services/task_service.dart

import '../core/utils/app_logger.dart';
import '../shared/models/task_model.dart';
import 'local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TaskService - 태스크 관리 비즈니스 로직
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 태스크 CRUD 및 상태 관리
/// LocalStorageService와 연동하여 데이터 영속성 제공
/// ═══════════════════════════════════════════════════════════════════════════

class TaskService {
  TaskService._();
  static final TaskService _instance = TaskService._();
  factory TaskService() => _instance;

  final _storage = LocalStorageService();

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  /// 전체 태스크 리스트
  List<Task> get tasks => _storage.getTasks();

  /// 완료된 태스크 리스트
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  /// 진행중인 태스크 리스트
  List<Task> get inProgressTasks => tasks.where((t) => t.isInProgress).toList();

  /// 대기중인 태스크 리스트
  List<Task> get pendingTasks => tasks.where((t) => t.isPending).toList();

  /// 태스크 개수
  int get taskCount => tasks.length;

  /// 완료율 (0-100)
  int get completionRate {
    final allTasks = tasks;
    if (allTasks.isEmpty) return 0;
    final completed = completedTasks.length;
    return ((completed / allTasks.length) * 100).round();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// 태스크 추가
  Future<Task> addTask({
    required String title,
    required int timeInMinutes,
    required String categoryId,
    String status = 'pending',
    int progress = 0,
  }) async {
    final newId = _storage.getNextTaskId();

    final newTask = Task(
      id: newId,
      title: title,
      status: status,
      progress: progress,
      timeInMinutes: timeInMinutes,
      categoryId: categoryId,
    );

    await _storage.saveTask(newTask);

    AppLogger.i(
      'Task added: ${newTask.title} (ID: ${newTask.id})',
      tag: 'TaskService',
    );

    return newTask;
  }

  /// 태스크 업데이트
  Future<bool> updateTask(Task updatedTask) async {
    try {
      await _storage.saveTask(updatedTask);

      AppLogger.i(
        'Task updated: ${updatedTask.title} (ID: ${updatedTask.id})',
        tag: 'TaskService',
      );

      return true;
    } catch (e) {
      AppLogger.e('Failed to update task', tag: 'TaskService', error: e);
      return false;
    }
  }

  /// 태스크 삭제
  Future<bool> deleteTask(int taskId) async {
    try {
      await _storage.deleteTask(taskId);

      AppLogger.i('Task deleted: ID $taskId', tag: 'TaskService');

      return true;
    } catch (e) {
      AppLogger.e('Failed to delete task', tag: 'TaskService', error: e);
      return false;
    }
  }

  /// ID로 태스크 찾기
  Task? getTaskById(int id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      AppLogger.w('Task not found: ID $id', tag: 'TaskService');
      return null;
    }
  }

  /// 태스크 상태 변경
  Future<bool> changeTaskStatus(int taskId, String newStatus) async {
    final task = getTaskById(taskId);
    if (task == null) return false;

    task.status = newStatus;

    // 상태에 따라 진행도 자동 조정
    switch (newStatus) {
      case 'completed':
        task.progress = 100;
        task.completedAt = DateTime.now();
        break;
      case 'in-progress':
        // pending에서 in-progress로 변경 시 진행도를 0으로 초기화
        if (task.progress == 0) {
          task.progress = 0; // 명시적으로 0으로 설정
        }
        break;
      case 'pending':
        task.progress = 0;
        task.completedAt = null;
        break;
    }

    await _storage.saveTask(task);

    AppLogger.i(
      'Task status changed: ${task.title} -> $newStatus (progress: ${task.progress}%)',
      tag: 'TaskService',
    );

    return true;
  }

  /// 태스크 진행도 업데이트
  Future<bool> updateTaskProgress(int taskId, int progress) async {
    final task = getTaskById(taskId);
    if (task == null) return false;

    task.progress = progress.clamp(0, 100);

    // 진행도에 따라 상태 자동 조정
    if (progress == 100 && !task.isCompleted) {
      task.status = 'completed';
      task.completedAt = DateTime.now();
    } else if (progress > 0 && progress < 100 && !task.isInProgress) {
      task.status = 'in-progress';
    } else if (progress == 0 && task.isInProgress) {
      // 진행도를 0으로 되돌릴 때는 상태를 변경하지 않음
      // (사용자가 의도적으로 진행도만 초기화하는 경우)
    }

    await _storage.saveTask(task);

    AppLogger.d(
      'Task progress updated: ${task.title} -> $progress%',
      tag: 'TaskService',
    );

    return true;
  }

  /// 모든 태스크 삭제 (테스트용)
  Future<void> clearAllTasks() async {
    await _storage.clearAllTasks();
    AppLogger.i('All tasks cleared', tag: 'TaskService');
  }
}
