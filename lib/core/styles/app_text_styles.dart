// lib/core/styles/app_text_styles.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 텍스트 스타일 시스템
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   Text('제목', style: AppTextStyles.heading1)
///   Text('본문', style: AppTextStyles.bodyM)
///
/// 커스텀 색상 적용:
///   Text('텍스트', style: AppTextStyles.bodyM.copyWith(color: AppColors.accentBlue))
///
/// 새로운 스타일 추가 시:
///   1. 해당 카테고리에 static TextStyle get 추가
///   2. 기존 스타일과 일관된 폰트 사이즈/웨이트 유지
/// ═══════════════════════════════════════════════════════════════════════════

class AppTextStyles {
  AppTextStyles._(); // 인스턴스화 방지

  // ─────────────────────────────────────────────────────────────────────────
  // 기본 폰트 설정
  // ─────────────────────────────────────────────────────────────────────────

  static const String _fontFamily = 'Pretendard'; // 또는 null로 시스템 폰트
  static const double _letterSpacing = -0.2;

  // ─────────────────────────────────────────────────────────────────────────
  // 헤딩 스타일 (제목용)
  // ─────────────────────────────────────────────────────────────────────────

  /// 가장 큰 제목 (28px, Bold)
  static TextStyle get heading1 => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  /// 섹션 제목 (22px, SemiBold)
  static TextStyle get heading2 => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: _letterSpacing,
    height: 1.3,
  );

  /// 카드/컴포넌트 제목 (18px, SemiBold)
  static TextStyle get heading3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: _letterSpacing,
    height: 1.4,
  );

  /// 소제목 (16px, SemiBold)
  static TextStyle get heading4 => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: _letterSpacing,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 레거시 호환 / Alias (기존 코드 호환용)
  // ─────────────────────────────────────────────────────────────────────────

  /// bodyM의 alias
  static TextStyle get bodyMedium => bodyM;

  /// bodyS의 alias
  static TextStyle get bodySmall => bodyS;

  /// bodyL의 alias
  static TextStyle get bodyLarge => bodyL;

  /// 큰 버튼 텍스트 (16px, SemiBold)
  static TextStyle get buttonLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 본문 스타일 (내용용)
  // ─────────────────────────────────────────────────────────────────────────

  /// 큰 본문 (16px, Regular)
  static TextStyle get bodyL => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: _letterSpacing,
    height: 1.5,
  );

  /// 중간 본문 (14px, Regular) - 기본값
  static TextStyle get bodyM => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: _letterSpacing,
    height: 1.5,
  );

  /// 작은 본문 (12px, Regular)
  static TextStyle get bodyS => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: _letterSpacing,
    height: 1.5,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 레이블 스타일 (버튼, 탭 등)
  // ─────────────────────────────────────────────────────────────────────────

  /// 큰 레이블 (14px, Medium)
  static TextStyle get labelL => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  /// 중간 레이블 (12px, Medium)
  static TextStyle get labelM => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );

  /// 작은 레이블 (10px, Medium)
  static TextStyle get labelS => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 캡션 스타일 (부가 정보)
  // ─────────────────────────────────────────────────────────────────────────

  /// 캡션 (11px, Regular)
  static TextStyle get caption => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 특수 스타일
  // ─────────────────────────────────────────────────────────────────────────

  /// 큰 숫자 (프로그레스 퍼센트 등)
  static TextStyle get displayNumber => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -1,
    height: 1.2,
  );

  /// 중간 숫자 (카운터, 뱃지 등)
  static TextStyle get numberM => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  /// 작은 숫자 (인라인 숫자)
  static TextStyle get numberS => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  /// 버튼 텍스트
  static TextStyle get button => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  /// 링크 텍스트
  static TextStyle get link => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
    letterSpacing: _letterSpacing,
    height: 1.5,
    decoration: TextDecoration.underline,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// 스타일에 색상 적용
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 스타일에 취소선 적용 (완료된 태스크용)
  static TextStyle withStrikethrough(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      color: AppColors.textTertiary,
    );
  }
}
