// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core
import 'core/core.dart';

// Features
import 'features/home/home.dart';
import 'features/analytics/analytics.dart';
import 'features/schedule/schedule.dart';
import 'features/settings/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.i('앱 시작', tag: 'Main');
  runApp(const FranklinFlowApp());
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
      home: const MainNavigator(),
    );
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
