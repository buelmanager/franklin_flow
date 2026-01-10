// lib/features/home/widgets/task_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/models/task_model.dart';
import '../../../services/task_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 태스크 추가/수정 폼 다이얼로그
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 태스크 생성 및 수정을 위한 폼 다이얼로그
/// TimeSelector와 CategorySelector 사용으로 UX 개선
///
/// 사용법:
///   // 새 태스크 추가
///   TaskFormDialog.show(context: context);
///
///   // 기존 태스크 수정
///   TaskFormDialog.show(context: context, task: existingTask);
/// ═══════════════════════════════════════════════════════════════════════════

class TaskFormDialog extends StatefulWidget {
  /// 수정할 태스크 (null이면 새로 추가)
  final Task? task;

  /// 저장 완료 콜백
  final Function(Task)? onSaved;

  const TaskFormDialog({Key? key, this.task, this.onSaved}) : super(key: key);

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<Task?> show({
    required BuildContext context,
    Task? task,
    Function(Task)? onSaved,
  }) {
    AppLogger.d(
      task == null ? 'Opening add task dialog' : 'Opening edit task dialog',
      tag: 'TaskFormDialog',
    );

    return showDialog<Task>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.shadowDark.withOpacity(0.3),
      builder: (context) => TaskFormDialog(task: task, onSaved: onSaved),
    );
  }

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  // 폼 컨트롤러
  late TextEditingController _titleController;

  // 선택된 값들
  int? _selectedTimeInMinutes;
  String? _selectedCategoryId;

  // 수정 모드 여부
  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    // 수정 모드면 기존 데이터로 초기화
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedTimeInMinutes = widget.task?.timeInMinutes;
    _selectedCategoryId = widget.task?.categoryId;

    AppLogger.d('TaskFormDialog initialized', tag: 'TaskFormDialog');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      AppLogger.w('Form validation failed', tag: 'TaskFormDialog');
      return;
    }

    // 시간 검증
    if (_selectedTimeInMinutes == null) {
      _showError('예상 시간을 선택해주세요');
      return;
    }

    // 카테고리 검증
    if (_selectedCategoryId == null) {
      _showError('카테고리를 선택해주세요');
      return;
    }

    Task savedTask;

    try {
      if (_isEditMode) {
        // 수정 모드
        savedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          timeInMinutes: _selectedTimeInMinutes,
          categoryId: _selectedCategoryId,
        );

        final success = await _taskService.updateTask(savedTask);

        if (!success) {
          _showError('태스크 수정에 실패했습니다.');
          return;
        }

        AppLogger.i('Task updated: ${savedTask.title}', tag: 'TaskFormDialog');
      } else {
        // 추가 모드
        savedTask = await _taskService.addTask(
          title: _titleController.text.trim(),
          timeInMinutes: _selectedTimeInMinutes!,
          categoryId: _selectedCategoryId!,
        );

        AppLogger.i('Task created: ${savedTask.title}', tag: 'TaskFormDialog');
      }

      // 콜백 실행
      widget.onSaved?.call(savedTask);

      // 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop(savedTask);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to save task',
        tag: 'TaskFormDialog',
        error: e,
        stackTrace: stackTrace,
      );
      _showError('태스크 저장 중 오류가 발생했습니다.');
    }
  }

  void _handleCancel() {
    AppLogger.d('Task form cancelled', tag: 'TaskFormDialog');
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        borderRadius: AppSizes.radiusXL,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  _isEditMode
                      ? AppStrings.taskFormTitleEdit
                      : AppStrings.taskFormTitleAdd,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.spaceXL),

                // 태스크 제목 입력
                _buildTitleField(),
                const SizedBox(height: AppSizes.spaceXL),

                // 예상 시간 선택
                _buildTimeSection(),
                const SizedBox(height: AppSizes.spaceXL),

                // 카테고리 선택
                _buildCategorySection(),
                const SizedBox(height: AppSizes.spaceXXL),

                // 액션 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 취소 버튼
                    NeumorphicButton.text(
                      text: AppStrings.btnCancel,
                      onTap: _handleCancel,
                      logTag: 'CancelBtn',
                    ),
                    const SizedBox(width: AppSizes.spaceM),

                    // 저장 버튼
                    NeumorphicButton.text(
                      text: AppStrings.btnSave,
                      textStyle: AppTextStyles.button.copyWith(
                        color: AppColors.accentBlue,
                      ),
                      onTap: _handleSave,
                      logTag: 'SaveBtn',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블
        Row(
          children: [
            Icon(
              Icons.task_alt,
              size: AppSizes.iconS,
              color: AppColors.accentBlue,
            ),
            const SizedBox(width: AppSizes.spaceS),
            Text(AppStrings.taskFormFieldTitle, style: AppTextStyles.labelL),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),

        // 입력 필드
        NeumorphicContainer(
          style: NeumorphicStyle.concave,
          borderRadius: AppSizes.radiusM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingXS,
          ),
          child: TextFormField(
            controller: _titleController,
            style: AppTextStyles.bodyM,
            decoration: InputDecoration(
              hintText: AppStrings.taskFormHintTitle,
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.validationTitleRequired;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: AppSizes.iconS,
              color: AppColors.accentBlue,
            ),
            const SizedBox(width: AppSizes.spaceS),
            Text(AppStrings.taskFormFieldTime, style: AppTextStyles.labelL),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        // TimeSelector
        TimeSelector(
          selectedMinutes: _selectedTimeInMinutes,
          onChanged: (minutes) {
            setState(() {
              _selectedTimeInMinutes = minutes;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블
        Row(
          children: [
            Icon(
              Icons.category,
              size: AppSizes.iconS,
              color: AppColors.accentBlue,
            ),
            const SizedBox(width: AppSizes.spaceS),
            Text(AppStrings.taskFormFieldCategory, style: AppTextStyles.labelL),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        // CategorySelector
        CategorySelector(
          selectedCategoryId: _selectedCategoryId,
          onChanged: (categoryId) {
            setState(() {
              _selectedCategoryId = categoryId;
            });
          },
        ),
      ],
    );
  }
}
