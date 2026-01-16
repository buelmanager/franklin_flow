// lib/features/auth/screens/login_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/styles/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/local_storage_service.dart';
import '../services/auth_service.dart';
import 'terms_agreement_screen.dart';
import 'email_auth_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Login Screen - 소셜 로그인 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Google / Apple / Kakao / Email 로그인 화면
/// - 신규 가입 시에만 약관 동의 화면 표시
/// - Google Sign In 버튼
/// - Apple Sign In 버튼 (iOS만)
/// - Kakao Sign In 버튼
/// - 이메일 로그인 버튼
/// - 프랭클린 Flow 브랜딩
///
/// 사용법:
///   LoginScreen(onLoginSuccess: () {
///     // 로그인 성공 후 처리
///   })
/// ═══════════════════════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AppLogger.i('LoginScreen initialized', tag: 'LoginScreen');
  }

  /// 약관 동의 여부 확인
  bool _hasAgreedToTerms() {
    final storage = LocalStorageService();
    return storage.getSetting<bool>('termsAgreed') ?? false;
  }

  /// 약관 동의 화면 표시 및 동의 후 처리
  Future<void> _showTermsAndComplete(AuthResult result) async {
    final agreed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TermsAgreementScreen(
          onAgree: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );

    if (agreed == true) {
      // 약관 동의 저장
      final storage = LocalStorageService();
      await storage.saveSetting('termsAgreed', true);
      await storage.saveSetting(
        'termsAgreedAt',
        DateTime.now().toIso8601String(),
      );

      AppLogger.i('Terms agreement saved', tag: 'LoginScreen');

      // 상태 업데이트 및 로그인 완료
      ref.read(currentUserProvider.notifier).state = result.user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
      widget.onLoginSuccess();
    } else {
      // 약관 동의 취소 시 로그아웃
      AppLogger.w('Terms agreement cancelled, signing out', tag: 'LoginScreen');
      final authService = AuthService();
      await authService.signOut();
    }
  }

  /// 로그인 결과 처리
  Future<void> _handleLoginResult(AuthResult result) async {
    if (!result.success || result.user == null) {
      // 취소는 에러 메시지 표시하지 않음
      if (result.errorCode != 'sign-in-cancelled') {
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
      return;
    }

    // 신규 사용자이고 아직 약관에 동의하지 않은 경우
    if (result.isNewUser && !_hasAgreedToTerms()) {
      AppLogger.i(
        'New user detected, showing terms agreement',
        tag: 'LoginScreen',
      );
      await _showTermsAndComplete(result);
    } else {
      // 기존 사용자 또는 이미 약관 동의한 사용자
      AppLogger.i(
        'Existing user or already agreed to terms',
        tag: 'LoginScreen',
      );
      ref.read(currentUserProvider.notifier).state = result.user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
      widget.onLoginSuccess();
    }
  }

  /// Google 로그인
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Starting Google Sign In', tag: 'LoginScreen');

      final authService = AuthService();
      final result = await authService.signInWithGoogle();

      await _handleLoginResult(result);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Google Sign In error',
        tag: 'LoginScreen',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = AppStrings.authErrorUnknown;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Apple 로그인
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Starting Apple Sign In', tag: 'LoginScreen');

      final authService = AuthService();
      final result = await authService.signInWithApple();

      await _handleLoginResult(result);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Apple Sign In error',
        tag: 'LoginScreen',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = AppStrings.authErrorUnknown;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 카카오 로그인
  Future<void> _handleKakaoSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Starting Kakao Sign In', tag: 'LoginScreen');

      final authService = AuthService();
      final result = await authService.signInWithKakao();

      await _handleLoginResult(result);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Kakao Sign In error',
        tag: 'LoginScreen',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = '카카오 로그인 중 오류가 발생했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 이메일 로그인
  void _handleEmailSignIn() {
    if (_isLoading) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmailAuthScreen(
          onSuccess: () async {
            Navigator.of(context).pop();

            // 이메일 로그인 성공 후 현재 사용자 정보 가져오기
            final authService = AuthService();
            final currentUser = authService.getCurrentUser();

            if (currentUser != null) {
              // 약관 동의 여부 확인
              if (!_hasAgreedToTerms()) {
                AppLogger.i(
                  'Email user needs terms agreement',
                  tag: 'LoginScreen',
                );
                final result = AuthResult.success(currentUser, isNewUser: true);
                await _showTermsAndComplete(result);
              } else {
                // 이미 약관 동의한 사용자
                ref.read(currentUserProvider.notifier).state = currentUser;
                ref.read(authStateProvider.notifier).state =
                    AuthState.authenticated;
                widget.onLoginSuccess();
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 헤더 (로고 + 타이틀)
              _buildHeader(),

              const Spacer(flex: 2),

              // 에러 메시지
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: AppSizes.spaceL),
              ],

              // 소셜 로그인 버튼들
              _buildSocialButtons(),

              const SizedBox(height: AppSizes.spaceL),

              // 약관 안내
              _buildTermsNotice(),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 빌드
  Widget _buildHeader() {
    return Column(
      children: [
        // 앱 아이콘
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark.withOpacity(0.25),
                offset: const Offset(5, 5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: AppColors.shadowLight.withOpacity(0.8),
                offset: const Offset(-5, -5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/icon/icon.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      size: 50,
                      color: AppColors.accentOrange,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),

        // 앱 이름
        Text(
          AppStrings.appName,
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),

        // 슬로건
        Text(
          AppStrings.appSlogan,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 프랭클린 명언
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            children: [
              Text(
                AppStrings.onboardingWelcomeQuote,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                AppStrings.onboardingWelcomeAuthor,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 에러 메시지 빌드
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSizes.spaceS),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 소셜 로그인 버튼들
  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google 로그인 버튼
        _SocialLoginButton(
          onTap: _handleGoogleSignIn,
          isLoading: _isLoading,
          icon: _buildGoogleIcon(),
          label: AppStrings.authSignInWithGoogle,
          backgroundColor: Colors.white,
          textColor: AppColors.textPrimary,
          borderColor: AppColors.shadowDark.withOpacity(0.2),
        ),

        // Apple 로그인 버튼 (iOS만)
        if (Platform.isIOS) ...[
          const SizedBox(height: AppSizes.spaceM),
          _SocialLoginButton(
            onTap: _handleAppleSignIn,
            isLoading: _isLoading,
            icon: const Icon(Icons.apple, color: Colors.white, size: 24),
            label: AppStrings.authSignInWithApple,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],

        // 카카오 로그인 버튼
        const SizedBox(height: AppSizes.spaceM),
        _SocialLoginButton(
          onTap: _handleKakaoSignIn,
          isLoading: _isLoading,
          icon: _buildKakaoIcon(),
          label: AppStrings.signInWithKakao,
          backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
          textColor: const Color(0xFF191919), // 카카오 텍스트 색상
        ),

        // 구분선
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceL),
          child: Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.textTertiary.withOpacity(0.3)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                child: Text(
                  AppStrings.authOr,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.textTertiary.withOpacity(0.3)),
              ),
            ],
          ),
        ),

        // 이메일 로그인 버튼
        _SocialLoginButton(
          onTap: _handleEmailSignIn,
          isLoading: _isLoading,
          icon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
          label: AppStrings.authContinueWithEmail,
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          borderColor: AppColors.shadowDark.withOpacity(0.1),
        ),
      ],
    );
  }

  /// Google 아이콘
  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.network(
        'https://www.google.com/favicon.ico',
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.g_mobiledata, color: Colors.red, size: 24);
        },
      ),
    );
  }

  /// 카카오 아이콘
  Widget _buildKakaoIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.chat_bubble, color: Color(0xFFFEE500), size: 14),
      ),
    );
  }

  /// 약관 안내
  Widget _buildTermsNotice() {
    return GestureDetector(
      onTap: () {
        // 약관 보기 (동의 없이)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TermsAgreementScreen(
              onAgree: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            children: [
              const TextSpan(text: '가입 시 '),
              TextSpan(
                text: AppStrings.termsOfService,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: ' 및 '),
              TextSpan(
                text: AppStrings.privacyPolicy,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: '에 동의하게 됩니다.'),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 소셜 로그인 버튼 위젯
/// ═══════════════════════════════════════════════════════════════════════════

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSizes.spaceM),
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
