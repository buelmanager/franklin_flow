// lib/features/auth/services/auth_session_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import '../../../core/utils/app_logger.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AuthSessionService - 인증 세션 관리 서비스
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Hive를 사용하여 로그인 세션을 영속화
/// - 앱 재시작 시 로그인 상태 복원
/// - 카카오 토큰 자동 갱신
/// - 세션 유효성 검증
///
/// 사용법:
///   final sessionService = ref.read(authSessionServiceProvider);
///   await sessionService.saveSession(session);
///   final session = await sessionService.restoreSession();
/// ═══════════════════════════════════════════════════════════════════════════

// Provider
final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService();
});

class AuthSessionService {
  AuthSessionService._();
  static final AuthSessionService _instance = AuthSessionService._();
  factory AuthSessionService() => _instance;

  static const String _tag = 'AuthSessionService';
  static const String _boxName = 'auth_session';
  static const String _sessionKey = 'current_session';

  Box<AuthSession>? _sessionBox;
  bool _isInitialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────────────

  /// 세션 서비스 초기화
  Future<void> init() async {
    if (_isInitialized) {
      AppLogger.w('AuthSessionService already initialized', tag: _tag);
      return;
    }

    try {
      AppLogger.i('Initializing AuthSessionService...', tag: _tag);

      // Adapter 등록 (이미 등록되어 있으면 무시)
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(AuthSessionAdapter());
        AppLogger.d('AuthSessionAdapter registered', tag: _tag);
      }

      // Box 열기
      _sessionBox = await Hive.openBox<AuthSession>(_boxName);
      _isInitialized = true;

      AppLogger.i('AuthSessionService initialized successfully', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to initialize AuthSessionService',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 초기화 확인
  void _checkInitialized() {
    if (!_isInitialized || _sessionBox == null) {
      throw Exception(
        'AuthSessionService not initialized. Call init() first.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 세션 관리
  // ─────────────────────────────────────────────────────────────────────────

  /// 현재 세션 가져오기
  AuthSession? getCurrentSession() {
    _checkInitialized();
    return _sessionBox!.get(_sessionKey);
  }

  /// 세션 저장
  Future<void> saveSession(AuthSession session) async {
    _checkInitialized();
    await _sessionBox!.put(_sessionKey, session);
    AppLogger.i(
      'Session saved: provider=${session.provider}, userId=${session.userId}',
      tag: _tag,
    );
  }

  /// 세션 삭제 (로그아웃)
  Future<void> clearSession() async {
    _checkInitialized();
    await _sessionBox!.delete(_sessionKey);
    AppLogger.i('Session cleared', tag: _tag);
  }

  /// 세션 유효성 확인
  bool hasValidSession() {
    _checkInitialized();
    final session = getCurrentSession();
    if (session == null) return false;
    return session.isValid;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 세션 복원
  // ─────────────────────────────────────────────────────────────────────────

  /// 저장된 세션에서 User 객체 복원
  /// 카카오 로그인의 경우 토큰 유효성 검사 및 갱신 시도
  Future<User?> restoreUser() async {
    _checkInitialized();

    final session = getCurrentSession();
    if (session == null) {
      AppLogger.d('No saved session found', tag: _tag);
      return null;
    }

    AppLogger.i(
      'Restoring session: provider=${session.provider}, userId=${session.userId}',
      tag: _tag,
    );

    // 세션 기본 유효성 확인
    if (!session.isValid) {
      AppLogger.w('Session expired, clearing...', tag: _tag);
      await clearSession();
      return null;
    }

    // 카카오 로그인인 경우 토큰 검증/갱신
    if (session.isKakaoAuth) {
      final validatedSession = await _validateKakaoSession(session);
      if (validatedSession == null) {
        AppLogger.w('Kakao session validation failed, clearing...', tag: _tag);
        await clearSession();
        return null;
      }
      // 갱신된 세션 저장
      if (validatedSession != session) {
        await saveSession(validatedSession);
      }
      return _sessionToUser(validatedSession);
    }

    // Firebase 기반 로그인은 Firebase Auth에서 자동 관리되므로
    // 세션 정보만 반환 (실제 인증은 Firebase에서 확인)
    return _sessionToUser(session);
  }

  /// 카카오 세션 검증 및 토큰 갱신
  Future<AuthSession?> _validateKakaoSession(AuthSession session) async {
    try {
      AppLogger.d('Validating Kakao session...', tag: _tag);

      // 토큰이 없으면 무효
      if (session.kakaoAccessToken == null) {
        AppLogger.w('No Kakao access token in session', tag: _tag);
        return null;
      }

      // 토큰 유효성 확인
      if (!session.isKakaoTokenValid) {
        AppLogger.d('Kakao token expired, attempting refresh...', tag: _tag);

        // 토큰 갱신 시도
        if (session.kakaoRefreshToken != null) {
          try {
            final token = await kakao.TokenManagerProvider.instance.manager
                .getToken();
            if (token != null) {
              AppLogger.i('Kakao token refreshed successfully', tag: _tag);
              return session.copyWithKakaoTokens(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                expiresAt: token.expiresAt,
              );
            }
          } catch (e) {
            AppLogger.w('Kakao token refresh failed: $e', tag: _tag);
            return null;
          }
        }
        return null;
      }

      // 카카오 API로 사용자 정보 확인
      try {
        await kakao.UserApi.instance.me();
        AppLogger.d('Kakao user verification successful', tag: _tag);
        return session.copyWithLastActive();
      } catch (e) {
        AppLogger.w('Kakao user verification failed: $e', tag: _tag);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Kakao session validation error',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 세션 생성 헬퍼
  // ─────────────────────────────────────────────────────────────────────────

  /// User와 Provider 정보로 세션 생성 (Firebase 기반)
  AuthSession createSessionFromUser(User user) {
    return AuthSession(
      userId: user.id,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      provider: user.provider ?? 'unknown',
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  /// 카카오 로그인 결과로 세션 생성
  AuthSession createKakaoSession({
    required String id,
    required String email,
    required String name,
    String? profileImageUrl,
    required String accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthSession(
      userId: id,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      provider: 'kakao',
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      kakaoAccessToken: accessToken,
      kakaoRefreshToken: refreshToken,
      kakaoTokenExpiresAt: tokenExpiresAt,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  /// 세션에서 User 객체 변환
  User _sessionToUser(AuthSession session) {
    return User(
      id: session.userId,
      email: session.email,
      name: session.name,
      profileImageUrl: session.profileImageUrl,
      provider: session.provider,
      createdAt: session.createdAt,
      lastLoginAt: session.lastActiveAt,
    );
  }

  /// 마지막 활동 시간 업데이트
  Future<void> updateLastActive() async {
    _checkInitialized();
    final session = getCurrentSession();
    if (session != null) {
      await saveSession(session.copyWithLastActive());
    }
  }

  /// Box 닫기
  Future<void> close() async {
    if (_sessionBox != null && _sessionBox!.isOpen) {
      await _sessionBox!.close();
    }
    _isInitialized = false;
    AppLogger.i('AuthSessionService closed', tag: _tag);
  }
}
