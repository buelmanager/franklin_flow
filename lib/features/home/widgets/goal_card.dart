// lib/features/home/widgets/goal_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/goal_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 목표 카드 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 주간 목표 개별 카드
/// 전체 카드 탭으로 진행도 증가, 오른쪽 메뉴 버튼으로 옵션 표시
/// ═══════════════════════════════════════════════════════════════════════════

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const GoalCard({
    Key? key,
    required this.goal,
    this.onTap,
    this.onMenuTap,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 전체 카드에 탭 적용
      onTap: onTap ?? onIncrement,
      // 메뉴 버튼 영역은 제외하고 탭 가능하도록
      behavior: HitTestBehavior.opaque,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 아이콘 + 진행도 + 메뉴 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘
                IconBox.emoji(
                  emoji: goal.emoji,
                  color: goal.color,
                  size: AppSizes.avatarM,
                ),

                // 진행도 + 메뉴 버튼
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.spaceM,
                      top: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 진행도
                        Row(
                          children: [
                            Text(
                              '${goal.current}',
                              style: AppTextStyles.numberS.copyWith(
                                color: goal.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '/${goal.total}',
                              style: AppTextStyles.numberS.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),

                        // 메뉴 버튼 (탭 이벤트 분리)
                        GestureDetector(
                          onTap: onMenuTap,
                          // 메뉴 버튼만 독립적으로 동작하도록
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              size: AppSizes.iconS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 제목
            Text(
              goal.title,
              style: AppTextStyles.heading4.copyWith(
                decoration: goal.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: goal.isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // 프로그레스 바
            NeumorphicProgressBar(
              progress: goal.progress,
              color: goal.color,
              height: AppSizes.progressBarHeightM,
            ),

            // 완료 표시
            if (goal.isCompleted) ...[
              const SizedBox(height: AppSizes.spaceS),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: AppSizes.iconXS,
                    color: goal.color,
                  ),
                  const SizedBox(width: AppSizes.spaceXS),
                  Text(
                    'Completed!',
                    style: AppTextStyles.caption.copyWith(
                      color: goal.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
