// lib/features/home/widgets/today_intention_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 오늘의 의도 카드 (Today Intention Card)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 낮 모드에서 홈 화면 상단에 표시되는 오늘의 의도 요약 카드
/// - 선택된 의도 목록 표시
/// - 완료 진행도 표시
/// - 아침 의도 수정 / 저녁 성찰 이동 버튼
///
/// 사용법:
///   TodayIntentionCard(
///     selectedTaskIds: [1, 2],
///     freeIntentions: ['감사 표현하기'],
///     freeIntentionCompleted: [false],
///     onEditMorning: () { ... },
///     onGoToEvening: () { ... },
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class TodayIntentionCard extends ConsumerWidget {
  /// 선택된 Task ID 목록
  final List<int> selectedTaskIds;

  /// 자유 의도 목록
  final List<String> freeIntentions;

  /// 자유 의도 완료 상태
  final List<bool> freeIntentionCompleted;

  /// 아침 의도 수정 콜백
  final VoidCallback? onEditMorning;

  /// 저녁 성찰로 이동 콜백
  final VoidCallback? onGoToEvening;

  /// 의도 설정하기 콜백 (의도가 없을 때)
  final VoidCallback? onSetIntention;

  const TodayIntentionCard({
    Key? key,
    this.selectedTaskIds = const [],
    this.freeIntentions = const [],
    this.freeIntentionCompleted = const [],
    this.onEditMorning,
    this.onGoToEvening,
    this.onSetIntention,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final hasIntentions =
        selectedTaskIds.isNotEmpty || freeIntentions.isNotEmpty;

    AppLogger.d(
      'TodayIntentionCard build - tasks: ${selectedTaskIds.length}, free: ${freeIntentions.length}',
      tag: 'TodayIntentionCard',
    );

    if (!hasIntentions) {
      return _buildEmptyState();
    }

    return _buildIntentionCard(tasks);
  }

  /// 의도 없음 상태
  Widget _buildEmptyState() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      style: NeumorphicStyle.flat,
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: AppSizes.iconXL,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSizes.spaceM),
          Text(
            AppStrings.dayNoIntention,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceL),
          NeumorphicButton(
            onTap: onSetIntention,
            height: AppSizes.buttonHeightM,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: Text(
              AppStrings.daySetIntention,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 의도 카드
  Widget _buildIntentionCard(List<Task> allTasks) {
    // 완료된 Task 수 계산
    final completedTaskCount = selectedTaskIds.where((taskId) {
      final task = allTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => Task(
          id: taskId,
          title: '',
          status: 'pending',
          progress: 0,
          timeInMinutes: 0,
          categoryId: '',
        ),
      );
      return task.isCompleted;
    }).length;

    // 완료된 자유 의도 수
    final completedFreeCount = freeIntentionCompleted.where((c) => c).length;

    final totalCount = selectedTaskIds.length + freeIntentions.length;
    final completedCount = completedTaskCount + completedFreeCount;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      style: NeumorphicStyle.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('⭐', style: AppTextStyles.bodyL),
                  const SizedBox(width: AppSizes.spaceS),
                  Text(
                    AppStrings.dayTodayIntention,
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: completedCount == totalCount
                      ? AppColors.accentGreen.withOpacity(0.2)
                      : AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  AppStrings.intentionProgressText(completedCount, totalCount),
                  style: AppTextStyles.labelM.copyWith(
                    color: completedCount == totalCount
                        ? AppColors.accentGreen
                        : AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 의도 목록 - Task
          ...selectedTaskIds.take(3).map((taskId) {
            final task = allTasks.firstWhere(
              (t) => t.id == taskId,
              orElse: () => Task(
                id: taskId,
                title: '삭제된 태스크',
                status: 'pending',
                progress: 0,
                timeInMinutes: 0,
                categoryId: '',
              ),
            );
            return _buildIntentionItem(
              title: task.title,
              isCompleted: task.isCompleted,
              icon: Icons.task_alt,
              time: task.timeString,
            );
          }),

          // 의도 목록 - 자유 의도 (toList() 추가)
          ...freeIntentions.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final intention = entry.value;
            final isCompleted = index < freeIntentionCompleted.length
                ? freeIntentionCompleted[index]
                : false;

            return _buildIntentionItem(
              title: intention,
              isCompleted: isCompleted,
              icon: Icons.star,
              isFreeIntention: true,
            );
          }),

          const SizedBox(height: AppSizes.spaceM),

          // 액션 버튼
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onEditMorning,
                  child: Text(
                    AppStrings.morningEditIntention,
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.textTertiary.withOpacity(0.3),
              ),
              Expanded(
                child: TextButton(
                  onPressed: onGoToEvening,
                  child: Text(
                    AppStrings.eveningGoToReflection,
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.accentPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 의도 항목
  Widget _buildIntentionItem({
    required String title,
    required bool isCompleted,
    required IconData icon,
    String? time,
    bool isFreeIntention = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: Row(
        children: [
          // 완료 체크
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.accentGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isCompleted
                    ? AppColors.accentGreen
                    : AppColors.textTertiary,
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppSizes.spaceS),

          // 아이콘
          Icon(
            icon,
            size: AppSizes.iconS,
            color: isFreeIntention
                ? AppColors.accentPurple
                : AppColors.accentBlue,
          ),
          const SizedBox(width: AppSizes.spaceS),

          // 제목
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyS.copyWith(
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

          // 시간 (Task인 경우)
          if (time != null)
            Text(
              time,
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

          // 자유 의도 표시
          if (isFreeIntention)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppStrings.dayFreeIntention,
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.accentPurple,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
