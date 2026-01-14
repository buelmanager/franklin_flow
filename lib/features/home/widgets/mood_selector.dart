// lib/features/home/widgets/mood_selector.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 기분 선택기 (Mood Selector)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 저녁 성찰에서 오늘의 기분을 선택하는 위젯
/// - 5가지 기분 이모지
/// - 선택 시 하이라이트
/// - 기분별 레이블 표시
///
/// 사용법:
///   MoodSelector(
///     selectedMood: 'happy',
///     onMoodSelected: (mood) { ... },
///   )
/// ═══════════════════════════════════════════════════════════════════════════

/// 기분 타입 정의
enum MoodType {
  veryHappy('very_happy', '😄', '최고예요', Color(0xFF4CAF50)),
  happy('happy', '😊', '좋아요', Color(0xFF8BC34A)),
  neutral('neutral', '😐', '그냥 그래요', Color(0xFFFFB74D)),
  sad('sad', '😢', '별로예요', Color(0xFF64B5F6)),
  tired('tired', '😴', '피곤해요', Color(0xFF9575CD));

  final String value;
  final String emoji;
  final String label;
  final Color color;

  const MoodType(this.value, this.emoji, this.label, this.color);

  static MoodType? fromValue(String? value) {
    if (value == null) return null;
    return MoodType.values.firstWhere(
      (m) => m.value == value,
      orElse: () => MoodType.neutral,
    );
  }
}

class MoodSelector extends StatelessWidget {
  /// 선택된 기분 값
  final String? selectedMood;

  /// 기분 선택 콜백
  final void Function(String mood)? onMoodSelected;

  /// 라벨 표시 여부
  final bool showLabels;

  /// 크기 (small, medium, large)
  final MoodSelectorSize size;

  const MoodSelector({
    Key? key,
    this.selectedMood,
    this.onMoodSelected,
    this.showLabels = true,
    this.size = MoodSelectorSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.d(
      'MoodSelector build - selected: $selectedMood',
      tag: 'MoodSelector',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Text(AppStrings.moodTitle, style: AppTextStyles.heading3),
        const SizedBox(height: AppSizes.spaceL),

        // 기분 선택 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MoodType.values.map((mood) {
            return _buildMoodButton(mood);
          }).toList(),
        ),

        // 선택된 기분 레이블
        if (showLabels && selectedMood != null) ...[
          const SizedBox(height: AppSizes.spaceM),
          Center(child: _buildSelectedMoodLabel()),
        ],
      ],
    );
  }

  /// 기분 버튼
  Widget _buildMoodButton(MoodType mood) {
    final isSelected = selectedMood == mood.value;
    final emojiSize = _getEmojiSize();
    final buttonSize = _getButtonSize();

    return GestureDetector(
      onTap: () {
        onMoodSelected?.call(mood.value);
        AppLogger.ui('Mood selected: ${mood.value}', screen: 'MoodSelector');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: isSelected
              ? mood.color.withOpacity(0.2)
              : AppColors.background,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          border: Border.all(
            color: isSelected
                ? mood.color
                : AppColors.textTertiary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mood.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(mood.emoji, style: TextStyle(fontSize: emojiSize)),
        ),
      ),
    );
  }

  /// 선택된 기분 레이블
  Widget _buildSelectedMoodLabel() {
    final mood = MoodType.fromValue(selectedMood);
    if (mood == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: mood.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSizes.spaceS),
          Text(
            mood.label,
            style: AppTextStyles.bodyM.copyWith(
              color: mood.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _getEmojiSize() {
    switch (size) {
      case MoodSelectorSize.small:
        return 20;
      case MoodSelectorSize.medium:
        return 28;
      case MoodSelectorSize.large:
        return 36;
    }
  }

  double _getButtonSize() {
    switch (size) {
      case MoodSelectorSize.small:
        return 44;
      case MoodSelectorSize.medium:
        return 56;
      case MoodSelectorSize.large:
        return 68;
    }
  }
}

enum MoodSelectorSize { small, medium, large }

/// 컴팩트 버전 (홈 화면용)
class MoodSelectorCompact extends StatelessWidget {
  final String? selectedMood;
  final void Function(String mood)? onMoodSelected;

  const MoodSelectorCompact({Key? key, this.selectedMood, this.onMoodSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: MoodType.values.map((mood) {
        final isSelected = selectedMood == mood.value;

        return GestureDetector(
          onTap: () => onMoodSelected?.call(mood.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? mood.color.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? mood.color
                      : AppColors.textTertiary.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  mood.emoji,
                  style: TextStyle(fontSize: isSelected ? 18 : 16),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
