// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/constants/time_of_day_mode.dart';
import '../../../shared/models/models.dart';
import '../../../services/local_storage_service.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/widgets.dart';
import '../widgets/morning_intention_section.dart';
import '../widgets/evening_reflection_section.dart';
import '../widgets/today_summary_card.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 홈 화면 (메인 화면 기본)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Today's Good 기능이 통합된 메인 홈 화면
/// - 메인 모드: 기본 홈 화면 (오늘의 요약 + 태스크 + 목표)
/// - 아침 모드: 이벤트성 (06:00~10:00 + 의도 미설정 시)
/// - 저녁 모드: 이벤트성 (18:00~24:00 + 성찰 미완료 시)
///
/// 아침/저녁 완료 후 자동으로 메인 화면으로 복귀
/// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTaskIndex = -1;

  // ─────────────────────────────────────────────────────────────────────────
  // Today's Good 상태
  // ─────────────────────────────────────────────────────────────────────────

  /// 현재 모드 (null이면 자동 결정)
  TimeOfDayMode? _overrideMode;

  /// 자동 모드 여부
  bool get _isAutoMode => _overrideMode == null;

  /// 현재 활성화된 모드
  TimeOfDayMode get _currentMode {
    if (_overrideMode != null) return _overrideMode!;

    // 자동 모드: 시간대 + 완료 여부에 따라 결정
    return TimeOfDayModeExtension.determineMode(
      isMorningCompleted: _isMorningCompleted,
      isEveningCompleted: _isEveningCompleted,
    );
  }

  /// 선택된 Task ID 목록 (오늘의 의도)
  final List<int> _selectedIntentionTaskIds = [];

  /// 자유 의도 목록
  final List<String> _freeIntentions = [];

  /// 자유 의도 완료 상태
  final List<bool> _freeIntentionCompleted = [];

  /// 아침 의도 완료 여부
  bool _isMorningCompleted = false;

  /// 저녁 성찰 완료 여부
  bool _isEveningCompleted = false;

  /// 연속 달성 일수 (임시)
  final int _streak = 7;

  @override
  void initState() {
    super.initState();
    AppLogger.d('HomeScreen initState', tag: 'HomeScreen');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 사용자 정보 가져오기
  // ─────────────────────────────────────────────────────────────────────────

  /// 사용자 이름 가져오기 (우선순위: LocalStorage > 로그인 정보 > 기본값)
  String _getUserName() {
    // 1. LocalStorage에서 온보딩 시 저장한 이름 확인
    final storage = LocalStorageService();
    final savedName = storage.getSetting<String>('userName');
    if (savedName != null && savedName.isNotEmpty) {
      return savedName;
    }

    // 2. 로그인 정보에서 이름 가져오기
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && currentUser.name.isNotEmpty) {
      return currentUser.displayName;
    }

    // 3. 기본값
    return '사용자';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 모드 변경 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleModeChange(TimeOfDayMode? mode, bool isAuto) {
    setState(() {
      _overrideMode = isAuto ? null : mode;
    });

    AppLogger.ui(
      'Mode changed: ${isAuto ? 'Auto' : mode?.displayName}',
      screen: 'HomeScreen',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 아침 의도 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTaskIntentionToggle(int taskId) {
    setState(() {
      if (_selectedIntentionTaskIds.contains(taskId)) {
        _selectedIntentionTaskIds.remove(taskId);
      } else {
        // 최대 3개까지만 선택 가능
        if (_selectedIntentionTaskIds.length + _freeIntentions.length < 3) {
          _selectedIntentionTaskIds.add(taskId);
        }
      }
    });

    AppLogger.ui('Task intention toggled: $taskId', screen: 'HomeScreen');
  }

  void _handleAddFreeIntention(String intention) {
    if (_selectedIntentionTaskIds.length + _freeIntentions.length >= 3) {
      return;
    }

    setState(() {
      _freeIntentions.add(intention);
      _freeIntentionCompleted.add(false);
    });

    AppLogger.ui('Free intention added: $intention', screen: 'HomeScreen');
  }

  void _handleRemoveFreeIntention(int index) {
    setState(() {
      _freeIntentions.removeAt(index);
      _freeIntentionCompleted.removeAt(index);
    });

    AppLogger.ui(
      'Free intention removed at index: $index',
      screen: 'HomeScreen',
    );
  }

  void _handleStartDay() {
    setState(() {
      _isMorningCompleted = true;
      // 완료 후 자동으로 메인 화면으로 (자동 모드일 경우)
      if (_isAutoMode) {
        _overrideMode = null; // 자동 모드 유지 → 메인으로
      } else {
        _overrideMode = TimeOfDayMode.main; // 수동 → 메인으로
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.morningCompleted),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    AppLogger.ui('Morning intention completed', screen: 'HomeScreen');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleFreeIntentionToggle(int index) {
    setState(() {
      _freeIntentionCompleted[index] = !_freeIntentionCompleted[index];
    });

    AppLogger.ui(
      'Free intention toggled at index: $index',
      screen: 'HomeScreen',
    );
  }

  void _handleTaskComplete(int taskId) {
    // Task 상태를 완료로 변경
    ref.read(taskListProvider.notifier).changeTaskStatus(taskId, 'completed');

    AppLogger.ui('Task completed from evening: $taskId', screen: 'HomeScreen');
  }

  void _handleSaveReflection(String reflection, int rating) {
    AppLogger.i(
      'Reflection saved - rating: $rating, text: $reflection',
      tag: 'HomeScreen',
    );
  }

  void _handleFinishDay() {
    setState(() {
      _isEveningCompleted = true;
      // 완료 후 자동으로 메인 화면으로
      if (_isAutoMode) {
        _overrideMode = null;
      } else {
        _overrideMode = TimeOfDayMode.main;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.eveningCompleted),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    AppLogger.ui('Evening reflection completed', screen: 'HomeScreen');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 모드 전환 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleGoToMorning() {
    setState(() {
      _overrideMode = TimeOfDayMode.morning;
    });
    AppLogger.ui('Navigate to morning mode', screen: 'HomeScreen');
  }

  void _handleGoToEvening() {
    setState(() {
      _overrideMode = TimeOfDayMode.evening;
    });
    AppLogger.ui('Navigate to evening mode', screen: 'HomeScreen');
  }

  void _handleGoToMain() {
    setState(() {
      _overrideMode = TimeOfDayMode.main;
    });
    AppLogger.ui('Navigate to main mode', screen: 'HomeScreen');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 메인 화면 의도 완료 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  /// 메인 화면에서 의도 태스크 체크 시 태스크도 완료 처리
  void _handleIntentionTaskComplete(int taskId) {
    final tasks = ref.read(taskListProvider);
    final task = tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => Task(
        id: taskId,
        title: '',
        status: 'pending',
        progress: 0,
        timeInMinutes: 0,
        categoryId: '',
      ),
    );

    // 완료 ↔ 미완료 토글
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    ref.read(taskListProvider.notifier).changeTaskStatus(taskId, newStatus);

    AppLogger.ui(
      'Intention task toggled: $taskId -> $newStatus',
      screen: 'HomeScreen',
    );
  }

  /// 메인 화면에서 자유 의도 토글
  void _handleFreeIntentionToggleFromMain(int index) {
    setState(() {
      _freeIntentionCompleted[index] = !_freeIntentionCompleted[index];
    });

    AppLogger.ui(
      'Free intention toggled from main at index: $index',
      screen: 'HomeScreen',
    );
  }

  void _handleTaskTap(int index) {
    setState(() {
      _selectedTaskIndex = _selectedTaskIndex == index ? -1 : index;
    });
    AppLogger.ui('Task tapped at index: $index', screen: 'HomeScreen');
  }

  void _handleTaskStatusChange(int index) {
    final tasks = ref.read(taskListProvider);
    final task = tasks[index];

    // 상태 토글: pending ↔ completed
    final newStatus = task.isCompleted ? 'pending' : 'completed';

    ref.read(taskListProvider.notifier).changeTaskStatus(task.id, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태가 변경되었습니다: ${task.title} → $newStatus'),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }

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
    // 현재 사용자 정보 watch
    final currentUser = ref.watch(currentUserProvider);
    final userName = _getUserName();

    AppLogger.d(
      'HomeScreen build - mode: ${_currentMode.displayName}, auto: $_isAutoMode, user: $userName',
      tag: 'HomeScreen',
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.spaceL),

            // 공통 헤더 (모든 모드에서 표시)
            HomeHeader(
              userName: userName,
              notificationCount: 3,
              onNotificationTap: _handleNotificationTap,
              onProfileTap: _handleProfileTap,
            ),
            const SizedBox(height: AppSizes.spaceXL),

            // 시간대별 콘텐츠
            _buildModeContent(userName),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 시간대별 콘텐츠 빌드
  Widget _buildModeContent(String userName) {
    switch (_currentMode) {
      case TimeOfDayMode.morning:
        return _buildMorningMode(userName);
      case TimeOfDayMode.main:
        return _buildMainMode();
      case TimeOfDayMode.evening:
        return _buildEveningMode();
    }
  }

  /// 아침 모드 콘텐츠 (이벤트)
  Widget _buildMorningMode(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인으로 돌아가기 버튼
        _buildBackToMainButton(),
        const SizedBox(height: AppSizes.spaceL),

        // 아침 의도 섹션
        MorningIntentionSection(
          userName: userName,
          selectedTaskIds: _selectedIntentionTaskIds,
          freeIntentions: _freeIntentions,
          onTaskToggle: _handleTaskIntentionToggle,
          onAddFreeIntention: _handleAddFreeIntention,
          onRemoveFreeIntention: _handleRemoveFreeIntention,
          onStartDay: _handleStartDay,
        ),
      ],
    );
  }

  /// 메인 모드 콘텐츠 (기본 홈 화면)
  Widget _buildMainMode() {
    final tasks = ref.watch(taskListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오늘의 요약 카드
        TodaySummaryCard(
          selectedTaskIds: _selectedIntentionTaskIds,
          freeIntentions: _freeIntentions,
          freeIntentionCompleted: _freeIntentionCompleted,
          isMorningCompleted: _isMorningCompleted,
          isEveningCompleted: _isEveningCompleted,
          streak: _streak,
          onEditMorning: _handleGoToMorning,
          onGoToEvening: _handleGoToEvening,
          onSetIntention: _handleGoToMorning,
          onIntentionTaskToggle: _handleIntentionTaskComplete,
          onFreeIntentionToggle: _handleFreeIntentionToggleFromMain,
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Tasks Section
        TasksSection(
          tasks: tasks,
          selectedTaskIndex: _selectedTaskIndex,
          onTaskTap: _handleTaskTap,
          onTaskStatusChange: _handleTaskStatusChange,
          onAddTap: _handleAddTaskTap,
          onEditTap: _handleEditTaskTap,
          onDeleteTap: _handleDeleteTaskTap,
          onProgressChange: _handleProgressChange,
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Weekly Goals Section
        const WeeklyGoalsSection(),
      ],
    );
  }

  /// 저녁 모드 콘텐츠 (이벤트)
  Widget _buildEveningMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인으로 돌아가기 버튼
        _buildBackToMainButton(),
        const SizedBox(height: AppSizes.spaceL),

        // 저녁 성찰 섹션
        EveningReflectionSection(
          selectedTaskIds: _selectedIntentionTaskIds,
          freeIntentions: _freeIntentions,
          freeIntentionCompleted: _freeIntentionCompleted,
          onTaskComplete: _handleTaskComplete,
          onFreeIntentionToggle: _handleFreeIntentionToggle,
          onSaveReflection: _handleSaveReflection,
          onFinishDay: _handleFinishDay,
        ),
      ],
    );
  }

  /// 메인으로 돌아가기 버튼
  Widget _buildBackToMainButton() {
    return GestureDetector(
      onTap: _handleGoToMain,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              size: AppSizes.iconS,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              AppStrings.backToMain,
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
