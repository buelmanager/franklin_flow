// lib/core/widgets/icon_box.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 아이콘 박스 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 배경색이 있는 아이콘/이모지 컨테이너
///
/// 사용법:
///   IconBox(
///     icon: Icons.check,
///     color: AppColors.accentGreen,
///   )
///
///   IconBox.emoji(
///     emoji: '🏃',
///     color: AppColors.accentPink,
///   )
/// ═══════════════════════════════════════════════════════════════════════════

enum IconBoxShape { circle, square }

class IconBox extends StatelessWidget {
  /// 아이콘 데이터
  final IconData? icon;

  /// 이모지 문자열
  final String? emoji;

  /// 액센트 색상 (배경 투명도 15%)
  final Color color;

  /// 박스 크기
  final double size;

  /// 아이콘/이모지 크기
  final double? iconSize;

  /// 박스 모양
  final IconBoxShape shape;

  /// 테두리 둥글기 (square일 때만)
  final double borderRadius;

  const IconBox({
    Key? key,
    this.icon,
    this.emoji,
    required this.color,
    this.size = AppSizes.avatarM,
    this.iconSize,
    this.shape = IconBoxShape.square,
    this.borderRadius = AppSizes.radiusM,
  }) : assert(icon != null || emoji != null, 'icon 또는 emoji 중 하나는 필수'),
       super(key: key);

  /// 아이콘 전용 팩토리
  factory IconBox.icon({
    Key? key,
    required IconData icon,
    required Color color,
    double size = AppSizes.avatarM,
    double? iconSize,
    IconBoxShape shape = IconBoxShape.square,
  }) {
    return IconBox(
      key: key,
      icon: icon,
      color: color,
      size: size,
      iconSize: iconSize,
      shape: shape,
    );
  }

  /// 이모지 전용 팩토리
  factory IconBox.emoji({
    Key? key,
    required String emoji,
    required Color color,
    double size = AppSizes.avatarM,
    double? iconSize,
    IconBoxShape shape = IconBoxShape.square,
  }) {
    return IconBox(
      key: key,
      emoji: emoji,
      color: color,
      size: size,
      iconSize: iconSize,
      shape: shape,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (size * 0.5);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: shape == IconBoxShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == IconBoxShape.square
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: effectiveIconSize, color: color)
            : Text(emoji!, style: TextStyle(fontSize: effectiveIconSize)),
      ),
    );
  }
}
