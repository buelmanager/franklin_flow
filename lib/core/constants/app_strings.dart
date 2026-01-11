// lib/core/constants/app_strings.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 앱 문자열 상수
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   - 앱 이름: AppStrings.appName
///   - 버튼 텍스트: AppStrings.btnSave
///   - Focus 관련: AppStrings.focusReadyTitle
///
/// 네이밍 컨벤션:
///   - [기능영역][컴포넌트][용도]
///   - 예: focusBtnComplete, taskLabelProgress, snackBarTaskAdded
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
  // 공통 버튼
  // ─────────────────────────────────────────────────────────────────────────

  static const String btnSave = '저장';
  static const String btnCancel = '취소';
  static const String btnDelete = '삭제';
  static const String btnEdit = '편집';
  static const String btnAdd = '추가';
  static const String btnConfirm = '확인';
  static const String btnClose = '닫기';

  // ─────────────────────────────────────────────────────────────────────────
  // 홈 화면
  // ─────────────────────────────────────────────────────────────────────────

  static const String todayProgress = '오늘의 진행도';
  static const String priorityTasks = '우선순위 태스크';
  static const String thisWeek = '이번 주 목표';
  static const String done = '완료';

  // ─────────────────────────────────────────────────────────────────────────
  // Focus Session - 기본
  // ─────────────────────────────────────────────────────────────────────────

  static const String focusReadyTitle = '집중할 준비가 되셨나요?';
  static const String focusReadyDescription = '태스크를 선택하고 집중 세션을 시작하세요';
  static const String focusModeActive = '집중 모드';
  static const String focusModePaused = '일시정지';
  static const String focusLabelProgress = '진행도';
  static const String focusLabelTarget = '목표';
  static const String focusLabelMinutes = '분';

  // Focus Session - 통계
  static const String focusStatSessions = '세션';
  static const String focusStatFocusTime = '집중 시간';
  static const String focusTargetLabel = '목표';
  static const String focusMinuteSuffix = '분';

  // Focus Session - 버튼
  static const String focusBtnStart = '태스크 선택 & 시작';
  static const String focusBtnPause = '일시정지';
  static const String focusBtnResume = '재개';
  static const String focusBtnComplete = '완료';
  static const String focusBtnCancel = '세션 취소';

  // Focus Session - 다이얼로그
  static const String focusDialogCancelTitle = '세션 취소';
  static const String focusDialogCancelMessage = '진행 중인 세션을 취소하시겠습니까?';
  static const String focusDialogCancelConfirm = '취소';
  static const String focusDialogCancelContinue = '계속하기';

  // ─────────────────────────────────────────────────────────────────────────
  // Focus Session - BottomSheet
  // ─────────────────────────────────────────────────────────────────────────

  static const String focusBottomSheetTitle = '태스크 선택';
  static const String focusBottomSheetEmptyTitle = '사용 가능한 태스크가 없습니다';
  static const String focusBottomSheetEmptyDescription =
      '먼저 태스크를 생성한 후\n집중 세션을 시작하세요!';
  static const String focusTaskProgressSuffix = '완료';

  // ─────────────────────────────────────────────────────────────────────────
  // Task - 상태
  // ─────────────────────────────────────────────────────────────────────────

  static const String statusCompleted = '완료됨';
  static const String statusInProgress = '진행중';
  static const String statusPending = '대기중';

  // ─────────────────────────────────────────────────────────────────────────
  // Task - 레이블
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskLabelProgress = '진행도';

  // ─────────────────────────────────────────────────────────────────────────
  // Task - 폼
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskFormTitleAdd = '새 태스크 추가';
  static const String taskFormTitleEdit = '태스크 수정';
  static const String taskFormFieldTitle = '태스크 제목';
  static const String taskFormFieldTime = '예상 시간';
  static const String taskFormFieldCategory = '카테고리';
  static const String taskFormHintTitle = '무엇을 하시겠습니까?';
  static const String taskFormHintTime = '예: 2시간, 30분';
  static const String taskFormHintCategory = '업무, 개인, 운동 등';

  // ─────────────────────────────────────────────────────────────────────────
  // Task - 진행도 다이얼로그
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskProgressDialogTitle = '진행도 설정';
  static const String taskProgressDialogDescription = '의 진행도를 설정하세요';
  static const String taskProgressLabel = 'Progress';

  // Task - 옵션 BottomSheet
  static const String taskOptionIncreaseProgress = '진행도 +10%';
  static const String taskOptionDecreaseProgress = '진행도 -10%';
  static const String taskOptionSetProgress = '진행도 직접 설정';
  static const String taskOptionStart = '시작하기';
  static const String taskOptionInProgress = '진행 중';
  static const String taskOptionComplete = '완료 처리';
  static const String taskOptionRestart = '다시 시작';
  static const String taskOptionEdit = '수정';
  static const String taskOptionDelete = '삭제';

  // Task - 빈 상태
  static const String taskEmptyTitle = '우선순위 태스크를 추가하세요';
  static const String taskEmptyDescription =
      '오늘 해야 할 중요한 일들을 추가하고\n집중해서 하나씩 완료해보세요!';
  static const String taskEmptyAddFirst = '첫 번째 태스크 추가하기';
  static const String taskEmptyExampleTitle = '예시';
  static const String taskEmptyExample1Title = '프로젝트 기획서 작성';
  static const String taskEmptyExample1Time = '2시간';
  static const String taskEmptyExample2Title = '이메일 답장';
  static const String taskEmptyExample2Time = '30분';
  static const String taskEmptyExample3Title = '주간 회의 준비';
  static const String taskEmptyExample3Time = '1시간';

  // ─────────────────────────────────────────────────────────────────────────
  // Task - 삭제 다이얼로그
  // ─────────────────────────────────────────────────────────────────────────

  static const String dialogDeleteTitle = '태스크 삭제';
  static const String dialogDeleteMessage = '이 태스크를 삭제하시겠습니까?';
  static const String dialogDeleteConfirm = '삭제';
  static const String dialogDeleteCancel = '취소';

  // ─────────────────────────────────────────────────────────────────────────
  // Goal - 기본
  // ─────────────────────────────────────────────────────────────────────────

  static const String goalWorkout = 'Workout';
  static const String goalReading = 'Reading';
  static const String goalWater = 'Water';
  static const String goalMeditation = 'Meditation';

  // Goal - 삭제 다이얼로그
  static const String goalDialogDeleteTitle = '목표 삭제';
  static const String goalDialogDeleteMessage = '이 목표를 삭제하시겠습니까?';

  // Goal - 빈 상태
  static const String goalEmptyTitle = '설정된 주간 목표가 없습니다';
  static const String goalEmptyDescription = '새로운 목표를 추가하여\n이번 주를 계획해보세요!';

  // Goal - 폼 다이얼로그
  static const String goalFormTitleAdd = '새 목표 추가';
  static const String goalFormTitleEdit = '목표 수정';
  static const String goalFormFieldEmoji = '이모지';
  static const String goalFormFieldName = '목표 이름';
  static const String goalFormFieldTotal = '주간 목표 횟수';
  static const String goalFormFieldColor = '색상';
  static const String goalFormHintName = '예: Workout, Reading';
  static const String goalFormHintTotal = '예: 7';
  static const String goalFormSuffixTotal = '회';

  // Goal - 검증 메시지
  static const String goalValidationNameRequired = '목표 이름을 입력해주세요';
  static const String goalValidationTotalRequired = '목표 횟수를 입력해주세요';
  static const String goalValidationTotalInvalid = '1 이상의 숫자를 입력해주세요';

  // Goal - 에러 메시지
  static const String goalErrorUpdateFailed = '목표 수정에 실패했습니다.';
  static const String goalErrorSaveFailed = '목표 저장 중 오류가 발생했습니다.';

  // Goal - 주간 목표 섹션
  static const String goalSectionEmptyTitle = '주간 목표를 설정하세요';
  static const String goalSectionEmptyDescription =
      '이번 주에 달성하고 싶은 목표를 추가해보세요.\n매일 조금씩 진행하면서 성취감을 느껴보세요!';
  static const String goalSectionAddFirst = '첫 번째 목표 추가하기';
  static const String goalSectionExampleTitle = '예시';
  static const String goalSectionExample1 = '운동 3회';
  static const String goalSectionExample2 = '독서 10페이지';
  static const String goalSectionExample3 = '물 8잔';

  // Goal - 옵션
  static const String goalOptionIncrease = '진행도 증가';
  static const String goalOptionDecrease = '진행도 감소';

  // ─────────────────────────────────────────────────────────────────────────
  // SnackBar 메시지 - Task
  // ─────────────────────────────────────────────────────────────────────────

  static const String snackBarTaskAdded = '태스크가 추가되었습니다';
  static const String snackBarTaskUpdated = '태스크가 수정되었습니다';
  static const String snackBarTaskDeleted = '태스크가 삭제되었습니다';
  static const String snackBarTaskProgressUpdated = '진행도가 업데이트되었습니다';

  // SnackBar 메시지 - Focus Session
  static const String snackBarFocusCompleted = '수고하셨습니다! 집중 세션이 완료되었습니다 🎉';

  // SnackBar 메시지 - Goal
  static const String snackBarGoalAdded = '목표가 추가되었습니다';
  static const String snackBarGoalUpdated = '목표가 수정되었습니다';
  static const String snackBarGoalDeleted = '목표가 삭제되었습니다';

  // SnackBar 메시지 - Category
  static const String snackBarCategoryDeleted = '카테고리가 삭제되었습니다';
  static const String snackBarCategoryDeleteFailed = '카테고리 삭제에 실패했습니다';

  // Screen 설명
  static const String screenAnalyticsDescription =
      '통계 및 분석 화면입니다.\n곧 업데이트 예정입니다.';
  static const String screenScheduleDescription = '일정 관리 화면입니다.\n곧 업데이트 예정입니다.';
  static const String screenSettingsDescription = '설정 화면입니다.\n곧 업데이트 예정입니다.';

  // ─────────────────────────────────────────────────────────────────────────
  // Category
  // ─────────────────────────────────────────────────────────────────────────

  static const String categoryDialogAddTitle = '새 카테고리 추가';
  static const String categoryDialogDeleteTitle = '카테고리 삭제';
  static const String categoryDialogDeleteMessage = '카테고리를 삭제하시겠습니까?';
  static const String categoryHintName = '카테고리 이름';
  static const String categorySelectPlaceholder = '카테고리를 선택하세요';
  static const String categorySelectTitle = '카테고리 선택';
  static const String categorySaved = '카테고리가 삭제되었습니다';

  // ─────────────────────────────────────────────────────────────────────────
  // TimeSelector
  // ─────────────────────────────────────────────────────────────────────────

  static const String timeSelectorPlaceholder = '시간을 선택하세요';
  static const String timeSelectorAdd30Min = '+30분';
  static const String timeSelectorAdd1Hour = '+1시간';
  static const String timeSelectorCustom = '직접입력';
  static const String timeSelectorCustomHint = '시간을 분 단위로 입력 (예: 45)';
  static const String timeSelectorMinuteSuffix = '분';
  static const String timeSelectorTotal = '총';

  // ─────────────────────────────────────────────────────────────────────────
  // 검증 메시지
  // ─────────────────────────────────────────────────────────────────────────

  static const String validationTitleRequired = '제목을 입력해주세요';
  static const String validationTimeRequired = '예상 시간을 입력해주세요';
  static const String validationCategoryRequired = '카테고리를 입력해주세요';

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

  /// Task 제목과 함께 SnackBar 메시지 생성
  static String snackBarTaskAddedWithTitle(String title) {
    return '$snackBarTaskAdded: $title';
  }

  static String snackBarTaskUpdatedWithTitle(String title) {
    return '$snackBarTaskUpdated: $title';
  }

  static String snackBarTaskDeletedWithTitle(String title) {
    return '$snackBarTaskDeleted: $title';
  }

  static String snackBarGoalDeletedWithTitle(String title) {
    return '$title $snackBarGoalDeleted';
  }

  /// Task 진행도 메시지 생성
  static String taskProgressMessage(String title, int progress) {
    return '$title - $progress%';
  }

  /// Task 진행도 다이얼로그 설명
  static String taskProgressDialogDescriptionWithTitle(String title) {
    return '$title$taskProgressDialogDescription';
  }

  /// 카테고리 삭제 메시지
  static String categoryDeleteMessageWithTitle(String name) {
    return '$name $categoryDialogDeleteMessage';
  }
}
