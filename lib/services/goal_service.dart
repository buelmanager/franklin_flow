// lib/services/goal_service.dart

import '../core/utils/app_logger.dart';
import '../shared/models/goal_model.dart';
import 'local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GoalService - 주간 목표 관리 비즈니스 로직
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 목표 CRUD 및 진행도 관리
/// ═══════════════════════════════════════════════════════════════════════════

class GoalService {
  GoalService._();
  static final GoalService _instance = GoalService._();
  factory GoalService() => _instance;

  final _storage = LocalStorageService();

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  /// 모든 목표 가져오기
  List<Goal> getGoals() {
    return _storage.getGoals();
  }

  /// 이번 주 목표만 가져오기
  List<Goal> getCurrentWeekGoals() {
    final goals = getGoals();
    return goals.where((g) => g.isCurrentWeek).toList();
  }

  /// 완료된 목표
  List<Goal> getCompletedGoals() {
    return getGoals().where((g) => g.isCompleted).toList();
  }

  /// 이번 주 완료율
  int getCurrentWeekCompletionRate() {
    final weekGoals = getCurrentWeekGoals();
    if (weekGoals.isEmpty) return 0;

    final completed = weekGoals.where((g) => g.isCompleted).length;
    return ((completed / weekGoals.length) * 100).round();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// 목표 추가
  Future<Goal> addGoal({
    required String emoji,
    required String title,
    required int total,
    required int colorValue,
    int current = 0,
  }) async {
    final newId = _storage.getNextGoalId();

    final newGoal = Goal(
      id: newId,
      emoji: emoji,
      title: title,
      current: current,
      total: total,
      colorValue: colorValue,
    );

    await _storage.saveGoal(newGoal);

    AppLogger.i(
      'Goal added: ${newGoal.title} (${newGoal.emoji})',
      tag: 'GoalService',
    );

    return newGoal;
  }

  /// 목표 업데이트
  Future<bool> updateGoal(Goal goal) async {
    try {
      await _storage.saveGoal(goal);

      AppLogger.i('Goal updated: ${goal.title}', tag: 'GoalService');

      return true;
    } catch (e) {
      AppLogger.e('Failed to update goal', tag: 'GoalService', error: e);
      return false;
    }
  }

  /// 목표 삭제
  Future<bool> deleteGoal(int goalId) async {
    try {
      await _storage.deleteGoal(goalId);

      AppLogger.i('Goal deleted: ID $goalId', tag: 'GoalService');

      return true;
    } catch (e) {
      AppLogger.e('Failed to delete goal', tag: 'GoalService', error: e);
      return false;
    }
  }

  /// ID로 목표 찾기
  Goal? getGoalById(int id) {
    try {
      return getGoals().firstWhere((g) => g.id == id);
    } catch (e) {
      AppLogger.w('Goal not found: ID $id', tag: 'GoalService');
      return null;
    }
  }

  /// 목표 진행도 증가
  Future<bool> incrementGoal(int goalId) async {
    final goal = getGoalById(goalId);
    if (goal == null) return false;

    if (goal.isCompleted) {
      AppLogger.w('Goal already completed', tag: 'GoalService');
      return false;
    }

    goal.current++;

    if (goal.isCompleted) {
      goal.completedAt = DateTime.now();
    }

    await _storage.saveGoal(goal);

    AppLogger.i(
      'Goal progress: ${goal.title} -> ${goal.current}/${goal.total}',
      tag: 'GoalService',
    );

    return true;
  }

  /// 목표 진행도 감소
  Future<bool> decrementGoal(int goalId) async {
    final goal = getGoalById(goalId);
    if (goal == null) return false;

    if (goal.current <= 0) {
      AppLogger.w('Goal already at 0', tag: 'GoalService');
      return false;
    }

    goal.current--;

    // 완료 상태 해제
    if (goal.current < goal.total) {
      goal.completedAt = null;
    }

    await _storage.saveGoal(goal);

    AppLogger.i(
      'Goal progress decreased: ${goal.title} -> ${goal.current}/${goal.total}',
      tag: 'GoalService',
    );

    return true;
  }

  /// 목표 진행도 직접 설정
  Future<bool> setGoalProgress(int goalId, int current) async {
    final goal = getGoalById(goalId);
    if (goal == null) return false;

    goal.current = current.clamp(0, goal.total);

    if (goal.isCompleted) {
      goal.completedAt = DateTime.now();
    } else {
      goal.completedAt = null;
    }

    await _storage.saveGoal(goal);

    AppLogger.i(
      'Goal progress set: ${goal.title} -> ${goal.current}/${goal.total}',
      tag: 'GoalService',
    );

    return true;
  }

  /// 모든 목표 초기화 (새로운 주 시작 시)
  Future<void> resetWeeklyGoals() async {
    final goals = getCurrentWeekGoals();

    for (final goal in goals) {
      goal.current = 0;
      goal.completedAt = null;
      await _storage.saveGoal(goal);
    }

    AppLogger.i('Weekly goals reset', tag: 'GoalService');
  }

  // initializeDefaultGoals 메서드 삭제 (기본 목표 생성 안 함)
}
