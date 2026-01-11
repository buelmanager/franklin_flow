// lib/features/home/widgets/focus_session_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/focus_session_model.dart';
import '../../../shared/models/task_model.dart';
import '../../../services/category_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 포커스 세션 카드 위젯 (Riverpod 적용)
/// ═══════════════════════════════════════════════════════════════════════════

class FocusSessionCard extends ConsumerStatefulWidget {
  const FocusSessionCard({Key? key}) : super(key: key);

  @override
  ConsumerState<FocusSessionCard> createState() => _FocusSessionCardState();
}

class _FocusSessionCardState extends ConsumerState<FocusSessionCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
    AppLogger.d('FocusSessionCard initState', tag: 'FocusSessionCard');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    final session = ref.read(focusSessionProvider);
    if (session != null && session.isActive) {
      _elapsed = DateTime.now().difference(session.startTime);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          final currentSession = ref.read(focusSessionProvider);
          if (currentSession != null) {
            setState(() {
              _elapsed =
                  DateTime.now().difference(currentSession.startTime) -
                  Duration(minutes: currentSession.totalPausedMinutes);
            });
          }
        }
      });
    } else {
      _elapsed = Duration.zero;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleStartSession(Task task) async {
    await ref.read(focusSessionProvider.notifier).startSession(task);
    _startTimer();

    AppLogger.ui(
      'Focus session started: ${task.title}',
      screen: 'FocusSessionCard',
    );
  }

  Future<void> _handlePause() async {
    await ref.read(focusSessionProvider.notifier).pauseSession();
    _timer?.cancel();

    AppLogger.ui('Focus session paused', screen: 'FocusSessionCard');
  }

  Future<void> _handleResume() async {
    await ref.read(focusSessionProvider.notifier).resumeSession();
    _startTimer();

    AppLogger.ui('Focus session resumed', screen: 'FocusSessionCard');
  }

  Future<void> _handleComplete() async {
    // 목표 시간 체크 없이 바로 완료 처리
    await ref.read(focusSessionProvider.notifier).completeSession();
    _timer?.cancel();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('수고하셨습니다! 집중 세션이 완료되었습니다 🎉'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Focus session completed', screen: 'FocusSessionCard');
  }

  Future<void> _handleCancel() async {
    final confirmed = await NeumorphicDialog.showConfirm(
      context: context,
      title: '세션 취소',
      message: '진행 중인 세션을 취소하시겠습니까?',
      confirmText: '취소',
      cancelText: '계속하기',
    );

    if (confirmed == true) {
      await ref.read(focusSessionProvider.notifier).cancelSession();
      _timer?.cancel();

      AppLogger.ui('Focus session cancelled', screen: 'FocusSessionCard');
    }
  }

  void _showTaskSelector() {
    _showTaskBottomSheet();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Provider에서 현재 세션 구독
    final session = ref.watch(focusSessionProvider);
    final hasSession = session != null;

    // 세션 상태 변경 시 타이머 재시작
    ref.listen<FocusSession?>(focusSessionProvider, (previous, next) {
      if (next != null && next.isActive) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: hasSession ? _buildActiveSession(session) : _buildTaskSelector(),
    );
  }

  /// 활성 세션 UI
  Widget _buildActiveSession(session) {
    final tasks = ref.watch(taskListProvider);
    final task = tasks.cast<Task?>().firstWhere(
      (t) => t?.id == session.taskId,
      orElse: () => null,
    );

    final isPaused = session.isPaused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: AppDecorations.accentIconSquare(
                AppColors.accentBlue,
                borderRadius: AppSizes.radiusM,
              ),
              child: Icon(
                isPaused
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: AppSizes.iconM,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPaused ? '일시정지' : '집중 모드',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.taskTitle,
                    style: AppTextStyles.heading4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 타이머
        Center(
          child: Text(
            _formatDuration(_elapsed),
            style: AppTextStyles.displayNumber.copyWith(
              fontSize: 48,
              color: isPaused ? AppColors.textTertiary : AppColors.accentBlue,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Center(
          child: Text(
            '${AppStrings.focusTargetLabel}: ${session.targetMinutes}${AppStrings.focusMinuteSuffix}',
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 프로그레스 바
        _buildProgressBar(session),
        const SizedBox(height: AppSizes.spaceXL),

        // 버튼들
        Row(
          children: [
            // 일시정지/재개
            Expanded(
              child: NeumorphicButton(
                height: AppSizes.buttonHeightM,
                borderRadius: AppSizes.radiusM,
                onTap: isPaused ? _handleResume : _handlePause,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      size: AppSizes.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Text(isPaused ? '재개' : '일시정지', style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),

            // 완료 (목표 시간 제약 없음)
            Expanded(
              child: NeumorphicButton(
                height: AppSizes.buttonHeightM,
                borderRadius: AppSizes.radiusM,
                onTap: _handleComplete,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      size: AppSizes.iconS,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Text(
                      '완료',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        // 취소 버튼
        SizedBox(
          width: double.infinity,
          child: NeumorphicButton(
            height: AppSizes.buttonHeightS,
            borderRadius: AppSizes.radiusM,
            onTap: _handleCancel,
            child: Text(
              '세션 취소',
              style: AppTextStyles.labelL.copyWith(color: AppColors.accentRed),
            ),
          ),
        ),
      ],
    );
  }

  /// Task 선택 UI (한글화)
  Widget _buildTaskSelector() {
    final todaySessions = ref.watch(todaySessionsProvider);
    final todayMinutes = ref.watch(todayFocusMinutesProvider);

    return Column(
      children: [
        // 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: AppDecorations.accentIconCircle(AppColors.accentBlue),
          child: Icon(
            Icons.rocket_launch_rounded,
            size: 40,
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 메시지 (한글화)
        Text(
          '집중할 준비가 되셨나요?',
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          '태스크를 선택하고 집중 세션을 시작하세요',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 오늘 통계 (한글화)
        if (todaySessions > 0 || todayMinutes > 0)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$todaySessions',
                      style: AppTextStyles.numberM.copyWith(
                        color: AppColors.accentGreen,
                      ),
                    ),
                    Text('세션', style: AppTextStyles.caption),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.textTertiary.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      '${todayMinutes}분',
                      style: AppTextStyles.numberM.copyWith(
                        color: AppColors.accentGreen,
                      ),
                    ),
                    Text('집중 시간', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSizes.spaceXL),

        // 시작 버튼 (한글화)
        NeumorphicButton(
          width: double.infinity,
          height: AppSizes.buttonHeightL,
          borderRadius: AppSizes.radiusM,
          onTap: _showTaskSelector,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                size: AppSizes.iconL,
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text(
                '태스크 선택 & 시작',
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(session) {
    final progress = _elapsed.inSeconds / (session.targetMinutes * 60);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('진행도', style: AppTextStyles.caption),
            Text(
              '${(progress * 100).clamp(0, 100).toInt()}%',
              style: AppTextStyles.numberS.copyWith(
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        NeumorphicProgressBar(
          progress: progress.clamp(0.0, 1.0),
          color: AppColors.accentBlue,
          height: AppSizes.progressBarHeightL,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TaskSelectorBottomSheet(
        onTaskSelect: (task) {
          Navigator.of(context).pop();
          _handleStartSession(task);
        },
      ),
    );
  }
}

/// Task 선택 BottomSheet (한글화)
class _TaskSelectorBottomSheet extends ConsumerWidget {
  final Function(Task) onTaskSelect;

  const _TaskSelectorBottomSheet({Key? key, required this.onTaskSelect})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref
        .watch(taskListProvider)
        .where((t) => !t.isCompleted)
        .toList();

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXXL),
          topRight: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: AppSizes.paddingM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더 (한글화)
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Text('태스크 선택', style: AppTextStyles.heading3),
          ),

          // Task 리스트 또는 빈 상태
          if (tasks.isEmpty)
            // 빈 상태 (한글화)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
                vertical: AppSizes.paddingXXL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXL),

                  // 메시지 (한글화)
                  Text(
                    '사용 가능한 태스크가 없습니다',
                    style: AppTextStyles.heading4,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spaceM),

                  Text(
                    '먼저 태스크를 생성한 후\n집중 세션을 시작하세요!',
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spaceXL),

                  // 닫기 버튼 (한글화)
                  NeumorphicButton(
                    width: double.infinity,
                    height: AppSizes.buttonHeightL,
                    borderRadius: AppSizes.radiusM,
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          size: AppSizes.iconM,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        Text('닫기', style: AppTextStyles.button),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Task 목록
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingS,
                ),
                itemCount: tasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSizes.spaceS),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskItem(context, ref, task);
                },
              ),
            ),

          //const SizedBox(height: AppSizes.paddingXL),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, WidgetRef ref, Task task) {
    final categoryService = CategoryService();
    final category = categoryService.getCategoryById(task.categoryId);

    return GestureDetector(
      onTap: () => onTaskSelect(task),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            // 카테고리 아이콘
            if (category != null)
              Container(
                width: AppSizes.avatarS,
                height: AppSizes.avatarS,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  category.icon,
                  size: AppSizes.iconS,
                  color: category.color,
                ),
              ),
            const SizedBox(width: AppSizes.spaceM),

            // Task 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: AppSizes.iconXS,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSizes.spaceXS),
                      Text(task.timeString, style: AppTextStyles.caption),
                      if (task.progress > 0) ...[
                        const SizedBox(width: AppSizes.spaceM),
                        Text(
                          '${task.progress}% 완료',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.iconS,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
