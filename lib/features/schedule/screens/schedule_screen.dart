// lib/features/schedule/screens/schedule_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 일정 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 캘린더 및 일정 관리
/// TODO: 구현 예정
/// ═══════════════════════════════════════════════════════════════════════════

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('ScheduleScreen build', tag: 'ScheduleScreen');

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
                Icons.calendar_today_rounded,
                size: 48,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            Text(AppStrings.navSchedule, style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              AppStrings.screenScheduleDescription,
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
