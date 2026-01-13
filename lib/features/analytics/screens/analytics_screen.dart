// lib/features/analytics/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 분석 화면 (Analytics Screen)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 프랭클린 철학 기반 생산성 분석
/// - 상단 요약 통계 (완료, 집중 시간, 스트릭)
/// - 현재 연속 실천 현황
/// - 주간 완료율 차트
/// - 카테고리별 분석
/// - AI 인사이트
///
/// ═══════════════════════════════════════════════════════════════════════════

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  // 임시 데이터 (나중에 Provider로 대체)
  final int _totalCompleted = 47;
  final int _totalFocusMinutes = 1260;
  final int _currentStreak = 7;
  final int _bestStreak = 14;
  final List<double> _weeklyData = [0.8, 0.6, 1.0, 0.4, 0.9, 0.7, 0.5];
  final Map<String, double> _categoryData = {
    '업무': 0.45,
    '개인': 0.25,
    '운동': 0.15,
    '학습': 0.15,
  };

  @override
  Widget build(BuildContext context) {
    AppLogger.d('AnalyticsScreen build', tag: 'AnalyticsScreen');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),
          const SizedBox(height: AppSizes.spaceXL),

          // 상단 요약 카드들
          _buildSummaryCards(),
          const SizedBox(height: AppSizes.spaceXL),

          // 현재 연속 실천 카드
          _buildStreakCard(),
          const SizedBox(height: AppSizes.spaceXL),

          // 주간 완료율 차트
          _buildWeeklyChart(),
          const SizedBox(height: AppSizes.spaceXL),

          // 카테고리별 분석
          _buildCategoryAnalysis(),
          const SizedBox(height: AppSizes.spaceXL),

          // AI 인사이트
          _buildInsightCard(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(
            Icons.insights_rounded,
            size: AppSizes.iconL,
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.navAnalytics, style: AppTextStyles.heading2),
            Text(
              '나의 실천 기록',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 상단 요약 카드들
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.accentGreen,
            value: '$_totalCompleted',
            label: AppStrings.analyticsTotalTasks,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.timer_rounded,
            iconColor: AppColors.accentBlue,
            value: _formatFocusTime(_totalFocusMinutes),
            label: AppStrings.analyticsTotalFocus,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.accentOrange,
            value: '$_bestStreak${AppStrings.streakDaySuffix}',
            label: AppStrings.analyticsBestStreak,
          ),
        ),
      ],
    );
  }

  /// 미니 통계 카드
  Widget _buildMiniStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 연속 실천 카드
  Widget _buildStreakCard() {
    final streakMessage = _getStreakMessage(_currentStreak);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.analyticsCurrentStreak,
                      style: AppTextStyles.labelM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_currentStreak',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.analyticsDaysInRow,
                          style: AppTextStyles.bodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 최고 기록 배지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.analyticsBestRecord,
                      style: AppTextStyles.labelS.copyWith(
                        color: AppColors.accentPurple,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$_bestStreak${AppStrings.streakDaySuffix}',
                      style: AppTextStyles.labelM.copyWith(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
          // 응원 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              streakMessage,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 주간 완료율 차트
  Widget _buildWeeklyChart() {
    final weekAverage =
        _weeklyData.reduce((a, b) => a + b) / _weeklyData.length;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.analyticsWeeklyProgress,
                style: AppTextStyles.heading4,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                ),
                child: Text(
                  '${AppStrings.analyticsAverage} ${(weekAverage * 100).toInt()}%',
                  style: AppTextStyles.labelS.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          // 막대 차트
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = _weeklyData[index];
                final isToday = index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 퍼센트 표시
                        Text(
                          '${(value * 100).toInt()}%',
                          style: AppTextStyles.labelS.copyWith(
                            color: isToday
                                ? AppColors.accentBlue
                                : AppColors.textTertiary,
                            fontSize: 9,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 막대
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: constraints.maxHeight * value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: isToday
                                          ? [
                                              AppColors.accentBlue,
                                              AppColors.accentBlue.withOpacity(
                                                0.6,
                                              ),
                                            ]
                                          : [
                                              AppColors.accentGreen.withOpacity(
                                                0.8,
                                              ),
                                              AppColors.accentGreen.withOpacity(
                                                0.4,
                                              ),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        // 요일
                        Text(
                          AppStrings.weekdaysKor[index],
                          style: AppTextStyles.labelS.copyWith(
                            color: isToday
                                ? AppColors.accentBlue
                                : AppColors.textTertiary,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 분석
  Widget _buildCategoryAnalysis() {
    final sortedCategories = _categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryColors = [
      AppColors.accentBlue,
      AppColors.accentGreen,
      AppColors.accentOrange,
      AppColors.accentPurple,
    ];

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.analyticsByCategory, style: AppTextStyles.heading4),
          const SizedBox(height: AppSizes.spaceL),
          // 도넛 차트 대신 프로그레스 바 스타일
          ...sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final color = categoryColors[index % categoryColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            category.key,
                            style: AppTextStyles.bodyS.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(category.value * 100).toInt()}%',
                        style: AppTextStyles.labelM.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: category.value,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// AI 인사이트 카드
  Widget _buildInsightCard() {
    final insights = [
      AppStrings.analyticsInsight1,
      AppStrings.analyticsInsight2,
      AppStrings.analyticsInsight3,
    ];

    // 랜덤하게 하나 선택 (실제로는 분석 기반으로)
    final todayInsight = insights[DateTime.now().day % insights.length];

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentPurple, AppColors.accentBlue],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text(AppStrings.analyticsInsight, style: AppTextStyles.heading4),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                ),
                child: Text(
                  'AI',
                  style: AppTextStyles.labelS.copyWith(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPurple.withOpacity(0.08),
                  AppColors.accentBlue.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.accentPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Text(
                    todayInsight,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 집중 시간 포맷팅
  String _formatFocusTime(int minutes) {
    if (minutes < 60) {
      return '$minutes${AppStrings.focusMinuteSuffix}';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours시간';
    }
    return '$hours시간 $mins분';
  }

  /// 스트릭 메시지
  String _getStreakMessage(int streak) {
    if (streak == 0) return AppStrings.streakMessageStart;
    if (streak == 1) return AppStrings.streakMessageDay1;
    if (streak <= 3) return AppStrings.streakMessageDay2;
    if (streak <= 7) return AppStrings.streakMessageWeek;
    if (streak <= 14) return AppStrings.streakMessageTwoWeeks;
    if (streak <= 30) return AppStrings.streakMessageMonth;
    return AppStrings.streakMessageLegend;
  }
}
