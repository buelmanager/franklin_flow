// lib/shared/models/task_model.dart

import 'package:hive/hive.dart';

part 'task_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Task 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 태스크 정보
/// Hive를 사용한 로컬 저장
/// ═══════════════════════════════════════════════════════════════════════════

enum TaskStatus { pending, inProgress, completed }

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  String status; // 'pending', 'in-progress', 'completed'

  @HiveField(3)
  int progress;

  @HiveField(4)
  final int timeInMinutes; // 분 단위로 저장

  @HiveField(5)
  final String categoryId; // Category ID로 저장

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.timeInMinutes,
    required this.categoryId,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 시간을 문자열로 반환 (예: "2시간", "30분", "1.5시간")
  String get timeString {
    if (timeInMinutes < 60) {
      return '$timeInMinutes분';
    } else if (timeInMinutes % 60 == 0) {
      return '${timeInMinutes ~/ 60}시간';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return '$hours시간 $minutes분';
    }
  }

  /// 상태 문자열을 TaskStatus enum으로 변환
  TaskStatus get statusEnum {
    switch (status) {
      case 'completed':
        return TaskStatus.completed;
      case 'in-progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.pending;
    }
  }

  /// 완료 여부
  bool get isCompleted => status == 'completed';

  /// 진행중 여부
  bool get isInProgress => status == 'in-progress';

  /// 대기중 여부
  bool get isPending => status == 'pending';

  /// 복사본 생성
  Task copyWith({
    int? id,
    String? title,
    String? status,
    int? progress,
    int? timeInMinutes,
    String? categoryId,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      timeInMinutes: timeInMinutes ?? this.timeInMinutes,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
