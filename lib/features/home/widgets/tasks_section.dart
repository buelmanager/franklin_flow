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

  const TasksSection({
    Key? key,
    required this.tasks,
    required this.selectedTaskIndex,
    required this.onTaskTap,
    required this.onTaskStatusChange,
    this.onAddTap,
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
        ...List.generate(
          tasks.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
            child: TaskCard(
              task: tasks[index],
              isExpanded: selectedTaskIndex == index,
              onTap: () => onTaskTap(index),
              onStatusTap: () => onTaskStatusChange(index),
            ),
          ),
        ),
      ],
    );
  }
}
