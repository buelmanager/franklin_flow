// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면 헤더 위젯 (개선 버전)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용자 이름, 날짜, 알림 버튼, 프로필 아바타 포함
/// "Franklin Flow" 타이틀 제거 및 레이아웃 개선
/// ═══════════════════════════════════════════════════════════════════════════

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  /// 사용자 이름 (기본값: "Wade")
  final String? userName;

  /// 알림 뱃지 숫자 (0이면 표시 안함)
  final int notificationCount;

  const HomeHeader({
    Key? key,
    this.onNotificationTap,
    this.onProfileTap,
    this.userName,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('HomeHeader build', tag: 'HomeHeader');

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final displayName = userName ?? 'Wade';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 인사말 & 날짜 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 인사말 + 사용자 이름
              Row(
                children: [
                  Text(
                    AppStrings.getGreeting(),
                    style: AppTextStyles.bodyM.copyWith(
                      color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    ', $displayName',
                    style: AppTextStyles.bodyM.copyWith(
                      color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceXS),
              // 날짜 정보
              Text(
                _formatDate(now),
                style: AppTextStyles.bodyS.copyWith(
                  color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // 버튼 영역
        Row(
          children: [
            // 알림 버튼 (뱃지 포함)
            _buildNotificationButton(),
            const SizedBox(width: AppSizes.spaceM),
            // 프로필 아바타
            _buildProfileAvatar(displayName),
          ],
        ),
      ],
    );
  }

  /// 알림 버튼 (뱃지 포함)
  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        NeumorphicButton.icon(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            AppLogger.ui('Notification tapped', screen: 'HomeHeader');
            onNotificationTap?.call();
          },
          logTag: 'NotificationBtn',
        ),
        // 뱃지
        if (notificationCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentRed.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: AppTextStyles.labelS.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 프로필 아바타
  Widget _buildProfileAvatar(String displayName) {
    return GestureDetector(
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
                _getInitials(displayName),
                style: AppTextStyles.heading4.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 날짜 포맷팅 (예: "Friday, January 10")
  String _formatDate(DateTime date) {
    final weekday = AppStrings.getWeekday(date.weekday);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    final day = date.day;

    return '$weekday, $month $day';
  }

  /// 사용자 이름에서 이니셜 추출 (예: "Wade Wilson" -> "W")
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      // 두 단어 이상이면 첫 글자만 (예: Wade Wilson -> W)
      return parts[0][0].toUpperCase();
    }

    // 한 단어면 첫 글자
    return name[0].toUpperCase();
  }
}
