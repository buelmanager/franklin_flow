// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';
import '../widgets/focus_session_card.dart';
import '../widgets/widgets.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱의 메인 홈 화면
/// 헤더, 포커스 세션, 프로그레스, 태스크, 주간목표 섹션 포함
/// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTaskIndex = -1;

  // 포커스 세션 관련 상태
  String? _currentFocusTask;
  DateTime? _focusStartTime;

  // 태스크 데이터
  final List<Task> _tasks = [
    Task(
      id: 1,
      title: '클라이언트 미팅',
      status: 'in-progress',
      progress: 55,
      time: '2시간',
      category: '업무',
    ),
    Task(
      id: 2,
      title: '이메일 답변',
      status: 'pending',
      progress: 0,
      time: '1시간',
      category: '업무',
    ),
    Task(
      id: 3,
      title: '문서 작성',
      status: 'completed',
      progress: 100,
      time: '1.5시간',
      category: '업무',
    ),
  ];

  // 주간 목표 데이터
  late final List<Goal> _goals;

  @override
  void initState() {
    super.initState();
    AppLogger.d('HomeScreen initState', tag: 'HomeScreen');

    _goals = [
      Goal(
        emoji: '🏃',
        title: AppStrings.goalWorkout,
        current: 2,
        total: 3,
        color: AppColors.accentPink,
      ),
      Goal(
        emoji: '📚',
        title: AppStrings.goalReading,
        current: 5,
        total: 10,
        color: AppColors.accentPurple,
      ),
      Goal(
        emoji: '💧',
        title: AppStrings.goalWater,
        current: 6,
        total: 8,
        color: AppColors.accentBlue,
      ),
      Goal(
        emoji: '🧘',
        title: AppStrings.goalMeditation,
        current: 3,
        total: 7,
        color: AppColors.accentGreen,
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 상태 계산
  // ─────────────────────────────────────────────────────────────────────────

  int get _completionRate {
    if (_tasks.isEmpty) return 0;
    int completed = _tasks.where((t) => t.status == 'completed').length;
    return ((completed / _tasks.length) * 100).round();
  }

  int get _completedCount =>
      _tasks.where((t) => t.status == 'completed').length;
  int get _inProgressCount =>
      _tasks.where((t) => t.status == 'in-progress').length;
  int get _pendingCount => _tasks.where((t) => t.status == 'pending').length;

  // ─────────────────────────────────────────────────────────────────────────
  // 포커스 세션 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleStartFocusSession() {
    setState(() {
      // 진행중인 태스크가 있으면 그걸로, 없으면 첫 번째 pending 태스크
      final inProgressTask = _tasks.firstWhere(
        (t) => t.status == 'in-progress',
        orElse: () => _tasks.firstWhere(
          (t) => t.status == 'pending',
          orElse: () => _tasks.first,
        ),
      );

      _currentFocusTask = inProgressTask.title;
      _focusStartTime = DateTime.now();
    });

    AppLogger.ui(
      'Focus session started: $_currentFocusTask',
      screen: 'HomeScreen',
    );
  }

  void _handlePauseFocusSession() {
    setState(() {
      _currentFocusTask = null;
      _focusStartTime = null;
    });

    AppLogger.ui('Focus session paused', screen: 'HomeScreen');
  }

  void _handleCompleteFocusSession() {
    // TODO: 작업 완료 처리 및 통계 업데이트
    setState(() {
      _currentFocusTask = null;
      _focusStartTime = null;
    });

    AppLogger.ui('Focus session completed', screen: 'HomeScreen');

    // 스낵바로 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great work! Focus session completed 🎉'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 태스크 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTaskTap(int index) {
    setState(() {
      _selectedTaskIndex = _selectedTaskIndex == index ? -1 : index;
    });
    AppLogger.ui('Task selected: ${_tasks[index].title}', screen: 'HomeScreen');
  }

  void _handleTaskStatusChange(int index) {
    setState(() {
      final task = _tasks[index];
      if (task.status == 'completed') {
        task.status = 'pending';
        task.progress = 0;
      } else if (task.status == 'pending') {
        task.status = 'in-progress';
        task.progress = 30;
      } else {
        task.status = 'completed';
        task.progress = 100;
      }
    });

    AppLogger.ui(
      'Task status changed: ${_tasks[index].title} -> ${_tasks[index].status}',
      screen: 'HomeScreen',
    );
  }

  void _handleNotificationTap() {
    AppLogger.ui('Notification tapped', screen: 'HomeScreen');
    // TODO: 알림 화면으로 이동
  }

  void _handleProfileTap() {
    AppLogger.ui('Profile tapped', screen: 'HomeScreen');
    // TODO: 프로필 화면으로 이동
  }

  void _handleAddTaskTap() {
    AppLogger.ui('Add task tapped', screen: 'HomeScreen');
    // TODO: 태스크 추가 다이얼로그
  }

  void _handleGoalTap(int index) {
    AppLogger.ui('Goal tapped: ${_goals[index].title}', screen: 'HomeScreen');
    // TODO: 목표 상세 화면으로 이동
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.spaceL),

            // 헤더 (개선 버전)
            HomeHeader(
              userName: 'Wade', // TODO: 실제 사용자 이름으로 변경
              notificationCount: 3, // TODO: 실제 알림 개수로 변경
              onNotificationTap: _handleNotificationTap,
              onProfileTap: _handleProfileTap,
            ),
            const SizedBox(height: AppSizes.spaceXXL),

            // 포커스 세션 카드 (DateTimeCard 대체)
            FocusSessionCard(
              currentTaskTitle: _currentFocusTask,
              startTime: _focusStartTime,
              onStartSession: _handleStartFocusSession,
              onPause: _handlePauseFocusSession,
              onComplete: _handleCompleteFocusSession,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 프로그레스 섹션
            ProgressSection(
              completionRate: _completionRate,
              completedCount: _completedCount,
              inProgressCount: _inProgressCount,
              pendingCount: _pendingCount,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 태스크 섹션
            TasksSection(
              tasks: _tasks,
              selectedTaskIndex: _selectedTaskIndex,
              onTaskTap: _handleTaskTap,
              onTaskStatusChange: _handleTaskStatusChange,
              onAddTap: _handleAddTaskTap,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 주간 목표 섹션
            WeeklyGoalsSection(goals: _goals, onGoalTap: _handleGoalTap),

            // 하단 여백 (네비게이션 바 공간)
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
