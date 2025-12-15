// lib/features/home/widgets/goal_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/goal_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 목표 카드 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 주간 목표 개별 카드
/// ═══════════════════════════════════════════════════════════════════════════

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalCard({Key? key, required this.goal, this.onTap}) : super(key: key);

  /// Goal 모델 없이 직접 값으로 생성하는 팩토리
  factory GoalCard.fromValues({
    Key? key,
    required String emoji,
    required String title,
    required int current,
    required int total,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GoalCard(
      key: key,
      goal: Goal(
        emoji: emoji,
        title: title,
        current: current,
        total: total,
        color: color,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 아이콘 + 진행도
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBox.emoji(
                  emoji: goal.emoji,
                  color: goal.color,
                  size: AppSizes.avatarM,
                ),
                Text(
                  '${goal.current}/${goal.total}',
                  style: AppTextStyles.numberS.copyWith(color: goal.color),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceL),
            // 제목
            Text(goal.title, style: AppTextStyles.heading4),
            const SizedBox(height: AppSizes.spaceM),
            // 프로그레스 바
            NeumorphicProgressBar(
              progress: goal.progress,
              color: goal.color,
              height: AppSizes.progressBarHeightM,
            ),
          ],
        ),
      ),
    );
  }
}
