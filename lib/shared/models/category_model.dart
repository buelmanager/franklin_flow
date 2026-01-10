// lib/shared/models/category_model.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_colors.dart';

part 'category_model.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Category 데이터 모델
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 태스크 카테고리 정보
/// Hive를 사용한 로컬 저장
/// ═══════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.isDefault = false,
  });

  /// Color 객체 getter
  Color get color => Color(colorValue);

  /// IconData 객체 getter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// 복사본 생성
  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// 기본 카테고리 목록
  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'work',
        name: '업무',
        colorValue: AppColors.accentBlue.value,
        iconCodePoint: Icons.work_outline.codePoint,
        isDefault: true,
      ),
      Category(
        id: 'personal',
        name: '개인',
        colorValue: AppColors.accentPurple.value,
        iconCodePoint: Icons.person_outline.codePoint,
        isDefault: true,
      ),
      Category(
        id: 'exercise',
        name: '운동',
        colorValue: AppColors.accentPink.value,
        iconCodePoint: Icons.fitness_center.codePoint,
        isDefault: true,
      ),
      Category(
        id: 'study',
        name: '학습',
        colorValue: AppColors.accentGreen.value,
        iconCodePoint: Icons.school_outlined.codePoint,
        isDefault: true,
      ),
      Category(
        id: 'etc',
        name: '기타',
        colorValue: AppColors.accentOrange.value,
        iconCodePoint: Icons.more_horiz.codePoint,
        isDefault: true,
      ),
    ];
  }
}
