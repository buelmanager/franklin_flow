// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';
import '../../../services/task_service.dart';
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
  final _taskService = TaskService();
  int _selectedTaskIndex = -1;

  // 포커스 세션 관련 상태
  String? _currentFocusTask;
  DateTime? _focusStartTime;

  // 주간 목표 데이터
  late final List<Goal> _goals;

  @override
  void initState() {
    super.initState();
    AppLogger.d('HomeScreen initState', tag: 'HomeScreen');

    // loadSampleData() 제거 - 이제 Hive에서 자동으로 로드됨

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
  // 상태 계산 (TaskService에서 가져오기)
  // ─────────────────────────────────────────────────────────────────────────

  List<Task> get _tasks => _taskService.tasks;
  int get _completionRate => _taskService.completionRate;
  int get _completedCount => _taskService.completedTasks.length;
  int get _inProgressCount => _taskService.inProgressTasks.length;
  int get _pendingCount => _taskService.pendingTasks.length;

  // ─────────────────────────────────────────────────────────────────────────
  // 포커스 세션 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleStartFocusSession() {
    setState(() {
      // 진행중인 태스크가 있으면 그걸로, 없으면 첫 번째 pending 태스크
      final inProgressTasks = _taskService.inProgressTasks;
      final pendingTasks = _taskService.pendingTasks;

      if (inProgressTasks.isNotEmpty) {
        _currentFocusTask = inProgressTasks.first.title;
      } else if (pendingTasks.isNotEmpty) {
        _currentFocusTask = pendingTasks.first.title;
      } else if (_tasks.isNotEmpty) {
        _currentFocusTask = _tasks.first.title;
      }

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
    setState(() {
      _currentFocusTask = null;
      _focusStartTime = null;
    });

    AppLogger.ui('Focus session completed', screen: 'HomeScreen');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great work! Focus session completed 🎉'),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 2),
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
    final task = _tasks[index];

    // 상태 순환: pending -> in-progress -> completed -> pending
    String newStatus;
    if (task.status == 'completed') {
      newStatus = 'pending';
    } else if (task.status == 'pending') {
      newStatus = 'in-progress';
    } else {
      newStatus = 'completed';
    }

    _taskService.changeTaskStatus(task.id, newStatus);

    setState(() {});

    AppLogger.ui(
      'Task status changed: ${task.title} -> $newStatus',
      screen: 'HomeScreen',
    );
  }

  void _handleNotificationTap() {
    AppLogger.ui('Notification tapped', screen: 'HomeScreen');
  }

  void _handleProfileTap() {
    AppLogger.ui('Profile tapped', screen: 'HomeScreen');
  }

  void _handleAddTaskTap() {
    AppLogger.ui('Add task tapped', screen: 'HomeScreen');

    TaskFormDialog.show(
      context: context,
      onSaved: (task) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('태스크가 추가되었습니다: ${task.title}'),
            backgroundColor: AppColors.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _handleEditTaskTap(int index) {
    final task = _tasks[index];

    AppLogger.ui('Edit task tapped: ${task.title}', screen: 'HomeScreen');

    TaskFormDialog.show(
      context: context,
      task: task,
      onSaved: (updatedTask) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('태스크가 수정되었습니다: ${updatedTask.title}'),
            backgroundColor: AppColors.accentBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _handleDeleteTaskTap(int index) {
    final task = _tasks[index];

    AppLogger.ui('Delete task tapped: ${task.title}', screen: 'HomeScreen');

    NeumorphicDialog.showConfirm(
      context: context,
      title: AppStrings.dialogDeleteTitle,
      message: AppStrings.dialogDeleteMessage,
      confirmText: AppStrings.dialogDeleteConfirm,
      cancelText: AppStrings.dialogDeleteCancel,
    ).then((confirmed) {
      if (confirmed == true) {
        _taskService.deleteTask(task.id);

        setState(() {
          _selectedTaskIndex = -1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('태스크가 삭제되었습니다: ${task.title}'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );

        AppLogger.i('Task deleted: ${task.title}', tag: 'HomeScreen');
      }
    });
  }

  void _handleGoalTap(int index) {
    AppLogger.ui('Goal tapped: ${_goals[index].title}', screen: 'HomeScreen');
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

            HomeHeader(
              userName: 'Wade',
              notificationCount: 3,
              onNotificationTap: _handleNotificationTap,
              onProfileTap: _handleProfileTap,
            ),
            const SizedBox(height: AppSizes.spaceXXL),

            FocusSessionCard(
              currentTaskTitle: _currentFocusTask,
              startTime: _focusStartTime,
              onStartSession: _handleStartFocusSession,
              onPause: _handlePauseFocusSession,
              onComplete: _handleCompleteFocusSession,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            ProgressSection(
              completionRate: _completionRate,
              completedCount: _completedCount,
              inProgressCount: _inProgressCount,
              pendingCount: _pendingCount,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            TasksSection(
              tasks: _tasks,
              selectedTaskIndex: _selectedTaskIndex,
              onTaskTap: _handleTaskTap,
              onTaskStatusChange: _handleTaskStatusChange,
              onAddTap: _handleAddTaskTap,
              onEditTap: _handleEditTaskTap,
              onDeleteTap: _handleDeleteTaskTap,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            WeeklyGoalsSection(goals: _goals, onGoalTap: _handleGoalTap),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
