// lib/core/constants/app_sizes.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 앱 사이즈 시스템
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   - 패딩: AppSizes.paddingM
///   - 아이콘: AppSizes.iconM
///   - 테두리: AppSizes.radiusM
///
/// 새로운 사이즈 추가 시:
///   1. 해당 카테고리에 static const double 추가
///   2. XS, S, M, L, XL 네이밍 규칙 준수
///   3. 일관된 배율 유지 (보통 1.5배 또는 2배)
/// ═══════════════════════════════════════════════════════════════════════════

class AppSizes {
  AppSizes._(); // 인스턴스화 방지

  // ─────────────────────────────────────────────────────────────────────────
  // 패딩 & 마진
  // ─────────────────────────────────────────────────────────────────────────

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 간격 (SizedBox용)
  // ─────────────────────────────────────────────────────────────────────────

  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius (뉴모피즘 기본값 크게)
  // ─────────────────────────────────────────────────────────────────────────

  static const double radiusXS = 8.0;
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircle = 999.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 아이콘 사이즈
  // ─────────────────────────────────────────────────────────────────────────

  static const double iconXS = 14.0;
  static const double iconS = 18.0;
  static const double iconM = 22.0;
  static const double iconL = 28.0;
  static const double iconXL = 36.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 버튼 & 컴포넌트 높이
  // ─────────────────────────────────────────────────────────────────────────

  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
  static const double buttonHeightXL = 60.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 뉴모피즘 특화 사이즈
  // ─────────────────────────────────────────────────────────────────────────

  /// 뉴모피즘 그림자 오프셋 (작은 컴포넌트)
  static const double neumorphicOffsetS = 4.0;

  /// 뉴모피즘 그림자 오프셋 (중간 컴포넌트)
  static const double neumorphicOffsetM = 6.0;

  /// 뉴모피즘 그림자 오프셋 (큰 컴포넌트)
  static const double neumorphicOffsetL = 8.0;

  /// 뉴모피즘 블러 반경 (작은)
  static const double neumorphicBlurS = 10.0;

  /// 뉴모피즘 블러 반경 (중간)
  static const double neumorphicBlurM = 15.0;

  /// 뉴모피즘 블러 반경 (큰)
  static const double neumorphicBlurL = 20.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 컴포넌트 사이즈
  // ─────────────────────────────────────────────────────────────────────────

  /// 아바타 사이즈
  static const double avatarS = 32.0;
  static const double avatarM = 44.0;
  static const double avatarL = 56.0;
  static const double avatarXL = 80.0;

  /// 카드 최소 높이
  static const double cardMinHeight = 80.0;

  /// 프로그레스 원형 사이즈
  static const double progressCircleS = 80.0;
  static const double progressCircleM = 120.0;
  static const double progressCircleL = 160.0;

  /// 프로그레스 바 높이
  static const double progressBarHeightS = 4.0;
  static const double progressBarHeightM = 6.0;
  static const double progressBarHeightL = 8.0;

  // ─────────────────────────────────────────────────────────────────────────
  // 네비게이션
  // ─────────────────────────────────────────────────────────────────────────

  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;
}
