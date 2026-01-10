// lib/services/local_storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../core/utils/app_logger.dart';
import '../shared/models/task_model.dart';
import '../shared/models/category_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LocalStorageService - 로컬 데이터 저장소 관리
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Hive를 사용한 중앙 집중식 로컬 저장소 관리
///
/// 사용법:
///   await LocalStorageService.init(); // 앱 시작 시 초기화
///   final storage = LocalStorageService();
///   storage.saveTasks(tasks);
///   final tasks = storage.getTasks();
/// ═══════════════════════════════════════════════════════════════════════════

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService _instance = LocalStorageService._();
  factory LocalStorageService() => _instance;

  // Box 이름
  static const String _taskBoxName = 'tasks';
  static const String _categoryBoxName = 'categories';
  static const String _settingsBoxName = 'settings';

  // Box 인스턴스
  late Box<Task> _taskBox;
  late Box<Category> _categoryBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────────────────────────────────

  /// Hive 초기화 (앱 시작 시 한 번만 실행)
  static Future<void> init() async {
    try {
      AppLogger.i('Initializing Hive...', tag: 'LocalStorageService');

      // Hive 초기화
      await Hive.initFlutter();

      // Adapter 등록
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(CategoryAdapter());

      AppLogger.i('Hive initialized successfully', tag: 'LocalStorageService');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Hive initialization failed',
        tag: 'LocalStorageService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Box 열기
  Future<void> openBoxes() async {
    if (_isInitialized) {
      AppLogger.w('Boxes already opened', tag: 'LocalStorageService');
      return;
    }

    try {
      AppLogger.i('Opening Hive boxes...', tag: 'LocalStorageService');

      _taskBox = await Hive.openBox<Task>(_taskBoxName);
      _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      _isInitialized = true;

      AppLogger.i(
        'Boxes opened - Tasks: ${_taskBox.length}, Categories: ${_categoryBox.length}',
        tag: 'LocalStorageService',
      );

      // 카테고리가 없으면 기본 카테고리 추가
      if (_categoryBox.isEmpty) {
        await _initializeDefaultCategories();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to open boxes',
        tag: 'LocalStorageService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 기본 카테고리 초기화
  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = Category.getDefaultCategories();

    for (final category in defaultCategories) {
      await _categoryBox.put(category.id, category);
    }

    AppLogger.i(
      'Default categories initialized: ${defaultCategories.length}',
      tag: 'LocalStorageService',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Task CRUD
  // ─────────────────────────────────────────────────────────────────────────

  /// 모든 태스크 가져오기
  List<Task> getTasks() {
    _checkInitialized();
    return _taskBox.values.toList();
  }

  /// 태스크 저장
  Future<void> saveTask(Task task) async {
    _checkInitialized();
    await _taskBox.put(task.id, task);
    AppLogger.d(
      'Task saved: ${task.title} (ID: ${task.id})',
      tag: 'LocalStorageService',
    );
  }

  /// 태스크 삭제
  Future<void> deleteTask(int taskId) async {
    _checkInitialized();
    await _taskBox.delete(taskId);
    AppLogger.d('Task deleted: ID $taskId', tag: 'LocalStorageService');
  }

  /// 모든 태스크 삭제
  Future<void> clearAllTasks() async {
    _checkInitialized();
    await _taskBox.clear();
    AppLogger.i('All tasks cleared', tag: 'LocalStorageService');
  }

  /// 다음 태스크 ID 생성
  int getNextTaskId() {
    _checkInitialized();
    if (_taskBox.isEmpty) return 1;
    final maxId = _taskBox.keys.cast<int>().reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category CRUD
  // ─────────────────────────────────────────────────────────────────────────

  /// 모든 카테고리 가져오기
  List<Category> getCategories() {
    _checkInitialized();
    return _categoryBox.values.toList();
  }

  /// 카테고리 저장
  Future<void> saveCategory(Category category) async {
    _checkInitialized();
    await _categoryBox.put(category.id, category);
    AppLogger.d('Category saved: ${category.name}', tag: 'LocalStorageService');
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String categoryId) async {
    _checkInitialized();
    await _categoryBox.delete(categoryId);
    AppLogger.d('Category deleted: $categoryId', tag: 'LocalStorageService');
  }

  /// ID로 카테고리 찾기
  Category? getCategoryById(String id) {
    _checkInitialized();
    return _categoryBox.get(id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings
  // ─────────────────────────────────────────────────────────────────────────

  /// 설정 값 가져오기
  T? getSetting<T>(String key, {T? defaultValue}) {
    _checkInitialized();
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// 설정 값 저장
  Future<void> saveSetting<T>(String key, T value) async {
    _checkInitialized();
    await _settingsBox.put(key, value);
    AppLogger.d('Setting saved: $key = $value', tag: 'LocalStorageService');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티
  // ─────────────────────────────────────────────────────────────────────────

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'LocalStorageService not initialized. Call openBoxes() first.',
      );
    }
  }

  /// Box 닫기 (앱 종료 시)
  Future<void> close() async {
    await _taskBox.close();
    await _categoryBox.close();
    await _settingsBox.close();
    _isInitialized = false;
    AppLogger.i('All boxes closed', tag: 'LocalStorageService');
  }

  /// 모든 데이터 삭제 (초기화)
  Future<void> clearAllData() async {
    _checkInitialized();
    await _taskBox.clear();
    await _categoryBox.clear();
    await _settingsBox.clear();
    await _initializeDefaultCategories();
    AppLogger.i('All data cleared and reset', tag: 'LocalStorageService');
  }
}
