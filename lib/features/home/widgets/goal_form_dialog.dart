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
  String _selectedEmoji = '🎯';
  Color _selectedColor = AppColors.accentBlue;

  // 이모지 목록
  final List<String> _emojiList = [
    '🎯',
    '🏃',
    '📚',
    '💧',
    '🧘',
    '💪',
    '🎨',
    '🎵',
    '✍️',
    '🌱',
    '🍎',
    '😴',
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
      _selectedEmoji = widget.goal!.emoji;
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
      _showError('목표 횟수는 1 이상이어야 합니다');
      return;
    }

    Goal savedGoal;

    try {
      if (_isEditMode) {
        // 수정 모드
        savedGoal = widget.goal!.copyWith(
          emoji: _selectedEmoji,
          title: _titleController.text.trim(),
          total: total,
          colorValue: _selectedColor.value,
        );

        final success = await ref
            .read(goalListProvider.notifier)
            .updateGoal(savedGoal);

        if (!success) {
          _showError('목표 수정에 실패했습니다.');
          return;
        }

        AppLogger.i('Goal updated: ${savedGoal.title}', tag: 'GoalFormDialog');
      } else {
        // 추가 모드
        savedGoal = await ref
            .read(goalListProvider.notifier)
            .addGoal(
              emoji: _selectedEmoji,
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
      _showError('목표 저장 중 오류가 발생했습니다.');
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
                  _isEditMode ? '목표 수정' : '새 목표 추가',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.spaceXL),

                // 이모지 선택
                _buildEmojiSelector(),
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

  Widget _buildEmojiSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('이모지', style: AppTextStyles.labelL),
        const SizedBox(height: AppSizes.spaceM),
        Wrap(
          spacing: AppSizes.spaceM,
          runSpacing: AppSizes.spaceM,
          children: _emojiList.map((emoji) {
            final isSelected = emoji == _selectedEmoji;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEmoji = emoji;
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
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
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
        Text('목표 이름', style: AppTextStyles.labelL),
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
              hintText: '예: Workout, Reading',
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
                return '목표 이름을 입력해주세요';
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
        Text('주간 목표 횟수', style: AppTextStyles.labelL),
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
              hintText: '예: 7',
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
              ),
              suffixText: '회',
              suffixStyle: AppTextStyles.labelM,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '목표 횟수를 입력해주세요';
              }
              final number = int.tryParse(value);
              if (number == null || number <= 0) {
                return '1 이상의 숫자를 입력해주세요';
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
        Text('색상', style: AppTextStyles.labelL),
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
