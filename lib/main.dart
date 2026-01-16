// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

// Core
import 'core/core.dart';

// Features
import 'features/auth/config/auth_config.dart';
import 'features/home/home.dart';
import 'features/analytics/analytics.dart';
import 'features/schedule/schedule.dart';
import 'features/settings/settings.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/auth.dart';

// Services
import 'firebase_options.dart';
import 'services/local_storage_service.dart';

// Models
import 'shared/models/focus_session_model.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ⭐ 카카오 SDK 초기화 추가
  KakaoSdk.init(
    nativeAppKey: AuthConfig.kakaoNativeAppKey,
    javaScriptAppKey: AuthConfig.kakaoJavaScriptKey,
  );

  AppLogger.i('앱 시작', tag: 'Main');

  // FocusSession 어댑터 등록 (Splash에서 다른 어댑터들 등록)
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(FocusSessionAdapter());
  }

  // ProviderScope로 앱 전체 감싸기
  runApp(const ProviderScope(child: FranklinFlowApp()));
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 메인 앱
/// ═══════════════════════════════════════════════════════════════════════════

class FranklinFlowApp extends ConsumerWidget {
  const FranklinFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.accentBlue,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accentBlue,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppRoot(),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 앱 루트 - Splash → Auth → Onboarding → Main 흐름 관리
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 시작 시 다음 순서로 화면 전환:
/// 1. SplashScreen - 앱 초기화 (Firebase, Hive)
/// 2. LoginScreen - 소셜 로그인 (미인증 시)
/// 3. OnboardingScreen - 온보딩 (미완료 시)
/// 4. MainNavigator - 메인 화면
/// ═══════════════════════════════════════════════════════════════════════════

class AppRoot extends StatefulWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // 현재 표시할 화면
  _AppScreen _currentScreen = _AppScreen.splash;

  @override
  void initState() {
    super.initState();
    AppLogger.i('AppRoot initialized', tag: 'AppRoot');
  }

  /// Splash 완료 후 처리
  void _onSplashComplete(SplashResult result) {
    AppLogger.i('Splash complete: $result', tag: 'AppRoot');

    setState(() {
      switch (result) {
        case SplashResult.authenticatedWithOnboarding:
          // 로그인됨 + 온보딩 완료 → 메인 화면
          _currentScreen = _AppScreen.main;
          break;
        case SplashResult.authenticatedNeedsOnboarding:
          // 로그인됨 + 온보딩 미완료 → 온보딩 화면
          _currentScreen = _AppScreen.onboarding;
          break;
        case SplashResult.unauthenticated:
        case SplashResult.error:
          // 로그인 안됨 또는 에러 → 로그인 화면
          _currentScreen = _AppScreen.login;
          break;
      }
    });
  }

  /// 로그인 성공 후 처리
  void _onLoginSuccess() {
    AppLogger.i('Login success, checking onboarding status', tag: 'AppRoot');

    // 온보딩 상태 확인
    final storage = LocalStorageService();
    final onboardingCompleted =
        storage.getSetting<bool>('onboardingCompleted') ?? false;

    setState(() {
      if (onboardingCompleted) {
        _currentScreen = _AppScreen.main;
      } else {
        _currentScreen = _AppScreen.onboarding;
      }
    });
  }

  /// 온보딩 완료 후 처리
  void _onOnboardingComplete() {
    AppLogger.i('Onboarding completed, navigating to main', tag: 'AppRoot');
    setState(() {
      _currentScreen = _AppScreen.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case _AppScreen.splash:
        return SplashScreen(onComplete: _onSplashComplete);

      case _AppScreen.login:
        return LoginScreen(onLoginSuccess: _onLoginSuccess);

      case _AppScreen.onboarding:
        return OnboardingScreen(onComplete: _onOnboardingComplete);

      case _AppScreen.main:
        return const MainNavigator();
    }
  }
}

/// 앱 화면 열거형
enum _AppScreen { splash, login, onboarding, main }

/// ═══════════════════════════════════════════════════════════════════════════
/// 메인 네비게이터
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 하단 탭 네비게이션과 각 화면을 관리하는 메인 컨테이너
/// ═══════════════════════════════════════════════════════════════════════════

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  void _onNavigate(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // 네비게이션 로그
    final screenNames = [
      AppStrings.navHome,
      AppStrings.navAnalytics,
      AppStrings.navSchedule,
      AppStrings.navSettings,
    ];
    AppLogger.nav('MainNavigator', screenNames[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
      ),
    );
  }
}
