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
  @override
  Widget build(BuildContext context) {
    // Provider에서 실제 데이터 가져오기
    final totalCompleted = ref.watch(totalCompletedTasksProvider);
    final totalFocusMinutes = ref.watch(totalFocusMinutesProvider);
    final currentStreak = ref.watch(streakDaysProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final weeklyData = ref.watch(weeklyCompletionDataProvider);
    final categoryData = ref.watch(categoryAnalyticsProvider);
    final taskIntentionData = ref.watch(taskIntentionAnalyticsProvider);
    final goalData = ref.watch(goalAnalyticsProvider);

    AppLogger.d(
      'AnalyticsScreen build - completed: $totalCompleted, focus: $totalFocusMinutes, streak: $currentStreak',
      tag: 'AnalyticsScreen',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),
          const SizedBox(height: AppSizes.spaceXL),

          // 상단 요약 카드들
          _buildSummaryCards(
            totalCompleted: totalCompleted,
            totalFocusMinutes: totalFocusMinutes,
            bestStreak: bestStreak,
          ),
          const SizedBox(height: AppSizes.spaceXL),

          // 현재 연속 실천 카드
          _buildStreakCard(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
          ),
          const SizedBox(height: AppSizes.spaceXL),

          // 할일/다짐 상세 분석
          _buildTaskIntentionAnalysis(data: taskIntentionData),
          const SizedBox(height: AppSizes.spaceXL),

          // 주 목표 분석
          _buildGoalAnalysis(data: goalData),
          const SizedBox(height: AppSizes.spaceXL),

          // 주간 완료율 차트
          _buildWeeklyChart(weeklyData: weeklyData),
          const SizedBox(height: AppSizes.spaceXL),

          // 카테고리별 분석
          _buildCategoryAnalysis(categoryData: categoryData),
          const SizedBox(height: AppSizes.spaceXL),

          // AI 인사이트
          _buildInsightCard(
            totalCompleted: totalCompleted,
            currentStreak: currentStreak,
          ),

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
  Widget _buildSummaryCards({
    required int totalCompleted,
    required int totalFocusMinutes,
    required int bestStreak,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.accentGreen,
            value: '$totalCompleted',
            label: AppStrings.analyticsTotalTasks,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.timer_rounded,
            iconColor: AppColors.accentBlue,
            value: _formatFocusTime(totalFocusMinutes),
            label: AppStrings.analyticsTotalFocus,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.accentOrange,
            value: '$bestStreak${AppStrings.streakDaySuffix}',
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
  Widget _buildStreakCard({
    required int currentStreak,
    required int bestStreak,
  }) {
    final streakMessage = _getStreakMessage(currentStreak);

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
                  color: AppColors.accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 24,
                  color: AppColors.accentOrange,
                ),
              ),
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
                          '$currentStreak',
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
                      '$bestStreak${AppStrings.streakDaySuffix}',
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
  Widget _buildWeeklyChart({required List<double> weeklyData}) {
    final weekAverage = weeklyData.isEmpty
        ? 0.0
        : weeklyData.reduce((a, b) => a + b) / weeklyData.length;

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
                final value = index < weeklyData.length ? weeklyData[index] : 0.0;
                // weeklyData는 6일 전부터 오늘까지이므로, 마지막 인덱스(6)가 오늘
                final isToday = index == 6;

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
                        // 요일 (6일 전부터 오늘까지)
                        Text(
                          _getWeekdayLabel(index),
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

  /// 주간 차트 요일 라벨
  String _getWeekdayLabel(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    final weekday = date.weekday; // 1=월, 7=일
    return AppStrings.weekdaysKor[weekday - 1];
  }

  /// 카테고리별 분석
  Widget _buildCategoryAnalysis({required Map<String, double> categoryData}) {
    final sortedCategories = categoryData.entries.toList()
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
          // 데이터가 없으면 빈 상태 표시
          if (sortedCategories.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 40,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    '완료한 할 일이 없어요',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
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
  Widget _buildInsightCard({
    required int totalCompleted,
    required int currentStreak,
  }) {
    // 실제 데이터 기반으로 인사이트 생성
    final String todayInsight;

    if (totalCompleted == 0 && currentStreak == 0) {
      todayInsight = '첫 번째 할 일을 완료하고 여정을 시작해보세요! 작은 시작이 큰 변화를 만듭니다.';
    } else if (currentStreak >= 7) {
      todayInsight = '$currentStreak일 연속 실천 중이에요! 꾸준함이 습관을 만들고, 습관이 성공을 만듭니다.';
    } else if (currentStreak >= 3) {
      todayInsight = '좋은 흐름이에요! $currentStreak일째 연속 실천 중입니다. 이 페이스를 유지해보세요.';
    } else if (totalCompleted >= 10) {
      todayInsight = '총 $totalCompleted개의 할 일을 완료했어요! 프랭클린처럼 매일 조금씩 발전하고 있습니다.';
    } else {
      final insights = [
        AppStrings.analyticsInsight1,
        AppStrings.analyticsInsight2,
        AppStrings.analyticsInsight3,
      ];
      todayInsight = insights[DateTime.now().day % insights.length];
    }

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
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: AppColors.accentOrange,
                ),
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

  /// 할일/다짐 상세 분석
  Widget _buildTaskIntentionAnalysis({required Map<String, dynamic> data}) {
    final totalTasks = data['totalTasks'] as int;
    final completedTasks = data['completedTasks'] as int;
    final pendingTasks = data['pendingTasks'] as int;
    final inProgressTasks = data['inProgressTasks'] as int;
    final taskCompletionRate = data['taskCompletionRate'] as int;
    final totalIntentionDays = data['totalIntentionDays'] as int;
    final totalIntentions = data['totalIntentions'] as int;
    final completedIntentions = data['completedIntentions'] as int;
    final intentionCompletionRate = data['intentionCompletionRate'] as int;

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
                  color: AppColors.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 18,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text('할일 & 다짐 분석', style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),

          // 할일 통계
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '할일 현황',
                      style: AppTextStyles.labelM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      ),
                      child: Text(
                        '완료율 $taskCompletionRate%',
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceM),
                Row(
                  children: [
                    _buildStatChip(
                      label: '전체',
                      value: '$totalTasks',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    _buildStatChip(
                      label: '완료',
                      value: '$completedTasks',
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    _buildStatChip(
                      label: '진행중',
                      value: '$inProgressTasks',
                      color: AppColors.accentBlue,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    _buildStatChip(
                      label: '대기',
                      value: '$pendingTasks',
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),

          // 다짐 통계 (최근 7일)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '오늘의 다짐 (최근 7일)',
                      style: AppTextStyles.labelM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      ),
                      child: Text(
                        '달성률 $intentionCompletionRate%',
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceM),
                Row(
                  children: [
                    _buildStatChip(
                      label: '다짐 설정',
                      value: '$totalIntentionDays일',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    _buildStatChip(
                      label: '총 다짐',
                      value: '$totalIntentions',
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    _buildStatChip(
                      label: '달성',
                      value: '$completedIntentions',
                      color: AppColors.accentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 칩
  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 주 목표 분석
  Widget _buildGoalAnalysis({required Map<String, dynamic> data}) {
    final weekGoals = data['weekGoals'] as int;
    final completedGoals = data['completedGoals'] as int;
    final goalCompletionRate = data['goalCompletionRate'] as int;
    final totalProgress = data['totalProgress'] as int;
    final goalDetails = data['goalDetails'] as List<dynamic>;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: AppColors.accentPurple,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  Text('이번 주 목표', style: AppTextStyles.heading4),
                ],
              ),
              if (weekGoals > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: goalCompletionRate >= 100
                        ? AppColors.accentGreen.withOpacity(0.15)
                        : AppColors.accentPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  ),
                  child: Text(
                    '$completedGoals/$weekGoals 완료',
                    style: AppTextStyles.labelS.copyWith(
                      color: goalCompletionRate >= 100
                          ? AppColors.accentGreen
                          : AppColors.accentPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),

          if (weekGoals == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 40,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    '이번 주 목표가 없어요',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // 전체 진행률
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '전체 진행률',
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalProgress / 100,
                          backgroundColor:
                              AppColors.accentPurple.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            totalProgress >= 100
                                ? AppColors.accentGreen
                                : AppColors.accentPurple,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),
                Text(
                  '$totalProgress%',
                  style: AppTextStyles.heading3.copyWith(
                    color: totalProgress >= 100
                        ? AppColors.accentGreen
                        : AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 개별 목표 리스트
            ...goalDetails.map((goal) {
              final iconCodePoint = goal['iconCodePoint'] as int;
              final title = goal['title'] as String;
              final current = goal['current'] as int;
              final total = goal['total'] as int;
              final progress = goal['progress'] as int;
              final isCompleted = goal['isCompleted'] as bool;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
                child: Row(
                  children: [
                    Icon(
                      IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                      size: 16,
                      color: isCompleted
                          ? AppColors.accentGreen
                          : AppColors.accentPurple,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyS.copyWith(
                          color: isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Text(
                      '$current/$total',
                      style: AppTextStyles.labelS.copyWith(
                        color: isCompleted
                            ? AppColors.accentGreen
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    SizedBox(
                      width: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor:
                              AppColors.textTertiary.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? AppColors.accentGreen
                                : AppColors.accentPurple,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
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
