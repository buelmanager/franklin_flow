// lib/features/auth/models/user_model.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// User Model - 사용자 정보 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Firebase User를 앱 내부에서 사용하기 위한 모델
/// Hive 저장이 필요 없으므로 일반 클래스로 구현
///
/// 사용법:
///   final user = User(
///     id: firebaseUser.uid,
///     email: firebaseUser.email ?? '',
///     name: firebaseUser.displayName ?? '',
///   );
///
/// Provider 종류:
///   - google: Google 로그인
///   - apple: Apple 로그인
///   - naver: 네이버 로그인
///   - kakao: 카카오 로그인
/// ═══════════════════════════════════════════════════════════════════════════

class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? provider; // 로그인 제공자 (google, apple, naver, kakao)

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    DateTime? createdAt,
    this.lastLoginAt,
    this.provider,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 복사본 생성 (업데이트용)
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? provider,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      provider: provider ?? this.provider,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'provider': provider,
    };
  }

  /// JSON에서 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      provider: json['provider'] as String?,
    );
  }

  /// 표시용 이름 (이름이 없으면 이메일에서 추출)
  String get displayName {
    if (name.isNotEmpty) return name;
    if (email.isEmpty) return '사용자';
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;
    return email.substring(0, atIndex);
  }

  /// 프로필 이니셜 (아바타용)
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// 로그인 제공자 표시명
  String get providerDisplayName {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'naver':
        return '네이버';
      case 'kakao':
        return '카카오';
      default:
        return provider ?? '알 수 없음';
    }
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, provider: $provider)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
