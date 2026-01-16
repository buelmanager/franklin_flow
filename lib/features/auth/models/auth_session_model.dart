// lib/features/auth/models/auth_session_model.dart

import 'package:hive/hive.dart';

part 'auth_session_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AuthSession Model - 인증 세션 모델 (Hive 영속화)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 로그인 세션 정보를 Hive에 저장하여 앱 재시작 시에도 로그인 상태 유지
/// Google/Apple은 Firebase Auth로 자동 유지되지만,
/// Kakao는 별도 세션 관리가 필요함
///
/// 저장 정보:
///   - 사용자 기본 정보 (id, email, name, profileImageUrl)
///   - 로그인 제공자 (google, apple, kakao, email)
///   - 세션 생성/만료 시간
///   - 카카오 전용: accessToken, refreshToken
///
/// 사용법:
///   final session = AuthSession(
///     userId: 'kakao_12345',
///     provider: 'kakao',
///     ...
///   );
///   await authSessionBox.put('current', session);
/// ═══════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 10)
class AuthSession extends HiveObject {
  /// 사용자 고유 ID
  @HiveField(0)
  final String userId;

  /// 이메일
  @HiveField(1)
  final String email;

  /// 사용자 이름
  @HiveField(2)
  final String name;

  /// 프로필 이미지 URL
  @HiveField(3)
  final String? profileImageUrl;

  /// 로그인 제공자 (google, apple, kakao, email)
  @HiveField(4)
  final String provider;

  /// 세션 생성 시간
  @HiveField(5)
  final DateTime createdAt;

  /// 마지막 활동 시간
  @HiveField(6)
  final DateTime lastActiveAt;

  /// 세션 만료 시간 (null = 무기한)
  @HiveField(7)
  final DateTime? expiresAt;

  /// 카카오 Access Token (카카오 로그인 전용)
  @HiveField(8)
  final String? kakaoAccessToken;

  /// 카카오 Refresh Token (카카오 로그인 전용)
  @HiveField(9)
  final String? kakaoRefreshToken;

  /// 카카오 토큰 만료 시간
  @HiveField(10)
  final DateTime? kakaoTokenExpiresAt;

  AuthSession({
    required this.userId,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.provider,
    required this.createdAt,
    required this.lastActiveAt,
    this.expiresAt,
    this.kakaoAccessToken,
    this.kakaoRefreshToken,
    this.kakaoTokenExpiresAt,
  });

  /// 세션이 유효한지 확인
  bool get isValid {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return true;
  }

  /// 카카오 토큰이 유효한지 확인
  bool get isKakaoTokenValid {
    if (provider != 'kakao') return true;
    if (kakaoAccessToken == null) return false;
    if (kakaoTokenExpiresAt != null &&
        DateTime.now().isAfter(kakaoTokenExpiresAt!)) {
      return false;
    }
    return true;
  }

  /// Firebase 기반 로그인인지 확인
  bool get isFirebaseAuth {
    return provider == 'google' || provider == 'apple' || provider == 'email';
  }

  /// 카카오 로그인인지 확인
  bool get isKakaoAuth => provider == 'kakao';

  /// 마지막 활동 시간 업데이트
  AuthSession copyWithLastActive() {
    return AuthSession(
      userId: userId,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      provider: provider,
      createdAt: createdAt,
      lastActiveAt: DateTime.now(),
      expiresAt: expiresAt,
      kakaoAccessToken: kakaoAccessToken,
      kakaoRefreshToken: kakaoRefreshToken,
      kakaoTokenExpiresAt: kakaoTokenExpiresAt,
    );
  }

  /// 카카오 토큰 업데이트
  AuthSession copyWithKakaoTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      userId: userId,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      provider: provider,
      createdAt: createdAt,
      lastActiveAt: DateTime.now(),
      expiresAt: this.expiresAt,
      kakaoAccessToken: accessToken ?? kakaoAccessToken,
      kakaoRefreshToken: refreshToken ?? kakaoRefreshToken,
      kakaoTokenExpiresAt: expiresAt ?? kakaoTokenExpiresAt,
    );
  }

  /// 사용자 정보 업데이트
  AuthSession copyWith({
    String? userId,
    String? email,
    String? name,
    String? profileImageUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    DateTime? expiresAt,
    String? kakaoAccessToken,
    String? kakaoRefreshToken,
    DateTime? kakaoTokenExpiresAt,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      expiresAt: expiresAt ?? this.expiresAt,
      kakaoAccessToken: kakaoAccessToken ?? this.kakaoAccessToken,
      kakaoRefreshToken: kakaoRefreshToken ?? this.kakaoRefreshToken,
      kakaoTokenExpiresAt: kakaoTokenExpiresAt ?? this.kakaoTokenExpiresAt,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'kakaoAccessToken': kakaoAccessToken,
      'kakaoRefreshToken': kakaoRefreshToken,
      'kakaoTokenExpiresAt': kakaoTokenExpiresAt?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      provider: json['provider'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      kakaoAccessToken: json['kakaoAccessToken'] as String?,
      kakaoRefreshToken: json['kakaoRefreshToken'] as String?,
      kakaoTokenExpiresAt: json['kakaoTokenExpiresAt'] != null
          ? DateTime.parse(json['kakaoTokenExpiresAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'AuthSession(userId: $userId, provider: $provider, email: $email, '
        'isValid: $isValid, isKakaoTokenValid: $isKakaoTokenValid)';
  }
}
