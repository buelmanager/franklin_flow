// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/constants/time_of_day_mode.dart';
import '../../../shared/models/models.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/widgets.dart';

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
  static const String _tag = 'HomeScreen';

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

    // Provider에서 DailyRecord 가져오기
    final todayRecord = ref.read(todayRecordProvider);
    final isMorningCompleted = todayRecord?.isMorningCompleted ?? false;
    final isEveningCompleted = todayRecord?.isEveningCompleted ?? false;

    // 자동 모드: 시간대 + 완료 여부에 따라 결정
    return TimeOfDayModeExtension.determineMode(
      isMorningCompleted: isMorningCompleted,
      isEveningCompleted: isEveningCompleted,
    );
  }

  @override
  void initState() {
    super.initState();
    AppLogger.d('HomeScreen initState', tag: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 사용자 정보 가져오기
  // ─────────────────────────────────────────────────────────────────────────

  /// 사용자 이름 가져오기 (Provider 사용 - 실시간 업데이트)
  /// 우선순위: userNameProvider > 로그인 정보 > 기본값
  String _getUserName() {
    // 1. Provider에서 이름 가져오기 (watch로 실시간 반영)
    final savedName = ref.watch(userNameProvider);
    if (savedName.isNotEmpty) {
      return savedName;
    }

    // 2. 로그인 정보에서 이름 가져오기
    final currentUser = ref.watch(currentUserProvider);
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

  Future<void> _handleTaskIntentionToggle(int taskId) async {
    final success = await ref
        .read(todayRecordProvider.notifier)
        .toggleTaskIntention(taskId);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.maxIntentionsReached),
          backgroundColor: AppColors.accentOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Task intention toggled: $taskId', screen: _tag);
  }

  Future<void> _handleAddFreeIntention(String intention) async {
    final success = await ref
        .read(todayRecordProvider.notifier)
        .addFreeIntention(intention);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.maxIntentionsReached),
          backgroundColor: AppColors.accentOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Free intention added: $intention', screen: _tag);
  }

  Future<void> _handleRemoveFreeIntention(int index) async {
    await ref.read(todayRecordProvider.notifier).removeFreeIntention(index);

    AppLogger.ui('Free intention removed at index: $index', screen: _tag);
  }

  Future<void> _handleStartDay() async {
    await ref.read(todayRecordProvider.notifier).completeMorningIntention();

    setState(() {
      // 완료 후 자동으로 메인 화면으로 (자동 모드일 경우)
      if (_isAutoMode) {
        _overrideMode = null; // 자동 모드 유지 -> 메인으로
      } else {
        _overrideMode = TimeOfDayMode.main; // 수동 -> 메인으로
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.morningCompleted),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Morning intention completed', screen: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 저녁 성찰 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleFreeIntentionToggle(int index) async {
    await ref
        .read(todayRecordProvider.notifier)
        .toggleFreeIntentionCompleted(index);

    AppLogger.ui('Free intention toggled at index: $index', screen: _tag);
  }

  void _handleTaskComplete(int taskId) {
    // Task 상태를 완료로 변경
    ref.read(taskListProvider.notifier).changeTaskStatus(taskId, 'completed');

    AppLogger.ui('Task completed from evening: $taskId', screen: _tag);
  }

  Future<void> _handleSaveReflection(String reflection, int rating) async {
    await ref
        .read(todayRecordProvider.notifier)
        .saveEveningReflection(reflection, rating);

    AppLogger.i(
      'Reflection saved - rating: $rating, text: $reflection',
      tag: _tag,
    );
  }

  Future<void> _handleFinishDay() async {
    await ref.read(todayRecordProvider.notifier).completeEveningReflection();

    setState(() {
      // 완료 후 자동으로 메인 화면으로
      if (_isAutoMode) {
        _overrideMode = null;
      } else {
        _overrideMode = TimeOfDayMode.main;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.eveningCompleted),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Evening reflection completed', screen: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 모드 전환 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleGoToMorning() {
    setState(() {
      _overrideMode = TimeOfDayMode.morning;
    });
    AppLogger.ui('Navigate to morning mode', screen: _tag);
  }

  void _handleGoToEvening() {
    setState(() {
      _overrideMode = TimeOfDayMode.evening;
    });
    AppLogger.ui('Navigate to evening mode', screen: _tag);
  }

  void _handleGoToMain() {
    setState(() {
      _overrideMode = TimeOfDayMode.main;
    });
    AppLogger.ui('Navigate to main mode', screen: _tag);
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

    // 완료 <-> 미완료 토글
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    ref.read(taskListProvider.notifier).changeTaskStatus(taskId, newStatus);

    AppLogger.ui('Intention task toggled: $taskId -> $newStatus', screen: _tag);
  }

  /// 메인 화면에서 자유 의도 토글
  Future<void> _handleFreeIntentionToggleFromMain(int index) async {
    await ref
        .read(todayRecordProvider.notifier)
        .toggleFreeIntentionCompleted(index);

    AppLogger.ui(
      'Free intention toggled from main at index: $index',
      screen: _tag,
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
    // 다크 모드 상태
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 사용자 이름 (Provider에서 실시간 watch)
    final userName = _getUserName();

    // DailyRecord watch (반응형 업데이트)
    final todayRecord = ref.watch(todayRecordProvider);

    AppLogger.d(
      'HomeScreen build - mode: ${_currentMode.displayName}, auto: $_isAutoMode, '
      'user: $userName, record: ${todayRecord?.id}',
      tag: _tag,
    );

    return Container(
      color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      child: SingleChildScrollView(
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
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // 시간대별 콘텐츠
              _buildModeContent(userName, todayRecord),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// 시간대별 콘텐츠 빌드
  Widget _buildModeContent(String userName, DailyRecord? todayRecord) {
    switch (_currentMode) {
      case TimeOfDayMode.morning:
        return _buildMorningMode(userName, todayRecord);
      case TimeOfDayMode.main:
        return _buildMainMode(todayRecord);
      case TimeOfDayMode.evening:
        return _buildEveningMode(todayRecord);
    }
  }

  /// 아침 모드 콘텐츠 (이벤트)
  Widget _buildMorningMode(String userName, DailyRecord? todayRecord) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인으로 돌아가기 버튼
        _buildBackToMainButton(),
        const SizedBox(height: AppSizes.spaceL),

        // 아침 의도 섹션
        MorningIntentionSection(
          userName: userName,
          selectedTaskIds: todayRecord?.selectedTaskIds ?? [],
          freeIntentions: todayRecord?.freeIntentions ?? [],
          onTaskToggle: _handleTaskIntentionToggle,
          onAddFreeIntention: _handleAddFreeIntention,
          onRemoveFreeIntention: _handleRemoveFreeIntention,
          onStartDay: _handleStartDay,
        ),
      ],
    );
  }

  /// 메인 모드 콘텐츠 (기본 홈 화면)
  Widget _buildMainMode(DailyRecord? todayRecord) {
    final tasks = ref.watch(taskListProvider);
    final streak = ref.watch(streakDaysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오늘의 요약 카드
        TodaySummaryCard(
          selectedTaskIds: todayRecord?.selectedTaskIds ?? [],
          freeIntentions: todayRecord?.freeIntentions ?? [],
          freeIntentionCompleted: todayRecord?.freeIntentionCompleted ?? [],
          isMorningCompleted: todayRecord?.isMorningCompleted ?? false,
          isEveningCompleted: todayRecord?.isEveningCompleted ?? false,
          streak: streak,
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
  Widget _buildEveningMode(DailyRecord? todayRecord) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인으로 돌아가기 버튼
        _buildBackToMainButton(),
        const SizedBox(height: AppSizes.spaceL),

        // 저녁 성찰 섹션
        EveningReflectionSection(
          selectedTaskIds: todayRecord?.selectedTaskIds ?? [],
          freeIntentions: todayRecord?.freeIntentions ?? [],
          freeIntentionCompleted: todayRecord?.freeIntentionCompleted ?? [],
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
