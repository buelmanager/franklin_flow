// lib/core/widgets/stat_item.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';
import 'icon_box.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 스탯 아이템 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 아이콘 + 숫자 + 레이블 조합
///
/// 사용법:
///   StatItem(
///     icon: Icons.check_circle_outline,
///     label: 'Completed',
///     value: '5',
///     color: AppColors.accentGreen,
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class StatItem extends StatelessWidget {
  /// 아이콘
  final IconData icon;

  /// 레이블 텍스트
  final String label;

  /// 값 텍스트
  final String value;

  /// 액센트 색상
  final Color color;

  /// 방향 (가로/세로)
  final Axis direction;

  /// 아이콘 박스 크기
  final double iconBoxSize;

  const StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.direction = Axis.horizontal,
    this.iconBoxSize = AppSizes.buttonHeightS,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return _buildVertical();
    }
    return _buildHorizontal();
  }

  Widget _buildHorizontal() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBox.icon(
          icon: icon,
          color: color,
          size: iconBoxSize,
          iconSize: iconBoxSize * 0.5,
          shape: IconBoxShape.square,
        ),
        const SizedBox(width: AppSizes.spaceM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.numberM),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildVertical() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBox.icon(
          icon: icon,
          color: color,
          size: iconBoxSize,
          iconSize: iconBoxSize * 0.5,
          shape: IconBoxShape.square,
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(value, style: AppTextStyles.numberM),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
