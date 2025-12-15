// lib/core/widgets/neumorphic_container.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 뉴모피즘 컨테이너 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 전체에서 사용되는 기본 뉴모피즘 컨테이너
///
/// 사용법:
///   NeumorphicContainer(
///     child: Text('내용'),
///   )
///
///   NeumorphicContainer(
///     padding: EdgeInsets.all(20),
///     borderRadius: 16,
///     style: NeumorphicStyle.convex,
///     child: Text('볼록한 컨테이너'),
///   )
/// ═══════════════════════════════════════════════════════════════════════════

enum NeumorphicStyle {
  /// 평평한 스타일 (기본)
  flat,

  /// 볼록한 스타일 (그라데이션)
  convex,

  /// 오목한 스타일 (인풋필드 등)
  concave,
}

class NeumorphicContainer extends StatelessWidget {
  /// 자식 위젯
  final Widget child;

  /// 내부 패딩
  final EdgeInsets padding;

  /// 테두리 둥글기
  final double borderRadius;

  /// 고정 너비 (null이면 자동)
  final double? width;

  /// 고정 높이 (null이면 자동)
  final double? height;

  /// 뉴모피즘 스타일
  final NeumorphicStyle style;

  /// 그림자 강도 (0.0 ~ 1.0)
  final double shadowIntensity;

  /// 배경색 (기본: AppColors.surface)
  final Color? backgroundColor;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = AppSizes.radiusXL,
    this.width,
    this.height,
    this.style = NeumorphicStyle.flat,
    this.shadowIntensity = 1.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: _buildDecoration(),
      child: child,
    );
  }

  BoxDecoration _buildDecoration() {
    final bgColor = backgroundColor ?? AppColors.surface;

    switch (style) {
      case NeumorphicStyle.flat:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _buildFlatShadow(),
        );

      case NeumorphicStyle.convex:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lighten(bgColor, 0.05), bgColor, _darken(bgColor, 0.05)],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: _buildFlatShadow(),
        );

      case NeumorphicStyle.concave:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _buildConcaveShadow(),
        );
    }
  }

  List<BoxShadow> _buildFlatShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.5 * shadowIntensity),
        offset: const Offset(
          AppSizes.neumorphicOffsetM,
          AppSizes.neumorphicOffsetM,
        ),
        blurRadius: AppSizes.neumorphicBlurM,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.9 * shadowIntensity),
        offset: const Offset(
          -AppSizes.neumorphicOffsetM,
          -AppSizes.neumorphicOffsetM,
        ),
        blurRadius: AppSizes.neumorphicBlurM,
        spreadRadius: 1,
      ),
    ];
  }

  List<BoxShadow> _buildConcaveShadow() {
    return [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.25 * shadowIntensity),
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.7 * shadowIntensity),
        offset: const Offset(-1, -1),
        blurRadius: 3,
        spreadRadius: -1,
      ),
    ];
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
