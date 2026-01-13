// lib/features/home/widgets/weekly_stats_mini_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 주간 통계 미니 카드 (Weekly Stats Mini Card)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 홈 화면에 표시되는 간략한 주간 통계 카드
/// - 이번 주 완료율
/// - 완료한 태스크 수
/// - 연속 일수
/// - 요일별 완료 도트
///
/// 사용법:
///   WeeklyStatsMiniCard(
///     completionRate: 75,
///     completedTasks: 15,
///     totalTasks: 20,
///     streak: 5,
///     weeklyCompletion: [true, true, false, true, true, false, false],
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyStatsMiniCard extends StatelessWidget {
  /// 이번 주 완료율 (0-100)
  final int completionRate;

  /// 완료한 태스크 수
  final int completedTasks;

  /// 전체 태스크 수
  final int totalTasks;

  /// 연속 일수
  final int streak;

  /// 이번 주 요일별 완료 여부 (월~일, 7개)
  final List<bool> weeklyCompletion;

  /// 탭 콜백 (Analytics로 이동)
  final VoidCallback? onTap;

  const WeeklyStatsMiniCard({
    Key? key,
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
    this.streak = 0,
    this.weeklyCompletion = const [],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d(
      'WeeklyStatsMiniCard build - rate: $completionRate%, tasks: $completedTasks/$totalTasks',
      tag: 'WeeklyStatsMiniCard',
    );

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.weeklyStatsTitle,
                  style: AppTextStyles.heading4,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconXS,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 통계 카드들
            Row(
              children: [
                // 완료율
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.pie_chart_outline,
                    value: '$completionRate%',
                    label: AppStrings.weeklyStatsCompletion,
                    color: _getCompletionColor(completionRate),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),

                // 완료 태스크
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle_outline,
                    value: '$completedTasks',
                    label: AppStrings.weeklyStatsCompleted,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),

                // 연속 일수
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department,
                    value: '$streak',
                    label: AppStrings.weeklyStatsStreak,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 요일별 완료 도트
            if (weeklyCompletion.isNotEmpty) _buildWeeklyDots(),
          ],
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppSizes.iconM, color: color),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 요일별 완료 도트
  Widget _buildWeeklyDots() {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final today = DateTime.now().weekday - 1; // 0-6 (월-일)

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isCompleted = index < weeklyCompletion.length
            ? weeklyCompletion[index]
            : false;
        final isToday = index == today;
        final isFuture = index > today;

        return Column(
          children: [
            // 도트
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isFuture
                    ? AppColors.textTertiary.withOpacity(0.1)
                    : isCompleted
                    ? AppColors.accentGreen
                    : AppColors.accentRed.withOpacity(0.3),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.accentBlue, width: 2)
                    : null,
              ),
              child: isCompleted && !isFuture
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            // 요일
            Text(
              weekdays[index],
              style: AppTextStyles.labelS.copyWith(
                color: isToday ? AppColors.accentBlue : AppColors.textTertiary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 완료율에 따른 색상
  Color _getCompletionColor(int rate) {
    if (rate >= 80) return AppColors.accentGreen;
    if (rate >= 60) return AppColors.accentBlue;
    if (rate >= 40) return AppColors.accentOrange;
    return AppColors.accentRed;
  }
}
