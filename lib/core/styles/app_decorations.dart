// lib/core/styles/app_decorations.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 뉴모피즘 데코레이션 시스템
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   Container(decoration: AppDecorations.neumorphicFlat)
///   Container(decoration: AppDecorations.neumorphicConvex)
///   Container(decoration: AppDecorations.neumorphicConcave)
///
/// 새로운 데코레이션 추가 시:
///   1. 기존 그림자 값 참고하여 일관성 유지
///   2. offset, blur, spread 값 문서화
/// ═══════════════════════════════════════════════════════════════════════════

class AppDecorations {
  AppDecorations._(); // 인스턴스화 방지

  // ─────────────────────────────────────────────────────────────────────────
  // 뉴모피즘 그림자 프리셋
  // ─────────────────────────────────────────────────────────────────────────

  /// 뉴모피즘 기본 그림자 (볼록한 느낌)
  static List<BoxShadow> get neumorphicShadow => [
    BoxShadow(
      color: AppColors.shadowDark.withOpacity(0.5),
      offset: const Offset(
        AppSizes.neumorphicOffsetM,
        AppSizes.neumorphicOffsetM,
      ),
      blurRadius: AppSizes.neumorphicBlurM,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.shadowLight.withOpacity(0.9),
      offset: const Offset(
        -AppSizes.neumorphicOffsetM,
        -AppSizes.neumorphicOffsetM,
      ),
      blurRadius: AppSizes.neumorphicBlurM,
      spreadRadius: 1,
    ),
  ];

  /// 뉴모피즘 작은 그림자 (버튼 등)
  static List<BoxShadow> get neumorphicShadowSmall => [
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

  /// 뉴모피즘 눌림 그림자 (버튼 pressed)
  static List<BoxShadow> get neumorphicShadowPressed => [
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

  /// 뉴모피즘 오목한 그림자 (인풋필드, 프로그레스바)
  static List<BoxShadow> get neumorphicShadowInset => [
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
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // 완성된 BoxDecoration 프리셋
  // ─────────────────────────────────────────────────────────────────────────

  /// 기본 뉴모피즘 컨테이너 (평평한)
  static BoxDecoration neumorphicFlat({
    double borderRadius = AppSizes.radiusXL,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: neumorphicShadow,
  );

  /// 볼록한 뉴모피즘 컨테이너
  static BoxDecoration neumorphicConvex({
    double borderRadius = AppSizes.radiusXL,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEFEDE8), // 밝은 쪽
        AppColors.surface,
        Color(0xFFDEDCD7), // 어두운 쪽
      ],
      stops: [0.0, 0.5, 1.0],
    ),
    boxShadow: neumorphicShadow,
  );

  /// 오목한 뉴모피즘 컨테이너 (인풋 필드용)
  static BoxDecoration neumorphicConcave({
    double borderRadius = AppSizes.radiusM,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: neumorphicShadowInset,
  );

  /// 뉴모피즘 버튼 (기본)
  static BoxDecoration neumorphicButton({
    double borderRadius = AppSizes.radiusM,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: neumorphicShadowSmall,
  );

  /// 뉴모피즘 버튼 (눌림)
  static BoxDecoration neumorphicButtonPressed({
    double borderRadius = AppSizes.radiusM,
  }) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: neumorphicShadowPressed,
  );

  /// 뉴모피즘 원형 (프로그레스, 아바타)
  static BoxDecoration get neumorphicCircle => BoxDecoration(
    color: AppColors.surface,
    shape: BoxShape.circle,
    boxShadow: neumorphicShadow,
  );

  /// 뉴모피즘 원형 (오목)
  static BoxDecoration get neumorphicCircleConcave => BoxDecoration(
    color: AppColors.surface,
    shape: BoxShape.circle,
    boxShadow: neumorphicShadowInset,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 액센트 컬러 배경
  // ─────────────────────────────────────────────────────────────────────────

  /// 액센트 컬러 배지/태그 배경
  static BoxDecoration accentBadge(
    Color color, {
    double borderRadius = AppSizes.radiusXS,
  }) => BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(borderRadius),
  );

  /// 액센트 컬러 아이콘 배경 (원형)
  static BoxDecoration accentIconCircle(Color color) =>
      BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle);

  /// 액센트 컬러 아이콘 배경 (사각형)
  static BoxDecoration accentIconSquare(
    Color color, {
    double borderRadius = AppSizes.radiusM,
  }) => BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(borderRadius),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 프로그레스 바 데코레이션
  // ─────────────────────────────────────────────────────────────────────────

  /// 프로그레스 바 배경 (오목)
  static BoxDecoration progressBarBackground({
    double height = AppSizes.progressBarHeightM,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(height / 2),
    color: AppColors.surface,
    boxShadow: neumorphicShadowInset,
  );

  /// 프로그레스 바 채움
  static BoxDecoration progressBarFill(
    Color color, {
    double height = AppSizes.progressBarHeightM,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(height / 2),
    gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.4),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
}
