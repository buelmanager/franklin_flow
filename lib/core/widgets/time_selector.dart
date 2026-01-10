// lib/core/widgets/time_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_logger.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 시간 선택 위젯 (최종 개선 버전)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 간단한 증가 버튼 방식의 시간 선택기
/// - +30분, +1시간 버튼: 누를 때마다 시간 증가
/// - 직접입력: 커스텀 시간 입력
/// - 초기화: 시간 디스플레이 영역에 작은 아이콘으로 표시
///
/// 사용법:
///   TimeSelector(
///     selectedMinutes: 60,
///     onChanged: (minutes) => print('Selected: $minutes minutes'),
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class TimeSelector extends StatefulWidget {
  /// 선택된 시간 (분)
  final int? selectedMinutes;

  /// 시간 변경 콜백
  final ValueChanged<int> onChanged;

  const TimeSelector({Key? key, this.selectedMinutes, required this.onChanged})
    : super(key: key);

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late int _currentMinutes;
  bool _isCustomMode = false;
  final TextEditingController _customController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentMinutes = widget.selectedMinutes ?? 0;
    _customController.text = _currentMinutes > 0
        ? _currentMinutes.toString()
        : '';

    AppLogger.d(
      'TimeSelector initialized: $_currentMinutes minutes',
      tag: 'TimeSelector',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleAdd30Minutes() {
    setState(() {
      _currentMinutes += 30;
      _isCustomMode = false;
      _customController.text = _currentMinutes.toString();
    });
    widget.onChanged(_currentMinutes);

    AppLogger.d(
      'Added 30 minutes: $_currentMinutes minutes total',
      tag: 'TimeSelector',
    );
  }

  void _handleAdd1Hour() {
    setState(() {
      _currentMinutes += 60;
      _isCustomMode = false;
      _customController.text = _currentMinutes.toString();
    });
    widget.onChanged(_currentMinutes);

    AppLogger.d(
      'Added 1 hour: $_currentMinutes minutes total',
      tag: 'TimeSelector',
    );
  }

  void _handleCustomMode() {
    setState(() {
      _isCustomMode = true;
    });

    // 입력 필드에 포커스
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });

    AppLogger.d('Custom input mode enabled', tag: 'TimeSelector');
  }

  void _handleReset() {
    setState(() {
      _currentMinutes = 0;
      _isCustomMode = false;
      _customController.clear();
    });
    widget.onChanged(0);

    AppLogger.d('Time reset to 0', tag: 'TimeSelector');
  }

  void _handleCustomInput(String value) {
    if (value.isEmpty) {
      setState(() => _currentMinutes = 0);
      widget.onChanged(0);
      return;
    }

    final minutes = int.tryParse(value);
    if (minutes != null && minutes >= 0) {
      setState(() {
        _currentMinutes = minutes;
      });
      widget.onChanged(minutes);

      AppLogger.d('Custom time entered: $minutes minutes', tag: 'TimeSelector');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI 헬퍼
  // ─────────────────────────────────────────────────────────────────────────

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '시간을 선택하세요';

    if (minutes < 60) {
      return '$minutes분';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60}시간';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours시간 $mins분';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 선택된 시간 표시 (리셋 버튼 포함)
        _buildTimeDisplay(),
        const SizedBox(height: AppSizes.spaceXL),

        // 3개 버튼 (1줄)
        Row(
          children: [
            // +30분 버튼
            Expanded(child: _buildAddButton('+30분', _handleAdd30Minutes)),
            const SizedBox(width: AppSizes.spaceM),

            // +1시간 버튼
            Expanded(child: _buildAddButton('+1시간', _handleAdd1Hour)),
            const SizedBox(width: AppSizes.spaceM),

            // 직접입력 버튼
            Expanded(child: _buildCustomButton()),
          ],
        ),

        // 커스텀 입력 필드 (직접입력 모드일 때만 표시)
        if (_isCustomMode) ...[
          const SizedBox(height: AppSizes.spaceL),
          _buildCustomInput(),
        ],
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return NeumorphicContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      style: NeumorphicStyle.concave,
      borderRadius: AppSizes.radiusL,
      child: Row(
        children: [
          // 시간 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMinutes(_currentMinutes),
                  style: AppTextStyles.heading3.copyWith(
                    color: _currentMinutes > 0
                        ? AppColors.accentBlue
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_currentMinutes > 0) ...[
                  const SizedBox(height: AppSizes.spaceXS),
                  Text('총 $_currentMinutes분', style: AppTextStyles.caption),
                ],
              ],
            ),
          ),

          // 작은 리셋 버튼
          if (_currentMinutes > 0)
            GestureDetector(
              onTap: _handleReset,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.refresh,
                  size: AppSizes.iconS,
                  color: AppColors.accentRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
        borderRadius: AppSizes.radiusM,
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelL.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton() {
    return GestureDetector(
      onTap: _handleCustomMode,
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
        borderRadius: AppSizes.radiusM,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: AppSizes.iconS,
                color: _isCustomMode
                    ? AppColors.accentBlue
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.spaceXS),
              Text(
                '직접입력',
                style: AppTextStyles.labelL.copyWith(
                  color: _isCustomMode
                      ? AppColors.accentBlue
                      : AppColors.textPrimary,
                  fontWeight: _isCustomMode ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInput() {
    return NeumorphicContainer(
      style: NeumorphicStyle.concave,
      borderRadius: AppSizes.radiusM,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customController,
              focusNode: _focusNode,
              style: AppTextStyles.bodyM,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4), // 최대 9999분
              ],
              decoration: InputDecoration(
                hintText: '시간을 분 단위로 입력 (예: 45)',
                hintStyle: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingS,
                ),
              ),
              onChanged: _handleCustomInput,
            ),
          ),
          Text(
            '분',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
