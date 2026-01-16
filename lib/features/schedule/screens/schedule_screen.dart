// lib/features/schedule/screens/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 일정 화면 (Schedule Screen)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 프랭클린 철학 기반 일정 관리
/// - 월간/주간 캘린더 뷰 (탭 버튼으로 전환)
/// - 선택 날짜 할 일 목록 (실제 DailyRecord/Task 데이터)
/// - 다짐 완료 표시
/// - 성찰 기록 표시
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

  // 캘린더 뷰 상태 (기본: 주간)
  bool _isWeekView = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();

    AppLogger.d('ScheduleScreen init', tag: 'ScheduleScreen');
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // 월/주 네비게이션
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

            // 뷰 전환 버튼 (캘린더 하단)
            const SizedBox(height: AppSizes.spaceM),
            _buildViewToggleButton(),
          ],
        ),
      ),
    );
  }

  /// 뷰 전환 토글 버튼
  Widget _buildViewToggleButton() {
    return GestureDetector(
      onTap: _toggleCalendarView,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: AppColors.accentPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isWeekView ? Icons.calendar_month_rounded : Icons.view_week_rounded,
              size: 16,
              color: AppColors.accentPurple,
            ),
            const SizedBox(width: 6),
            Text(
              _isWeekView ? '월간' : '주간',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final dailyRecordService = ref.watch(dailyRecordServiceProvider);
    final record = dailyRecordService.getRecordByDate(date);

    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);
    final isCompleted = record?.isDayCompleted ?? false;
    final hasSchedule = record?.hasIntentions ?? false;
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
    final dailyRecordService = ref.watch(dailyRecordServiceProvider);
    final tasks = ref.watch(taskListProvider);
    final categories = ref.watch(categoryListProvider);
    final record = dailyRecordService.getRecordByDate(_selectedDate);

    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final isPast = _selectedDate.isBefore(DateTime.now()) && !isToday;

    // DailyRecord에서 의도 데이터 추출
    final List<_IntentionItem> intentions = [];

    // Task 기반 의도
    if (record != null) {
      for (final taskId in record.selectedTaskIds) {
        final task = tasks.where((t) => t.id == taskId).firstOrNull;
        if (task != null) {
          final category = categories.where((c) => c.id == task.categoryId).firstOrNull;
          intentions.add(_IntentionItem(
            title: task.title,
            type: _IntentionType.task,
            category: category?.name,
            categoryColor: category != null ? Color(category.colorValue) : null,
            isCompleted: task.isCompleted,
            taskId: task.id,
            timeInMinutes: task.timeInMinutes,
          ));
        }
      }

      // 자유 의도
      for (int i = 0; i < record.freeIntentions.length; i++) {
        final isComplete = i < record.freeIntentionCompleted.length
            ? record.freeIntentionCompleted[i]
            : false;
        intentions.add(_IntentionItem(
          title: record.freeIntentions[i],
          type: _IntentionType.free,
          isCompleted: isComplete,
          freeIndex: i,
        ));
      }
    }

    // 성찰 기록 확인
    final hasReflection = record?.eveningReflection != null;

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
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 일정 목록 + 성찰 기록
          Expanded(
            child: (intentions.isEmpty && !hasReflection)
                ? _buildEmptySchedule()
                : _buildScheduleWithReflection(intentions, record, isPast),
          ),
        ],
      ),
    );
  }

  /// 일정 + 성찰 기록 통합 리스트
  Widget _buildScheduleWithReflection(
    List<_IntentionItem> intentions,
    DailyRecord? record,
    bool isPast,
  ) {
    final hasReflection = record?.eveningReflection != null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // 의도 타임라인
        if (intentions.isNotEmpty) ...[
          ...intentions.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildIntentionItem(
              item,
              isLast: index == intentions.length - 1 && !hasReflection,
            );
          }),
        ],

        // 성찰 기록 카드 (과거 날짜에만 표시)
        if (hasReflection && record != null) ...[
          const SizedBox(height: AppSizes.spaceM),
          _buildReflectionCardFromRecord(record, intentions),
        ],

        // 과거인데 성찰 기록이 없는 경우
        if (isPast && !hasReflection && intentions.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spaceM),
          _buildNoReflectionCard(),
        ],

        // 하단 여백
        const SizedBox(height: 100),
      ],
    );
  }

  /// 성찰 기록 카드 (DailyRecord 기반)
  Widget _buildReflectionCardFromRecord(DailyRecord record, List<_IntentionItem> intentions) {
    final completedCount = intentions.where((i) => i.isCompleted).length;
    final totalCount = intentions.length;
    final rating = record.satisfactionRating ?? 3;
    final isToday = _isSameDay(_selectedDate, DateTime.now());

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
              // 만족도 아이콘
              _buildSatisfactionIcon(rating),
              // 삭제 버튼 (오늘만)
              if (isToday) ...[
                const SizedBox(width: AppSizes.spaceS),
                GestureDetector(
                  onTap: _removeReflection,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppColors.accentRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 다짐 완료 현황
          if (totalCount > 0)
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
                    '다짐 $completedCount/$totalCount 완료',
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // 완료율
                  Text(
                    '${(completedCount / totalCount * 100).toInt()}%',
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          if (totalCount > 0)
            const SizedBox(height: AppSizes.spaceM),

          // 다짐 목록
          if (intentions.isNotEmpty)
            Wrap(
              spacing: AppSizes.spaceS,
              runSpacing: AppSizes.spaceS,
              children: intentions.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? AppColors.accentGreen.withOpacity(0.15)
                        : AppColors.textTertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isCompleted ? Icons.check : Icons.close,
                        size: 12,
                        color: item.isCompleted
                            ? AppColors.accentGreen
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.title,
                        style: AppTextStyles.labelS.copyWith(
                          color: item.isCompleted
                              ? AppColors.accentGreen
                              : AppColors.textTertiary,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          if (intentions.isNotEmpty)
            const SizedBox(height: AppSizes.spaceM),

          // 성찰 내용
          if (record.eveningReflection != null && record.eveningReflection!.isNotEmpty)
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
                    record.eveningReflection!,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 만족도 아이콘
  Widget _buildSatisfactionIcon(int rating) {
    IconData icon;
    Color color;

    switch (rating) {
      case 5:
        icon = Icons.sentiment_very_satisfied_rounded;
        color = AppColors.accentGreen;
        break;
      case 4:
        icon = Icons.sentiment_satisfied_rounded;
        color = AppColors.accentBlue;
        break;
      case 3:
        icon = Icons.sentiment_neutral_rounded;
        color = AppColors.accentOrange;
        break;
      case 2:
        icon = Icons.sentiment_dissatisfied_rounded;
        color = AppColors.accentPink;
        break;
      case 1:
        icon = Icons.sentiment_very_dissatisfied_rounded;
        color = AppColors.accentRed;
        break;
      default:
        icon = Icons.sentiment_neutral_rounded;
        color = AppColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Icon(icon, size: 24, color: color),
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

  /// 빈 일정
  Widget _buildEmptySchedule() {
    return SingleChildScrollView(
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

  /// 의도 아이템
  Widget _buildIntentionItem(_IntentionItem item, {bool isLast = false}) {
    Color accentColor;
    IconData icon;

    if (item.type == _IntentionType.task) {
      accentColor = item.categoryColor ?? AppColors.accentBlue;
      icon = Icons.task_alt_outlined;
    } else {
      accentColor = AppColors.accentPurple;
      icon = Icons.edit_note_rounded;
    }

    // 오늘 날짜의 의도만 삭제 가능
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // 의도 카드
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
                        if (item.timeInMinutes != null || item.category != null)
                          const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.timeInMinutes != null)
                              Text(
                                '${item.timeInMinutes}분',
                                style: AppTextStyles.labelS.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            if (item.timeInMinutes != null && item.category != null)
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
                            if (item.type == _IntentionType.free)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusXS,
                                  ),
                                ),
                                child: Text(
                                  '자유 다짐',
                                  style: AppTextStyles.labelS.copyWith(
                                    color: AppColors.accentPurple,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 완료 표시
                  Container(
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

                  // 삭제 버튼 (오늘 날짜만)
                  if (isToday) ...[
                    const SizedBox(width: AppSizes.spaceS),
                    GestureDetector(
                      onTap: () {
                        if (item.type == _IntentionType.task && item.taskId != null) {
                          _removeTaskIntention(item.taskId!);
                        } else if (item.type == _IntentionType.free && item.freeIndex != null) {
                          _removeFreeIntention(item.freeIndex!);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                  ],
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

  /// Task 의도 삭제 (selectedTaskIds에서 제거)
  Future<void> _removeTaskIntention(int taskId) async {
    final confirmed = await _showDeleteConfirmDialog('이 할일을 오늘의 다짐에서 제거하시겠습니까?');
    if (confirmed != true) return;

    final success = await ref.read(todayRecordProvider.notifier).toggleTaskIntention(taskId);
    if (success) {
      AppLogger.ui('Task intention removed: $taskId', screen: 'ScheduleScreen');
    }
  }

  /// 자유 의도 삭제
  Future<void> _removeFreeIntention(int index) async {
    final confirmed = await _showDeleteConfirmDialog('이 자유 다짐을 삭제하시겠습니까?');
    if (confirmed != true) return;

    final success = await ref.read(todayRecordProvider.notifier).removeFreeIntention(index);
    if (success) {
      AppLogger.ui('Free intention removed: $index', screen: 'ScheduleScreen');
    }
  }

  /// 성찰 기록 삭제
  Future<void> _removeReflection() async {
    final confirmed = await _showDeleteConfirmDialog('성찰 기록을 삭제하시겠습니까?');
    if (confirmed != true) return;

    final success = await ref.read(todayRecordProvider.notifier).saveEveningReflection('', 0);
    if (success) {
      AppLogger.ui('Reflection removed', screen: 'ScheduleScreen');
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 24),
            const SizedBox(width: AppSizes.spaceS),
            Text('삭제 확인', style: AppTextStyles.heading4),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '삭제',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.accentRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 모델
// ─────────────────────────────────────────────────────────────────────────────

enum _IntentionType { task, free }

class _IntentionItem {
  final String title;
  final _IntentionType type;
  final String? category;
  final Color? categoryColor;
  final bool isCompleted;
  final int? taskId;
  final int? freeIndex;
  final int? timeInMinutes;

  _IntentionItem({
    required this.title,
    required this.type,
    this.category,
    this.categoryColor,
    this.isCompleted = false,
    this.taskId,
    this.freeIndex,
    this.timeInMinutes,
  });
}
