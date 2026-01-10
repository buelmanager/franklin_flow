// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Franklin Flow 앱 컬러 시스템
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 사용법:
///   - 배경색: AppColors.background
///   - 텍스트: AppColors.textPrimary
///   - 액센트: AppColors.accentBlue
///
/// 새로운 색상 추가 시:
///   1. 해당 카테고리에 static const Color 추가
///   2. 주석으로 용도 명시
///   3. 필요시 opacity 버전도 함께 추가
/// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._(); // 인스턴스화 방지

  // ─────────────────────────────────────────────────────────────────────────
  // 뉴모피즘 베이스 컬러
  // ─────────────────────────────────────────────────────────────────────────

  /// 앱 전체 배경색 (따뜻한 크림/베이지 톤)
  static const Color background = Color(0xFFEFEDE9);

  /// 컴포넌트 표면색 (배경과 동일)
  static const Color surface = Color(0xFFF1EFEA);

  /// 카드/컨테이너 배경 (약간 밝은 버전)
  static const Color cardBackground = Color(0xFFF6F4F0);

  // ─────────────────────────────────────────────────────────────────────────
  // 뉴모피즘 그림자 컬러
  // ─────────────────────────────────────────────────────────────────────────

  /// 어두운 그림자 (오른쪽 하단)
  static const Color shadowDark = Color(0xFFBEBDB8);

  /// 밝은 그림자/하이라이트 (왼쪽 상단)
  static const Color shadowLight = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // 텍스트 컬러
  // ─────────────────────────────────────────────────────────────────────────

  /// 주요 텍스트 (제목, 중요 내용)
  static const Color textPrimary = Color(0xFF2D3436);

  /// 보조 텍스트 (부제목, 설명)
  static const Color textSecondary = Color(0xFF636E72);

  /// 비활성/힌트 텍스트
  static const Color textTertiary = Color(0xFFB2BEC3);

  /// 비활성화된 텍스트
  static const Color textDisabled = Color(0xFFCCD1D4);

  // ─────────────────────────────────────────────────────────────────────────
  // 액센트 컬러 (기능/상태 표시용)
  // ─────────────────────────────────────────────────────────────────────────

  /// 주요 액센트 - 파란색 (선택, 활성, 링크)
  static const Color accentBlue = Color(0xFF5B8DEF);

  /// 보조 액센트 - 핑크 (운동, 건강)
  static const Color accentPink = Color(0xFFFF8A9B);

  /// 보조 액센트 - 보라 (독서, 학습)
  static const Color accentPurple = Color(0xFFB19CD9);

  /// 보조 액센트 - 녹색 (완료, 성공)
  static const Color accentGreen = Color(0xFF7ED6A8);

  /// 보조 액센트 - 주황 (진행중, 경고)
  static const Color accentOrange = Color(0xFFFFB067);

  /// 보조 액센트 - 빨강 (삭제, 에러)
  static const Color accentRed = Color(0xFFFF6B6B);

  // ─────────────────────────────────────────────────────────────────────────
  // 상태 컬러
  // ─────────────────────────────────────────────────────────────────────────

  /// 성공 상태
  static const Color success = accentGreen;

  /// 경고 상태
  static const Color warning = accentOrange;

  /// 에러 상태
  static const Color error = accentRed;

  /// 정보 상태
  static const Color info = accentBlue;

  // ─────────────────────────────────────────────────────────────────────────
  // 태스크 상태 컬러
  // ─────────────────────────────────────────────────────────────────────────

  /// 완료된 태스크
  static const Color taskCompleted = accentGreen;

  /// 진행중인 태스크
  static const Color taskInProgress = accentOrange;

  /// 대기중인 태스크
  static const Color taskPending = textTertiary;

  // ─────────────────────────────────────────────────────────────────────────
  // 유틸리티 메서드
  // ─────────────────────────────────────────────────────────────────────────

  /// 색상에 투명도 적용
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// 액센트 컬러의 연한 버전 (배경용)
  static Color accentLight(Color accentColor) {
    return accentColor.withOpacity(0.15);
  }

  /// 태스크 상태에 따른 컬러 반환
  static Color getTaskStatusColor(String status) {
    switch (status) {
      case 'completed':
        return taskCompleted;
      case 'in-progress':
        return taskInProgress;
      case 'pending':
      default:
        return taskPending;
    }
  }
}
