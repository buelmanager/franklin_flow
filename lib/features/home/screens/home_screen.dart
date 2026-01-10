// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/models.dart';
import '../widgets/focus_session_card.dart';
import '../widgets/widgets.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면 (Riverpod 적용)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱의 메인 홈 화면
/// Riverpod를 사용한 반응형 UI
/// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTaskIndex = -1;

  @override
  void initState() {
    super.initState();
    AppLogger.d('HomeScreen initState', tag: 'HomeScreen');

    // Focus Session 복원
    Future.microtask(() {
      ref.read(focusSessionProvider.notifier).restoreSession();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTaskTap(int index) {
    setState(() {
      _selectedTaskIndex = _selectedTaskIndex == index ? -1 : index;
    });

    final tasks = ref.read(taskListProvider);
    AppLogger.ui('Task selected: ${tasks[index].title}', screen: 'HomeScreen');
  }

  Future<void> _handleTaskStatusChange(int index) async {
    final tasks = ref.read(taskListProvider);
    final task = tasks[index];

    // 상태 순환: pending -> in-progress -> completed -> pending
    String newStatus;
    if (task.status == 'completed') {
      newStatus = 'pending';
    } else if (task.status == 'pending') {
      newStatus = 'in-progress';
    } else {
      newStatus = 'completed';
    }

    await ref
        .read(taskListProvider.notifier)
        .changeTaskStatus(task.id, newStatus);

    AppLogger.ui(
      'Task status changed: ${task.title} -> $newStatus',
      screen: 'HomeScreen',
    );
  }

  Future<void> _handleProgressChange(int index, int newProgress) async {
    final tasks = ref.read(taskListProvider);
    final task = tasks[index];

    await ref
        .read(taskListProvider.notifier)
        .updateTaskProgress(task.id, newProgress);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('진행도가 변경되었습니다: ${task.title} → $newProgress%'),
          backgroundColor: AppColors.accentOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui(
      'Task progress changed: ${task.title} -> $newProgress%',
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
    final tasks = ref.read(taskListProvider);
    final task = tasks[index];

    AppLogger.ui('Edit task tapped: ${task.title}', screen: 'HomeScreen');

    TaskFormDialog.show(
      context: context,
      task: task,
      onSaved: (updatedTask) {
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
    final tasks = ref.read(taskListProvider);
    final task = tasks[index];

    AppLogger.ui('Delete task tapped: ${task.title}', screen: 'HomeScreen');

    NeumorphicDialog.showConfirm(
      context: context,
      title: AppStrings.dialogDeleteTitle,
      message: AppStrings.dialogDeleteMessage,
      confirmText: AppStrings.dialogDeleteConfirm,
      cancelText: AppStrings.dialogDeleteCancel,
    ).then((confirmed) async {
      if (confirmed == true) {
        await ref.read(taskListProvider.notifier).deleteTask(task.id);

        setState(() {
          _selectedTaskIndex = -1;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('태스크가 삭제되었습니다: ${task.title}'),
              backgroundColor: AppColors.accentRed,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        AppLogger.i('Task deleted: ${task.title}', tag: 'HomeScreen');
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Provider에서 데이터 구독
    final tasks = ref.watch(taskListProvider);
    final completionRate = ref.watch(completionRateProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final inProgressTasks = ref.watch(inProgressTasksProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);

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

            // Focus Session Card (Riverpod 적용됨)
            const FocusSessionCard(),
            const SizedBox(height: AppSizes.spaceXL),

            // Progress Section (자동 갱신됨)
            ProgressSection(
              completionRate: completionRate,
              completedCount: completedTasks.length,
              inProgressCount: inProgressTasks.length,
              pendingCount: pendingTasks.length,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // Tasks Section (자동 갱신됨 + 진행도 변경)
            TasksSection(
              tasks: tasks,
              selectedTaskIndex: _selectedTaskIndex,
              onTaskTap: _handleTaskTap,
              onTaskStatusChange: _handleTaskStatusChange,
              onAddTap: _handleAddTaskTap,
              onEditTap: _handleEditTaskTap,
              onDeleteTap: _handleDeleteTaskTap,
              onProgressChange: _handleProgressChange, // 추가
            ),
            const SizedBox(height: AppSizes.spaceXL),

            const WeeklyGoalsSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
