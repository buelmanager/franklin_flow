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
/// ═══════════════════════════════════════════════════════════════════════════

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    required this.onStatusTap,
    this.onEdit,
    this.onDelete,
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
              if (isExpanded) _buildExpandedContent(),
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
            // task.timeString 사용 (timeInMinutes를 자동으로 포맷팅)
            Text(task.timeString, style: AppTextStyles.caption),
            const SizedBox(width: AppSizes.spaceM),
            // 카테고리 이름과 색상 사용
            BadgeTag(text: categoryName, color: categoryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spaceL),

        // 프로그레스 바 (진행중일 때만)
        if (task.isInProgress) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTextStyles.caption),
              Text(
                '${task.progress}%',
                style: AppTextStyles.numberS.copyWith(
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          NeumorphicProgressBar(
            progress: task.progress / 100,
            color: AppColors.accentOrange,
            height: AppSizes.progressBarHeightL,
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
