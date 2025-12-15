// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면 헤더 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 인사말, 앱 타이틀, 알림 버튼, 프로필 아바타 포함
/// ═══════════════════════════════════════════════════════════════════════════

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({Key? key, this.onNotificationTap, this.onProfileTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 인사말 & 타이틀
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getGreeting(),
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Text(AppStrings.appName, style: AppTextStyles.heading1),
          ],
        ),
        // 버튼 영역
        Row(
          children: [
            // 알림 버튼
            NeumorphicButton.icon(
              icon: Icons.notifications_none_rounded,
              onTap: () {
                AppLogger.ui('Notification tapped', screen: 'HomeHeader');
                onNotificationTap?.call();
              },
              logTag: 'NotificationBtn',
            ),
            const SizedBox(width: AppSizes.spaceM),
            // 프로필 아바타
            GestureDetector(
              onTap: () {
                AppLogger.ui('Profile tapped', screen: 'HomeHeader');
                onProfileTap?.call();
              },
              child: NeumorphicContainer(
                width: AppSizes.avatarM,
                height: AppSizes.avatarM,
                style: NeumorphicStyle.convex,
                borderRadius: AppSizes.radiusM,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accentBlue.withOpacity(0.8),
                          AppColors.accentPurple.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'W',
                        style: AppTextStyles.heading4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
