// lib/features/home/widgets/weekly_goals_section.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_card.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 주간 목표 섹션 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// This Week 섹션 전체 (2x2 그리드)
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyGoalsSection extends StatelessWidget {
  final List<Goal> goals;
  final Function(int)? onGoalTap;

  const WeeklyGoalsSection({Key? key, required this.goals, this.onGoalTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppStrings.thisWeek),
        const SizedBox(height: AppSizes.spaceL),
        _buildGoalGrid(),
      ],
    );
  }

  Widget _buildGoalGrid() {
    // 2개씩 Row로 묶어서 표시
    final List<Widget> rows = [];

    for (int i = 0; i < goals.length; i += 2) {
      final row = Row(
        children: [
          Expanded(
            child: GoalCard(goal: goals[i], onTap: () => onGoalTap?.call(i)),
          ),
          const SizedBox(width: AppSizes.spaceL),
          if (i + 1 < goals.length)
            Expanded(
              child: GoalCard(
                goal: goals[i + 1],
                onTap: () => onGoalTap?.call(i + 1),
              ),
            )
          else
            const Expanded(child: SizedBox()), // 빈 공간
        ],
      );

      rows.add(row);
      if (i + 2 < goals.length) {
        rows.add(const SizedBox(height: AppSizes.spaceM));
      }
    }

    return Column(children: rows);
  }
}
