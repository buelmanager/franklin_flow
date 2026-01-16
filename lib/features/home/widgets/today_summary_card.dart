// lib/features/home/widgets/today_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 오늘의 요약 카드 (Today Summary Card)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 메인 화면 상단에 표시되는 오늘 하루 요약
/// - 아침에 설정한 의도 요약
/// - 의도 진행 상황 (완료/전체) - 체크 가능
/// - 아침/저녁 상태
/// - 스트릭 정보
///
/// 사용법:
///   TodaySummaryCard(
///     selectedTaskIds: [1, 2],
///     freeIntentions: ['감사 표현'],
///     freeIntentionCompleted: [true],
///     streak: 7,
///     onEditMorning: () { ... },
///     onGoToEvening: () { ... },
///     onIntentionTaskToggle: (taskId) { ... },
///     onFreeIntentionToggle: (index) { ... },
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class TodaySummaryCard extends ConsumerWidget {
  /// 선택된 Task ID 목록
  final List<int> selectedTaskIds;

  /// 자유 의도 목록
  final List<String> freeIntentions;

  /// 자유 의도 완료 상태
  final List<bool> freeIntentionCompleted;

  /// 아침 의도 완료 여부
  final bool isMorningCompleted;

  /// 저녁 성찰 완료 여부
  final bool isEveningCompleted;

  /// 연속 달성 일수
  final int streak;

  /// 아침 의도 수정 콜백
  final VoidCallback? onEditMorning;

  /// 저녁 성찰로 이동 콜백
  final VoidCallback? onGoToEvening;

  /// 아침 의도 설정 콜백 (미설정 시)
  final VoidCallback? onSetIntention;

  /// 의도 태스크 완료 토글 콜백
  final void Function(int taskId)? onIntentionTaskToggle;

  /// 자유 의도 완료 토글 콜백
  final void Function(int index)? onFreeIntentionToggle;

  const TodaySummaryCard({
    Key? key,
    this.selectedTaskIds = const [],
    this.freeIntentions = const [],
    this.freeIntentionCompleted = const [],
    this.isMorningCompleted = false,
    this.isEveningCompleted = false,
    this.streak = 0,
    this.onEditMorning,
    this.onGoToEvening,
    this.onSetIntention,
    this.onIntentionTaskToggle,
    this.onFreeIntentionToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    // 존재하는 Task 의도만 카운트
    final validTaskCount = _getValidTaskIntentionCount(tasks);
    final hasIntentions = validTaskCount > 0 || freeIntentions.isNotEmpty;

    AppLogger.d(
      'TodaySummaryCard build - intentions: ${validTaskCount + freeIntentions.length}',
      tag: 'TodaySummaryCard',
    );

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),
          const SizedBox(height: AppSizes.spaceL),

          // 내용 (의도 유무에 따라)
          if (hasIntentions)
            _buildIntentionSummary(tasks)
          else
            _buildEmptyState(),

          // 구분선
          const SizedBox(height: AppSizes.spaceL),
          Divider(color: AppColors.textTertiary.withOpacity(0.2)),
          const SizedBox(height: AppSizes.spaceL),

          // 하단 통계 (의도 기준)
          _buildStats(tasks),
        ],
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.today,
                size: AppSizes.iconM,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Text(AppStrings.todaySummaryTitle, style: AppTextStyles.heading4),
          ],
        ),
        // 스트릭 배지
        if (streak > 0) _buildStreakBadge(),
      ],
    );
  }

  /// 스트릭 배지
  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: AppColors.accentOrange,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak${AppStrings.streakDaySuffix}',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 존재하는 Task 의도 개수 (삭제된 Task 제외)
  int _getValidTaskIntentionCount(List<Task> allTasks) {
    return selectedTaskIds.where((taskId) {
      return allTasks.any((t) => t.id == taskId);
    }).length;
  }

  /// 완료 개수 계산
  int _getCompletedCount(List<Task> allTasks) {
    // 태스크 의도 중 완료된 것 (존재하는 Task만)
    final completedTaskCount = selectedTaskIds.where((taskId) {
      final task = allTasks.where((t) => t.id == taskId).firstOrNull;
      return task != null && task.isCompleted;
    }).length;

    // 자유 의도 중 완료된 것
    final completedFreeCount = freeIntentionCompleted.where((c) => c).length;

    return completedTaskCount + completedFreeCount;
  }

  /// 의도 요약
  Widget _buildIntentionSummary(List<Task> allTasks) {
    // 존재하는 Task 의도만 카운트
    final validTaskCount = _getValidTaskIntentionCount(allTasks);
    final totalIntentions = validTaskCount + freeIntentions.length;
    final completedCount = _getCompletedCount(allTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 진행 상황 표시
        Row(
          children: [
            Text(
              AppStrings.todaySummaryIntentions,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: completedCount == totalIntentions
                    ? AppColors.accentGreen.withOpacity(0.15)
                    : AppColors.accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusXS),
              ),
              child: Text(
                '$completedCount / $totalIntentions ${AppStrings.dayIntentionProgress}',
                style: AppTextStyles.labelS.copyWith(
                  color: completedCount == totalIntentions
                      ? AppColors.accentGreen
                      : AppColors.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        // 프로그레스 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: totalIntentions > 0 ? completedCount / totalIntentions : 0,
            backgroundColor: AppColors.textTertiary.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(
              completedCount == totalIntentions
                  ? AppColors.accentGreen
                  : AppColors.accentBlue,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),

        // 의도 목록 (체크 가능)
        ..._buildIntentionList(allTasks),

        // 액션 버튼
        const SizedBox(height: AppSizes.spaceM),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_outlined,
                label: AppStrings.todaySummaryEdit,
                onTap: onEditMorning,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: _buildActionButton(
                icon: Icons.nights_stay_outlined,
                label: AppStrings.todaySummaryReflect,
                onTap: onGoToEvening,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 의도 목록 빌드 (체크 가능)
  List<Widget> _buildIntentionList(List<Task> allTasks) {
    final List<Widget> items = [];

    // Task 의도 (존재하는 Task만 표시)
    for (int i = 0; i < selectedTaskIds.length; i++) {
      final taskId = selectedTaskIds[i];
      final task = allTasks.where((t) => t.id == taskId).firstOrNull;

      // 삭제된 Task는 건너뛰기
      if (task == null) continue;

      items.add(
        _buildIntentionItem(
          title: task.title,
          isCompleted: task.isCompleted,
          icon: Icons.task_alt,
          onTap: () => onIntentionTaskToggle?.call(taskId),
        ),
      );
    }

    // 자유 의도
    for (int i = 0; i < freeIntentions.length; i++) {
      final isCompleted = i < freeIntentionCompleted.length
          ? freeIntentionCompleted[i]
          : false;
      items.add(
        _buildIntentionItem(
          title: freeIntentions[i],
          isCompleted: isCompleted,
          icon: Icons.star,
          onTap: () => onFreeIntentionToggle?.call(i),
        ),
      );
    }

    return items;
  }

  /// 의도 아이템 (체크 가능)
  Widget _buildIntentionItem({
    required String title,
    required bool isCompleted,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.accentGreen
                    : AppColors.textTertiary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: isCompleted
                    ? null
                    : Border.all(
                        color: AppColors.textTertiary.withOpacity(0.3),
                        width: 1.5,
                      ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSizes.spaceM),
            // 아이콘
            Icon(
              icon,
              size: 16,
              color: isCompleted
                  ? AppColors.accentGreen
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSizes.spaceS),
            // 제목
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyM.copyWith(
                  color: isCompleted
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 (의도 미설정)
  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.accentOrange.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                size: 32,
                color: AppColors.accentOrange,
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                AppStrings.todaySummaryNoIntention,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceM),
              NeumorphicButton(
                height: AppSizes.buttonHeightM,
                borderRadius: AppSizes.radiusS,
                onTap: onSetIntention,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: AppSizes.iconS,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Text(
                      AppStrings.todaySummarySetIntention,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하단 통계 (의도 기준으로 통합)
  Widget _buildStats(List<Task> allTasks) {
    // 존재하는 Task 의도만 카운트
    final validTaskCount = _getValidTaskIntentionCount(allTasks);
    final totalIntentions = validTaskCount + freeIntentions.length;
    final completedCount = _getCompletedCount(allTasks);

    return Row(
      children: [
        // 의도 완료
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle_outline,
            value: totalIntentions > 0
                ? '$completedCount/$totalIntentions'
                : '-',
            label: AppStrings.todaySummaryIntentionComplete,
            color: completedCount == totalIntentions && totalIntentions > 0
                ? AppColors.accentGreen
                : AppColors.accentBlue,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.textTertiary.withOpacity(0.2),
        ),
        // 아침 상태
        Expanded(
          child: _buildStatItem(
            icon: Icons.wb_sunny_outlined,
            value: isMorningCompleted ? '✓' : '-',
            label: AppStrings.todaySummaryMorning,
            color: isMorningCompleted
                ? AppColors.accentGreen
                : AppColors.textTertiary,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.textTertiary.withOpacity(0.2),
        ),
        // 저녁 상태
        Expanded(
          child: _buildStatItem(
            icon: Icons.nights_stay_outlined,
            value: isEveningCompleted ? '✓' : '-',
            label: AppStrings.todaySummaryEvening,
            color: isEveningCompleted
                ? AppColors.accentGreen
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// 통계 아이템
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: AppSizes.iconS, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelS.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 액션 버튼
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.accentPurple.withOpacity(0.15)
              : AppColors.textTertiary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconS,
              color: isPrimary
                  ? AppColors.accentPurple
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              label,
              style: AppTextStyles.labelM.copyWith(
                color: isPrimary
                    ? AppColors.accentPurple
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
