// lib/shared/models/daily_record_model.dart

import 'package:hive/hive.dart';

part 'daily_record_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DailyRecord 모델 - Today's Good 일일 기록
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 하루의 아침 의도와 저녁 성찰을 저장하는 모델
///
/// 데이터 구조:
/// - 아침 의도: 선택된 Task ID 목록 + 자유 의도 텍스트 목록
/// - 저녁 성찰: 성찰 텍스트 + 만족도 (1-5)
///
/// 사용법:
///   final record = DailyRecord.forToday();
///   record.addSelectedTaskId(taskId);
///   record.setEveningReflection('좋은 하루였다', 5);
/// ═══════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 6)
class DailyRecord {
  /// 고유 ID (날짜 기반: "2025-01-14")
  @HiveField(0)
  final String id;

  /// 날짜
  @HiveField(1)
  final DateTime date;

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 의도 (Morning Intention)
  // ─────────────────────────────────────────────────────────────────────────

  /// 선택된 Task ID 목록
  @HiveField(2)
  List<int> selectedTaskIds;

  /// 자유 의도 텍스트 목록 (Task 외 추가 의도)
  @HiveField(3)
  List<String> freeIntentions;

  /// 자유 의도 완료 상태 목록
  @HiveField(4)
  List<bool> freeIntentionCompleted;

  /// 아침 기록 완료 시간
  @HiveField(5)
  DateTime? morningCompletedAt;

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 (Evening Reflection)
  // ─────────────────────────────────────────────────────────────────────────

  /// 저녁 성찰 텍스트
  @HiveField(6)
  String? eveningReflection;

  /// 하루 만족도 (1-5)
  @HiveField(7)
  int? satisfactionRating;

  /// 저녁 기록 완료 시간
  @HiveField(8)
  DateTime? eveningCompletedAt;

  // ─────────────────────────────────────────────────────────────────────────
  // 메타 정보
  // ─────────────────────────────────────────────────────────────────────────

  /// 생성 시간
  @HiveField(9)
  final DateTime createdAt;

  /// 마지막 수정 시간
  @HiveField(10)
  DateTime updatedAt;

  // ─────────────────────────────────────────────────────────────────────────
  // 생성자
  // ─────────────────────────────────────────────────────────────────────────

  DailyRecord({
    required this.id,
    required this.date,
    List<int>? selectedTaskIds,
    List<String>? freeIntentions,
    List<bool>? freeIntentionCompleted,
    this.morningCompletedAt,
    this.eveningReflection,
    this.satisfactionRating,
    this.eveningCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : selectedTaskIds = selectedTaskIds ?? [],
       freeIntentions = freeIntentions ?? [],
       freeIntentionCompleted = freeIntentionCompleted ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 오늘 날짜로 새 레코드 생성
  factory DailyRecord.forToday() {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    return DailyRecord(id: _formatDateId(dateOnly), date: dateOnly);
  }

  /// 특정 날짜로 새 레코드 생성
  factory DailyRecord.forDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return DailyRecord(id: _formatDateId(dateOnly), date: dateOnly);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 의도 관련 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// Task ID 추가
  void addSelectedTaskId(int taskId) {
    if (!selectedTaskIds.contains(taskId)) {
      selectedTaskIds.add(taskId);
      updatedAt = DateTime.now();
    }
  }

  /// Task ID 제거
  void removeSelectedTaskId(int taskId) {
    selectedTaskIds.remove(taskId);
    updatedAt = DateTime.now();
  }

  /// Task ID 토글
  bool toggleSelectedTaskId(int taskId) {
    if (selectedTaskIds.contains(taskId)) {
      removeSelectedTaskId(taskId);
      return false;
    } else {
      addSelectedTaskId(taskId);
      return true;
    }
  }

  /// 자유 의도 추가
  void addFreeIntention(String intention) {
    if (intention.trim().isNotEmpty) {
      freeIntentions.add(intention.trim());
      freeIntentionCompleted.add(false);
      updatedAt = DateTime.now();
    }
  }

  /// 자유 의도 제거
  void removeFreeIntention(int index) {
    if (index >= 0 && index < freeIntentions.length) {
      freeIntentions.removeAt(index);
      freeIntentionCompleted.removeAt(index);
      updatedAt = DateTime.now();
    }
  }

  /// 자유 의도 완료 토글
  void toggleFreeIntentionCompleted(int index) {
    if (index >= 0 && index < freeIntentionCompleted.length) {
      freeIntentionCompleted[index] = !freeIntentionCompleted[index];
      updatedAt = DateTime.now();
    }
  }

  /// 아침 의도 완료 처리
  void completeMorningIntention() {
    morningCompletedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 관련 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// 저녁 성찰 설정
  void setEveningReflection(String reflection, int rating) {
    eveningReflection = reflection.trim();
    satisfactionRating = rating.clamp(1, 5);
    updatedAt = DateTime.now();
  }

  /// 저녁 성찰 완료 처리
  void completeEveningReflection() {
    eveningCompletedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Getter
  // ─────────────────────────────────────────────────────────────────────────

  /// 아침 의도가 완료되었는지
  bool get isMorningCompleted => morningCompletedAt != null;

  /// 저녁 성찰이 완료되었는지
  bool get isEveningCompleted => eveningCompletedAt != null;

  /// 오늘 하루가 완전히 완료되었는지
  bool get isDayCompleted => isMorningCompleted && isEveningCompleted;

  /// 의도가 있는지 (Task 또는 자유 의도)
  bool get hasIntentions =>
      selectedTaskIds.isNotEmpty || freeIntentions.isNotEmpty;

  /// 전체 의도 개수
  int get totalIntentionCount => selectedTaskIds.length + freeIntentions.length;

  /// 완료된 자유 의도 개수
  int get completedFreeIntentionCount =>
      freeIntentionCompleted.where((c) => c).length;

  /// 오늘 날짜인지 확인
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  /// 날짜를 ID 형식으로 변환
  static String _formatDateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 표시 문자열
  String get displayDate {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  /// 복사본 생성
  DailyRecord copyWith({
    String? id,
    DateTime? date,
    List<int>? selectedTaskIds,
    List<String>? freeIntentions,
    List<bool>? freeIntentionCompleted,
    DateTime? morningCompletedAt,
    String? eveningReflection,
    int? satisfactionRating,
    DateTime? eveningCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      selectedTaskIds: selectedTaskIds ?? List.from(this.selectedTaskIds),
      freeIntentions: freeIntentions ?? List.from(this.freeIntentions),
      freeIntentionCompleted:
          freeIntentionCompleted ?? List.from(this.freeIntentionCompleted),
      morningCompletedAt: morningCompletedAt ?? this.morningCompletedAt,
      eveningReflection: eveningReflection ?? this.eveningReflection,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
      eveningCompletedAt: eveningCompletedAt ?? this.eveningCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyRecord(id: $id, tasks: ${selectedTaskIds.length}, freeIntentions: ${freeIntentions.length}, morning: $isMorningCompleted, evening: $isEveningCompleted)';
  }
}
