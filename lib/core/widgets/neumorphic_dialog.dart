// lib/core/widgets/neumorphic_dialog.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_logger.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 뉴모피즘 다이얼로그 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 전체에서 사용되는 공용 다이얼로그
///
/// 사용법:
///   showDialog(
///     context: context,
///     builder: (context) => NeumorphicDialog(
///       title: '제목',
///       content: Text('내용'),
///       actions: [
///         NeumorphicButton.text(text: '취소', onTap: () {}),
///         NeumorphicButton.text(text: '확인', onTap: () {}),
///       ],
///     ),
///   );
///
///   // 또는 헬퍼 메서드 사용
///   NeumorphicDialog.show(
///     context: context,
///     title: '제목',
///     content: Text('내용'),
///   );
/// ═══════════════════════════════════════════════════════════════════════════

class NeumorphicDialog extends StatelessWidget {
  /// 다이얼로그 제목
  final String? title;

  /// 다이얼로그 내용 위젯
  final Widget content;

  /// 액션 버튼들 (하단)
  final List<Widget>? actions;

  /// 다이얼로그 너비
  final double? width;

  /// 패딩
  final EdgeInsets padding;

  /// 액션 버튼 정렬
  final MainAxisAlignment actionsAlignment;

  const NeumorphicDialog({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.width,
    this.padding = const EdgeInsets.all(AppSizes.paddingXL),
    this.actionsAlignment = MainAxisAlignment.end,
  }) : super(key: key);

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    AppLogger.d('Showing NeumorphicDialog: $title', tag: 'NeumorphicDialog');

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.shadowDark.withOpacity(0.3),
      builder: (context) =>
          NeumorphicDialog(title: title, content: content, actions: actions),
    );
  }

  /// 확인 다이얼로그 (OK 버튼만)
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String okText = '확인',
  }) {
    return show(
      context: context,
      title: title,
      content: Text(message, style: AppTextStyles.bodyM),
      actions: [
        NeumorphicButton.text(
          text: okText,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 확인/취소 다이얼로그
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
  }) {
    return show<bool>(
      context: context,
      title: title,
      content: Text(message, style: AppTextStyles.bodyM),
      actions: [
        NeumorphicButton.text(
          text: cancelText,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSizes.spaceM),
        NeumorphicButton.text(
          text: confirmText,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.accentBlue),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXL,
        vertical: AppSizes.paddingXL,
      ),
      child: NeumorphicContainer(
        width: width,
        padding: padding,
        borderRadius: AppSizes.radiusXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            if (title != null) ...[
              Text(title!, style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.spaceXL),
            ],

            // 내용
            content,

            // 액션 버튼
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceXXL),
              Row(mainAxisAlignment: actionsAlignment, children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
