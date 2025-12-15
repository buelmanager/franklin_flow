// lib/core/widgets/section_header.dart

import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';
import 'neumorphic_button.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 섹션 헤더 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 섹션 제목과 선택적 액션 버튼
///
/// 사용법:
///   SectionHeader(title: 'Priority Tasks')
///
///   SectionHeader(
///     title: 'This Week',
///     actionIcon: Icons.add,
///     onActionTap: () {},
///   )
///
///   SectionHeader(
///     title: 'Tasks',
///     actionText: '더보기',
///     onActionTap: () {},
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  /// 섹션 제목
  final String title;

  /// 액션 아이콘 (actionText와 함께 사용 불가)
  final IconData? actionIcon;

  /// 액션 텍스트 (actionIcon과 함께 사용 불가)
  final String? actionText;

  /// 액션 탭 콜백
  final VoidCallback? onActionTap;

  /// 제목 스타일 커스텀
  final TextStyle? titleStyle;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionIcon,
    this.actionText,
    this.onActionTap,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle ?? AppTextStyles.heading3),
        if (actionIcon != null)
          NeumorphicButton.icon(
            icon: actionIcon!,
            onTap: onActionTap,
            size: AppSizes.buttonHeightS,
            iconSize: AppSizes.iconS,
          )
        else if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(actionText!, style: AppTextStyles.link),
          ),
      ],
    );
  }
}
