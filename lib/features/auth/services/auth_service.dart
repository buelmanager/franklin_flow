// lib/features/auth/services/auth_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import '../../../core/utils/app_logger.dart';
import '../config/auth_config.dart';
import '../models/user_model.dart';
import 'auth_session_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AuthService - Firebase 기반 인증 서비스
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Firebase Authentication을 사용한 소셜 로그인 서비스
/// - Google Sign In (웹/모바일)
/// - Apple Sign In (iOS/macOS)
/// - Kakao Sign In (모바일)
///
/// 사용법:
///   final authService = ref.read(authServiceProvider);
///   final result = await authService.signInWithGoogle();
///
/// 에러 코드:
///   - sign-in-cancelled: 사용자가 로그인을 취소함
///   - google-sign-in-failed: Google 로그인 실패
///   - apple-sign-in-failed: Apple 로그인 실패
///   - kakao-sign-in-failed: Kakao 로그인 실패
///   - unknown-error: 알 수 없는 에러
/// ═══════════════════════════════════════════════════════════════════════════

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 현재 사용자 상태 Provider
final currentUserProvider = StateProvider<User?>((ref) => null);

// 인증 상태 Provider
final authStateProvider = StateProvider<AuthState>((ref) => AuthState.initial);

// Firebase User 스트림 Provider
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return firebase_auth.FirebaseAuth.instance.authStateChanges();
});

/// 인증 상태
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// 인증 결과
class AuthResult {
  final bool success;
  final User? user;
  final String? errorCode;
  final String? errorMessage;
  final bool isNewUser; // 신규 가입 여부

  AuthResult({
    required this.success,
    this.user,
    this.errorCode,
    this.errorMessage,
    this.isNewUser = false,
  });

  factory AuthResult.success(User user, {bool isNewUser = false}) {
    return AuthResult(success: true, user: user, isNewUser: isNewUser);
  }

  factory AuthResult.failure(String errorCode, String errorMessage) {
    return AuthResult(
      success: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }
}

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  static const String _tag = 'AuthService';

  // Firebase Auth 인스턴스
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // 세션 서비스 인스턴스
  final AuthSessionService _sessionService = AuthSessionService();

  // Google Sign In 인스턴스 (플랫폼별 설정)
  late final GoogleSignIn _googleSignIn = _createGoogleSignIn();

  /// Google Sign In 인스턴스 생성 (플랫폼별)
  GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) {
      AppLogger.d('Creating GoogleSignIn for Web with clientId', tag: _tag);
      return GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: AuthConfig.googleWebClientId,
      );
    } else {
      AppLogger.d('Creating GoogleSignIn for Mobile/Desktop', tag: _tag);
      return GoogleSignIn(scopes: ['email', 'profile']);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;
  bool get isSignedIn => firebaseUser != null;
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // ─────────────────────────────────────────────────────────────────────────
  // Google Sign In
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    try {
      AppLogger.i('Starting Google Sign In...', tag: _tag);
      AppLogger.d('Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}', tag: _tag);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.w('Google Sign In cancelled by user', tag: _tag);
        return AuthResult.failure('sign-in-cancelled', '로그인이 취소되었습니다.');
      }

      AppLogger.d('Google user: ${googleUser.email}', tag: _tag);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      AppLogger.d('Got Google auth tokens', tag: _tag);

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        AppLogger.e('Firebase user is null after Google Sign In', tag: _tag);
        return AuthResult.failure(
          'google-sign-in-failed',
          'Google 로그인에 실패했습니다.',
        );
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final user = _firebaseUserToUser(userCredential.user!);

      AppLogger.i(
        'Google Sign In successful: ${user.name}, isNewUser: $isNewUser',
        tag: _tag,
      );
      return AuthResult.success(user, isNewUser: isNewUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e(
        'Firebase Auth Exception during Google Sign In: ${e.code}',
        tag: _tag,
        error: e,
      );
      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Google Sign In failed: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );

      if (e.toString().contains('ClientID not set')) {
        return AuthResult.failure(
          'google-client-id-not-set',
          'Google Sign In ClientID가 설정되지 않았습니다.',
        );
      }

      return AuthResult.failure('google-sign-in-failed', 'Google 로그인에 실패했습니다.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Apple Sign In
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> signInWithApple() async {
    try {
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.i('Starting Apple Sign In...', tag: _tag);
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);

      // Step 1: 웹 환경 체크
      AppLogger.d('[Step 1] Checking platform...', tag: _tag);
      if (kIsWeb) {
        AppLogger.w('Apple Sign In not supported on web', tag: _tag);
        return AuthResult.failure(
          'apple-sign-in-unavailable',
          'Apple 로그인은 웹에서 지원되지 않습니다.',
        );
      }
      AppLogger.d('[Step 1] Platform check passed (not web)', tag: _tag);

      // Step 2: Apple Sign In 가능 여부 확인
      AppLogger.d('[Step 2] Checking Apple Sign In availability...', tag: _tag);
      final isAvailable = await SignInWithApple.isAvailable();
      AppLogger.d('[Step 2] Apple Sign In available: $isAvailable', tag: _tag);

      if (!isAvailable) {
        AppLogger.w('Apple Sign In not available on this device', tag: _tag);
        return AuthResult.failure(
          'apple-sign-in-unavailable',
          'Apple 로그인을 사용할 수 없습니다.',
        );
      }

      // Step 3: Nonce 생성 (보안용)
      AppLogger.d('[Step 3] Generating nonce...', tag: _tag);
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);
      AppLogger.d('[Step 3] Raw nonce length: ${rawNonce.length}', tag: _tag);
      AppLogger.d(
        '[Step 3] Hashed nonce (first 20 chars): ${hashedNonce.substring(0, 20)}...',
        tag: _tag,
      );

      // Step 4: Apple ID credential 요청
      AppLogger.d('[Step 4] Requesting Apple ID credential...', tag: _tag);
      AppLogger.d('[Step 4] Scopes: email, fullName', tag: _tag);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      AppLogger.d('[Step 4] Got Apple credential successfully', tag: _tag);

      // Step 5: Apple credential 상세 정보 로깅
      AppLogger.d('[Step 5] Apple credential details:', tag: _tag);
      AppLogger.d(
        '  - identityToken: ${appleCredential.identityToken != null ? "EXISTS (${appleCredential.identityToken!.length} chars)" : "NULL"}',
        tag: _tag,
      );
      AppLogger.d(
        '  - authorizationCode: ${appleCredential.authorizationCode != null ? "EXISTS (${appleCredential.authorizationCode!.length} chars)" : "NULL"}',
        tag: _tag,
      );
      AppLogger.d('  - email: ${appleCredential.email ?? "NULL"}', tag: _tag);
      AppLogger.d(
        '  - givenName: ${appleCredential.givenName ?? "NULL"}',
        tag: _tag,
      );
      AppLogger.d(
        '  - familyName: ${appleCredential.familyName ?? "NULL"}',
        tag: _tag,
      );
      AppLogger.d(
        '  - userIdentifier: ${appleCredential.userIdentifier ?? "NULL"}',
        tag: _tag,
      );

      // Step 6: identityToken 유효성 검사
      AppLogger.d('[Step 6] Validating identityToken...', tag: _tag);
      if (appleCredential.identityToken == null) {
        AppLogger.e('[Step 6] FAILED: identityToken is NULL!', tag: _tag);
        return AuthResult.failure(
          'apple-sign-in-failed',
          'Apple 인증 토큰을 받지 못했습니다.',
        );
      }
      AppLogger.d('[Step 6] identityToken is valid', tag: _tag);

      // Step 7: JWT 디코딩 (디버깅용)
      AppLogger.d('[Step 7] Decoding identityToken (JWT)...', tag: _tag);
      _logJwtContents(appleCredential.identityToken!, hashedNonce);

      // Step 8: Firebase OAuthCredential 생성
      AppLogger.d('[Step 8] Creating Firebase OAuthCredential...', tag: _tag);
      AppLogger.d('[Step 8] Provider: apple.com', tag: _tag);
      AppLogger.d(
        '[Step 8] Using rawNonce (not hashed) for Firebase',
        tag: _tag,
      );
      AppLogger.d(
        '[Step 8] ⭐ Adding accessToken (authorizationCode) - THIS IS THE FIX',
        tag: _tag,
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
            idToken: appleCredential.identityToken!,
            accessToken: appleCredential.authorizationCode, // ⭐ 핵심 수정!
            rawNonce: rawNonce, // 해시되지 않은 원본 nonce 사용
          );

      AppLogger.d('[Step 8] OAuthCredential created successfully', tag: _tag);
      AppLogger.d(
        '[Step 8] Credential providerId: ${oauthCredential.providerId}',
        tag: _tag,
      );
      AppLogger.d(
        '[Step 8] Credential signInMethod: ${oauthCredential.signInMethod}',
        tag: _tag,
      );

      // Step 9: Firebase 로그인 시도
      AppLogger.d(
        '[Step 9] Attempting Firebase signInWithCredential...',
        tag: _tag,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      AppLogger.d('[Step 9] Firebase sign in completed', tag: _tag);

      // Step 10: Firebase 결과 확인
      AppLogger.d('[Step 10] Checking Firebase result...', tag: _tag);
      if (userCredential.user == null) {
        AppLogger.e('[Step 10] FAILED: Firebase user is null!', tag: _tag);
        return AuthResult.failure('apple-sign-in-failed', 'Apple 로그인에 실패했습니다.');
      }

      AppLogger.d('[Step 10] Firebase user exists', tag: _tag);
      AppLogger.d('[Step 10] User UID: ${userCredential.user!.uid}', tag: _tag);
      AppLogger.d(
        '[Step 10] User email: ${userCredential.user!.email}',
        tag: _tag,
      );
      AppLogger.d(
        '[Step 10] User displayName: ${userCredential.user!.displayName}',
        tag: _tag,
      );
      AppLogger.d(
        '[Step 10] isNewUser: ${userCredential.additionalUserInfo?.isNewUser}',
        tag: _tag,
      );

      // Step 11: 이름 업데이트
      AppLogger.d('[Step 11] Checking if name update needed...', tag: _tag);
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();

        if (displayName.isNotEmpty) {
          AppLogger.d(
            '[Step 11] Updating display name to: $displayName',
            tag: _tag,
          );
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
          AppLogger.d('[Step 11] Display name updated', tag: _tag);
        }
      } else {
        AppLogger.d(
          '[Step 11] No name provided by Apple (not first login)',
          tag: _tag,
        );
      }

      // Step 12: 최종 결과 생성
      AppLogger.d('[Step 12] Creating final result...', tag: _tag);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final user = _firebaseUserToUser(
        _firebaseAuth.currentUser ?? userCredential.user!,
      );

      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.i('Apple Sign In SUCCESSFUL!', tag: _tag);
      AppLogger.i('  User: ${user.name}', tag: _tag);
      AppLogger.i('  Email: ${user.email}', tag: _tag);
      AppLogger.i('  isNewUser: $isNewUser', tag: _tag);
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);

      return AuthResult.success(user, isNewUser: isNewUser);
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Apple Sign In FAILED (Authorization Exception)', tag: _tag);
      AppLogger.e('  Code: ${e.code}', tag: _tag);
      AppLogger.e('  Message: ${e.message}', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.failure('sign-in-cancelled', '로그인이 취소되었습니다.');
      }
      return AuthResult.failure(
        'apple-sign-in-failed',
        'Apple 로그인에 실패했습니다: ${e.message}',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Apple Sign In FAILED (Firebase Auth Exception)', tag: _tag);
      AppLogger.e('  Code: ${e.code}', tag: _tag);
      AppLogger.e('  Message: ${e.message}', tag: _tag);
      AppLogger.e('  Credential: ${e.credential}', tag: _tag);
      AppLogger.e('  Email: ${e.email}', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Apple Sign In FAILED (Unknown Exception)', tag: _tag);
      AppLogger.e('  Type: ${e.runtimeType}', tag: _tag);
      AppLogger.e('  Error: $e', tag: _tag);
      AppLogger.e('  StackTrace: $stackTrace', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      return AuthResult.failure('apple-sign-in-failed', 'Apple 로그인에 실패했습니다.');
    }
  }

  /// JWT 내용 로깅 (디버깅용)
  void _logJwtContents(String token, String expectedNonce) {
    try {
      final parts = token.split('.');
      AppLogger.d('[Step 7] JWT parts count: ${parts.length}', tag: _tag);

      if (parts.length == 3) {
        final header = _decodeBase64(parts[0]);
        AppLogger.d('[Step 7] JWT Header: $header', tag: _tag);

        final payload = _decodeBase64(parts[1]);
        AppLogger.d('[Step 7] JWT Payload: $payload', tag: _tag);

        try {
          final payloadMap = json.decode(payload) as Map<String, dynamic>;
          AppLogger.d(
            '[Step 7] JWT iss (issuer): ${payloadMap['iss']}',
            tag: _tag,
          );
          AppLogger.d(
            '[Step 7] JWT aud (audience): ${payloadMap['aud']}',
            tag: _tag,
          );
          AppLogger.d(
            '[Step 7] JWT sub (subject): ${payloadMap['sub']}',
            tag: _tag,
          );
          AppLogger.d('[Step 7] JWT nonce: ${payloadMap['nonce']}', tag: _tag);
          AppLogger.d(
            '[Step 7] JWT nonce_supported: ${payloadMap['nonce_supported']}',
            tag: _tag,
          );

          final tokenNonce = payloadMap['nonce'];
          if (tokenNonce != null && tokenNonce != expectedNonce) {
            AppLogger.w('[Step 7] WARNING: Nonce mismatch!', tag: _tag);
            AppLogger.w(
              '[Step 7]   Expected: ${expectedNonce.substring(0, 20)}...',
              tag: _tag,
            );
            AppLogger.w(
              '[Step 7]   Got: ${tokenNonce.toString().substring(0, 20)}...',
              tag: _tag,
            );
          } else if (tokenNonce != null) {
            AppLogger.d('[Step 7] Nonce matches!', tag: _tag);
          }
        } catch (e) {
          AppLogger.w('[Step 7] Could not parse JWT payload: $e', tag: _tag);
        }
      }
    } catch (e) {
      AppLogger.w('[Step 7] Could not decode JWT: $e', tag: _tag);
    }
  }

  /// Base64 URL-safe 디코딩 헬퍼
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64 string');
    }
    return utf8.decode(base64Url.decode(output));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 카카오 로그인
  // ─────────────────────────────────────────────────────────────────────────

  /// 카카오 로그인
  Future<AuthResult> signInWithKakao() async {
    try {
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.i('Starting Kakao Sign In...', tag: _tag);
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);

      // Step 1: 웹 환경 체크
      AppLogger.d('[Kakao Step 1] Checking platform...', tag: _tag);
      if (kIsWeb) {
        AppLogger.w(
          'Kakao Sign In not supported on web in this app',
          tag: _tag,
        );
        return AuthResult.failure(
          'kakao-sign-in-unavailable',
          '카카오 로그인은 웹에서 지원되지 않습니다.',
        );
      }
      AppLogger.d('[Kakao Step 1] Platform check passed (not web)', tag: _tag);

      // Step 2: 카카오톡 설치 여부 확인
      AppLogger.d(
        '[Kakao Step 2] Checking if KakaoTalk is installed...',
        tag: _tag,
      );
      final isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();
      AppLogger.d(
        '[Kakao Step 2] KakaoTalk installed: $isKakaoTalkInstalled',
        tag: _tag,
      );

      // Step 3: 로그인 시도
      kakao.OAuthToken token;

      if (isKakaoTalkInstalled) {
        // 카카오톡으로 로그인
        AppLogger.d(
          '[Kakao Step 3] Attempting login with KakaoTalk app...',
          tag: _tag,
        );
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          AppLogger.d('[Kakao Step 3] KakaoTalk login successful', tag: _tag);
        } catch (e) {
          AppLogger.w(
            '[Kakao Step 3] KakaoTalk login failed, trying web login: $e',
            tag: _tag,
          );
          // 카카오톡 로그인 실패 시 웹 로그인으로 폴백
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          AppLogger.d(
            '[Kakao Step 3] Kakao Account web login successful',
            tag: _tag,
          );
        }
      } else {
        // 카카오 계정으로 로그인 (웹뷰)
        AppLogger.d(
          '[Kakao Step 3] Attempting login with Kakao Account (web)...',
          tag: _tag,
        );
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        AppLogger.d('[Kakao Step 3] Kakao Account login successful', tag: _tag);
      }

      // Step 4: 토큰 정보 로깅
      AppLogger.d('[Kakao Step 4] Token details:', tag: _tag);
      AppLogger.d(
        '  - accessToken: ${token.accessToken.isNotEmpty ? "EXISTS (${token.accessToken.length} chars)" : "NULL"}',
        tag: _tag,
      );
      AppLogger.d(
        '  - refreshToken: ${token.refreshToken?.isNotEmpty == true ? "EXISTS" : "NULL"}',
        tag: _tag,
      );
      AppLogger.d('  - scopes: ${token.scopes}', tag: _tag);

      // Step 5: 사용자 정보 가져오기
      AppLogger.d('[Kakao Step 5] Fetching user info...', tag: _tag);
      final kakaoUser = await kakao.UserApi.instance.me();
      AppLogger.d('[Kakao Step 5] User info retrieved', tag: _tag);

      // Step 6: 사용자 정보 로깅
      AppLogger.d('[Kakao Step 6] User details:', tag: _tag);
      AppLogger.d('  - id: ${kakaoUser.id}', tag: _tag);
      AppLogger.d('  - connectedAt: ${kakaoUser.connectedAt}', tag: _tag);
      AppLogger.d(
        '  - kakaoAccount.email: ${kakaoUser.kakaoAccount?.email}',
        tag: _tag,
      );
      AppLogger.d(
        '  - kakaoAccount.profile.nickname: ${kakaoUser.kakaoAccount?.profile?.nickname}',
        tag: _tag,
      );
      AppLogger.d(
        '  - kakaoAccount.profile.profileImageUrl: ${kakaoUser.kakaoAccount?.profile?.profileImageUrl}',
        tag: _tag,
      );
      AppLogger.d(
        '  - kakaoAccount.profile.thumbnailImageUrl: ${kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl}',
        tag: _tag,
      );

      // Step 7: User 모델 생성
      AppLogger.d('[Kakao Step 7] Creating User model...', tag: _tag);

      final String userName =
          kakaoUser.kakaoAccount?.profile?.nickname ??
          kakaoUser.kakaoAccount?.name ??
          '카카오 사용자';

      final String email = kakaoUser.kakaoAccount?.email ?? '';

      final user = User(
        id: 'kakao_${kakaoUser.id}',
        email: email,
        name: userName,
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        createdAt: kakaoUser.connectedAt ?? DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: 'kakao',
      );

      AppLogger.d('[Kakao Step 7] User model created', tag: _tag);

      // Step 8: 세션 저장 (로그인 상태 유지를 위해)
      AppLogger.d('[Kakao Step 8] Saving session...', tag: _tag);
      final session = _sessionService.createKakaoSession(
        id: user.id,
        email: user.email,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        tokenExpiresAt: token.expiresAt,
      );
      await _sessionService.saveSession(session);
      AppLogger.d('[Kakao Step 8] Session saved', tag: _tag);

      // Step 9: 성공 로깅
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.i('Kakao Sign In SUCCESSFUL!', tag: _tag);
      AppLogger.i('  User: ${user.name}', tag: _tag);
      AppLogger.i('  Email: ${user.email}', tag: _tag);
      AppLogger.i('  ID: ${user.id}', tag: _tag);
      AppLogger.i('═══════════════════════════════════════════════', tag: _tag);

      // 카카오는 Firebase를 사용하지 않으므로 첫 로그인으로 간주
      return AuthResult.success(user, isNewUser: true);
    } on kakao.KakaoAuthException catch (e) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Kakao Sign In FAILED (KakaoAuthException)', tag: _tag);
      AppLogger.e('  Error: ${e.error}', tag: _tag);
      AppLogger.e('  Message: ${e.message}', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      if (e.error == kakao.AuthErrorCause.accessDenied) {
        return AuthResult.failure('sign-in-cancelled', '로그인이 취소되었습니다.');
      }
      return AuthResult.failure(
        'kakao-sign-in-failed',
        '카카오 로그인에 실패했습니다: ${e.message}',
      );
    } on kakao.KakaoClientException catch (e) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Kakao Sign In FAILED (KakaoClientException)', tag: _tag);
      AppLogger.e('  Message: ${e.message}', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      return AuthResult.failure(
        'kakao-sign-in-failed',
        '카카오 로그인에 실패했습니다: ${e.message}',
      );
    } catch (e, stackTrace) {
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);
      AppLogger.e('Kakao Sign In FAILED (Unknown Exception)', tag: _tag);
      AppLogger.e('  Type: ${e.runtimeType}', tag: _tag);
      AppLogger.e('  Error: $e', tag: _tag);
      AppLogger.e('  StackTrace: $stackTrace', tag: _tag);
      AppLogger.e('═══════════════════════════════════════════════', tag: _tag);

      // 사용자 취소 체크
      if (e.toString().contains('cancelled') ||
          e.toString().contains('CANCELED')) {
        return AuthResult.failure('sign-in-cancelled', '로그인이 취소되었습니다.');
      }

      return AuthResult.failure('kakao-sign-in-failed', '카카오 로그인에 실패했습니다.');
    }
  }

  /// 카카오 로그아웃
  Future<void> _signOutKakao() async {
    try {
      await kakao.UserApi.instance.logout();
      AppLogger.d('Kakao Sign Out completed', tag: _tag);
    } catch (e) {
      AppLogger.w('Kakao Sign Out failed: $e', tag: _tag);
    }
  }

  /// 카카오 연결 해제 (회원 탈퇴 시 사용)
  Future<void> unlinkKakao() async {
    try {
      await kakao.UserApi.instance.unlink();
      AppLogger.d('Kakao unlink completed', tag: _tag);
    } catch (e) {
      AppLogger.w('Kakao unlink failed: $e', tag: _tag);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이메일 로그인
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.i('Starting Email Sign In...', tag: _tag);
      AppLogger.d('Email: $email', tag: _tag);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        AppLogger.e('Firebase user is null after Email Sign In', tag: _tag);
        return AuthResult.failure('email-sign-in-failed', '이메일 로그인에 실패했습니다.');
      }

      final user = _firebaseUserToUser(userCredential.user!, provider: 'email');

      AppLogger.i('Email Sign In successful: ${user.name}', tag: _tag);
      return AuthResult.success(user, isNewUser: false);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e(
        'Firebase Auth Exception during Email Sign In: ${e.code}',
        tag: _tag,
        error: e,
      );
      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Email Sign In failed: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('email-sign-in-failed', '이메일 로그인에 실패했습니다.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이메일 회원가입
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.i('Starting Email Sign Up...', tag: _tag);
      AppLogger.d('Email: $email, Name: $displayName', tag: _tag);

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        AppLogger.e('Firebase user is null after Email Sign Up', tag: _tag);
        return AuthResult.failure('email-sign-up-failed', '회원가입에 실패했습니다.');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      final user = _firebaseUserToUser(
        _firebaseAuth.currentUser ?? userCredential.user!,
        provider: 'email',
      );

      AppLogger.i('Email Sign Up successful: ${user.name}', tag: _tag);
      return AuthResult.success(user, isNewUser: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e(
        'Firebase Auth Exception during Email Sign Up: ${e.code}',
        tag: _tag,
        error: e,
      );
      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Email Sign Up failed: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('email-sign-up-failed', '회원가입에 실패했습니다.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 비밀번호 재설정
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.i('Sending password reset email to: $email', tag: _tag);

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      AppLogger.i('Password reset email sent successfully', tag: _tag);
      return AuthResult(success: true, errorMessage: '비밀번호 재설정 이메일을 발송했습니다.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e(
        'Firebase Auth Exception during password reset: ${e.code}',
        tag: _tag,
        error: e,
      );
      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Password reset failed: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('password-reset-failed', '비밀번호 재설정에 실패했습니다.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 로그아웃
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      AppLogger.i('Signing out...', tag: _tag);

      // Google Sign Out
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
          AppLogger.d('Google Sign Out completed', tag: _tag);
        }
      } catch (e) {
        AppLogger.w('Google Sign Out failed: $e', tag: _tag);
      }

      // Kakao Sign Out
      await _signOutKakao();

      // Firebase Sign Out
      await _firebaseAuth.signOut();

      // 세션 삭제
      await _sessionService.clearSession();
      AppLogger.d('Session cleared', tag: _tag);

      AppLogger.i('Sign out successful', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Sign out failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 현재 사용자
  // ─────────────────────────────────────────────────────────────────────────

  User? getCurrentUser() {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      AppLogger.d('No current user', tag: _tag);
      return null;
    }
    return _firebaseUserToUser(fbUser);
  }

  Future<User?> refreshUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return getCurrentUser();
    } catch (e) {
      AppLogger.e('Failed to refresh user', tag: _tag, error: e);
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 계정 삭제
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('user-not-found', '로그인이 필요합니다.');
      }

      AppLogger.i('Deleting account: ${user.email}', tag: _tag);

      // 카카오 연결 해제
      await unlinkKakao();

      await user.delete();

      AppLogger.i('Account deleted successfully', tag: _tag);
      return AuthResult.success(
        User(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
        ),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('Failed to delete account: ${e.code}', tag: _tag, error: e);

      if (e.code == 'requires-recent-login') {
        return AuthResult.failure(
          'requires-recent-login',
          '보안을 위해 다시 로그인한 후 시도해주세요.',
        );
      }
      return AuthResult.failure(e.code, _getFirebaseErrorMessage(e.code));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete account',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult.failure('unknown-error', '계정 삭제에 실패했습니다.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티 메서드
  // ─────────────────────────────────────────────────────────────────────────

  User _firebaseUserToUser(firebase_auth.User fbUser, {String? provider}) {
    String? authProvider = provider;
    if (authProvider == null && fbUser.providerData.isNotEmpty) {
      final providerId = fbUser.providerData.first.providerId;
      if (providerId.contains('google')) {
        authProvider = 'google';
      } else if (providerId.contains('apple')) {
        authProvider = 'apple';
      } else if (providerId.contains('password')) {
        authProvider = 'email';
      }
    }

    return User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName ?? _extractNameFromEmail(fbUser.email),
      profileImageUrl: fbUser.photoURL,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: fbUser.metadata.lastSignInTime,
      provider: authProvider,
    );
  }

  String _extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return '사용자';
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;
    return email.substring(0, atIndex);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return '이미 다른 로그인 방식으로 가입된 계정입니다.';
      case 'invalid-credential':
        return '인증 정보가 올바르지 않습니다. 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 로그인 방식은 현재 사용할 수 없습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '비밀번호가 틀렸습니다.';
      case 'invalid-verification-code':
        return '인증 코드가 올바르지 않습니다.';
      case 'invalid-verification-id':
        return '인증 ID가 올바르지 않습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인한 후 시도해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요. (코드: $code)';
    }
  }
}
