// lib/shared/models/goal_model.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Goal 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   final goal = Goal(
///     emoji: '🏃',
///     title: 'Workout',
///     current: 2,
///     total: 3,
///   );
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class Goal {
  final String emoji;
  final String title;
  final int current;
  final int total;
  final Color color;

  Goal({
    required this.emoji,
    required this.title,
    required this.current,
    required this.total,
    required this.color,
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progress => total > 0 ? current / total : 0.0;

  /// 완료 여부
  bool get isCompleted => current >= total;

  /// 남은 횟수
  int get remaining => total - current;

  /// 복사본 생성
  Goal copyWith({
    String? emoji,
    String? title,
    int? current,
    int? total,
    Color? color,
  }) {
    return Goal(
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      current: current ?? this.current,
      total: total ?? this.total,
      color: color ?? this.color,
    );
  }
}
