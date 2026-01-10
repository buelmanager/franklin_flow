// lib/features/home/widgets/weekly_goals_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_card.dart';
import 'goal_form_dialog.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 주간 목표 섹션 위젯 (Riverpod 적용)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// This Week 섹션 전체 (2x2 그리드)
/// 목표 추가, 수정, 삭제, 진행도 업데이트 기능
/// 메뉴 버튼으로 옵션 접근
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyGoalsSection extends ConsumerWidget {
  const WeeklyGoalsSection({Key? key}) : super(key: key);

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleAddGoal(BuildContext context, WidgetRef ref) async {
    AppLogger.ui('Add goal tapped', screen: 'WeeklyGoalsSection');

    final result = await GoalFormDialog.show(context: context);

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('목표가 추가되었습니다: ${result.title}'),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleGoalTap(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    if (goal.isCompleted) {
      AppLogger.d(
        'Goal already completed: ${goal.title}',
        tag: 'WeeklyGoalsSection',
      );
      return;
    }

    await ref.read(goalListProvider.notifier).incrementGoal(goal.id);

    AppLogger.ui(
      'Goal progress: ${goal.title} -> ${goal.current + 1}/${goal.total}',
      screen: 'WeeklyGoalsSection',
    );
  }

  Future<void> _handleMenuTap(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    AppLogger.ui(
      'Goal menu tapped: ${goal.title}',
      screen: 'WeeklyGoalsSection',
    );

    await _showGoalOptions(context, ref, goal);
  }

  Future<void> _showGoalOptions(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalOptionsBottomSheet(
        goal: goal,
        ref: ref, // ref를 전달
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(currentWeekGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.thisWeek,
          actionIcon: Icons.add,
          onActionTap: () => _handleAddGoal(context, ref),
        ),
        const SizedBox(height: AppSizes.spaceL),

        if (goals.isEmpty)
          _buildEmptyState(context, ref)
        else
          _buildGoalGrid(context, ref, goals),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _handleAddGoal(context, ref),
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
                Icons.flag_outlined,
                size: 40,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 제목
            Text(
              '주간 목표를 설정하세요',
              style: AppTextStyles.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceM),

            // 설명
            Text(
              '이번 주에 달성하고 싶은 목표를 추가해보세요.\n매일 조금씩 진행하면서 성취감을 느껴보세요!',
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
              onTap: () => _handleAddGoal(context, ref),
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
                    '첫 번째 목표 추가하기',
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
                color: AppColors.accentGreen.withOpacity(0.05),
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
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      Text(
                        '예시',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildExampleItem('🏃', '운동 3회', AppColors.accentPink),
                  const SizedBox(height: AppSizes.spaceS),
                  _buildExampleItem('📚', '독서 10페이지', AppColors.accentPurple),
                  const SizedBox(height: AppSizes.spaceS),
                  _buildExampleItem('💧', '물 8잔', AppColors.accentBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleItem(String emoji, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Text(
          text,
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGoalGrid(BuildContext context, WidgetRef ref, List<Goal> goals) {
    final List<Widget> rows = [];

    for (int i = 0; i < goals.length; i += 2) {
      final row = Row(
        children: [
          Expanded(
            child: GoalCard(
              goal: goals[i],
              onTap: () => _handleGoalTap(context, ref, goals[i]),
              onMenuTap: () => _handleMenuTap(context, ref, goals[i]),
            ),
          ),
          const SizedBox(width: AppSizes.spaceL),
          if (i + 1 < goals.length)
            Expanded(
              child: GoalCard(
                goal: goals[i + 1],
                onTap: () => _handleGoalTap(context, ref, goals[i + 1]),
                onMenuTap: () => _handleMenuTap(context, ref, goals[i + 1]),
              ),
            )
          else
            const Expanded(child: SizedBox()),
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

/// ═══════════════════════════════════════════════════════════════════════════
/// 목표 옵션 BottomSheet (StatelessWidget으로 변경)
/// ═══════════════════════════════════════════════════════════════════════════

class _GoalOptionsBottomSheet extends StatelessWidget {
  final Goal goal;
  final WidgetRef ref; // ref를 생성자로 받음

  const _GoalOptionsBottomSheet({
    Key? key,
    required this.goal,
    required this.ref,
  }) : super(key: key);

  Future<void> _handleIncrement(BuildContext context) async {
    await ref.read(goalListProvider.notifier).incrementGoal(goal.id);
    if (context.mounted) Navigator.of(context).pop();

    AppLogger.ui('Goal incremented: ${goal.title}', screen: 'GoalOptions');
  }

  Future<void> _handleDecrement(BuildContext context) async {
    await ref.read(goalListProvider.notifier).decrementGoal(goal.id);
    if (context.mounted) Navigator.of(context).pop();

    AppLogger.ui('Goal decremented: ${goal.title}', screen: 'GoalOptions');
  }

  Future<void> _handleEdit(BuildContext context) async {
    // BuildContext를 먼저 저장
    if (!context.mounted) return;
    final navigatorContext = Navigator.of(context).context;

    // BottomSheet 닫기
    Navigator.of(context).pop();

    // 약간의 지연 후 다이얼로그 표시
    await Future.delayed(const Duration(milliseconds: 100));

    if (!navigatorContext.mounted) return;

    final result = await GoalFormDialog.show(
      context: navigatorContext,
      goal: goal,
    );

    if (result != null && navigatorContext.mounted) {
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(
          content: Text('목표가 수정되었습니다: ${result.title}'),
          backgroundColor: AppColors.accentBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Goal edit tapped: ${goal.title}', screen: 'GoalOptions');
  }

  Future<void> _handleDelete(BuildContext context) async {
    // BuildContext를 먼저 저장
    if (!context.mounted) return;
    final navigatorContext = Navigator.of(context).context;

    // BottomSheet 닫기
    Navigator.of(context).pop();

    // 약간의 지연 후 확인 다이얼로그 표시
    await Future.delayed(const Duration(milliseconds: 100));

    if (!navigatorContext.mounted) return;

    final confirmed = await NeumorphicDialog.showConfirm(
      context: navigatorContext,
      title: '목표 삭제',
      message: '${goal.title} 목표를 삭제하시겠습니까?',
      confirmText: AppStrings.btnDelete,
      cancelText: AppStrings.btnCancel,
    );

    if (confirmed == true) {
      // ref 사용 - 이미 생성자에서 받았으므로 문제없음
      await ref.read(goalListProvider.notifier).deleteGoal(goal.id);

      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('목표가 삭제되었습니다: ${goal.title}'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      AppLogger.i('Goal deleted: ${goal.title}', tag: 'GoalOptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXXL),
          topRight: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: AppSizes.paddingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 목표 정보
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Row(
              children: [
                IconBox.emoji(
                  emoji: goal.emoji,
                  color: goal.color,
                  size: AppSizes.avatarM,
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: AppTextStyles.heading4),
                      const SizedBox(height: AppSizes.spaceXS),
                      Text(
                        '${goal.current}/${goal.total} 완료',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 옵션 리스트
          _buildOption(
            context,
            icon: Icons.add,
            label: '진행도 증가',
            color: AppColors.accentGreen,
            onTap: () => _handleIncrement(context),
            enabled: !goal.isCompleted,
          ),
          _buildOption(
            context,
            icon: Icons.remove,
            label: '진행도 감소',
            color: AppColors.accentOrange,
            onTap: () => _handleDecrement(context),
            enabled: goal.current > 0,
          ),
          _buildOption(
            context,
            icon: Icons.edit,
            label: '수정',
            color: AppColors.accentBlue,
            onTap: () => _handleEdit(context),
          ),
          _buildOption(
            context,
            icon: Icons.delete_outline,
            label: '삭제',
            color: AppColors.accentRed,
            onTap: () => _handleDelete(context),
          ),

          const SizedBox(height: AppSizes.paddingXL),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingL,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconM,
              color: enabled ? color : AppColors.textDisabled,
            ),
            const SizedBox(width: AppSizes.spaceL),
            Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
