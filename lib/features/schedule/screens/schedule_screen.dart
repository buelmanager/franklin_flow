// lib/features/schedule/screens/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 일정 화면 (Schedule Screen)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 프랭클린 철학 기반 일정 관리
/// - 월간/주간 캘린더 뷰 (스크롤 시 전환)
/// - 선택 날짜 할 일 목록
/// - 다짐 완료 표시
/// - 시간대별 타임라인
///
/// ═══════════════════════════════════════════════════════════════════════════

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  late ScrollController _scrollController;

  // 캘린더 뷰 상태
  bool _isWeekView = false;

  // 임시 데이터: 다짐 완료된 날짜들
  final Set<DateTime> _completedDates = {
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 2)),
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 6)),
    DateTime.now().subtract(const Duration(days: 7)),
  };

  // 임시 데이터: 날짜별 일정
  final Map<String, List<_ScheduleItem>> _scheduleData = {};

  // 임시 데이터: 날짜별 성찰 기록
  final Map<String, _ReflectionRecord> _reflectionData = {};

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _initScheduleData();
    _initReflectionData();

    AppLogger.d('ScheduleScreen init', tag: 'ScheduleScreen');
  }

  void _initScheduleData() {
    // 오늘 일정 샘플
    final today = _dateKey(DateTime.now());
    _scheduleData[today] = [
      _ScheduleItem(
        title: '아침 다짐',
        time: '06:00',
        type: _ScheduleType.morning,
        isCompleted: true,
      ),
      _ScheduleItem(
        title: '프로젝트 기획서 작성',
        time: '09:00',
        duration: '2시간',
        type: _ScheduleType.task,
        category: '업무',
        isCompleted: false,
      ),
      _ScheduleItem(
        title: '팀 미팅',
        time: '14:00',
        duration: '1시간',
        type: _ScheduleType.task,
        category: '업무',
        isCompleted: false,
      ),
      _ScheduleItem(
        title: '운동',
        time: '18:00',
        duration: '1시간',
        type: _ScheduleType.task,
        category: '운동',
        isCompleted: false,
      ),
      _ScheduleItem(
        title: '저녁 성찰',
        time: '22:00',
        type: _ScheduleType.evening,
        isCompleted: false,
      ),
    ];
  }

  void _initReflectionData() {
    // 과거 성찰 기록 샘플
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    _reflectionData[yesterday] = _ReflectionRecord(
      date: DateTime.now().subtract(const Duration(days: 1)),
      resolutions: ['프로젝트 기획서 작성', '운동하기', '독서 30분'],
      completedCount: 2,
      reflectionText:
          '오늘 기획서 작성을 완료했다. 운동도 했지만 독서는 하지 못했다. '
          '내일은 아침에 일찍 일어나서 독서 시간을 확보해야겠다.',
      mood: 4,
      gratitude: '팀원들의 피드백이 도움이 되었다.',
    );

    final twoDaysAgo = _dateKey(
      DateTime.now().subtract(const Duration(days: 2)),
    );
    _reflectionData[twoDaysAgo] = _ReflectionRecord(
      date: DateTime.now().subtract(const Duration(days: 2)),
      resolutions: ['회의 준비', '이메일 정리', '가족과 저녁식사'],
      completedCount: 3,
      reflectionText:
          '모든 다짐을 완료한 보람찬 하루였다. '
          '특히 가족과 함께한 저녁식사가 행복했다.',
      mood: 5,
      gratitude: '건강한 하루를 보낼 수 있어서 감사하다.',
    );

    final threeDaysAgo = _dateKey(
      DateTime.now().subtract(const Duration(days: 3)),
    );
    _reflectionData[threeDaysAgo] = _ReflectionRecord(
      date: DateTime.now().subtract(const Duration(days: 3)),
      resolutions: ['보고서 마감', '병원 예약'],
      completedCount: 1,
      reflectionText:
          '보고서 마감은 했지만 병원 예약을 잊어버렸다. '
          '내일 꼭 해야지.',
      mood: 3,
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 스크롤 감도 설정 (값이 클수록 더 많이 스크롤해야 전환됨)
  // ─────────────────────────────────────────────────────────────────────────
  static const double _scrollThresholdToWeekView = 150.0; // 주간 뷰로 전환
  static const double _scrollThresholdToMonthView = 30.0; // 월간 뷰로 복귀

  /// 스크롤 감지 → 캘린더 뷰 전환
  void _onScroll() {
    final offset = _scrollController.offset;

    // 스크롤 다운: 월간 → 주간 뷰
    if (offset > _scrollThresholdToWeekView && !_isWeekView) {
      setState(() {
        _isWeekView = true;
      });
      AppLogger.d(
        'Switch to week view (offset: $offset)',
        tag: 'ScheduleScreen',
      );
    }
    // 스크롤 업 (맨 위): 주간 → 월간 뷰
    else if (offset <= _scrollThresholdToMonthView && _isWeekView) {
      setState(() {
        _isWeekView = false;
      });
      AppLogger.d(
        'Switch to month view (offset: $offset)',
        tag: 'ScheduleScreen',
      );
    }
  }

  /// 캘린더 뷰 토글 (탭으로 전환)
  void _toggleCalendarView() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
    AppLogger.d('Calendar view toggled: $_isWeekView', tag: 'ScheduleScreen');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('ScheduleScreen build', tag: 'ScheduleScreen');

    return Column(
      children: [
        // 헤더 + 월 선택
        _buildHeader(),

        // 캘린더 (애니메이션)
        _buildCalendar(),

        // 구분선
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          child: Divider(color: AppColors.textTertiary.withOpacity(0.2)),
        ),

        // 선택 날짜 일정
        Expanded(child: _buildDaySchedule()),
      ],
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: AppSizes.iconL,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.navSchedule, style: AppTextStyles.heading2),
              Text(
                '일정을 계획하고 실천하세요',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 오늘로 이동 버튼
          GestureDetector(
            onTap: _goToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                '오늘',
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더
  Widget _buildCalendar() {
    return GestureDetector(
      onTap: _toggleCalendarView,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              // 월 네비게이션
              _buildMonthNavigation(),
              const SizedBox(height: AppSizes.spaceM),

              // 요일 헤더
              _buildWeekdayHeader(),
              const SizedBox(height: AppSizes.spaceS),

              // 날짜 그리드 (월간 or 주간)
              AnimatedCrossFade(
                firstChild: _buildMonthGrid(),
                secondChild: _buildWeekGrid(),
                crossFadeState: _isWeekView
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),

              // 뷰 전환 힌트
              _buildViewToggleHint(),
            ],
          ),
        ),
      ),
    );
  }

  /// 뷰 전환 힌트
  Widget _buildViewToggleHint() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spaceS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isWeekView ? Icons.expand_more : Icons.expand_less,
            size: 16,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            _isWeekView ? '탭하여 월간 보기' : '스크롤하여 주간 보기',
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.textTertiary.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 월/주 네비게이션
  Widget _buildMonthNavigation() {
    String titleText;
    if (_isWeekView) {
      final weekDates = _getWeekDates(_selectedDate);
      final startDate = weekDates.first;
      final endDate = weekDates.last;
      if (startDate.month == endDate.month) {
        titleText =
            '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 - ${endDate.day}일';
      } else {
        titleText =
            '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}';
      }
    } else {
      titleText = '${_focusedMonth.year}년 ${_focusedMonth.month}월';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _isWeekView ? _previousWeek : _previousMonth,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(
              Icons.chevron_left,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            titleText,
            style: AppTextStyles.heading4,
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
          onTap: _isWeekView ? _nextWeek : _nextMonth,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 요일 헤더
  Widget _buildWeekdayHeader() {
    // 주간 뷰에서는 셀에 요일이 표시되므로 숨김
    if (_isWeekView) {
      return const SizedBox.shrink();
    }

    return Row(
      children: AppStrings.weekdaysKor.map((day) {
        final isWeekend = day == '토' || day == '일';
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.labelS.copyWith(
                color: isWeekend
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 월간 날짜 그리드
  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );

    // 월요일 시작으로 조정 (1 = Monday)
    int startWeekday = firstDayOfMonth.weekday;
    final daysBeforeMonth = startWeekday - 1;
    final totalDays = daysBeforeMonth + lastDayOfMonth.day;
    final totalRows = (totalDays / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final dayIndex = rowIndex * 7 + colIndex - daysBeforeMonth + 1;

            if (dayIndex < 1 || dayIndex > lastDayOfMonth.day) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayIndex,
            );

            return Expanded(child: _buildDateCell(date));
          }),
        );
      }),
    );
  }

  /// 주간 날짜 그리드 (선택된 날짜 기준 해당 주)
  Widget _buildWeekGrid() {
    final weekDates = _getWeekDates(_selectedDate);

    return Row(
      children: weekDates.map((date) {
        return Expanded(child: _buildDateCell(date, isWeekView: true));
      }).toList(),
    );
  }

  /// 선택된 날짜가 포함된 주의 날짜들 반환
  List<DateTime> _getWeekDates(DateTime date) {
    // 월요일 시작
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));

    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// 날짜 셀
  Widget _buildDateCell(DateTime date, {bool isWeekView = false}) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);
    final isCompleted = _completedDates.any((d) => _isSameDay(d, date));
    final hasSchedule = _scheduleData.containsKey(_dateKey(date));
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final isCurrentMonth = date.month == _focusedMonth.month;

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        height: isWeekView ? 56 : 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue
              : isToday
              ? AppColors.accentBlue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 주간 뷰에서는 요일도 표시
            if (isWeekView)
              Text(
                AppStrings.weekdaysKor[date.weekday - 1],
                style: AppTextStyles.labelS.copyWith(
                  color: isSelected
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            // 날짜 숫자
            Text(
              '${date.day}',
              style: AppTextStyles.bodyS.copyWith(
                color: isSelected
                    ? Colors.white
                    : !isCurrentMonth && !isWeekView
                    ? AppColors.textTertiary.withOpacity(0.3)
                    : isToday
                    ? AppColors.accentBlue
                    : isWeekend
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: isWeekView ? 16 : 14,
              ),
            ),
            // 다짐 완료 표시 (하단 점)
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCompleted)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasSchedule && !isCompleted)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.accentOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (!isCompleted && !hasSchedule)
                  const SizedBox(width: 5, height: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 선택 날짜 일정
  Widget _buildDaySchedule() {
    final schedules = _scheduleData[_dateKey(_selectedDate)] ?? [];
    final reflection = _reflectionData[_dateKey(_selectedDate)];
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final isPast = _selectedDate.isBefore(DateTime.now()) && !isToday;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Row(
            children: [
              Text(
                '${_selectedDate.month}월 ${_selectedDate.day}일',
                style: AppTextStyles.heading4,
              ),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                '(${AppStrings.weekdaysKor[_selectedDate.weekday - 1]})',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: AppSizes.spaceS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  ),
                  child: Text(
                    '오늘',
                    style: AppTextStyles.labelS.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // 일정 추가 버튼
              GestureDetector(
                onTap: _addSchedule,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.accentPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 일정 목록 + 성찰 기록
          Expanded(
            child: (schedules.isEmpty && reflection == null)
                ? _buildEmptySchedule()
                : _buildScheduleWithReflection(schedules, reflection, isPast),
          ),
        ],
      ),
    );
  }

  /// 일정 + 성찰 기록 통합 리스트
  Widget _buildScheduleWithReflection(
    List<_ScheduleItem> schedules,
    _ReflectionRecord? reflection,
    bool isPast,
  ) {
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // 일정 타임라인
        if (schedules.isNotEmpty) ...[
          ...schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildScheduleItem(
              item,
              isLast: index == schedules.length - 1 && reflection == null,
            );
          }),
        ],

        // 성찰 기록 카드 (과거 날짜에만 표시)
        if (reflection != null) ...[
          const SizedBox(height: AppSizes.spaceM),
          _buildReflectionCard(reflection),
        ],

        // 과거인데 성찰 기록이 없는 경우
        if (isPast && reflection == null && schedules.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spaceM),
          _buildNoReflectionCard(),
        ],

        // 하단 여백
        const SizedBox(height: 100),
      ],
    );
  }

  /// 성찰 기록 카드
  Widget _buildReflectionCard(_ReflectionRecord reflection) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentPurple, AppColors.accentBlue],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text('저녁 성찰 기록', style: AppTextStyles.heading4),
              const Spacer(),
              // 기분 이모지
              Text(
                _getMoodEmoji(reflection.mood),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 다짐 완료 현황
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.accentGreen,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  '다짐 ${reflection.completedCount}/${reflection.resolutions.length} 완료',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // 완료율
                Text(
                  '${((reflection.completedCount / reflection.resolutions.length) * 100).toInt()}%',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 다짐 목록
          Wrap(
            spacing: AppSizes.spaceS,
            runSpacing: AppSizes.spaceS,
            children: reflection.resolutions.asMap().entries.map((entry) {
              final index = entry.key;
              final resolution = entry.value;
              final isCompleted = index < reflection.completedCount;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accentGreen.withOpacity(0.15)
                      : AppColors.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check : Icons.close,
                      size: 12,
                      color: isCompleted
                          ? AppColors.accentGreen
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      resolution,
                      style: AppTextStyles.labelS.copyWith(
                        color: isCompleted
                            ? AppColors.accentGreen
                            : AppColors.textTertiary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 성찰 내용
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.textTertiary.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '오늘의 성찰',
                      style: AppTextStyles.labelS.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  reflection.reflectionText,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          // 감사한 점 (있는 경우)
          if (reflection.gratitude != null) ...[
            const SizedBox(height: AppSizes.spaceM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentOrange.withOpacity(0.1),
                    AppColors.accentOrange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🙏', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감사한 점',
                          style: AppTextStyles.labelS.copyWith(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reflection.gratitude!,
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 성찰 기록 없음 카드
  Widget _buildNoReflectionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.textTertiary.withOpacity(0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.nights_stay_outlined,
            size: 24,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성찰 기록 없음',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '이 날은 저녁 성찰을 기록하지 않았어요',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 기분 이모지
  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 5:
        return '😄';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😔';
      case 1:
        return '😫';
      default:
        return '😐';
    }
  }

  /// 빈 일정
  Widget _buildEmptySchedule() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 48,
                color: AppColors.textTertiary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                '일정이 없습니다',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                '새로운 할 일을 추가해보세요',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textTertiary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 일정 목록 (스크롤 컨트롤러 적용)
  // _buildScheduleWithReflection으로 대체됨

  /// 일정 아이템
  Widget _buildScheduleItem(_ScheduleItem item, {bool isLast = false}) {
    Color accentColor;
    IconData icon;

    switch (item.type) {
      case _ScheduleType.morning:
        accentColor = AppColors.accentOrange;
        icon = Icons.wb_sunny_outlined;
        break;
      case _ScheduleType.evening:
        accentColor = AppColors.accentPurple;
        icon = Icons.nights_stay_outlined;
        break;
      case _ScheduleType.task:
      default:
        accentColor = AppColors.accentBlue;
        icon = Icons.task_alt_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간
          SizedBox(
            width: 50,
            child: Text(
              item.time,
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 타임라인 바
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? AppColors.accentGreen
                      : accentColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isCompleted
                        ? AppColors.accentGreen
                        : accentColor,
                    width: 2,
                  ),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 50,
                  color: AppColors.textTertiary.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.spaceM),

          // 일정 카드
          Expanded(
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Row(
                children: [
                  // 아이콘
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(icon, size: 18, color: accentColor),
                  ),
                  const SizedBox(width: AppSizes.spaceM),

                  // 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (item.duration != null || item.category != null)
                          const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.duration != null)
                              Text(
                                item.duration!,
                                style: AppTextStyles.labelS.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            if (item.duration != null && item.category != null)
                              Text(
                                ' · ',
                                style: AppTextStyles.labelS.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            if (item.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusXS,
                                  ),
                                ),
                                child: Text(
                                  item.category!,
                                  style: AppTextStyles.labelS.copyWith(
                                    color: accentColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 완료 체크
                  if (item.type == _ScheduleType.task)
                    GestureDetector(
                      onTap: () => _toggleComplete(item),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item.isCompleted
                              ? AppColors.accentGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.isCompleted
                                ? AppColors.accentGreen
                                : AppColors.textTertiary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: item.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 헬퍼 메서드
  // ─────────────────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    AppLogger.ui('Date selected: $date', screen: 'ScheduleScreen');
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      // 월도 함께 업데이트
      _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      // 월도 함께 업데이트
      _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  void _addSchedule() {
    // TODO: 일정 추가 다이얼로그
    AppLogger.ui('Add schedule tapped', screen: 'ScheduleScreen');
  }

  void _toggleComplete(_ScheduleItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
    AppLogger.ui(
      'Schedule item toggled: ${item.title} -> ${item.isCompleted}',
      screen: 'ScheduleScreen',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 모델
// ─────────────────────────────────────────────────────────────────────────────

enum _ScheduleType { morning, task, evening }

class _ScheduleItem {
  final String title;
  final String time;
  final String? duration;
  final _ScheduleType type;
  final String? category;
  bool isCompleted;

  _ScheduleItem({
    required this.title,
    required this.time,
    this.duration,
    required this.type,
    this.category,
    this.isCompleted = false,
  });
}

/// 성찰 기록 모델
class _ReflectionRecord {
  final DateTime date;
  final List<String> resolutions;
  final int completedCount;
  final String reflectionText;
  final int mood; // 1-5
  final String? gratitude;

  _ReflectionRecord({
    required this.date,
    required this.resolutions,
    required this.completedCount,
    required this.reflectionText,
    required this.mood,
    this.gratitude,
  });
}
