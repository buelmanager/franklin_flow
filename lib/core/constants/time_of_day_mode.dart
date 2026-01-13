// lib/core/constants/time_of_day_mode.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// 시간대 모드 (Time of Day Mode)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Today's Good 기능을 위한 시간대별 모드
/// - main: 메인 화면 (기본, 항상 접근 가능)
/// - morning: 아침 모드 (06:00 ~ 10:00, 의도 미설정 시)
/// - evening: 저녁 모드 (18:00 ~ 24:00, 성찰 미완료 시)
///
/// 기본 흐름:
///   1. 메인 화면이 기본
///   2. 아침 시간대 + 의도 미설정 → 아침 모드 (이벤트)
///   3. 저녁 시간대 + 성찰 미완료 → 저녁 모드 (이벤트)
///   4. 완료 후 → 메인 화면으로 복귀
/// ═══════════════════════════════════════════════════════════════════════════

enum TimeOfDayMode {
  /// 메인 화면 (기본)
  /// 홈, 태스크, 집중, 주간 목표 등
  main,

  /// 아침 모드 (06:00 ~ 10:00, 이벤트)
  /// 오늘의 의도 설정
  morning,

  /// 저녁 모드 (18:00 ~ 24:00, 이벤트)
  /// 하루 성찰
  evening,
}

/// 시간대 타입 (아침/저녁 시간대 판별용)
enum TimeSlot {
  /// 아침 시간대 (06:00 ~ 10:00)
  morning,

  /// 일반 시간대 (10:00 ~ 18:00)
  daytime,

  /// 저녁 시간대 (18:00 ~ 24:00)
  evening,

  /// 심야 시간대 (00:00 ~ 06:00)
  night,
}

/// TimeOfDayMode 확장 메서드
extension TimeOfDayModeExtension on TimeOfDayMode {
  /// 현재 시간대 슬롯 반환
  static TimeSlot currentTimeSlot() {
    return getTimeSlot(DateTime.now());
  }

  /// 특정 시간의 시간대 슬롯 반환
  static TimeSlot getTimeSlot(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 6 && hour < 10) {
      return TimeSlot.morning;
    } else if (hour >= 10 && hour < 18) {
      return TimeSlot.daytime;
    } else if (hour >= 18 && hour < 24) {
      return TimeSlot.evening;
    } else {
      return TimeSlot.night;
    }
  }

  /// 아침 시간대인지 확인
  static bool isMorningTime([DateTime? dateTime]) {
    final slot = dateTime != null ? getTimeSlot(dateTime) : currentTimeSlot();
    return slot == TimeSlot.morning;
  }

  /// 저녁 시간대인지 확인
  static bool isEveningTime([DateTime? dateTime]) {
    final slot = dateTime != null ? getTimeSlot(dateTime) : currentTimeSlot();
    return slot == TimeSlot.evening;
  }

  /// 아침 이벤트를 표시해야 하는지 확인
  /// (아침 시간대 + 아침 의도 미완료)
  static bool shouldShowMorningEvent({required bool isMorningCompleted}) {
    return isMorningTime() && !isMorningCompleted;
  }

  /// 저녁 이벤트를 표시해야 하는지 확인
  /// (저녁 시간대 + 저녁 성찰 미완료)
  static bool shouldShowEveningEvent({required bool isEveningCompleted}) {
    return isEveningTime() && !isEveningCompleted;
  }

  /// 현재 표시해야 할 모드 결정
  /// (기본: main, 조건 충족 시 morning/evening)
  static TimeOfDayMode determineMode({
    required bool isMorningCompleted,
    required bool isEveningCompleted,
  }) {
    if (shouldShowMorningEvent(isMorningCompleted: isMorningCompleted)) {
      return TimeOfDayMode.morning;
    }
    if (shouldShowEveningEvent(isEveningCompleted: isEveningCompleted)) {
      return TimeOfDayMode.evening;
    }
    return TimeOfDayMode.main;
  }

  /// [Deprecated] 기존 호환성을 위한 current() - main 반환
  static TimeOfDayMode current() {
    return TimeOfDayMode.main;
  }

  /// 모드 이름 (한글)
  String get displayName {
    switch (this) {
      case TimeOfDayMode.main:
        return '메인';
      case TimeOfDayMode.morning:
        return '아침';
      case TimeOfDayMode.evening:
        return '저녁';
    }
  }

  /// 모드 아이콘
  String get icon {
    switch (this) {
      case TimeOfDayMode.main:
        return '🏠';
      case TimeOfDayMode.morning:
        return '☀️';
      case TimeOfDayMode.evening:
        return '🌙';
    }
  }

  /// 모드별 설명
  String get description {
    switch (this) {
      case TimeOfDayMode.main:
        return '홈 화면';
      case TimeOfDayMode.morning:
        return '06:00 ~ 10:00';
      case TimeOfDayMode.evening:
        return '18:00 ~ 24:00';
    }
  }
}

/// TimeSlot 확장 메서드
extension TimeSlotExtension on TimeSlot {
  String get displayName {
    switch (this) {
      case TimeSlot.morning:
        return '아침';
      case TimeSlot.daytime:
        return '낮';
      case TimeSlot.evening:
        return '저녁';
      case TimeSlot.night:
        return '심야';
    }
  }
}
