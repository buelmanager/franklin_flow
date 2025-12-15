// lib/core/widgets/neumorphic_button.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/app_logger.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 뉴모피즘 버튼 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 탭 시 눌림 효과가 있는 뉴모피즘 버튼
///
/// 사용법:
///   NeumorphicButton(
///     onTap: () => print('클릭'),
///     child: Icon(Icons.add),
///   )
///
///   NeumorphicButton(
///     width: 100,
///     height: 44,
///     borderRadius: 12,
///     onTap: () {},
///     child: Text('버튼'),
///   )
///
///   NeumorphicButton.icon(
///     icon: Icons.settings,
///     onTap: () {},
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class NeumorphicButton extends StatefulWidget {
  /// 자식 위젯
  final Widget child;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 롱프레스 콜백
  final VoidCallback? onLongPress;

  /// 고정 너비
  final double? width;

  /// 고정 높이
  final double? height;

  /// 테두리 둥글기
  final double borderRadius;

  /// 내부 패딩
  final EdgeInsets padding;

  /// 비활성화 여부
  final bool disabled;

  /// 로그 태그 (디버깅용)
  final String? logTag;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.borderRadius = AppSizes.radiusM,
    this.padding = EdgeInsets.zero,
    this.disabled = false,
    this.logTag,
  }) : super(key: key);

  /// 아이콘 전용 버튼 팩토리
  factory NeumorphicButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onTap,
    double size = AppSizes.buttonHeightM,
    double iconSize = AppSizes.iconM,
    Color? iconColor,
    bool disabled = false,
    String? logTag,
  }) {
    return NeumorphicButton(
      key: key,
      width: size,
      height: size,
      borderRadius: AppSizes.radiusM,
      onTap: onTap,
      disabled: disabled,
      logTag: logTag,
      child: Icon(
        icon,
        size: iconSize,
        color: disabled
            ? AppColors.textDisabled
            : (iconColor ?? AppColors.textSecondary),
      ),
    );
  }

  /// 텍스트 버튼 팩토리
  factory NeumorphicButton.text({
    Key? key,
    required String text,
    VoidCallback? onTap,
    double? width,
    double height = AppSizes.buttonHeightM,
    TextStyle? textStyle,
    bool disabled = false,
    String? logTag,
  }) {
    return NeumorphicButton(
      key: key,
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      onTap: onTap,
      disabled: disabled,
      logTag: logTag,
      child: Text(
        text,
        style:
            textStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: disabled ? AppColors.textDisabled : AppColors.textPrimary,
            ),
      ),
    );
  }

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.disabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.disabled) return;
    setState(() => _isPressed = false);

    if (widget.logTag != null) {
      AppLogger.d('Button tapped');
    }

    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.disabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.disabled ? null : widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _buildShadow(),
        ),
        child: Center(
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadow() {
    if (widget.disabled) {
      // 비활성화 상태: 그림자 약하게
      return [
        BoxShadow(
          color: AppColors.shadowDark.withOpacity(0.2),
          offset: const Offset(2, 2),
          blurRadius: 5,
        ),
        BoxShadow(
          color: AppColors.shadowLight.withOpacity(0.5),
          offset: const Offset(-2, -2),
          blurRadius: 5,
        ),
      ];
    }

    if (_isPressed) {
      // 눌림 상태: 오목한 그림자
      return [
        BoxShadow(
          color: AppColors.shadowDark.withOpacity(0.3),
          offset: const Offset(2, 2),
          blurRadius: 5,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.shadowLight.withOpacity(0.7),
          offset: const Offset(-2, -2),
          blurRadius: 5,
          spreadRadius: -2,
        ),
      ];
    }

    // 기본 상태
    return [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.4),
        offset: const Offset(
          AppSizes.neumorphicOffsetS,
          AppSizes.neumorphicOffsetS,
        ),
        blurRadius: AppSizes.neumorphicBlurS,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.9),
        offset: const Offset(
          -AppSizes.neumorphicOffsetS,
          -AppSizes.neumorphicOffsetS,
        ),
        blurRadius: AppSizes.neumorphicBlurS,
        spreadRadius: 0,
      ),
    ];
  }
}
