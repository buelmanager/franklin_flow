// lib/features/home/widgets/progress_section.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 오늘의 진행도 섹션 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 원형 프로그레스 + 통계 표시
/// ═══════════════════════════════════════════════════════════════════════════

class ProgressSection extends StatelessWidget {
  final int completionRate;
  final int completedCount;
  final int inProgressCount;
  final int pendingCount;

  const ProgressSection({
    Key? key,
    required this.completionRate,
    required this.completedCount,
    required this.inProgressCount,
    required this.pendingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppStrings.todayProgress),
        const SizedBox(height: AppSizes.spaceL),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Row(
            children: [
              // 원형 프로그레스
              Expanded(child: _buildCircularProgress()),
              const SizedBox(width: AppSizes.spaceXL),
              // 통계
              Expanded(child: _buildStats()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return Center(
      child: NeumorphicCircularProgress(
        progress: completionRate / 100,
        size: AppSizes.progressCircleL,
        strokeWidth: 10,
        progressColor: AppColors.accentBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$completionRate%', style: AppTextStyles.displayNumber),
            Text(AppStrings.done, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        StatItem(
          icon: Icons.check_circle_outline,
          label: AppStrings.statusCompleted,
          value: '$completedCount',
          color: AppColors.accentGreen,
        ),
        const SizedBox(height: AppSizes.spaceL),
        StatItem(
          icon: Icons.play_circle_outline,
          label: AppStrings.statusInProgress,
          value: '$inProgressCount',
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: AppSizes.spaceL),
        StatItem(
          icon: Icons.access_time,
          label: AppStrings.statusPending,
          value: '$pendingCount',
          color: AppColors.textTertiary,
        ),
      ],
    );
  }
}
