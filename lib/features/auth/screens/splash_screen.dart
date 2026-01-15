// lib/features/auth/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase Options - flutterfire configure로 생성됨
import '../../../firebase_options.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/styles/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/notification_service.dart';
import '../config/auth_config.dart';
import '../services/auth_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Splash Screen - 스플래시 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 시작 시 표시되는 스플래시 화면
/// - 앱 로고 및 이름 표시
/// - 초기화 작업 수행 (Firebase, Hive, Notification 등)
/// - 초기화 완료 후 적절한 화면으로 이동
///
/// 네비게이션:
///   - 로그인됨 + 온보딩 완료 → MainNavigator
///   - 로그인됨 + 온보딩 미완료 → OnboardingScreen
///   - 로그인 안됨 → LoginScreen
///
/// 테스트 모드:
///   - AuthConfig.forceLogoutOnStart = true 시 매번 로그아웃
/// ═══════════════════════════════════════════════════════════════════════════

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onInitialized;
  final Function(SplashResult) onComplete;

  const SplashScreen({Key? key, this.onInitialized, required this.onComplete})
    : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'SplashScreen';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    AppLogger.i('SplashScreen initialized', tag: _tag);

    // 애니메이션 설정
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // 애니메이션 시작 및 초기화
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    try {
      AppLogger.i('Starting app initialization...', tag: _tag);

      // 1. Firebase 초기화 (DefaultFirebaseOptions 사용)
      _updateStatus(AppStrings.splashInitializing);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.i('Firebase initialized', tag: _tag);

      // 2. Hive 초기화
      _updateStatus(AppStrings.splashLoadingData);
      await LocalStorageService.init();
      await LocalStorageService().openBoxes();
      AppLogger.i('Hive initialized', tag: _tag);

      // 3. 알림 서비스 초기화
      _updateStatus(AppStrings.splashSettingUpNotifications);
      await NotificationService.init();
      AppLogger.i('NotificationService initialized', tag: _tag);

      // 4. 최소 표시 시간 보장 (UX)
      await Future.delayed(const Duration(milliseconds: 1500));

      // ⚠ 테스트 모드: 강제 로그아웃
      if (AuthConfig.forceLogoutOnStart) {
        AppLogger.w('️ TEST MODE: Force logout on start is ENABLED', tag: _tag);
        _updateStatus('테스트 모드: 로그아웃 중...');

        final authService = AuthService();
        //await authService.signOut();

        AppLogger.i('Force logout completed', tag: _tag);

        // 강제 로그아웃 후 로그인 화면으로
        ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
        widget.onComplete(SplashResult.unauthenticated);
        return;
      }

      // 5. 인증 상태 확인
      _updateStatus(AppStrings.splashCheckingAuth);
      final authService = AuthService();
      final currentUser = authService.getCurrentUser();

      // 6. 온보딩 상태 확인
      final storage = LocalStorageService();
      final onboardingCompleted =
          storage.getSetting<bool>('onboardingCompleted') ?? false;

      // 7. 알림 재스케줄링 (온보딩 완료 사용자만)
      if (onboardingCompleted) {
        await _rescheduleNotifications();
      }

      AppLogger.i(
        'Initialization complete - User: ${currentUser?.name ?? 'null'}, '
        'Onboarding: $onboardingCompleted',
        tag: _tag,
      );

      // 8. 결과 반환
      if (currentUser != null) {
        // 로그인됨
        ref.read(currentUserProvider.notifier).state = currentUser;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;

        if (onboardingCompleted) {
          widget.onComplete(SplashResult.authenticatedWithOnboarding);
        } else {
          widget.onComplete(SplashResult.authenticatedNeedsOnboarding);
        }
      } else {
        // 로그인 안됨
        ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
        widget.onComplete(SplashResult.unauthenticated);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'App initialization failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );

      // 에러 발생 시에도 로그인 화면으로 이동
      ref.read(authStateProvider.notifier).state = AuthState.error;
      widget.onComplete(SplashResult.error);
    }
  }

  /// 알림 재스케줄링
  /// 앱이 재시작되거나 기기가 재부팅된 후에도 알림이 유지되도록 함
  Future<void> _rescheduleNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.scheduleFromSettings();

      // 스케줄된 알림 확인 (디버그용)
      final pendingNotifications = await notificationService
          .getPendingNotifications();
      AppLogger.i(
        'Notifications rescheduled - Pending: ${pendingNotifications.length}',
        tag: _tag,
      );

      for (final notification in pendingNotifications) {
        AppLogger.d(
          'Pending notification: ID=${notification.id}, Title=${notification.title}',
          tag: _tag,
        );
      }
    } catch (e) {
      AppLogger.e('Failed to reschedule notifications', tag: _tag, error: e);
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 아이콘
                _buildAppIcon(),
                const SizedBox(height: AppSizes.spaceL),

                // 앱 이름
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),

                // 슬로건
                Text(
                  AppStrings.appSlogan,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXL),

                // 로딩 인디케이터
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentBlue.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceM),

                // 상태 메시지
                Text(
                  _statusMessage,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                // 테스트 모드 표시
                if (AuthConfig.forceLogoutOnStart) ...[
                  const SizedBox(height: AppSizes.spaceL),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Text(
                      '⚠️ 테스트 모드: 자동 로그아웃 활성화',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          // 어두운 그림자 (오른쪽 하단)
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.3),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
          // 밝은 하이라이트 (왼쪽 상단)
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.8),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/icon/icon.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.w('Failed to load app icon: $error', tag: _tag);
            // 아이콘 로드 실패 시 대체 아이콘
            return Container(
              width: 120,
              height: 120,
              color: AppColors.accentBlue.withOpacity(0.15),
              child: const Center(
                child: Text('🌅', style: TextStyle(fontSize: 60)),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Splash 결과 열거형
enum SplashResult {
  /// 인증됨 + 온보딩 완료 → 메인 화면으로
  authenticatedWithOnboarding,

  /// 인증됨 + 온보딩 미완료 → 온보딩 화면으로
  authenticatedNeedsOnboarding,

  /// 인증 안됨 → 로그인 화면으로
  unauthenticated,

  /// 에러 발생 → 로그인 화면으로
  error,
}
