// lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../services/local_storage_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 온보딩 화면 (Onboarding Screen)
/// ═══════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 4;

  // 사용자 입력 데이터
  final TextEditingController _nameController = TextEditingController();
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);
  bool _morningAlarmEnabled = true;
  bool _eveningAlarmEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    AppLogger.d('OnboardingScreen init', tag: 'OnboardingScreen');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildNamePage(),
                  _buildNotificationPage(),
                  _buildCompletePage(),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_currentPage + 1} / $_totalPages',
            style: AppTextStyles.labelM.copyWith(color: AppColors.textTertiary),
          ),
          if (_currentPage < _totalPages - 1)
            GestureDetector(
              onTap: _skipToEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                child: Text(
                  AppStrings.onboardingSkip,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  /// 하단 섹션
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingS,
        AppSizes.paddingL,
        AppSizes.paddingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          const SizedBox(height: AppSizes.spaceM),
          _buildActionButton(),
        ],
      ),
    );
  }

  /// 프로그레스 바
  Widget _buildProgressBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: constraints.maxWidth * ((_currentPage + 1) / _totalPages),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 액션 버튼
  Widget _buildActionButton() {
    final isLastPage = _currentPage == _totalPages - 1;
    final isNamePage = _currentPage == 1;

    return Row(
      children: [
        if (_currentPage > 0) ...[
          Expanded(
            child: NeumorphicButton(
              onTap: _previousPage,
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.onboardingBack,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
        ],
        Expanded(
          flex: _currentPage > 0 ? 2 : 1,
          child: _buildPrimaryButton(
            text: isLastPage
                ? AppStrings.onboardingCompleteButton
                : isNamePage && _nameController.text.isEmpty
                ? AppStrings.onboardingNameSkip
                : AppStrings.onboardingNext,
            icon: isLastPage
                ? Icons.check_rounded
                : Icons.arrow_forward_rounded,
            onTap: isLastPage ? _completeOnboarding : _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.accentBlue,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTextStyles.bodyM.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Page 1: 환영 페이지
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceXL),
          _buildLogoIcon(),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            AppStrings.onboardingWelcomeTitle,
            style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildQuoteCard(),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            AppStrings.onboardingWelcomeSubtitle,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            AppStrings.onboardingWelcomeDesc,
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceXL),
        ],
      ),
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 24,
            color: AppColors.accentOrange.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            AppStrings.onboardingWelcomeQuote,
            style: AppTextStyles.bodyL.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            AppStrings.onboardingWelcomeAuthor,
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Page 2: 이름 입력 페이지
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNamePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceXL * 2),
          _buildIconCircle(
            icon: Icons.person_outline_rounded,
            color: AppColors.accentBlue,
          ),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            AppStrings.onboardingNameTitle,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            AppStrings.onboardingNameDesc,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spaceL),
          NeumorphicContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingS,
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading4,
              decoration: InputDecoration(
                hintText: AppStrings.onboardingNameHint,
                hintStyle: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_nameController.text.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceL),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Good Morning, ${_nameController.text}님!',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spaceXL * 2),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Page 3: 알림 설정 페이지
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNotificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceL),
          _buildIconCircle(
            icon: Icons.notifications_none_rounded,
            color: AppColors.accentPurple,
          ),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            AppStrings.onboardingNotificationTitle,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            AppStrings.onboardingNotificationDesc,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildNotificationCard(
            icon: Icons.wb_sunny_outlined,
            title: AppStrings.onboardingMorningAlarm,
            description: AppStrings.onboardingMorningAlarmDesc,
            time: _morningTime,
            enabled: _morningAlarmEnabled,
            color: AppColors.accentOrange,
            onTimePressed: () => _selectTime(true),
            onToggle: (v) => setState(() => _morningAlarmEnabled = v),
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildNotificationCard(
            icon: Icons.nightlight_outlined,
            title: AppStrings.onboardingEveningAlarm,
            description: AppStrings.onboardingEveningAlarmDesc,
            time: _eveningTime,
            enabled: _eveningAlarmEnabled,
            color: AppColors.accentPurple,
            onTimePressed: () => _selectTime(false),
            onToggle: (v) => setState(() => _eveningAlarmEnabled = v),
          ),
          const SizedBox(height: AppSizes.spaceM),
          Text(
            AppStrings.onboardingNotificationLater,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSizes.spaceL),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required TimeOfDay time,
    required bool enabled,
    required Color color,
    required VoidCallback onTimePressed,
    required ValueChanged<bool> onToggle,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeColor: color,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSizes.spaceM),
            GestureDetector(
              onTap: onTimePressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(time),
                      style: AppTextStyles.heading4.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Page 4: 완료 페이지
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCompletePage() {
    final userName = _nameController.text.isNotEmpty
        ? _nameController.text
        : '사용자';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.spaceL),
          _buildSuccessIcon(),
          const SizedBox(height: AppSizes.spaceL),
          Text(
            '$userName님,',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            AppStrings.onboardingCompleteTitle,
            style: AppTextStyles.heading1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildSummaryCard(),
          const SizedBox(height: AppSizes.spaceM),
          _buildGuideCard(),
          const SizedBox(height: AppSizes.spaceL),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          _buildSummaryRow(
            icon: Icons.wb_sunny_outlined,
            label: AppStrings.onboardingMorningAlarm,
            value: _morningAlarmEnabled ? _formatTime(_morningTime) : '사용 안함',
            color: AppColors.accentOrange,
            enabled: _morningAlarmEnabled,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceS),
            child: Divider(
              color: AppColors.textTertiary.withOpacity(0.1),
              height: 1,
            ),
          ),
          _buildSummaryRow(
            icon: Icons.nightlight_outlined,
            label: AppStrings.onboardingEveningAlarm,
            value: _eveningAlarmEnabled ? _formatTime(_eveningTime) : '사용 안함',
            color: AppColors.accentPurple,
            enabled: _eveningAlarmEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool enabled,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(enabled ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? color : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyM.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelM.copyWith(
            color: enabled ? color : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildGuideRow(
            icon: Icons.wb_sunny_outlined,
            text: AppStrings.onboardingCompleteDesc1,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildGuideRow(
            icon: Icons.nightlight_outlined,
            text: AppStrings.onboardingCompleteDesc2,
            color: AppColors.accentPurple,
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildGuideRow(
            icon: Icons.trending_up_rounded,
            text: AppStrings.onboardingCompleteDesc3,
            color: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 공통 위젯
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildIconCircle({required IconData icon, required Color color}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 헬퍼 메서드
  // ─────────────────────────────────────────────────────────────────────────

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(bool isMorning) async {
    final initialTime = isMorning ? _morningTime : _eveningTime;
    final color = isMorning ? AppColors.accentOrange : AppColors.accentPurple;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: color)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final storage = LocalStorageService();

      await storage.saveSetting('userName', _nameController.text);
      await storage.saveSetting('morningReminderHour', _morningTime.hour);
      await storage.saveSetting('morningReminderMinute', _morningTime.minute);
      await storage.saveSetting('eveningReminderHour', _eveningTime.hour);
      await storage.saveSetting('eveningReminderMinute', _eveningTime.minute);
      await storage.saveSetting('morningAlarmEnabled', _morningAlarmEnabled);
      await storage.saveSetting('eveningAlarmEnabled', _eveningAlarmEnabled);
      await storage.saveSetting('onboardingCompleted', true);

      AppLogger.i(
        'Onboarding completed - userName: ${_nameController.text}',
        tag: 'OnboardingScreen',
      );

      widget.onComplete();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to save onboarding settings',
        tag: 'OnboardingScreen',
        error: e,
        stackTrace: stackTrace,
      );
      widget.onComplete();
    }
  }
}
