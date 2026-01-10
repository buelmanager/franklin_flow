// lib/shared/models/focus_session_model.dart

import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FocusSession 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Task 기반 집중 세션 정보
/// Hive를 사용한 로컬 저장
/// ═══════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 2)
class FocusSession {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int taskId; // 필수: 어떤 Task에 대한 세션인지

  @HiveField(2)
  final String taskTitle; // Task 제목 (히스토리용)

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  final int targetMinutes; // Task의 예상 시간

  @HiveField(6)
  int actualMinutes; // 실제 집중한 시간

  @HiveField(7)
  String status; // 'active', 'paused', 'completed', 'cancelled'

  @HiveField(8)
  DateTime? pausedAt; // 일시정지 시간

  @HiveField(9)
  int totalPausedMinutes; // 총 일시정지 시간

  FocusSession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.startTime,
    this.endTime,
    required this.targetMinutes,
    this.actualMinutes = 0,
    this.status = 'active',
    this.pausedAt,
    this.totalPausedMinutes = 0,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (targetMinutes == 0) return 0.0;
    return (actualMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  /// 남은 시간 (분)
  int get remainingMinutes {
    return (targetMinutes - actualMinutes).clamp(0, targetMinutes);
  }

  /// 활성 상태 여부
  bool get isActive => status == 'active';

  /// 일시정지 상태 여부
  bool get isPaused => status == 'paused';

  /// 완료 여부
  bool get isCompleted => status == 'completed';

  /// 복사본 생성
  FocusSession copyWith({
    int? id,
    int? taskId,
    String? taskTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? targetMinutes,
    int? actualMinutes,
    String? status,
    DateTime? pausedAt,
    int? totalPausedMinutes,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      status: status ?? this.status,
      pausedAt: pausedAt ?? this.pausedAt,
      totalPausedMinutes: totalPausedMinutes ?? this.totalPausedMinutes,
    );
  }
}
