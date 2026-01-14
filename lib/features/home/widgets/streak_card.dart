// lib/features/home/widgets/streak_card.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 습관 스트릭 카드 (Streak Card)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 연속 완료 일수를 표시하는 동기부여 카드
/// - 🔥 불꽃 아이콘 + 연속 일수
/// - 최고 기록 표시
/// - 동기부여 메시지
///
/// 사용법:
///   StreakCard(
///     currentStreak: 7,
///     bestStreak: 14,
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class StreakCard extends StatelessWidget {
  /// 현재 연속 일수
  final int currentStreak;

  /// 최고 연속 기록
  final int bestStreak;

  /// 탭 콜백 (상세 보기)
  final VoidCallback? onTap;

  const StreakCard({
    Key? key,
    required this.currentStreak,
    this.bestStreak = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d(
      'StreakCard build - current: $currentStreak, best: $bestStreak',
      tag: 'StreakCard',
    );

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            // 불꽃 아이콘
            _buildFireIcon(),
            const SizedBox(width: AppSizes.spaceL),

            // 스트릭 정보
            Expanded(child: _buildStreakInfo()),

            // 최고 기록
            if (bestStreak > 0) _buildBestStreak(),
          ],
        ),
      ),
    );
  }

  /// 불꽃 아이콘
  Widget _buildFireIcon() {
    final isActive = currentStreak > 0;
    final color = _getStreakColor();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(isActive ? '🔥' : '💤', style: const TextStyle(fontSize: 28)),
          // 연속 일수 배지
          if (currentStreak > 0)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$currentStreak',
                  style: AppTextStyles.labelS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 스트릭 정보
  Widget _buildStreakInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.streakTitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$currentStreak',
              style: AppTextStyles.heading2.copyWith(
                color: _getStreakColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.streakDays,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getMotivationMessage(),
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  /// 최고 기록
  Widget _buildBestStreak() {
    final isNewRecord = currentStreak >= bestStreak && currentStreak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: isNewRecord
            ? AppColors.accentGold.withOpacity(0.15)
            : AppColors.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Text(isNewRecord ? '🏆' : '🎯', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            AppStrings.streakBest,
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
          Text(
            '$bestStreak${AppStrings.streakDaySuffix}',
            style: AppTextStyles.labelM.copyWith(
              color: isNewRecord
                  ? AppColors.accentGold
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 스트릭에 따른 색상
  Color _getStreakColor() {
    if (currentStreak == 0) return AppColors.textTertiary;
    if (currentStreak < 3) return AppColors.accentOrange;
    if (currentStreak < 7) return AppColors.accentOrange;
    if (currentStreak < 14) return AppColors.accentRed;
    if (currentStreak < 30) return AppColors.accentPurple;
    return AppColors.accentGold;
  }

  /// 동기부여 메시지
  String _getMotivationMessage() {
    if (currentStreak == 0) return AppStrings.streakMessageStart;
    if (currentStreak == 1) return AppStrings.streakMessageDay1;
    if (currentStreak < 3) return AppStrings.streakMessageDay2;
    if (currentStreak < 7) return AppStrings.streakMessageWeek;
    if (currentStreak < 14) return AppStrings.streakMessageTwoWeeks;
    if (currentStreak < 30) return AppStrings.streakMessageMonth;
    return AppStrings.streakMessageLegend;
  }
}
