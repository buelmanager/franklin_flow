// lib/features/home/widgets/task_options_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/task_model.dart';
import '../../../services/category_service.dart';
import 'task_form_dialog.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 태스크 옵션 BottomSheet
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 태스크 진행도 관리 및 옵션 제공
/// - 진행도 증가/감소
/// - 상태 변경
/// - 편집/삭제
/// ═══════════════════════════════════════════════════════════════════════════

class TaskOptionsBottomSheet extends StatelessWidget {
  final Task task;
  final WidgetRef ref;

  const TaskOptionsBottomSheet({
    Key? key,
    required this.task,
    required this.ref,
  }) : super(key: key);

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleIncreaseProgress(BuildContext context) async {
    final newProgress = (task.progress + 10).clamp(0, 100);
    await ref
        .read(taskListProvider.notifier)
        .updateTaskProgress(task.id, newProgress);

    if (context.mounted) Navigator.of(context).pop();

    AppLogger.ui(
      'Task progress increased: ${task.title} -> $newProgress%',
      screen: 'TaskOptions',
    );
  }

  Future<void> _handleDecreaseProgress(BuildContext context) async {
    final newProgress = (task.progress - 10).clamp(0, 100);
    await ref
        .read(taskListProvider.notifier)
        .updateTaskProgress(task.id, newProgress);

    if (context.mounted) Navigator.of(context).pop();

    AppLogger.ui(
      'Task progress decreased: ${task.title} -> $newProgress%',
      screen: 'TaskOptions',
    );
  }

  Future<void> _handleSetProgress(BuildContext context) async {
    if (!context.mounted) return;
    final navigatorContext = Navigator.of(context).context;

    // BottomSheet 닫기
    Navigator.of(context).pop();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!navigatorContext.mounted) return;

    // 진행도 설정 다이얼로그 표시
    await _showProgressDialog(navigatorContext);
  }

  Future<void> _showProgressDialog(BuildContext context) async {
    int selectedProgress = task.progress;

    await NeumorphicDialog.show(
      context: context,
      title: AppStrings.taskProgressDialogTitle,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 슬라이더
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.accentOrange,
                  inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
                  thumbColor: AppColors.accentOrange,
                  overlayColor: AppColors.accentOrange.withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: selectedProgress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '$selectedProgress%',
                  onChanged: (value) {
                    setState(() {
                      selectedProgress = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),

              // 진행도 표시
              Text(
                '$selectedProgress%',
                style: AppTextStyles.displayNumber.copyWith(
                  fontSize: 32,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        NeumorphicButton.text(
          text: AppStrings.btnCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSizes.spaceM),
        NeumorphicButton.text(
          text: AppStrings.btnConfirm,
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.accentOrange,
          ),
          onTap: () async {
            await ref
                .read(taskListProvider.notifier)
                .updateTaskProgress(task.id, selectedProgress);
            if (context.mounted) Navigator.of(context).pop();

            AppLogger.ui(
              'Task progress set: ${task.title} -> $selectedProgress%',
              screen: 'TaskOptions',
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleChangeStatus(
    BuildContext context,
    String newStatus,
  ) async {
    await ref
        .read(taskListProvider.notifier)
        .changeTaskStatus(task.id, newStatus);

    if (context.mounted) Navigator.of(context).pop();

    AppLogger.ui(
      'Task status changed: ${task.title} -> $newStatus',
      screen: 'TaskOptions',
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    if (!context.mounted) return;
    final navigatorContext = Navigator.of(context).context;

    Navigator.of(context).pop();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!navigatorContext.mounted) return;

    final result = await TaskFormDialog.show(
      context: navigatorContext,
      task: task,
    );

    if (result != null && navigatorContext.mounted) {
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(
          content: Text('태스크가 수정되었습니다: ${result.title}'),
          backgroundColor: AppColors.accentBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.ui('Task edit tapped: ${task.title}', screen: 'TaskOptions');
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (!context.mounted) return;
    final navigatorContext = Navigator.of(context).context;

    Navigator.of(context).pop();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!navigatorContext.mounted) return;

    final confirmed = await NeumorphicDialog.showConfirm(
      context: navigatorContext,
      title: AppStrings.dialogDeleteTitle,
      message: AppStrings.dialogDeleteMessage,
      confirmText: AppStrings.dialogDeleteConfirm,
      cancelText: AppStrings.dialogDeleteCancel,
    );

    if (confirmed == true) {
      await ref.read(taskListProvider.notifier).deleteTask(task.id);

      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('태스크가 삭제되었습니다: ${task.title}'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      AppLogger.i('Task deleted: ${task.title}', tag: 'TaskOptions');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoryService = CategoryService();
    final category = categoryService.getCategoryById(task.categoryId);

    return Container(
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

          // 태스크 정보
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Row(
              children: [
                // 카테고리 아이콘
                if (category != null)
                  Container(
                    width: AppSizes.avatarM,
                    height: AppSizes.avatarM,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      category.icon,
                      size: AppSizes.iconM,
                      color: category.color,
                    ),
                  ),
                const SizedBox(width: AppSizes.spaceM),

                // 제목 및 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: AppTextStyles.heading4),
                      const SizedBox(height: AppSizes.spaceXS),
                      Row(
                        children: [
                          BadgeTag.status(status: task.status),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            '${task.progress}% 완료',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 진행도 바 (진행 중일 때만)
          if (task.isInProgress)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
              ),
              child: NeumorphicProgressBar(
                progress: task.progress / 100,
                color: AppColors.accentOrange,
                height: AppSizes.progressBarHeightL,
              ),
            ),

          const SizedBox(height: AppSizes.spaceL),

          // 옵션 리스트
          _buildOption(
            context,
            icon: Icons.add,
            label: AppStrings.taskOptionIncreaseProgress,
            color: AppColors.accentGreen,
            onTap: () => _handleIncreaseProgress(context),
            enabled: task.progress < 100,
          ),
          _buildOption(
            context,
            icon: Icons.remove,
            label: AppStrings.taskOptionDecreaseProgress,
            color: AppColors.accentOrange,
            onTap: () => _handleDecreaseProgress(context),
            enabled: task.progress > 0,
          ),
          _buildOption(
            context,
            icon: Icons.tune,
            label: AppStrings.taskOptionSetProgress,
            color: AppColors.accentPurple,
            onTap: () => _handleSetProgress(context),
          ),

          const Divider(height: 1),

          // 상태 변경
          if (!task.isCompleted)
            _buildOption(
              context,
              icon: Icons.play_arrow,
              label: task.isPending
                  ? AppStrings.taskOptionStart
                  : AppStrings.taskOptionInProgress,
              color: AppColors.accentOrange,
              onTap: () => _handleChangeStatus(context, 'in-progress'),
              enabled: task.isPending,
            ),
          _buildOption(
            context,
            icon: Icons.check,
            label: AppStrings.taskOptionComplete,
            color: AppColors.accentGreen,
            onTap: () => _handleChangeStatus(context, 'completed'),
            enabled: !task.isCompleted,
          ),
          if (task.isCompleted)
            _buildOption(
              context,
              icon: Icons.replay,
              label: AppStrings.taskOptionRestart,
              color: AppColors.accentBlue,
              onTap: () => _handleChangeStatus(context, 'pending'),
            ),

          const Divider(height: 1),

          _buildOption(
            context,
            icon: Icons.edit,
            label: AppStrings.taskOptionEdit,
            color: AppColors.accentBlue,
            onTap: () => _handleEdit(context),
          ),
          _buildOption(
            context,
            icon: Icons.delete_outline,
            label: AppStrings.taskOptionDelete,
            color: AppColors.accentRed,
            onTap: () => _handleDelete(context),
          ),

          const SizedBox(height: AppSizes.paddingXL),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingL,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconM,
              color: enabled ? color : AppColors.textDisabled,
            ),
            const SizedBox(width: AppSizes.spaceL),
            Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
