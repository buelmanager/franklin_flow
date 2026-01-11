// lib/features/home/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/task_model.dart';
import '../../../services/category_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 태스크 카드 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 개별 태스크를 표시하는 카드
/// 탭하여 확장, 상태 버튼으로 상태 변경
/// 프로그레스 바 클릭으로 진행도 설정
/// ═══════════════════════════════════════════════════════════════════════════

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(int)? onProgressTap; // 진행도 설정 콜백 추가

  const TaskCard({
    Key? key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    required this.onStatusTap,
    this.onEdit,
    this.onDelete,
    this.onProgressTap, // 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getTaskStatusColor(task.status);
    final statusIcon = _getStatusIcon();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              _buildMainRow(statusColor, statusIcon),
              if (isExpanded) _buildExpandedContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainRow(Color statusColor, IconData statusIcon) {
    return Row(
      children: [
        // 상태 버튼
        _buildStatusButton(statusColor, statusIcon),
        const SizedBox(width: AppSizes.spaceL),
        // 태스크 정보
        Expanded(child: _buildTaskInfo()),
        // 화살표
        Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
          color: AppColors.textTertiary,
          size: AppSizes.iconL,
        ),
      ],
    );
  }

  Widget _buildStatusButton(Color statusColor, IconData statusIcon) {
    return GestureDetector(
      onTap: onStatusTap,
      child: NeumorphicContainer(
        width: AppSizes.avatarM,
        height: AppSizes.avatarM,
        borderRadius: AppSizes.radiusM,
        style: task.isCompleted ? NeumorphicStyle.convex : NeumorphicStyle.flat,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            color: !task.isPending
                ? statusColor.withOpacity(0.15)
                : Colors.transparent,
          ),
          child: Icon(statusIcon, color: statusColor, size: AppSizes.iconS),
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    // CategoryService를 통해 카테고리 정보 가져오기
    final categoryService = CategoryService();
    final category = categoryService.getCategoryById(task.categoryId);
    final categoryName = category?.name ?? '기타';
    final categoryColor = category?.color ?? AppColors.accentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: task.isCompleted
              ? AppTextStyles.withStrikethrough(AppTextStyles.heading4)
              : AppTextStyles.heading4,
        ),
        const SizedBox(height: AppSizes.spaceXS),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: AppSizes.iconXS,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Text(task.timeString, style: AppTextStyles.caption),
            const SizedBox(width: AppSizes.spaceM),
            BadgeTag(text: categoryName, color: categoryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spaceL),

        // 프로그레스 바 (진행중일 때만, 클릭 가능)
        if (task.isInProgress) ...[
          GestureDetector(
            onTap: onProgressTap != null
                ? () => _showProgressDialog(context)
                : null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.taskProgressLabel,
                      style: AppTextStyles.caption,
                    ),
                    Row(
                      children: [
                        Text(
                          '${task.progress}%',
                          style: AppTextStyles.numberS.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceXS),
                        Icon(
                          Icons.edit,
                          size: AppSizes.iconXS,
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceS),
                NeumorphicProgressBar(
                  progress: task.progress / 100,
                  color: AppColors.accentOrange,
                  height: AppSizes.progressBarHeightL,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
        ],

        // 편집/삭제 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 편집 버튼
            if (onEdit != null)
              NeumorphicButton.icon(
                icon: Icons.edit,
                size: AppSizes.buttonHeightS,
                iconSize: AppSizes.iconS,
                iconColor: AppColors.accentBlue,
                onTap: onEdit,
                logTag: 'EditTaskBtn',
              ),
            const SizedBox(width: AppSizes.spaceM),

            // 삭제 버튼
            if (onDelete != null)
              NeumorphicButton.icon(
                icon: Icons.delete_outline,
                size: AppSizes.buttonHeightS,
                iconSize: AppSizes.iconS,
                iconColor: AppColors.accentRed,
                onTap: onDelete,
                logTag: 'DeleteTaskBtn',
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _showProgressDialog(BuildContext context) async {
    int selectedProgress = task.progress;

    await NeumorphicDialog.show(
      context: context,
      title: AppStrings.taskProgressDialogTitle,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 설명
              Text(
                '${task.title}의 진행도를 설정하세요',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // 슬라이더
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.accentOrange,
                  inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
                  thumbColor: AppColors.accentOrange,
                  overlayColor: AppColors.accentOrange.withOpacity(0.2),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: selectedProgress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$selectedProgress%',
                  onChanged: (value) {
                    setState(() {
                      selectedProgress = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),

              // 진행도 표시
              Text(
                '$selectedProgress%',
                style: AppTextStyles.displayNumber.copyWith(
                  fontSize: 42,
                  color: AppColors.accentOrange,
                ),
              ),

              // 프로그레스 바 미리보기
              const SizedBox(height: AppSizes.spaceL),
              NeumorphicProgressBar(
                progress: selectedProgress / 100,
                color: AppColors.accentOrange,
                height: AppSizes.progressBarHeightL,
              ),
            ],
          );
        },
      ),
      actions: [
        NeumorphicButton.text(
          text: AppStrings.btnCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSizes.spaceM),
        NeumorphicButton.text(
          text: AppStrings.btnConfirm,
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.accentOrange,
          ),
          onTap: () {
            onProgressTap?.call(selectedProgress);
            Navigator.of(context).pop();

            AppLogger.ui(
              'Progress set: ${task.title} -> $selectedProgress%',
              screen: 'TaskCard',
            );
          },
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case 'completed':
        return Icons.check;
      case 'in-progress':
        return Icons.play_arrow;
      default:
        return Icons.circle_outlined;
    }
  }
}
