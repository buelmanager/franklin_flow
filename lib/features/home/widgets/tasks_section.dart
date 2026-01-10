// lib/features/home/widgets/tasks_section.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/task_model.dart';
import 'task_card.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 태스크 리스트 섹션 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Priority Tasks 섹션 전체
/// ═══════════════════════════════════════════════════════════════════════════

class TasksSection extends StatelessWidget {
  final List<Task> tasks;
  final int selectedTaskIndex;
  final Function(int) onTaskTap;
  final Function(int) onTaskStatusChange;
  final VoidCallback? onAddTap;
  final Function(int)? onEditTap;
  final Function(int)? onDeleteTap;
  final Function(int, int)? onProgressChange; // 진행도 변경 콜백 추가

  const TasksSection({
    Key? key,
    required this.tasks,
    required this.selectedTaskIndex,
    required this.onTaskTap,
    required this.onTaskStatusChange,
    this.onAddTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onProgressChange, // 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.priorityTasks,
          actionIcon: Icons.add,
          onActionTap: () {
            AppLogger.ui('Add task tapped', screen: 'TasksSection');
            onAddTap?.call();
          },
        ),
        const SizedBox(height: AppSizes.spaceL),

        if (tasks.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(
            tasks.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
              child: TaskCard(
                task: tasks[index],
                isExpanded: selectedTaskIndex == index,
                onTap: () => onTaskTap(index),
                onStatusTap: () => onTaskStatusChange(index),
                onEdit: onEditTap != null ? () => onEditTap!(index) : null,
                onDelete: onDeleteTap != null
                    ? () => onDeleteTap!(index)
                    : null,
                onProgressTap: onProgressChange != null
                    ? (progress) => onProgressChange!(index, progress)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onAddTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 40,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 제목
            Text(
              '우선순위 태스크를 추가하세요',
              style: AppTextStyles.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceM),

            // 설명
            Text(
              '오늘 해야 할 중요한 일들을 추가하고\n집중해서 하나씩 완료해보세요!',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 추가 버튼
            NeumorphicButton(
              width: double.infinity,
              height: AppSizes.buttonHeightL,
              borderRadius: AppSizes.radiusM,
              onTap: onAddTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: AppSizes.iconM,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  Text(
                    '첫 번째 태스크 추가하기',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.accentBlue,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 예시
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: AppSizes.iconS,
                        color: AppColors.accentPurple,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      Text(
                        '예시',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildExampleItem('💼', '프로젝트 기획서 작성', '2시간'),
                  const SizedBox(height: AppSizes.spaceS),
                  _buildExampleItem('📧', '이메일 답장', '30분'),
                  const SizedBox(height: AppSizes.spaceS),
                  _buildExampleItem('📝', '주간 회의 준비', '1시간'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleItem(String emoji, String text, String time) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
          ),
        ),
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
            time,
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
