// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 설정 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 설정 및 사용자 프로필
/// TODO: 구현 예정
/// ═══════════════════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('SettingsScreen build', tag: 'SettingsScreen');

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
                Icons.settings_rounded,
                size: 48,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            Text(AppStrings.navSettings, style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              AppStrings.screenSettingsDescription,
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
