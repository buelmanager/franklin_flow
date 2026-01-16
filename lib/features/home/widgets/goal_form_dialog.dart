// lib/features/home/widgets/goal_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../shared/models/goal_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 목표 추가/수정 폼 다이얼로그
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 주간 목표 생성 및 수정을 위한 폼 다이얼로그
///
/// 사용법:
///   // 새 목표 추가
///   GoalFormDialog.show(context: context);
///
///   // 기존 목표 수정
///   GoalFormDialog.show(context: context, goal: existingGoal);
/// ═══════════════════════════════════════════════════════════════════════════

class GoalFormDialog extends ConsumerStatefulWidget {
  /// 수정할 목표 (null이면 새로 추가)
  final Goal? goal;

  /// 저장 완료 콜백
  final Function(Goal)? onSaved;

  const GoalFormDialog({Key? key, this.goal, this.onSaved}) : super(key: key);

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<Goal?> show({
    required BuildContext context,
    Goal? goal,
    Function(Goal)? onSaved,
  }) {
    AppLogger.d(
      goal == null ? 'Opening add goal dialog' : 'Opening edit goal dialog',
      tag: 'GoalFormDialog',
    );

    return showDialog<Goal>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.shadowDark.withOpacity(0.3),
      builder: (context) => GoalFormDialog(goal: goal, onSaved: onSaved),
    );
  }

  @override
  ConsumerState<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends ConsumerState<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // 폼 컨트롤러
  late TextEditingController _titleController;
  late TextEditingController _totalController;

  // 선택된 값들
  int _selectedIconCodePoint = Icons.flag_rounded.codePoint;
  Color _selectedColor = AppColors.accentBlue;

  // 아이콘 목록
  final List<IconData> _iconList = [
    Icons.flag_rounded,
    Icons.directions_run_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.fitness_center_rounded,
    Icons.palette_rounded,
    Icons.music_note_rounded,
    Icons.edit_rounded,
    Icons.eco_rounded,
    Icons.restaurant_rounded,
    Icons.bedtime_rounded,
  ];

  // 색상 목록
  final List<Color> _colorList = [
    AppColors.accentBlue,
    AppColors.accentPink,
    AppColors.accentPurple,
    AppColors.accentGreen,
    AppColors.accentOrange,
    AppColors.accentRed,
  ];

  // 수정 모드 여부
  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();

    // 수정 모드면 기존 데이터로 초기화
    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.goal!.title);
      _totalController = TextEditingController(
        text: widget.goal!.total.toString(),
      );
      _selectedIconCodePoint = widget.goal!.iconCodePoint;
      _selectedColor = widget.goal!.color;
    } else {
      _titleController = TextEditingController();
      _totalController = TextEditingController(text: '7');
    }

    AppLogger.d('GoalFormDialog initialized', tag: 'GoalFormDialog');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      AppLogger.w('Form validation failed', tag: 'GoalFormDialog');
      return;
    }

    final total = int.tryParse(_totalController.text);
    if (total == null || total <= 0) {
      _showError(AppStrings.goalValidationTotalInvalid);
      return;
    }

    Goal savedGoal;

    try {
      if (_isEditMode) {
        // 수정 모드
        savedGoal = widget.goal!.copyWith(
          iconCodePoint: _selectedIconCodePoint,
          title: _titleController.text.trim(),
          total: total,
          colorValue: _selectedColor.value,
        );

        final success = await ref
            .read(goalListProvider.notifier)
            .updateGoal(savedGoal);

        if (!success) {
          _showError(AppStrings.goalErrorUpdateFailed);
          return;
        }

        AppLogger.i('Goal updated: ${savedGoal.title}', tag: 'GoalFormDialog');
      } else {
        // 추가 모드
        savedGoal = await ref
            .read(goalListProvider.notifier)
            .addGoal(
              iconCodePoint: _selectedIconCodePoint,
              title: _titleController.text.trim(),
              total: total,
              colorValue: _selectedColor.value,
            );

        AppLogger.i('Goal created: ${savedGoal.title}', tag: 'GoalFormDialog');
      }

      // 콜백 실행
      widget.onSaved?.call(savedGoal);

      // 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop(savedGoal);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to save goal',
        tag: 'GoalFormDialog',
        error: e,
        stackTrace: stackTrace,
      );
      _showError(AppStrings.goalErrorSaveFailed);
    }
  }

  void _handleCancel() {
    AppLogger.d('Goal form cancelled', tag: 'GoalFormDialog');
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
                      ? AppStrings.goalFormTitleEdit
                      : AppStrings.goalFormTitleAdd,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.spaceXL),

                // 아이콘 선택
                _buildIconSelector(),
                const SizedBox(height: AppSizes.spaceXL),

                // 목표 이름 입력
                _buildTitleField(),
                const SizedBox(height: AppSizes.spaceXL),

                // 목표 횟수 입력
                _buildTotalField(),
                const SizedBox(height: AppSizes.spaceXL),

                // 색상 선택
                _buildColorSelector(),
                const SizedBox(height: AppSizes.spaceXXL),

                // 액션 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NeumorphicButton.text(
                      text: AppStrings.btnCancel,
                      onTap: _handleCancel,
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    NeumorphicButton.text(
                      text: AppStrings.btnSave,
                      textStyle: AppTextStyles.button.copyWith(
                        color: AppColors.accentBlue,
                      ),
                      onTap: _handleSave,
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

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.goalFormFieldIcon, style: AppTextStyles.labelL),
        const SizedBox(height: AppSizes.spaceM),
        Wrap(
          spacing: AppSizes.spaceM,
          runSpacing: AppSizes.spaceM,
          children: _iconList.map((icon) {
            final isSelected = icon.codePoint == _selectedIconCodePoint;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIconCodePoint = icon.codePoint;
                });
              },
              child: NeumorphicContainer(
                width: 50,
                height: 50,
                borderRadius: AppSizes.radiusM,
                style: isSelected
                    ? NeumorphicStyle.concave
                    : NeumorphicStyle.flat,
                child: Center(
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? _selectedColor
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.goalFormFieldName, style: AppTextStyles.labelL),
        const SizedBox(height: AppSizes.spaceM),
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
              hintText: AppStrings.goalFormHintName,
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
                return AppStrings.goalValidationNameRequired;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.goalFormFieldTotal, style: AppTextStyles.labelL),
        const SizedBox(height: AppSizes.spaceM),
        NeumorphicContainer(
          style: NeumorphicStyle.concave,
          borderRadius: AppSizes.radiusM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingXS,
          ),
          child: TextFormField(
            controller: _totalController,
            style: AppTextStyles.bodyM,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              hintText: AppStrings.goalFormHintTotal,
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
              ),
              suffixText: AppStrings.goalFormSuffixTotal,
              suffixStyle: AppTextStyles.labelM,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.goalValidationTotalRequired;
              }
              final number = int.tryParse(value);
              if (number == null || number <= 0) {
                return AppStrings.goalValidationTotalInvalid;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.goalFormFieldColor, style: AppTextStyles.labelL),
        const SizedBox(height: AppSizes.spaceM),
        Wrap(
          spacing: AppSizes.spaceM,
          runSpacing: AppSizes.spaceM,
          children: _colorList.map((color) {
            final isSelected = color.value == _selectedColor.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: NeumorphicContainer(
                width: 50,
                height: 50,
                borderRadius: AppSizes.radiusM,
                style: isSelected
                    ? NeumorphicStyle.concave
                    : NeumorphicStyle.flat,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppSizes.iconS,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
