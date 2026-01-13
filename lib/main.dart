// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Core
import 'core/core.dart';

// Features
import 'features/home/home.dart';
import 'features/analytics/analytics.dart';
import 'features/schedule/schedule.dart';
import 'features/settings/settings.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

// Services
import 'services/local_storage_service.dart';

// Models
import 'shared/models/focus_session_model.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.i('앱 시작', tag: 'Main');

  // Hive 초기화
  try {
    AppLogger.i('Hive 초기화 시작...', tag: 'Main');
    await LocalStorageService.init();
    AppLogger.i('Hive 초기화 완료', tag: 'Main');
    Hive.registerAdapter(FocusSessionAdapter());

    // Box 열기
    AppLogger.i('Storage Box 열기 시작...', tag: 'Main');
    await LocalStorageService().openBoxes();
    AppLogger.i('Storage Box 열기 완료', tag: 'Main');
  } catch (e, stackTrace) {
    AppLogger.e('Hive 초기화 실패', tag: 'Main', error: e, stackTrace: stackTrace);
  }

  // ProviderScope로 앱 전체 감싸기
  runApp(const ProviderScope(child: FranklinFlowApp()));
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 메인 앱
/// ═══════════════════════════════════════════════════════════════════════════

class FranklinFlowApp extends StatelessWidget {
  const FranklinFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AppRoot(),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 앱 루트 - 온보딩 체크
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 시작 시 온보딩 완료 여부를 확인하여
/// - 미완료: OnboardingScreen 표시
/// - 완료: MainNavigator 표시
/// ═══════════════════════════════════════════════════════════════════════════

class AppRoot extends StatefulWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final storage = LocalStorageService();
      final completed =
          storage.getSetting<bool>('onboardingCompleted') ?? false;

      AppLogger.d(
        'Onboarding status check: completed = $completed',
        tag: 'AppRoot',
      );

      setState(() {
        _onboardingCompleted = completed;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to check onboarding status',
        tag: 'AppRoot',
        error: e,
        stackTrace: stackTrace,
      );

      // 에러 시 온보딩 표시
      setState(() {
        _onboardingCompleted = false;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    AppLogger.i('Onboarding completed, navigating to main', tag: 'AppRoot');
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌅', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              Text(AppStrings.appName, style: AppTextStyles.heading3),
            ],
          ),
        ),
      );
    }

    // 온보딩 미완료 → OnboardingScreen
    if (!_onboardingCompleted) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    // 온보딩 완료 → MainNavigator
    return const MainNavigator();
  }
}

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
