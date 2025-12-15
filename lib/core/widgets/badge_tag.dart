// lib/core/widgets/badge_tag.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 배지/태그 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 카테고리, 상태 표시용 소형 태그
///
/// 사용법:
///   BadgeTag(text: '업무', color: AppColors.accentBlue)
///   BadgeTag.status(status: 'completed')
/// ═══════════════════════════════════════════════════════════════════════════

class BadgeTag extends StatelessWidget {
  /// 태그 텍스트
  final String text;

  /// 배경/텍스트 색상
  final Color color;

  /// 패딩
  final EdgeInsets padding;

  /// 테두리 둥글기
  final double borderRadius;

  const BadgeTag({
    Key? key,
    required this.text,
    required this.color,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingS,
      vertical: 2,
    ),
    this.borderRadius = AppSizes.radiusXS,
  }) : super(key: key);

  /// 태스크 상태 태그 팩토리
  factory BadgeTag.status({Key? key, required String status}) {
    String text;
    Color color;

    switch (status) {
      case 'completed':
        text = 'Completed';
        color = AppColors.taskCompleted;
        break;
      case 'in-progress':
        text = 'In Progress';
        color = AppColors.taskInProgress;
        break;
      case 'pending':
      default:
        text = 'Pending';
        color = AppColors.taskPending;
        break;
    }

    return BadgeTag(key: key, text: text, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelS.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
