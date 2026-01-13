// lib/core/constants/app_strings.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 앱 문자열 상수
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 프랭클린 철학 기반 용어:
///   - 할 일 (Task) - 오늘 해야 할 일
///   - 다짐 (Resolution) - 프랭클린의 13덕목 중 하나
///   - 실천 (Industry) - 프랭클린의 13덕목 중 하나
///   - 성찰 (Reflection) - 저녁 질문 "What good have I done today?"
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
  static const String appSlogan = '오늘, 어떤 좋은 일을 하시겠어요?';

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

  static const String todayProgress = '오늘의 진행';
  static const String priorityTasks = '오늘의 할 일';
  static const String thisWeek = '이번 주 목표';
  static const String done = '완료';

  // ─────────────────────────────────────────────────────────────────────────
  // Focus Session - 기본
  // ─────────────────────────────────────────────────────────────────────────

  static const String focusReadyTitle = '집중할 준비가 되셨나요?';
  static const String focusReadyDescription = '할 일을 선택하고 집중 세션을 시작하세요';
  static const String focusModeActive = '집중 모드';
  static const String focusModePaused = '일시정지';
  static const String focusLabelProgress = '진행';
  static const String focusLabelTarget = '목표';
  static const String focusLabelMinutes = '분';

  // Focus Session - 통계
  static const String focusStatSessions = '세션';
  static const String focusStatFocusTime = '집중 시간';
  static const String focusTargetLabel = '목표';
  static const String focusMinuteSuffix = '분';

  // Focus Session - 버튼
  static const String focusBtnStart = '할 일 선택 & 시작';
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

  static const String focusBottomSheetTitle = '할 일 선택';
  static const String focusBottomSheetEmptyTitle = '할 일이 없습니다';
  static const String focusBottomSheetEmptyDescription =
      '먼저 할 일을 추가한 후\n집중 세션을 시작하세요!';
  static const String focusTaskProgressSuffix = '완료';

  // ─────────────────────────────────────────────────────────────────────────
  // 할 일 (Task) - 상태
  // ─────────────────────────────────────────────────────────────────────────

  static const String statusCompleted = '완료';
  static const String statusInProgress = '진행중';
  static const String statusPending = '대기중';

  // ─────────────────────────────────────────────────────────────────────────
  // 할 일 (Task) - 레이블
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskLabelProgress = '진행';

  // ─────────────────────────────────────────────────────────────────────────
  // 할 일 (Task) - 폼
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskFormTitleAdd = '새 할 일 추가';
  static const String taskFormTitleEdit = '할 일 수정';
  static const String taskFormFieldTitle = '할 일';
  static const String taskFormFieldTime = '예상 시간';
  static const String taskFormFieldCategory = '카테고리';
  static const String taskFormHintTitle = '무엇을 하시겠습니까?';
  static const String taskFormHintTime = '예: 2시간, 30분';
  static const String taskFormHintCategory = '업무, 개인, 운동 등';

  // ─────────────────────────────────────────────────────────────────────────
  // 할 일 (Task) - 진행도 다이얼로그
  // ─────────────────────────────────────────────────────────────────────────

  static const String taskProgressDialogTitle = '진행도 설정';
  static const String taskProgressDialogDescription = '의 진행도를 설정하세요';
  static const String taskProgressLabel = 'Progress';

  // 할 일 - 옵션 BottomSheet
  static const String taskOptionIncreaseProgress = '진행도 +10%';
  static const String taskOptionDecreaseProgress = '진행도 -10%';
  static const String taskOptionSetProgress = '진행도 직접 설정';
  static const String taskOptionStart = '시작하기';
  static const String taskOptionInProgress = '진행 중';
  static const String taskOptionComplete = '완료 처리';
  static const String taskOptionRestart = '다시 시작';
  static const String taskOptionEdit = '수정';
  static const String taskOptionDelete = '삭제';

  // 할 일 - 빈 상태
  static const String taskEmptyTitle = '오늘의 할 일을 추가하세요';
  static const String taskEmptyDescription =
      '오늘 해야 할 중요한 일들을 추가하고\n집중해서 하나씩 완료해보세요!';
  static const String taskEmptyAddFirst = '첫 번째 할 일 추가하기';
  static const String taskEmptyExampleTitle = '예시';
  static const String taskEmptyExample1Title = '프로젝트 기획서 작성';
  static const String taskEmptyExample1Time = '2시간';
  static const String taskEmptyExample2Title = '이메일 답장';
  static const String taskEmptyExample2Time = '30분';
  static const String taskEmptyExample3Title = '주간 회의 준비';
  static const String taskEmptyExample3Time = '1시간';

  // ─────────────────────────────────────────────────────────────────────────
  // 할 일 - 삭제 다이얼로그
  // ─────────────────────────────────────────────────────────────────────────

  static const String dialogDeleteTitle = '할 일 삭제';
  static const String dialogDeleteMessage = '이 할 일을 삭제하시겠습니까?';
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
  // SnackBar 메시지 - 할 일
  // ─────────────────────────────────────────────────────────────────────────

  static const String snackBarTaskAdded = '할 일이 추가되었습니다';
  static const String snackBarTaskUpdated = '할 일이 수정되었습니다';
  static const String snackBarTaskDeleted = '할 일이 삭제되었습니다';
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
  // Today's Good - 아침 다짐 (Morning Resolution)
  // 프랭클린: "What good shall I do this day?"
  // ─────────────────────────────────────────────────────────────────────────

  static const String morningTitle = '좋은 아침이에요';
  static const String morningQuestion = '오늘 어떤 좋은 일을 하시겠어요?';
  static const String morningSubtitle = '프랭클린의 아침 질문';
  static const String morningSelectTask = '오늘 집중할 일 선택';
  static const String morningMaxTasks = '최대 3개';
  static const String morningAddResolution = '나만의 다짐 추가';
  static const String morningResolutionHint = '오늘 실천할 일을 적어보세요...';
  static const String morningStartDay = '하루 시작하기';
  static const String morningTip = '하나 이상 선택해주세요. 너무 많으면 피로해져요.';
  static const String morningCompleted = '오늘의 다짐이 저장되었습니다';
  static const String morningEditResolution = '다짐 수정';

  // ─────────────────────────────────────────────────────────────────────────
  // Today's Good - 저녁 성찰 (Evening Reflection)
  // 프랭클린: "What good have I done today?"
  // ─────────────────────────────────────────────────────────────────────────

  static const String eveningTitle = '하루를 돌아봅시다';
  static const String eveningSubtitle = '프랭클린의 저녁 질문';
  static const String eveningQuestion = '오늘 어떤 좋은 일을 하셨나요?';
  static const String eveningMorningPlan = '오늘 아침의 다짐';
  static const String eveningReflectionLabel = '오늘의 성찰';
  static const String eveningReflectionHint = '오늘 하루를 돌아보며 기록해보세요...';
  static const String eveningSatisfaction = '오늘 하루 만족도';
  static const String eveningFinishDay = '하루 마무리하기';
  static const String eveningCompleted = '오늘 하루도 수고하셨습니다!';
  static const String eveningEncouragement = '좋은 하루를 만들어주셨어요!';
  static const String eveningMarkComplete = '지금 완료';
  static const String eveningGoToReflection = '저녁 성찰로 이동';

  // ─────────────────────────────────────────────────────────────────────────
  // Today's Good - 메인 화면
  // ─────────────────────────────────────────────────────────────────────────

  static const String dayTodayResolution = '오늘의 다짐';
  static const String dayResolutionProgress = '완료';
  static const String dayNoResolution = '아직 오늘의 다짐을 하지 않았어요';
  static const String daySetResolution = '지금 다짐하기';
  static const String dayFreeResolution = '나만의 다짐';

  // ─────────────────────────────────────────────────────────────────────────
  // Today's Good - 시간 모드 테스트
  // ─────────────────────────────────────────────────────────────────────────

  static const String testModeLabel = '모드 테스트';
  static const String testModeMorning = '아침';
  static const String testModeDay = '낮';
  static const String testModeEvening = '저녁';
  static const String testModeAuto = '자동';

  // ─────────────────────────────────────────────────────────────────────────
  // Today's Good - 공통
  // ─────────────────────────────────────────────────────────────────────────

  static const String resolutionEmpty = '선택된 다짐이 없습니다';
  static const String resolutionCount = '개 선택됨';

  // ─────────────────────────────────────────────────────────────────────────
  // 스트릭 (Streak) 관련
  // ─────────────────────────────────────────────────────────────────────────

  static const String streakTitle = '연속 실천';
  static const String streakDays = '일째';
  static const String streakDaySuffix = '일';
  static const String streakBest = '최고';
  static const String streakMessageStart = '오늘부터 새로운 시작!';
  static const String streakMessageDay1 = '좋아요! 첫 발을 내딛었어요 👏';
  static const String streakMessageDay2 = '잘하고 있어요! 계속 유지해봐요 💪';
  static const String streakMessageWeek = '일주일 가까이! 습관이 되고 있어요 🌱';
  static const String streakMessageTwoWeeks = '대단해요! 2주 연속 실천 중 ⭐';
  static const String streakMessageMonth = '한 달 가까이! 당신은 진정한 챔피언 🏆';
  static const String streakMessageLegend = '전설이 되고 있어요! 🔥🔥🔥';

  // ─────────────────────────────────────────────────────────────────────────
  // 기분 (Mood) 관련
  // ─────────────────────────────────────────────────────────────────────────

  static const String moodTitle = '오늘의 기분';
  static const String moodVeryHappy = '최고예요';
  static const String moodHappy = '좋아요';
  static const String moodNeutral = '그냥 그래요';
  static const String moodSad = '별로예요';
  static const String moodTired = '피곤해요';

  // ─────────────────────────────────────────────────────────────────────────
  // 오늘의 요약 카드 (Today Summary)
  // ─────────────────────────────────────────────────────────────────────────

  static const String todaySummaryTitle = '오늘의 하루';
  static const String todaySummaryResolutions = '오늘의 다짐';
  static const String todaySummaryNoResolution = '아직 오늘의 다짐을 하지 않았어요';
  static const String todaySummarySetResolution = '다짐하기';
  static const String todaySummaryEdit = '수정';
  static const String todaySummaryReflect = '성찰하기';
  static const String todaySummaryPracticeComplete = '실천';
  static const String todaySummaryMorning = '아침';
  static const String todaySummaryEvening = '저녁';

  // ─────────────────────────────────────────────────────────────────────────
  // 메인 화면 네비게이션
  // ─────────────────────────────────────────────────────────────────────────

  static const String backToMain = '메인으로';

  // ─────────────────────────────────────────────────────────────────────────
  // 주간 통계 미니 카드
  // ─────────────────────────────────────────────────────────────────────────

  static const String weeklyStatsTitle = '이번 주 요약';
  static const String weeklyStatsCompletion = '완료율';
  static const String weeklyStatsCompleted = '완료';
  static const String weeklyStatsStreak = '연속';

  // ─────────────────────────────────────────────────────────────────────────
  // 설정 화면 (Settings)
  // ─────────────────────────────────────────────────────────────────────────

  static const String settingsProfile = '프로필';
  static const String settingsProfileDescription = '앱에서 사용할 이름이에요';
  static const String settingsEditName = '이름 변경';
  static const String settingsNameHint = '이름을 입력하세요';

  static const String settingsTheme = '테마';
  static const String settingsDarkMode = '다크 모드';
  static const String settingsDarkModeDescription = '어두운 테마로 변경합니다';

  static const String settingsNotifications = '알림';
  static const String settingsMorningReminder = '아침 알림';
  static const String settingsEveningReminder = '저녁 알림';

  static const String settingsData = '데이터 관리';
  static const String settingsExport = '데이터 내보내기';
  static const String settingsExportDescription = 'JSON 형식으로 내보내기';
  static const String settingsReset = '데이터 초기화';
  static const String settingsResetDescription = '모든 데이터를 삭제합니다';
  static const String settingsResetConfirmTitle = '정말 초기화하시겠습니까?';
  static const String settingsResetConfirmMessage =
      '모든 할 일, 목표, 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.';
  static const String settingsResetConfirm = '초기화';
  static const String settingsResetComplete = '데이터가 초기화되었습니다';

  static const String settingsAbout = '앱 정보';
  static const String settingsMadeWith = '만든 기술';
  static const String settingsComingSoon = '준비 중인 기능입니다';

  // ─────────────────────────────────────────────────────────────────────────
  // Analytics 화면
  // ─────────────────────────────────────────────────────────────────────────

  static const String analyticsTotalTasks = '총 완료';
  static const String analyticsTotalFocus = '집중 시간';
  static const String analyticsBestStreak = '최고 기록';
  static const String analyticsCurrentStreak = '현재 연속 실천';
  static const String analyticsDaysInRow = '일 연속';
  static const String analyticsBestRecord = '최고 기록';

  static const String analyticsWeeklyProgress = '주간 완료율';
  static const String analyticsMonthlyProgress = '월간 완료율';
  static const String analyticsAverage = '평균';

  static const String analyticsInsight = 'AI 인사이트';
  static const String analyticsInsight1 =
      '이번 주 평일 완료율이 주말보다 20% 높아요. 주말에도 작은 목표를 설정해보세요!';
  static const String analyticsInsight2 = '지난주 대비 집중 시간이 15% 증가했어요. 훌륭한 성장이에요!';
  static const String analyticsInsight3 =
      '오전 시간대 집중도가 가장 높아요. 중요한 일은 오전에 배치해보세요.';

  static const String analyticsByCategory = '카테고리별 분석';

  // ─────────────────────────────────────────────────────────────────────────
  // 일정 화면 (Schedule)
  // ─────────────────────────────────────────────────────────────────────────

  static const String scheduleTitle = '일정';
  static const String scheduleSubtitle = '일정을 계획하고 실천하세요';
  static const String scheduleToday = '오늘';
  static const String scheduleNoSchedule = '일정이 없습니다';
  static const String scheduleAddNew = '새로운 할 일을 추가해보세요';
  static const String scheduleTapForMonth = '탭하여 월간 보기';
  static const String scheduleScrollForWeek = '스크롤하여 주간 보기';

  // 성찰 기록
  static const String reflectionRecordTitle = '저녁 성찰 기록';
  static const String reflectionRecordEmpty = '성찰 기록 없음';
  static const String reflectionRecordEmptyDesc = '이 날은 저녁 성찰을 기록하지 않았어요';
  static const String reflectionTodayLabel = '오늘의 성찰';
  static const String reflectionGratitudeLabel = '감사한 점';
  static const String reflectionResolutionComplete = '다짐 완료';

  // ─────────────────────────────────────────────────────────────────────────
  // 온보딩 (Onboarding)
  // ─────────────────────────────────────────────────────────────────────────

  // Page 1: 환영
  static const String onboardingWelcomeTitle = 'Franklin Flow';
  static const String onboardingWelcomeQuote =
      '"What good shall I do this day?"';
  static const String onboardingWelcomeAuthor = '- Benjamin Franklin';
  static const String onboardingWelcomeSubtitle = '오늘, 어떤 좋은 일을 하시겠어요?';
  static const String onboardingWelcomeDesc =
      '프랭클린의 시간 관리 철학을 바탕으로\n매일 더 나은 하루를 만들어보세요';
  static const String onboardingStart = '시작하기';

  // Page 2: 이름 입력
  static const String onboardingNameTitle = '어떻게 불러드릴까요?';
  static const String onboardingNameHint = '이름을 입력하세요';
  static const String onboardingNameDesc = '개인화된 인사말에 사용됩니다';
  static const String onboardingNameSkip = '나중에 설정';

  // Page 3: 알림 설정
  static const String onboardingNotificationTitle = '알림을 설정해주세요';
  static const String onboardingNotificationDesc = '매일 규칙적인 루틴을 만들어드려요';
  static const String onboardingMorningAlarm = '아침 다짐 알림';
  static const String onboardingMorningAlarmDesc = '하루를 시작하며 오늘의 다짐을 세워요';
  static const String onboardingEveningAlarm = '저녁 성찰 알림';
  static const String onboardingEveningAlarmDesc = '하루를 마무리하며 돌아봐요';
  static const String onboardingNotificationLater = '나중에 설정에서 변경할 수 있어요';

  // Page 4: 완료
  static const String onboardingCompleteTitle = '준비가 완료됐어요!';
  static const String onboardingCompleteDesc1 = '매일 아침 다짐하고';
  static const String onboardingCompleteDesc2 = '저녁에 성찰하며';
  static const String onboardingCompleteDesc3 = '더 나은 하루를 만들어보세요';
  static const String onboardingCompleteButton = '시작하기';

  // 공통
  static const String onboardingNext = '다음';
  static const String onboardingSkip = '건너뛰기';
  static const String onboardingBack = '이전';

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

  /// 할 일 제목과 함께 SnackBar 메시지 생성
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

  /// 할 일 진행도 메시지 생성
  static String taskProgressMessage(String title, int progress) {
    return '$title - $progress%';
  }

  /// 할 일 진행도 다이얼로그 설명
  static String taskProgressDialogDescriptionWithTitle(String title) {
    return '$title$taskProgressDialogDescription';
  }

  /// 카테고리 삭제 메시지
  static String categoryDeleteMessageWithTitle(String name) {
    return '$name $categoryDialogDeleteMessage';
  }

  /// 사용자 이름과 함께 아침 인사 생성
  static String morningGreeting(String userName) {
    return '$morningTitle, $userName님!';
  }

  /// 다짐 선택 개수 표시
  static String resolutionCountText(int count) {
    return '$count$resolutionCount';
  }

  /// 다짐 진행도 표시
  static String resolutionProgressText(int completed, int total) {
    return '$completed/$total $dayResolutionProgress';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 레거시 호환 (점진적 마이그레이션용)
  // ─────────────────────────────────────────────────────────────────────────

  // 기존 코드 호환을 위한 별칭
  static const String morningAddIntention = morningAddResolution;
  static const String morningIntentionHint = morningResolutionHint;
  static const String morningEditIntention = morningEditResolution;
  static const String dayTodayIntention = dayTodayResolution;
  static const String dayIntentionProgress = dayResolutionProgress;
  static const String dayNoIntention = dayNoResolution;
  static const String daySetIntention = daySetResolution;
  static const String dayFreeIntention = dayFreeResolution;
  static const String intentionEmpty = resolutionEmpty;
  static const String intentionCount = resolutionCount;
  static const String todaySummaryIntentions = todaySummaryResolutions;
  static const String todaySummaryNoIntention = todaySummaryNoResolution;
  static const String todaySummarySetIntention = todaySummarySetResolution;
  static const String todaySummaryIntentionComplete =
      todaySummaryPracticeComplete;

  static String intentionCountText(int count) => resolutionCountText(count);
  static String intentionProgressText(int completed, int total) =>
      resolutionProgressText(completed, total);
}
