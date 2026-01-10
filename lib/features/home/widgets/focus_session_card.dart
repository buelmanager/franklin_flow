// lib/features/home/widgets/focus_session_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 포커스 세션 카드 위젯
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 진행 중인 작업 + 타이머 표시
/// 작업이 없으면 "Start your day" 버튼 표시
/// ═══════════════════════════════════════════════════════════════════════════

class FocusSessionCard extends StatefulWidget {
  /// 현재 작업 중인 태스크 제목
  final String? currentTaskTitle;

  /// 시작 시간 (null이면 작업 중이 아님)
  final DateTime? startTime;

  /// 포커스 세션 시작 콜백
  final VoidCallback? onStartSession;

  /// 일시정지 콜백
  final VoidCallback? onPause;

  /// 완료 콜백
  final VoidCallback? onComplete;

  const FocusSessionCard({
    Key? key,
    this.currentTaskTitle,
    this.startTime,
    this.onStartSession,
    this.onPause,
    this.onComplete,
  }) : super(key: key);

  @override
  State<FocusSessionCard> createState() => _FocusSessionCardState();
}

class _FocusSessionCardState extends State<FocusSessionCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
    AppLogger.d('FocusSessionCard initState', tag: 'FocusSessionCard');
  }

  @override
  void didUpdateWidget(FocusSessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.startTime != null) {
      // 타이머 시작
      _elapsed = DateTime.now().difference(widget.startTime!);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsed = DateTime.now().difference(widget.startTime!);
          });
        }
      });
      AppLogger.d('Timer started', tag: 'FocusSessionCard');
    } else {
      _elapsed = Duration.zero;
      AppLogger.d('No active session', tag: 'FocusSessionCard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveSession = widget.startTime != null;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: hasActiveSession ? _buildActiveSession() : _buildStartPrompt(),
    );
  }

  /// 활성 세션 UI
  Widget _buildActiveSession() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 아이콘 + 제목
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: AppDecorations.accentIconSquare(
                AppColors.accentBlue,
                borderRadius: AppSizes.radiusM,
              ),
              child: Icon(
                Icons.play_circle_outline,
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
                    'Working on',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.currentTaskTitle ?? 'Focus Session',
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

        // 타이머 표시
        Center(
          child: Text(
            _formatDuration(_elapsed),
            style: AppTextStyles.displayNumber.copyWith(
              fontSize: 48,
              color: AppColors.accentBlue,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Center(child: Text('Focus Mode', style: AppTextStyles.caption)),
        const SizedBox(height: AppSizes.spaceXL),

        // 프로그레스 바 (25분 기준 - 포모도로)
        _buildProgressBar(),
        const SizedBox(height: AppSizes.spaceXL),

        // 액션 버튼들
        Row(
          children: [
            Expanded(
              child: NeumorphicButton(
                height: AppSizes.buttonHeightM,
                borderRadius: AppSizes.radiusM,
                onTap: () {
                  AppLogger.ui('Pause tapped', screen: 'FocusSessionCard');
                  widget.onPause?.call();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pause,
                      size: AppSizes.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Text('Pause', style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: NeumorphicButton(
                height: AppSizes.buttonHeightM,
                borderRadius: AppSizes.radiusM,
                onTap: () {
                  AppLogger.ui('Complete tapped', screen: 'FocusSessionCard');
                  widget.onComplete?.call();
                },
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
                      'Complete',
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
      ],
    );
  }

  /// 시작 프롬프트 UI (작업이 없을 때)
  Widget _buildStartPrompt() {
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

        // 메시지
        Text(
          'Ready to Focus?',
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          'Start a focus session to track your productivity',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // 시작 버튼
        NeumorphicButton(
          width: double.infinity,
          height: AppSizes.buttonHeightL,
          borderRadius: AppSizes.radiusM,
          onTap: () {
            AppLogger.ui('Start session tapped', screen: 'FocusSessionCard');
            widget.onStartSession?.call();
          },
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
                'Start Focus Session',
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

  /// 프로그레스 바 (25분 포모도로 기준)
  Widget _buildProgressBar() {
    const pomodoroMinutes = 25;
    final progress = _elapsed.inSeconds / (pomodoroMinutes * 60);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress', style: AppTextStyles.caption),
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

  /// Duration을 "HH:MM:SS" 형식으로 포맷
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
}
