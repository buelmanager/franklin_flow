// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면 헤더 위젯 (개선 버전)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 프로필 아바타 + 사용자 이름 + 날짜 정보
/// 프로필 아바타는 왼쪽에 배치
/// ═══════════════════════════════════════════════════════════════════════════

class HomeHeader extends StatelessWidget {
  /// 사용자 이름 (기본값: "Wade")
  final String? userName;

  const HomeHeader({
    Key? key,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('HomeHeader build', tag: 'HomeHeader');

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final displayName = userName ?? 'Wade';

    return Row(
      children: [
        // 프로필 아바타 (왼쪽)
        _buildProfileAvatar(displayName),
        const SizedBox(width: AppSizes.spaceM),

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
      ],
    );
  }

  /// 프로필 아바타
  Widget _buildProfileAvatar(String displayName) {
    return NeumorphicContainer(
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
                AppColors.accentBlue.withValues(alpha: 0.8),
                AppColors.accentPurple.withValues(alpha: 0.8),
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
