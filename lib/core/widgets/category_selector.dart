// lib/core/widgets/category_selector.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../styles/app_text_styles.dart';
import '../utils/app_logger.dart';
import '../../shared/models/category_model.dart';
import '../../services/category_service.dart';
import 'neumorphic_container.dart';
import 'neumorphic_dialog.dart';
import 'neumorphic_button.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 카테고리 선택 위젯 (드롭다운 버전)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 드롭다운 형식의 카테고리 선택 및 관리
/// - 공간 효율적인 드롭다운 UI
/// - 커스텀 카테고리 삭제 기능
/// - 새 카테고리 추가 기능
///
/// 사용법:
///   CategorySelector(
///     selectedCategoryId: 'work',
///     onChanged: (categoryId) => print('Selected: $categoryId'),
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class CategorySelector extends StatefulWidget {
  /// 선택된 카테고리 ID
  final String? selectedCategoryId;

  /// 카테고리 변경 콜백
  final ValueChanged<String> onChanged;

  const CategorySelector({
    Key? key,
    this.selectedCategoryId,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final _categoryService = CategoryService();
  late String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 이벤트 핸들러
  // ─────────────────────────────────────────────────────────────────────────

  void _handleOpenDropdown() {
    AppLogger.d('Category dropdown opened', tag: 'CategorySelector');
    _showCategoryBottomSheet();
  }

  void _handleCategorySelect(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    widget.onChanged(categoryId);
    Navigator.of(context).pop();

    AppLogger.d('Category selected: $categoryId', tag: 'CategorySelector');
  }

  Future<void> _handleAddCategory() async {
    AppLogger.d('Add category tapped', tag: 'CategorySelector');

    final TextEditingController nameController = TextEditingController();

    final result = await NeumorphicDialog.show<bool>(
      context: context,
      title: '새 카테고리 추가',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeumorphicContainer(
            style: NeumorphicStyle.concave,
            borderRadius: AppSizes.radiusM,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingXS,
            ),
            child: TextField(
              controller: nameController,
              style: AppTextStyles.bodyM,
              decoration: InputDecoration(
                hintText: '카테고리 이름',
                hintStyle: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingS,
                ),
              ),
              autofocus: true,
            ),
          ),
        ],
      ),
      actions: [
        NeumorphicButton.text(
          text: AppStrings.btnCancel,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSizes.spaceM),
        NeumorphicButton.text(
          text: AppStrings.btnSave,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.accentBlue),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      // 랜덤 색상과 아이콘으로 카테고리 추가
      final colors = [
        AppColors.accentBlue.value,
        AppColors.accentPink.value,
        AppColors.accentPurple.value,
        AppColors.accentGreen.value,
        AppColors.accentOrange.value,
      ];

      final icons = [
        Icons.star.codePoint,
        Icons.favorite.codePoint,
        Icons.lightbulb.codePoint,
        Icons.rocket_launch.codePoint,
        Icons.eco.codePoint,
      ];

      final randomColor = colors[DateTime.now().millisecond % colors.length];
      final randomIcon = icons[DateTime.now().millisecond % icons.length];

      final newCategory = await _categoryService.addCategory(
        name: nameController.text.trim(),
        colorValue: randomColor,
        iconCodePoint: randomIcon,
      );

      setState(() {
        _selectedCategoryId = newCategory.id;
      });
      widget.onChanged(newCategory.id);

      AppLogger.i(
        'New category added: ${newCategory.name}',
        tag: 'CategorySelector',
      );
    }

    nameController.dispose();
  }

  Future<void> _handleDeleteCategory(Category category) async {
    AppLogger.d(
      'Delete category tapped: ${category.name}',
      tag: 'CategorySelector',
    );

    final confirmed = await NeumorphicDialog.showConfirm(
      context: context,
      title: '카테고리 삭제',
      message: '${category.name} 카테고리를 삭제하시겠습니까?',
      confirmText: AppStrings.btnDelete,
      cancelText: AppStrings.btnCancel,
    );

    if (confirmed == true) {
      final success = await _categoryService.deleteCategory(category.id);

      if (success) {
        // 삭제된 카테고리가 선택되어 있었다면 선택 해제
        if (_selectedCategoryId == category.id) {
          setState(() {
            _selectedCategoryId = null;
          });
          widget.onChanged('');
        } else {
          setState(() {});
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${category.name} 카테고리가 삭제되었습니다'),
              backgroundColor: AppColors.accentRed,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        AppLogger.i(
          'Category deleted: ${category.name}',
          tag: 'CategorySelector',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카테고리 삭제에 실패했습니다'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _selectedCategoryId != null
        ? _categoryService.getCategoryById(_selectedCategoryId!)
        : null;

    return GestureDetector(
      onTap: _handleOpenDropdown,
      child: NeumorphicContainer(
        style: NeumorphicStyle.concave,
        borderRadius: AppSizes.radiusM,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            // 선택된 카테고리 표시
            if (selectedCategory != null) ...[
              Icon(
                selectedCategory.icon,
                size: AppSizes.iconS,
                color: selectedCategory.color,
              ),
              const SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: Text(
                  selectedCategory.name,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  '카테고리를 선택하세요',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],

            // 드롭다운 아이콘
            Icon(
              Icons.keyboard_arrow_down,
              size: AppSizes.iconM,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CategoryBottomSheet(
        selectedCategoryId: _selectedCategoryId,
        onCategorySelect: _handleCategorySelect,
        onAddCategory: _handleAddCategory,
        onDeleteCategory: _handleDeleteCategory,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 카테고리 선택 BottomSheet
/// ═══════════════════════════════════════════════════════════════════════════

class _CategoryBottomSheet extends StatefulWidget {
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelect;
  final VoidCallback onAddCategory;
  final Function(Category) onDeleteCategory;

  const _CategoryBottomSheet({
    Key? key,
    this.selectedCategoryId,
    required this.onCategorySelect,
    required this.onAddCategory,
    required this.onDeleteCategory,
  }) : super(key: key);

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  final _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    final categories = _categoryService.getCategories();

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

          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('카테고리 선택', style: AppTextStyles.heading3),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onAddCategory();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.add,
                      size: AppSizes.iconS,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 리스트
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
              itemCount: categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.spaceS),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = widget.selectedCategoryId == category.id;

                return _buildCategoryItem(category, isSelected);
              },
            ),
          ),

          const SizedBox(height: AppSizes.paddingXL),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onCategorySelect(category.id),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        style: isSelected ? NeumorphicStyle.concave : NeumorphicStyle.flat,
        child: Row(
          children: [
            // 아이콘
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

            // 카테고리 이름
            Expanded(
              child: Text(
                category.name,
                style: AppTextStyles.bodyM.copyWith(
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),

            // 선택 표시 또는 삭제 버튼
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: AppSizes.iconM,
                color: AppColors.accentBlue,
              )
            else if (!category.isDefault)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDeleteCategory(category);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingXS),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: AppSizes.iconS,
                    color: AppColors.accentRed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
