// lib/features/auth/config/auth_config.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// AuthConfig - 인증 설정
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Google / Apple / Kakao / Naver 소셜 로그인에 필요한 설정값
///
/// ═══════════════════════════════════════════════════════════════════════════

class AuthConfig {
  AuthConfig._();

  // ─────────────────────────────────────────────────────────────────────────
  // Google 로그인 설정
  // ─────────────────────────────────────────────────────────────────────────

  /// Google OAuth Web Client ID
  /// Google Cloud Console에서 생성된 Web Client ID
  static const String googleWebClientId =
      '109821855872-3os8fudr59902iuv57o5hs019g266997.apps.googleusercontent.com';

  /// iOS Client ID (firebase_options.dart에서 확인됨)
  static const String googleIosClientId =
      '109821855872-i95cnhurp0dk5dumu12kanisf8d1bojd.apps.googleusercontent.com';

  // ─────────────────────────────────────────────────────────────────────────
  // Firebase 설정
  // ─────────────────────────────────────────────────────────────────────────

  /// Firebase Auth Domain
  static const String firebaseAuthDomain = 'franklin-flow.firebaseapp.com';

  /// Firebase Project ID
  static const String firebaseProjectId = 'franklin-flow';

  // ─────────────────────────────────────────────────────────────────────────
  // 네이버 로그인 설정
  // ─────────────────────────────────────────────────────────────────────────

  /// 네이버 Client ID
  static const String naverClientId = 'vEvZLeAssTAacCsANErx';

  /// 네이버 Client Secret
  static const String naverClientSecret = 'gZ7vsSjWND';

  /// 네이버 앱 이름 (로그인 화면에 표시)
  static const String naverAppName = 'Franklin Flow';

  /// 네이버 URL Scheme (iOS)
  static const String naverUrlScheme = 'franklinflow';

  // ─────────────────────────────────────────────────────────────────────────
  // 카카오 로그인 설정
  // ─────────────────────────────────────────────────────────────────────────
  // 카카오 개발자 콘솔: https://developers.kakao.com
  // 1. 애플리케이션 추가
  // 2. 앱 키 확인 (네이티브 앱 키, REST API 키)
  // 3. 플랫폼 등록 (iOS, Android)
  // 4. 카카오 로그인 활성화
  // ─────────────────────────────────────────────────────────────────────────

  /// 카카오 Native App Key
  /// 카카오 개발자 콘솔 > 앱 설정 > 앱 키 > 네이티브 앱 키
  /// TODO: 실제 카카오 Native App Key로 교체하세요
  static const String kakaoNativeAppKey = 'b017efe12d9d229ff065669aff2928ec';

  /// 카카오 REST API Key
  /// 카카오 개발자 콘솔 > 앱 설정 > 앱 키 > REST API 키
  /// TODO: 실제 카카오 REST API Key로 교체하세요
  static const String kakaoRestApiKey = '30e4d3bd5e51fc6f284d474b237d9e49';

  /// 카카오 JavaScript Key (웹용)
  /// 카카오 개발자 콘솔 > 앱 설정 > 앱 키 > JavaScript 키
  /// TODO: 실제 카카오 JavaScript Key로 교체하세요
  static const String kakaoJavaScriptKey = '96996ee11bb9086edc53169804221075';

  /// 카카오 Admin Key (서버용 - 앱에서는 사용하지 않음)
  /// ⚠️ 주의: Admin Key는 서버에서만 사용해야 합니다. 앱에 포함하지 마세요!
  // static const String kakaoAdminKey = 'YOUR_KAKAO_ADMIN_KEY';

  // ─────────────────────────────────────────────────────────────────────────
  // 개발 설정
  // ─────────────────────────────────────────────────────────────────────────

  /// 개발 모드 여부
  static const bool isDevelopment = true;

  /// 테스트용 로그인 활성화 (개발 중에만 사용)
  static const bool enableTestLogin = false;

  /// ⚠️ 테스트용: 앱 시작 시 자동 로그아웃 (true로 설정하면 매번 로그인 화면으로 이동)
  static const bool forceLogoutOnStart = false;
}
