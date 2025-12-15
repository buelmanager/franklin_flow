// lib/core/widgets/neumorphic_progress.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 뉴모피즘 원형 프로그레스 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   NeumorphicCircularProgress(
///     progress: 0.67,
///     size: 140,
///     child: Text('67%'),
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class NeumorphicCircularProgress extends StatelessWidget {
  /// 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 원 크기
  final double size;

  /// 프로그레스 두께
  final double strokeWidth;

  /// 중앙 위젯
  final Widget? child;

  /// 프로그레스 색상
  final Color? progressColor;

  /// 배경 트랙 색상
  final Color? trackColor;

  /// 애니메이션 사용 여부
  final bool animate;

  /// 애니메이션 지속시간
  final Duration animationDuration;

  const NeumorphicCircularProgress({
    Key? key,
    required this.progress,
    this.size = AppSizes.progressCircleM,
    this.strokeWidth = 10,
    this.child,
    this.progressColor,
    this.trackColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        boxShadow: [
          // 외부 그림자
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.4),
            offset: const Offset(6, 6),
            blurRadius: 15,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(-6, -6),
            blurRadius: 15,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth / 2 + 8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              // 내부 오목 효과
              BoxShadow(
                color: AppColors.shadowDark.withOpacity(0.2),
                offset: const Offset(3, 3),
                blurRadius: 6,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: AppColors.shadowLight.withOpacity(0.8),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 프로그레스 인디케이터
              SizedBox(
                width: size - strokeWidth * 2 - 16,
                height: size - strokeWidth * 2 - 16,
                child: animate
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                        duration: animationDuration,
                        builder: (context, value, _) =>
                            _buildProgressIndicator(value),
                      )
                    : _buildProgressIndicator(progress.clamp(0.0, 1.0)),
              ),
              // 중앙 위젯
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double value) {
    return CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth,
      backgroundColor: trackColor ?? AppColors.shadowDark.withOpacity(0.1),
      valueColor: AlwaysStoppedAnimation<Color>(
        progressColor ?? AppColors.accentBlue,
      ),
      strokeCap: StrokeCap.round,
    );
  }
}
