// lib/features/home/widgets/evening_reflection_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 저녁 성찰 섹션 (Evening Reflection Section)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 저녁 모드에서 표시되는 성찰 섹션
/// - 프랭클린의 저녁 질문 카드
/// - 아침에 설정한 의도 목록 표시 (완료 여부 체크)
/// - 오늘 한 좋은 일 기록
/// - 하루 만족도 평가 (1-5 별점)
///
/// HomeHeader와 함께 사용되므로 자체 인사말 헤더 없음
/// ═══════════════════════════════════════════════════════════════════════════

class EveningReflectionSection extends ConsumerStatefulWidget {
  final List<int> selectedTaskIds;
  final List<String> freeIntentions;
  final List<bool> freeIntentionCompleted;
  final void Function(int taskId)? onTaskComplete;
  final void Function(int index)? onFreeIntentionToggle;
  final void Function(String reflection, int rating)? onSaveReflection;
  final VoidCallback? onFinishDay;

  const EveningReflectionSection({
    Key? key,
    this.selectedTaskIds = const [],
    this.freeIntentions = const [],
    this.freeIntentionCompleted = const [],
    this.onTaskComplete,
    this.onFreeIntentionToggle,
    this.onSaveReflection,
    this.onFinishDay,
  }) : super(key: key);

  @override
  ConsumerState<EveningReflectionSection> createState() =>
      _EveningReflectionSectionState();
}

class _EveningReflectionSectionState
    extends ConsumerState<EveningReflectionSection> {
  final TextEditingController _reflectionController = TextEditingController();
  int _satisfactionRating = 0;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  bool get _canFinish => _satisfactionRating > 0;

  void _handleFinishDay() {
    if (_canFinish) {
      widget.onSaveReflection?.call(
        _reflectionController.text.trim(),
        _satisfactionRating,
      );
      widget.onFinishDay?.call();

      AppLogger.ui(
        'Day finished with rating: $_satisfactionRating',
        screen: 'EveningReflectionSection',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    AppLogger.d(
      'EveningReflectionSection build - tasks: ${widget.selectedTaskIds.length}, free: ${widget.freeIntentions.length}',
      tag: 'EveningReflectionSection',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 저녁 성찰 카드 (메인 비주얼)
        _buildEveningQuestionCard(),
        const SizedBox(height: AppSizes.spaceXL),

        // 아침 계획 목록
        _buildMorningPlanSection(tasks),
        const SizedBox(height: AppSizes.spaceXL),

        // 성찰 입력
        _buildReflectionInput(),
        const SizedBox(height: AppSizes.spaceXL),

        // 만족도 평가
        _buildSatisfactionRating(),
        const SizedBox(height: AppSizes.spaceXL),

        // 하루 마무리 버튼
        _buildFinishDayButton(),
      ],
    );
  }

  /// 저녁 질문 카드
  Widget _buildEveningQuestionCard() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: AppDecorations.accentIconSquare(
                  AppColors.accentPurple,
                  borderRadius: AppSizes.radiusM,
                ),
                child: Icon(
                  Icons.nights_stay_rounded,
                  size: AppSizes.iconL,
                  color: AppColors.accentPurple,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.eveningSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.eveningTitle,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),

          // 프랭클린 저녁 질문
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.accentPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  size: AppSizes.iconM,
                  color: AppColors.accentPurple.withOpacity(0.5),
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  AppStrings.eveningQuestion,
                  style: AppTextStyles.bodyL.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 존재하는 Task 의도만 카운트
  int _getValidTaskIntentionCount(List<Task> allTasks) {
    return widget.selectedTaskIds.where((taskId) {
      return allTasks.any((t) => t.id == taskId);
    }).length;
  }

  /// 아침 계획 섹션
  Widget _buildMorningPlanSection(List<Task> allTasks) {
    // 존재하는 Task 의도만 카운트
    final validTaskCount = _getValidTaskIntentionCount(allTasks);
    final hasIntentions =
        validTaskCount > 0 || widget.freeIntentions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.eveningMorningPlan, style: AppTextStyles.heading3),
        const SizedBox(height: AppSizes.spaceL),

        if (!hasIntentions)
          _buildNoIntentionMessage()
        else
          NeumorphicContainer(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            style: NeumorphicStyle.flat,
            child: Column(
              children: [
                // Task 의도 (존재하는 Task만 표시)
                ...widget.selectedTaskIds.map((taskId) {
                  final task = allTasks.where((t) => t.id == taskId).firstOrNull;
                  // 삭제된 Task는 건너뛰기
                  if (task == null) return const SizedBox.shrink();

                  return _buildIntentionItem(
                    title: task.title,
                    isCompleted: task.isCompleted,
                    onTap: () => widget.onTaskComplete?.call(taskId),
                    isTask: true,
                  );
                }),

                // 자유 의도
                ...widget.freeIntentions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final intention = entry.value;
                  final isCompleted =
                      index < widget.freeIntentionCompleted.length
                      ? widget.freeIntentionCompleted[index]
                      : false;

                  return _buildIntentionItem(
                    title: intention,
                    isCompleted: isCompleted,
                    onTap: () => widget.onFreeIntentionToggle?.call(index),
                    isTask: false,
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  /// 의도 없음 메시지
  Widget _buildNoIntentionMessage() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
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
          const SizedBox(height: AppSizes.spaceS),
          Text(
            '내일 아침에 의도를 설정해보세요',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 의도 항목
  Widget _buildIntentionItem({
    required String title,
    required bool isCompleted,
    required VoidCallback onTap,
    required bool isTask,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.accentGreen
                    : AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.accentGreen
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSizes.spaceM),

            // 아이콘 (Task vs 자유 의도)
            Icon(
              isTask ? Icons.task_alt : Icons.star,
              size: AppSizes.iconS,
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
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),

            // 완료 버튼
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                ),
                child: Text(
                  AppStrings.eveningMarkComplete,
                  style: AppTextStyles.labelS.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 성찰 입력
  Widget _buildReflectionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.eveningReflectionLabel, style: AppTextStyles.heading3),
        const SizedBox(height: AppSizes.spaceL),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          style: NeumorphicStyle.concave,
          child: TextField(
            controller: _reflectionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppStrings.eveningReflectionHint,
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  /// 만족도 평가
  Widget _buildSatisfactionRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.eveningSatisfaction, style: AppTextStyles.heading3),
        const SizedBox(height: AppSizes.spaceL),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          style: NeumorphicStyle.flat,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  final isSelected = rating <= _satisfactionRating;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _satisfactionRating = rating;
                      });
                      AppLogger.ui(
                        'Satisfaction rating: $rating',
                        screen: 'EveningReflectionSection',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceS,
                      ),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        size: 40,
                        color: isSelected
                            ? AppColors.accentOrange
                            : AppColors.textTertiary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizes.spaceS),
              if (_satisfactionRating > 0)
                Text(
                  '$_satisfactionRating / 5',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하루 마무리 버튼
  Widget _buildFinishDayButton() {
    final isEnabled = _canFinish;

    return Column(
      children: [
        NeumorphicButton(
          width: double.infinity,
          height: AppSizes.buttonHeightL,
          borderRadius: AppSizes.radiusM,
          onTap: isEnabled ? _handleFinishDay : null,
          disabled: !isEnabled,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nights_stay_rounded,
                size: 20,
                color: isEnabled ? AppColors.accentPurple : AppColors.textDisabled,
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text(
                AppStrings.eveningFinishDay,
                style: AppTextStyles.button.copyWith(
                  color: isEnabled
                      ? AppColors.accentPurple
                      : AppColors.textDisabled,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),

        // 격려 메시지
        if (_satisfactionRating > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: AppSizes.iconXS,
                color: AppColors.accentPink,
              ),
              const SizedBox(width: AppSizes.spaceXS),
              Text(
                AppStrings.eveningEncouragement,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
