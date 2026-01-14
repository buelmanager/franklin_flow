// lib/services/daily_record_service.dart

import '../core/utils/app_logger.dart';
import '../shared/models/daily_record_model.dart';
import 'local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DailyRecordService - Today's Good 일일 기록 관리
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 아침 의도와 저녁 성찰을 관리하는 서비스
///
/// 주요 기능:
/// - 오늘의 기록 조회/생성
/// - 아침 의도 설정 (Task 선택 + 자유 의도)
/// - 저녁 성찰 저장
/// - 과거 기록 조회
///
/// 사용법:
///   final service = DailyRecordService();
///   final todayRecord = service.getTodayRecord();
///   service.addTaskToIntention(taskId);
/// ═══════════════════════════════════════════════════════════════════════════

class DailyRecordService {
  static const String _tag = 'DailyRecordService';

  DailyRecordService._();
  static final DailyRecordService _instance = DailyRecordService._();
  factory DailyRecordService() => _instance;

  final LocalStorageService _storage = LocalStorageService();

  // ─────────────────────────────────────────────────────────────────────────
  // 기록 조회
  // ─────────────────────────────────────────────────────────────────────────

  /// 오늘의 기록 조회 (없으면 생성)
  DailyRecord getTodayRecord() {
    final today = DateTime.now();
    final record = getRecordByDate(today);

    if (record != null) {
      AppLogger.d('Today record found: ${record.id}', tag: _tag);
      return record;
    }

    // 새 레코드 생성
    final newRecord = DailyRecord.forToday();
    AppLogger.i('Created new today record: ${newRecord.id}', tag: _tag);
    return newRecord;
  }

  /// 특정 날짜의 기록 조회
  DailyRecord? getRecordByDate(DateTime date) {
    final dateId = _formatDateId(date);
    return _storage.getDailyRecord(dateId);
  }

  /// 특정 ID로 기록 조회
  DailyRecord? getRecordById(String id) {
    return _storage.getDailyRecord(id);
  }

  /// 모든 기록 조회
  List<DailyRecord> getAllRecords() {
    return _storage.getDailyRecords();
  }

  /// 최근 N일간의 기록 조회
  List<DailyRecord> getRecentRecords(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    return getAllRecords().where((r) => r.date.isAfter(startDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 의도 관리
  // ─────────────────────────────────────────────────────────────────────────

  /// Task를 오늘의 의도에 추가
  Future<bool> addTaskToIntention(int taskId) async {
    try {
      final record = getTodayRecord();
      record.addSelectedTaskId(taskId);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Task added to intention: $taskId', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to add task to intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Task를 오늘의 의도에서 제거
  Future<bool> removeTaskFromIntention(int taskId) async {
    try {
      final record = getTodayRecord();
      record.removeSelectedTaskId(taskId);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Task removed from intention: $taskId', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to remove task from intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Task 의도 토글
  Future<bool> toggleTaskIntention(int taskId) async {
    try {
      final record = getTodayRecord();
      final isSelected = record.toggleSelectedTaskId(taskId);
      await _storage.saveDailyRecord(record);

      AppLogger.i(
        'Task intention toggled: $taskId -> ${isSelected ? 'selected' : 'deselected'}',
        tag: _tag,
      );
      return isSelected;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to toggle task intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 자유 의도 추가
  Future<bool> addFreeIntention(String intention) async {
    try {
      if (intention.trim().isEmpty) return false;

      final record = getTodayRecord();
      record.addFreeIntention(intention);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Free intention added: $intention', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to add free intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 자유 의도 제거
  Future<bool> removeFreeIntention(int index) async {
    try {
      final record = getTodayRecord();
      record.removeFreeIntention(index);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Free intention removed at index: $index', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to remove free intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 자유 의도 완료 토글
  Future<bool> toggleFreeIntentionCompleted(int index) async {
    try {
      final record = getTodayRecord();
      record.toggleFreeIntentionCompleted(index);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Free intention toggled at index: $index', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to toggle free intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 아침 의도 완료 처리
  Future<bool> completeMorningIntention() async {
    try {
      final record = getTodayRecord();
      record.completeMorningIntention();
      await _storage.saveDailyRecord(record);

      AppLogger.i('Morning intention completed', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to complete morning intention',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 관리
  // ─────────────────────────────────────────────────────────────────────────

  /// 저녁 성찰 저장
  Future<bool> saveEveningReflection(String reflection, int rating) async {
    try {
      final record = getTodayRecord();
      record.setEveningReflection(reflection, rating);
      await _storage.saveDailyRecord(record);

      AppLogger.i('Evening reflection saved with rating: $rating', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to save evening reflection',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 저녁 성찰 완료 처리
  Future<bool> completeEveningReflection() async {
    try {
      final record = getTodayRecord();
      record.completeEveningReflection();
      await _storage.saveDailyRecord(record);

      AppLogger.i('Evening reflection completed', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to complete evening reflection',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 기록 저장/삭제
  // ─────────────────────────────────────────────────────────────────────────

  /// 기록 저장
  Future<bool> saveRecord(DailyRecord record) async {
    try {
      await _storage.saveDailyRecord(record);
      AppLogger.d('Record saved: ${record.id}', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to save record',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 기록 삭제
  Future<bool> deleteRecord(String id) async {
    try {
      await _storage.deleteDailyRecord(id);
      AppLogger.i('Record deleted: $id', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete record',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 통계
  // ─────────────────────────────────────────────────────────────────────────

  /// 연속 기록 일수 계산
  int getStreakDays() {
    final records = getAllRecords()..sort((a, b) => b.date.compareTo(a.date));

    if (records.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);

    for (final record in records) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );

      if (recordDate == checkDate && record.isDayCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (recordDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  /// 평균 만족도 계산
  double getAverageSatisfaction({int? days}) {
    var records = getAllRecords();

    if (days != null) {
      final startDate = DateTime.now().subtract(Duration(days: days));
      records = records.where((r) => r.date.isAfter(startDate)).toList();
    }

    final ratingsRecords = records
        .where((r) => r.satisfactionRating != null)
        .toList();

    if (ratingsRecords.isEmpty) return 0;

    final sum = ratingsRecords.fold<int>(
      0,
      (sum, r) => sum + r.satisfactionRating!,
    );
    return sum / ratingsRecords.length;
  }

  /// 완료된 일수
  int getCompletedDays({int? days}) {
    var records = getAllRecords();

    if (days != null) {
      final startDate = DateTime.now().subtract(Duration(days: days));
      records = records.where((r) => r.date.isAfter(startDate)).toList();
    }

    return records.where((r) => r.isDayCompleted).length;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  /// 날짜를 ID 형식으로 변환
  String _formatDateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
