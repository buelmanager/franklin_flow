// lib/core/constants/app_strings.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 앱 문자열 상수
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   - 앱 이름: AppStrings.appName
///   - 버튼 텍스트: AppStrings.btnSave
///
/// 다국어 지원 시:
///   이 파일을 기반으로 l10n 패키지로 마이그레이션 가능
/// ═══════════════════════════════════════════════════════════════════════════

class AppStrings {
  AppStrings._(); // 인스턴스화 방지

  // ─────────────────────────────────────────────────────────────────────────
  // 앱 기본 정보
  // ─────────────────────────────────────────────────────────────────────────

  static const String appName = 'Franklin Flow';
  static const String appSlogan = '벤자민 프랭클린의 시간 관리 철학';

  // ─────────────────────────────────────────────────────────────────────────
  // 인사말
  // ─────────────────────────────────────────────────────────────────────────

  static const String greetingMorning = 'Good Morning';
  static const String greetingAfternoon = 'Good Afternoon';
  static const String greetingEvening = 'Good Evening';

  // ─────────────────────────────────────────────────────────────────────────
  // 네비게이션
  // ─────────────────────────────────────────────────────────────────────────

  static const String navHome = '홈';
  static const String navAnalytics = '분석';
  static const String navSchedule = '일정';
  static const String navSettings = '설정';

  // ─────────────────────────────────────────────────────────────────────────
  // 홈 화면
  // ─────────────────────────────────────────────────────────────────────────

  static const String todayProgress = 'Today\'s Progress';
  static const String priorityTasks = 'Priority Tasks';
  static const String thisWeek = 'This Week';
  static const String done = 'Done';

  // ─────────────────────────────────────────────────────────────────────────
  // 태스크 상태
  // ─────────────────────────────────────────────────────────────────────────

  static const String statusCompleted = 'Completed';
  static const String statusInProgress = 'In Progress';
  static const String statusPending = 'Pending';

  // ─────────────────────────────────────────────────────────────────────────
  // 버튼 텍스트
  // ─────────────────────────────────────────────────────────────────────────

  static const String btnSave = '저장';
  static const String btnCancel = '취소';
  static const String btnDelete = '삭제';
  static const String btnEdit = '편집';
  static const String btnAdd = '추가';
  static const String btnConfirm = '확인';

  // ─────────────────────────────────────────────────────────────────────────
  // 요일
  // ─────────────────────────────────────────────────────────────────────────

  static const List<String> weekdaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> weekdaysKor = ['월', '화', '수', '목', '금', '토', '일'];

  // ─────────────────────────────────────────────────────────────────────────
  // 목표 카테고리
  // ─────────────────────────────────────────────────────────────────────────

  static const String goalWorkout = 'Workout';
  static const String goalReading = 'Reading';
  static const String goalWater = 'Water';
  static const String goalMeditation = 'Meditation';

  // ─────────────────────────────────────────────────────────────────────────
  // 에러 메시지
  // ─────────────────────────────────────────────────────────────────────────

  static const String errorGeneral = '오류가 발생했습니다';
  static const String errorNetwork = '네트워크 연결을 확인해주세요';
  static const String errorEmpty = '내용을 입력해주세요';

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// 현재 시간에 따른 인사말 반환
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return greetingMorning;
    if (hour < 18) return greetingAfternoon;
    return greetingEvening;
  }

  /// 요일 인덱스로 요일명 반환 (1=월요일)
  static String getWeekday(int weekday, {bool korean = false}) {
    final index = (weekday - 1) % 7;
    return korean ? weekdaysKor[index] : weekdaysShort[index];
  }
}
