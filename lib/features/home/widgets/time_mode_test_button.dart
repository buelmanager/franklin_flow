// lib/features/home/widgets/time_mode_test_button.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/constants/time_of_day_mode.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 시간대 모드 테스트 버튼 (개발용)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 홈 화면 하단에 배치되는 개발/테스트용 모드 전환 버튼
/// - 메인/아침/저녁 모드 수동 전환
/// - 자동 모드: 시간대 + 완료 상태에 따라 자동 결정
/// - 릴리즈 시 제거 또는 숨김 처리 필요
/// ═══════════════════════════════════════════════════════════════════════════

class TimeModeTestButton extends StatelessWidget {
  /// 현재 활성 모드
  final TimeOfDayMode currentMode;

  /// 자동 모드 여부
  final bool isAutoMode;

  /// 아침 의도 완료 여부
  final bool isMorningCompleted;

  /// 저녁 성찰 완료 여부
  final bool isEveningCompleted;

  /// 모드 변경 콜백 (mode, isAuto)
  final void Function(TimeOfDayMode? mode, bool isAuto)? onModeChanged;

  const TimeModeTestButton({
    Key? key,
    required this.currentMode,
    required this.isAutoMode,
    this.isMorningCompleted = false,
    this.isEveningCompleted = false,
    this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d(
      'TimeModeTestButton build - mode: ${currentMode.displayName}, auto: $isAutoMode',
      tag: 'TimeModeTestButton',
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 레이블
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report,
                size: AppSizes.iconXS,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSizes.spaceXS),
              Text(
                AppStrings.testModeLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 현재 모드 + 상태 표시
          _buildCurrentModeIndicator(),
          const SizedBox(height: AppSizes.spaceS),

          // 완료 상태 표시
          _buildCompletionStatus(),
          const SizedBox(height: AppSizes.spaceM),

          // 모드 선택 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(
                mode: TimeOfDayMode.main,
                icon: Icons.home,
                label: '메인',
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: AppSizes.spaceS),
              _buildModeButton(
                mode: TimeOfDayMode.morning,
                icon: Icons.wb_sunny,
                label: '아침',
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: AppSizes.spaceS),
              _buildModeButton(
                mode: TimeOfDayMode.evening,
                icon: Icons.nights_stay,
                label: '저녁',
                color: AppColors.accentPurple,
              ),
              const SizedBox(width: AppSizes.spaceS),
              _buildAutoButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 현재 모드 표시
  Widget _buildCurrentModeIndicator() {
    final color = _getModeColor(currentMode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getModeIcon(currentMode), size: AppSizes.iconS, color: color),
          const SizedBox(width: AppSizes.spaceXS),
          Text(
            currentMode.displayName,
            style: AppTextStyles.labelM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isAutoMode) ...[
            const SizedBox(width: AppSizes.spaceXS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'AUTO',
                style: AppTextStyles.labelS.copyWith(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 완료 상태 표시
  Widget _buildCompletionStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusChip(
          label: '아침',
          isCompleted: isMorningCompleted,
          color: AppColors.accentOrange,
        ),
        const SizedBox(width: AppSizes.spaceS),
        _buildStatusChip(
          label: '저녁',
          isCompleted: isEveningCompleted,
          color: AppColors.accentPurple,
        ),
        const SizedBox(width: AppSizes.spaceM),
        Text(
          TimeOfDayModeExtension.currentTimeSlot().displayName,
          style: AppTextStyles.labelS.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isCompleted,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.accentGreen.withOpacity(0.15)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            size: 10,
            color: isCompleted ? AppColors.accentGreen : color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.labelS.copyWith(
              color: isCompleted ? AppColors.accentGreen : color,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// 모드 선택 버튼
  Widget _buildModeButton({
    required TimeOfDayMode mode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = currentMode == mode && !isAutoMode;

    return GestureDetector(
      onTap: () {
        onModeChanged?.call(mode, false);
        AppLogger.ui(
          'Mode button tapped: ${mode.displayName}',
          screen: 'TimeModeTestButton',
        );
      },
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: isSelected ? color : AppColors.textTertiary.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelS.copyWith(
                color: isSelected ? color : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 자동 버튼
  Widget _buildAutoButton() {
    return GestureDetector(
      onTap: () {
        onModeChanged?.call(null, true);
        AppLogger.ui('Auto mode enabled', screen: 'TimeModeTestButton');
      },
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isAutoMode
              ? AppColors.accentGreen.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: isAutoMode
                ? AppColors.accentGreen
                : AppColors.textTertiary.withOpacity(0.3),
            width: isAutoMode ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.autorenew,
              size: 18,
              color: isAutoMode
                  ? AppColors.accentGreen
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              '자동',
              style: AppTextStyles.labelS.copyWith(
                color: isAutoMode
                    ? AppColors.accentGreen
                    : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: isAutoMode ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor(TimeOfDayMode mode) {
    switch (mode) {
      case TimeOfDayMode.main:
        return AppColors.accentBlue;
      case TimeOfDayMode.morning:
        return AppColors.accentOrange;
      case TimeOfDayMode.evening:
        return AppColors.accentPurple;
    }
  }

  IconData _getModeIcon(TimeOfDayMode mode) {
    switch (mode) {
      case TimeOfDayMode.main:
        return Icons.home;
      case TimeOfDayMode.morning:
        return Icons.wb_sunny;
      case TimeOfDayMode.evening:
        return Icons.nights_stay;
    }
  }
}
