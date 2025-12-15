// lib/features/home/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/task_model.dart';

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

  const TaskCard({
    Key? key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    required this.onStatusTap,
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
              if (isExpanded && task.isInProgress) _buildExpandedContent(),
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
            Text(task.time, style: AppTextStyles.caption),
            const SizedBox(width: AppSizes.spaceM),
            BadgeTag(text: task.category, color: AppColors.accentBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spaceL),
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
