// lib/core/widgets/neumorphic_progress_bar.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 뉴모피즘 프로그레스 바 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   NeumorphicProgressBar(
///     progress: 0.55,
///     color: AppColors.accentOrange,
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class NeumorphicProgressBar extends StatelessWidget {
  /// 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 프로그레스 색상
  final Color color;

  /// 바 높이
  final double height;

  /// 애니메이션 사용 여부
  final bool animate;

  /// 애니메이션 지속시간
  final Duration animationDuration;

  /// 그라데이션 사용 여부
  final bool useGradient;

  const NeumorphicProgressBar({
    Key? key,
    required this.progress,
    required this.color,
    this.height = AppSizes.progressBarHeightM,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.surface,
        boxShadow: [
          // 오목한 효과
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.25),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.7),
            offset: const Offset(-1, -1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 프로그레스 채움
          animate
              ? AnimatedFractionallySizedBox(
                  duration: animationDuration,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: _buildFill(),
                )
              : FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: _buildFill(),
                ),
        ],
      ),
    );
  }

  Widget _buildFill() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: useGradient
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
        color: useGradient ? null : color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
