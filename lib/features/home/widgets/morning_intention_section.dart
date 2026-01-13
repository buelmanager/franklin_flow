// lib/features/home/widgets/morning_intention_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 아침 의도 섹션 (Morning Intention Section)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 아침 모드에서 표시되는 의도 설정 섹션
/// - 프랭클린의 질문 카드 (메인 비주얼)
/// - 기존 Task에서 오늘의 의도 선택 (최대 3개)
/// - 새로운 자유 의도 추가
///
/// HomeHeader와 함께 사용되므로 자체 인사말 헤더 없음
/// ═══════════════════════════════════════════════════════════════════════════

class MorningIntentionSection extends ConsumerStatefulWidget {
  final String userName;
  final List<int> selectedTaskIds;
  final List<String> freeIntentions;
  final void Function(int taskId)? onTaskToggle;
  final void Function(String intention)? onAddFreeIntention;
  final void Function(int index)? onRemoveFreeIntention;
  final VoidCallback? onStartDay;
  final int maxIntentions;

  const MorningIntentionSection({
    Key? key,
    required this.userName,
    this.selectedTaskIds = const [],
    this.freeIntentions = const [],
    this.onTaskToggle,
    this.onAddFreeIntention,
    this.onRemoveFreeIntention,
    this.onStartDay,
    this.maxIntentions = 3,
  }) : super(key: key);

  @override
  ConsumerState<MorningIntentionSection> createState() =>
      _MorningIntentionSectionState();
}

class _MorningIntentionSectionState
    extends ConsumerState<MorningIntentionSection> {
  final TextEditingController _intentionController = TextEditingController();
  final FocusNode _intentionFocusNode = FocusNode();

  @override
  void dispose() {
    _intentionController.dispose();
    _intentionFocusNode.dispose();
    super.dispose();
  }

  int get _totalSelectedCount =>
      widget.selectedTaskIds.length + widget.freeIntentions.length;

  bool get _canAddMore => _totalSelectedCount < widget.maxIntentions;
  bool get _hasSelection => _totalSelectedCount > 0;

  void _handleAddFreeIntention() {
    final text = _intentionController.text.trim();
    if (text.isNotEmpty && _canAddMore) {
      widget.onAddFreeIntention?.call(text);
      _intentionController.clear();
      _intentionFocusNode.unfocus();

      AppLogger.ui(
        'Free intention added: $text',
        screen: 'MorningIntentionSection',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

    AppLogger.d(
      'MorningIntentionSection build - selected: ${widget.selectedTaskIds.length}, free: ${widget.freeIntentions.length}',
      tag: 'MorningIntentionSection',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 프랭클린의 질문 카드 (메인 비주얼)
        _buildFranklinQuestionCard(),
        const SizedBox(height: AppSizes.spaceXL),

        // Task 선택 섹션
        _buildTaskSelectionSection(pendingTasks),
        const SizedBox(height: AppSizes.spaceXL),

        // 자유 의도 입력
        _buildFreeIntentionSection(),
        const SizedBox(height: AppSizes.spaceXL),

        // 하루 시작 버튼
        _buildStartDayButton(),
      ],
    );
  }

  /// 프랭클린의 질문 카드
  Widget _buildFranklinQuestionCard() {
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
                  AppColors.accentOrange,
                  borderRadius: AppSizes.radiusM,
                ),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  size: AppSizes.iconL,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.morningSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.morningTitle,
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

          // 프랭클린 질문
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
                  Icons.format_quote,
                  size: AppSizes.iconM,
                  color: AppColors.accentOrange.withOpacity(0.5),
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  AppStrings.morningQuestion,
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

  /// Task 선택 섹션
  Widget _buildTaskSelectionSection(List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.morningSelectTask, style: AppTextStyles.heading3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: _canAddMore
                    ? AppColors.accentBlue.withOpacity(0.1)
                    : AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                '${_totalSelectedCount}/${widget.maxIntentions}',
                style: AppTextStyles.labelM.copyWith(
                  color: _canAddMore
                      ? AppColors.accentBlue
                      : AppColors.accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceL),

        // Task 목록
        if (tasks.isEmpty)
          _buildEmptyTaskState()
        else
          ...tasks.map((task) => _buildTaskItem(task)),
      ],
    );
  }

  /// 빈 Task 상태
  Widget _buildEmptyTaskState() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 28,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            AppStrings.taskEmptyTitle,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            '아래에 자유 의도를 직접 입력해보세요',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Task 항목
  Widget _buildTaskItem(Task task) {
    final isSelected = widget.selectedTaskIds.contains(task.id);
    final canSelect = _canAddMore || isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: GestureDetector(
        onTap: canSelect ? () => widget.onTaskToggle?.call(task.id) : null,
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          style: isSelected ? NeumorphicStyle.concave : NeumorphicStyle.flat,
          child: Row(
            children: [
              // 체크박스
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentBlue
                        : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: AppSizes.spaceM),

              // Task 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyM.copyWith(
                        color: canSelect
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.timeString,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택 표시
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: AppSizes.iconM,
                  color: AppColors.accentBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 자유 의도 섹션
  Widget _buildFreeIntentionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.morningAddIntention, style: AppTextStyles.heading3),
        const SizedBox(height: AppSizes.spaceL),

        // 입력 필드
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          style: NeumorphicStyle.concave,
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: AppSizes.iconM,
                color: _canAddMore
                    ? AppColors.accentPurple
                    : AppColors.textDisabled,
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: TextField(
                  controller: _intentionController,
                  focusNode: _intentionFocusNode,
                  enabled: _canAddMore,
                  decoration: InputDecoration(
                    hintText: AppStrings.morningIntentionHint,
                    hintStyle: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                  ),
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  onSubmitted: (_) => _handleAddFreeIntention(),
                ),
              ),
              NeumorphicButton(
                width: 40,
                height: 40,
                borderRadius: AppSizes.radiusS,
                onTap: _canAddMore ? _handleAddFreeIntention : null,
                disabled: !_canAddMore,
                child: Icon(
                  Icons.send,
                  size: AppSizes.iconS,
                  color: _canAddMore
                      ? AppColors.accentPurple
                      : AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),

        // 자유 의도 목록
        if (widget.freeIntentions.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spaceM),
          ...widget.freeIntentions.asMap().entries.map((entry) {
            return _buildFreeIntentionItem(entry.key, entry.value);
          }),
        ],
      ],
    );
  }

  /// 자유 의도 항목
  Widget _buildFreeIntentionItem(int index, String intention) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        style: NeumorphicStyle.concave,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accentPurple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.star, size: 14, color: Colors.white),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                intention,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => widget.onRemoveFreeIntention?.call(index),
              child: Icon(
                Icons.close,
                size: AppSizes.iconS,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하루 시작 버튼
  Widget _buildStartDayButton() {
    final isEnabled = _hasSelection;

    return Column(
      children: [
        NeumorphicButton(
          width: double.infinity,
          height: AppSizes.buttonHeightL,
          borderRadius: AppSizes.radiusM,
          onTap: isEnabled ? widget.onStartDay : null,
          disabled: !isEnabled,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('☀️', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSizes.spaceM),
              Text(
                AppStrings.morningStartDay,
                style: AppTextStyles.button.copyWith(
                  color: isEnabled
                      ? AppColors.accentOrange
                      : AppColors.textDisabled,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),

        // 팁
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: AppSizes.iconXS,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Flexible(
              child: Text(
                AppStrings.morningTip,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
