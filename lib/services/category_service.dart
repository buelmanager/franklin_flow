// lib/services/category_service.dart

import '../core/utils/app_logger.dart';
import '../shared/models/category_model.dart';
import 'local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CategoryService - 카테고리 관리 비즈니스 로직
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 카테고리 CRUD 관리
/// ═══════════════════════════════════════════════════════════════════════════

class CategoryService {
  CategoryService._();
  static final CategoryService _instance = CategoryService._();
  factory CategoryService() => _instance;

  final _storage = LocalStorageService();

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  /// 모든 카테고리 가져오기
  List<Category> getCategories() {
    return _storage.getCategories();
  }

  /// 기본 카테고리만 가져오기
  List<Category> getDefaultCategories() {
    return getCategories().where((c) => c.isDefault).toList();
  }

  /// 사용자 정의 카테고리만 가져오기
  List<Category> getCustomCategories() {
    return getCategories().where((c) => !c.isDefault).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// 카테고리 추가
  Future<Category> addCategory({
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final newCategory = Category(
      id: id,
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      isDefault: false,
    );

    await _storage.saveCategory(newCategory);

    AppLogger.i('Category added: $name', tag: 'CategoryService');

    return newCategory;
  }

  /// 카테고리 업데이트
  Future<bool> updateCategory(Category category) async {
    try {
      await _storage.saveCategory(category);
      AppLogger.i('Category updated: ${category.name}', tag: 'CategoryService');
      return true;
    } catch (e) {
      AppLogger.e(
        'Failed to update category',
        tag: 'CategoryService',
        error: e,
      );
      return false;
    }
  }

  /// 카테고리 삭제 (기본 카테고리는 삭제 불가)
  Future<bool> deleteCategory(String categoryId) async {
    final category = getCategoryById(categoryId);

    if (category == null) {
      AppLogger.w('Category not found: $categoryId', tag: 'CategoryService');
      return false;
    }

    if (category.isDefault) {
      AppLogger.w('Cannot delete default category', tag: 'CategoryService');
      return false;
    }

    try {
      await _storage.deleteCategory(categoryId);
      AppLogger.i('Category deleted: ${category.name}', tag: 'CategoryService');
      return true;
    } catch (e) {
      AppLogger.e(
        'Failed to delete category',
        tag: 'CategoryService',
        error: e,
      );
      return false;
    }
  }

  /// ID로 카테고리 찾기
  Category? getCategoryById(String id) {
    return _storage.getCategoryById(id);
  }

  /// 이름으로 카테고리 찾기
  Category? getCategoryByName(String name) {
    try {
      return getCategories().firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }
}
