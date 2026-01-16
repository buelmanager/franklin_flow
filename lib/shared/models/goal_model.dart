// lib/shared/models/goal_model.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_colors.dart';

part 'goal_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Goal 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 주간 목표 정보
/// Hive를 사용한 로컬 저장
/// ═══════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 3)
class Goal {
  @HiveField(0)
  final int id;

  @HiveField(1)
  @Deprecated('Use iconCodePoint instead')
  final String emoji;

  @HiveField(2)
  final String title;

  @HiveField(3)
  int current;

  @HiveField(4)
  final int total;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  final DateTime weekStartDate; // 주의 시작일 (월요일)

  @HiveField(9)
  final int iconCodePoint; // Material Icon code point

  Goal({
    required this.id,
    this.emoji = '',
    required this.title,
    required this.current,
    required this.total,
    required this.colorValue,
    DateTime? createdAt,
    this.completedAt,
    DateTime? weekStartDate,
    int? iconCodePoint,
  }) : createdAt = createdAt ?? DateTime.now(),
       weekStartDate = weekStartDate ?? _getWeekStart(DateTime.now()),
       iconCodePoint = iconCodePoint ?? Icons.flag_rounded.codePoint;

  /// Color 객체 getter
  Color get color => Color(colorValue);

  /// Icon getter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// 진행률 (0.0 ~ 1.0)
  double get progress => total > 0 ? current / total : 0.0;

  /// 완료 여부
  bool get isCompleted => current >= total;

  /// 남은 횟수
  int get remaining => (total - current).clamp(0, total);

  /// 이번 주 목표인지 확인
  bool get isCurrentWeek {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    return weekStartDate.isAtSameMomentAs(currentWeekStart);
  }

  /// 복사본 생성
  Goal copyWith({
    int? id,
    String? emoji,
    String? title,
    int? current,
    int? total,
    int? colorValue,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? weekStartDate,
    int? iconCodePoint,
  }) {
    return Goal(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      current: current ?? this.current,
      total: total ?? this.total,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  /// 주의 시작일(월요일) 계산
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1=월요일, 7=일요일
    final diff = weekday - 1; // 월요일까지의 차이
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: diff));
  }

  /// 기본 목표 리스트
  static List<Goal> getDefaultGoals({required int startId}) {
    final weekStart = _getWeekStart(DateTime.now());

    return [
      Goal(
        id: startId,
        title: 'Workout',
        current: 0,
        total: 3,
        colorValue: AppColors.accentPink.value,
        weekStartDate: weekStart,
        iconCodePoint: Icons.directions_run_rounded.codePoint,
      ),
      Goal(
        id: startId + 1,
        title: 'Reading',
        current: 0,
        total: 10,
        colorValue: AppColors.accentPurple.value,
        weekStartDate: weekStart,
        iconCodePoint: Icons.menu_book_rounded.codePoint,
      ),
      Goal(
        id: startId + 2,
        title: 'Water',
        current: 0,
        total: 8,
        colorValue: AppColors.accentBlue.value,
        weekStartDate: weekStart,
        iconCodePoint: Icons.water_drop_rounded.codePoint,
      ),
      Goal(
        id: startId + 3,
        title: 'Meditation',
        current: 0,
        total: 7,
        colorValue: AppColors.accentGreen.value,
        weekStartDate: weekStart,
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
      ),
    ];
  }
}
