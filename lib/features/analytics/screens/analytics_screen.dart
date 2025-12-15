// lib/features/analytics/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 분석 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 통계 및 분석 데이터 표시
/// TODO: 구현 예정
/// ═══════════════════════════════════════════════════════════════════════════

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('AnalyticsScreen build', tag: 'AnalyticsScreen');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicContainer(
              width: 120,
              height: 120,
              borderRadius: 60,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            Text(AppStrings.navAnalytics, style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              '통계 및 분석 화면입니다.\n곧 업데이트 예정입니다.',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
