// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/notification_service.dart';
import '../../auth/services/auth_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 설정 화면 (Settings Screen)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 설정 및 사용자 프로필 관리
/// - 프로필 설정 (이름, 아바타)
/// - 테마 설정 (다크 모드)
/// - 알림 설정 (LocalStorage 연동)
/// - 데이터 관리
/// - 앱 정보
///
/// 온보딩에서 저장한 설정을 로드하고, 변경 시 저장합니다.
/// ═══════════════════════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _tag = 'SettingsScreen';

  // 설정 상태
  String _userName = '';
  bool _isDarkMode = false;
  bool _morningReminder = true;
  bool _eveningReminder = true;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningReminderTime = const TimeOfDay(hour: 21, minute: 0);

  // 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppLogger.d('SettingsScreen initState', tag: _tag);
    _loadSettings();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 설정 로드
  // ─────────────────────────────────────────────────────────────────────────

  /// LocalStorage에서 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      final storage = LocalStorageService();

      // 사용자 이름 (온보딩 저장값 → 로그인 정보 → 기본값)
      String userName = storage.getSetting<String>('userName') ?? '';
      if (userName.isEmpty) {
        final currentUser = ref.read(currentUserProvider);
        userName = currentUser?.displayName ?? '';
      }

      // 알림 설정
      final morningEnabled =
          storage.getSetting<bool>('morningAlarmEnabled') ?? true;
      final eveningEnabled =
          storage.getSetting<bool>('eveningAlarmEnabled') ?? true;

      // 알림 시간
      final morningHour = storage.getSetting<int>('morningReminderHour') ?? 6;
      final morningMinute =
          storage.getSetting<int>('morningReminderMinute') ?? 0;
      final eveningHour = storage.getSetting<int>('eveningReminderHour') ?? 21;
      final eveningMinute =
          storage.getSetting<int>('eveningReminderMinute') ?? 0;

      // 다크 모드
      final isDarkMode = storage.getSetting<bool>('isDarkMode') ?? false;

      setState(() {
        _userName = userName;
        _morningReminder = morningEnabled;
        _eveningReminder = eveningEnabled;
        _morningReminderTime = TimeOfDay(
          hour: morningHour,
          minute: morningMinute,
        );
        _eveningReminderTime = TimeOfDay(
          hour: eveningHour,
          minute: eveningMinute,
        );
        _isDarkMode = isDarkMode;
        _isLoading = false;
      });

      AppLogger.i(
        'Settings loaded - userName: $_userName, '
        'morning: $_morningReminder (${_formatTime(_morningReminderTime)}), '
        'evening: $_eveningReminder (${_formatTime(_eveningReminderTime)})',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load settings',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 설정 저장
  // ─────────────────────────────────────────────────────────────────────────

  /// 사용자 이름 저장
  Future<void> _saveUserName(String name) async {
    try {
      final storage = LocalStorageService();
      await storage.saveSetting('userName', name);
      AppLogger.i('User name saved: $name', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save user name', tag: _tag, error: e);
    }
  }

  /// 아침 알림 활성화 저장
  Future<void> _saveMorningReminderEnabled(bool enabled) async {
    try {
      final storage = LocalStorageService();
      final notificationService = NotificationService();

      await storage.saveSetting('morningAlarmEnabled', enabled);

      if (enabled) {
        await notificationService.scheduleMorningNotification(
          _morningReminderTime,
        );
      } else {
        await notificationService.cancelMorningNotification();
      }

      AppLogger.i('Morning reminder enabled: $enabled', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save morning reminder', tag: _tag, error: e);
    }
  }

  /// 저녁 알림 활성화 저장
  Future<void> _saveEveningReminderEnabled(bool enabled) async {
    try {
      final storage = LocalStorageService();
      final notificationService = NotificationService();

      await storage.saveSetting('eveningAlarmEnabled', enabled);

      if (enabled) {
        await notificationService.scheduleEveningNotification(
          _eveningReminderTime,
        );
      } else {
        await notificationService.cancelEveningNotification();
      }

      AppLogger.i('Evening reminder enabled: $enabled', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save evening reminder', tag: _tag, error: e);
    }
  }

  /// 아침 알림 시간 저장
  Future<void> _saveMorningReminderTime(TimeOfDay time) async {
    try {
      final storage = LocalStorageService();
      final notificationService = NotificationService();

      await storage.saveSetting('morningReminderHour', time.hour);
      await storage.saveSetting('morningReminderMinute', time.minute);

      // 알림 재스케줄링
      if (_morningReminder) {
        await notificationService.scheduleMorningNotification(time);
      }

      AppLogger.i(
        'Morning reminder time saved: ${_formatTime(time)}',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.e('Failed to save morning reminder time', tag: _tag, error: e);
    }
  }

  /// 저녁 알림 시간 저장
  Future<void> _saveEveningReminderTime(TimeOfDay time) async {
    try {
      final storage = LocalStorageService();
      final notificationService = NotificationService();

      await storage.saveSetting('eveningReminderHour', time.hour);
      await storage.saveSetting('eveningReminderMinute', time.minute);

      // 알림 재스케줄링
      if (_eveningReminder) {
        await notificationService.scheduleEveningNotification(time);
      }

      AppLogger.i(
        'Evening reminder time saved: ${_formatTime(time)}',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.e('Failed to save evening reminder time', tag: _tag, error: e);
    }
  }

  /// 다크 모드 저장
  Future<void> _saveDarkMode(bool enabled) async {
    try {
      final storage = LocalStorageService();
      await storage.saveSetting('isDarkMode', enabled);
      AppLogger.i('Dark mode saved: $enabled', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to save dark mode', tag: _tag, error: e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    AppLogger.d('SettingsScreen build', tag: _tag);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.spaceL),

            // 헤더
            Text(AppStrings.navSettings, style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.spaceXL),

            // 프로필 섹션
            _buildProfileSection(),
            const SizedBox(height: AppSizes.spaceXL),

            // 테마 섹션
            _buildThemeSection(),
            const SizedBox(height: AppSizes.spaceXL),

            // 알림 섹션
            _buildNotificationSection(),
            const SizedBox(height: AppSizes.spaceXL),

            // 데이터 섹션
            _buildDataSection(),
            const SizedBox(height: AppSizes.spaceXL),

            // 앱 정보 섹션
            _buildAppInfoSection(),
            const SizedBox(height: AppSizes.spaceXL),

            // 계정 섹션
            _buildAccountSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 프로필 섹션
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.settingsProfile, Icons.person_outline),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              // 아바타
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentBlue, AppColors.accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceL),

              // 이름 & 편집
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.isNotEmpty
                          ? _userName
                          : AppStrings.settingsDefaultName,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.settingsProfileDescription,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // 편집 버튼
              NeumorphicButton.icon(
                icon: Icons.edit_outlined,
                onTap: _showNameEditDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 테마 섹션
  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.settingsTheme, Icons.palette_outlined),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.dark_mode_outlined,
                title: AppStrings.settingsDarkMode,
                subtitle: AppStrings.settingsDarkModeDescription,
                trailing: Switch.adaptive(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    _saveDarkMode(value);
                    AppLogger.ui('Dark mode: $value', screen: _tag);
                    // TODO: 실제 다크 모드 적용
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.settingsComingSoon),
                        backgroundColor: AppColors.accentOrange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: AppColors.accentBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 알림 섹션
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          AppStrings.settingsNotifications,
          Icons.notifications_outlined,
        ),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              // 권한 상태 체크
              _buildSettingRow(
                icon: Icons.verified_user_outlined,
                title: AppStrings.settingsNotificationCheckPermission,
                subtitle: AppStrings.settingsNotificationCheckPermissionDesc,
                iconColor: AppColors.accentBlue,
                onTap: _checkNotificationPermission,
              ),
              const Divider(height: AppSizes.spaceXL),

              // 아침 알림
              _buildSettingRow(
                icon: Icons.wb_sunny_outlined,
                title: AppStrings.settingsMorningReminder,
                subtitle: _formatTime(_morningReminderTime),
                trailing: Switch.adaptive(
                  value: _morningReminder,
                  onChanged: (value) async {
                    // 권한 확인
                    final hasPermission = await _checkAndRequestPermission();
                    if (!hasPermission) return;

                    setState(() => _morningReminder = value);
                    _saveMorningReminderEnabled(value);
                    AppLogger.ui('Morning reminder: $value', screen: _tag);
                  },
                  activeColor: AppColors.accentOrange,
                ),
                onTap: _morningReminder ? () => _showTimePicker(true) : null,
              ),
              const Divider(height: AppSizes.spaceXL),

              // 저녁 알림
              _buildSettingRow(
                icon: Icons.nights_stay_outlined,
                title: AppStrings.settingsEveningReminder,
                subtitle: _formatTime(_eveningReminderTime),
                trailing: Switch.adaptive(
                  value: _eveningReminder,
                  onChanged: (value) async {
                    // 권한 확인
                    final hasPermission = await _checkAndRequestPermission();
                    if (!hasPermission) return;

                    setState(() => _eveningReminder = value);
                    _saveEveningReminderEnabled(value);
                    AppLogger.ui('Evening reminder: $value', screen: _tag);
                  },
                  activeColor: AppColors.accentPurple,
                ),
                onTap: _eveningReminder ? () => _showTimePicker(false) : null,
              ),
              const Divider(height: AppSizes.spaceXL),

              // 테스트 알림 버튼
              _buildSettingRow(
                icon: Icons.notifications_active_outlined,
                title: AppStrings.settingsTestNotification,
                subtitle: AppStrings.settingsTestNotificationDesc,
                iconColor: AppColors.accentGreen,
                onTap: _showTestNotificationDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 테스트 알림 다이얼로그
  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          AppStrings.settingsTestNotification,
          style: AppTextStyles.heading4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.settingsTestNotificationDialogDesc,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),

            // 아침 알림 테스트
            _buildTestButton(
              icon: Icons.wb_sunny_outlined,
              label: AppStrings.settingsMorningReminder,
              color: AppColors.accentOrange,
              onTap: () {
                Navigator.pop(context);
                _sendTestNotification(isMorning: true);
              },
            ),
            const SizedBox(height: AppSizes.spaceM),

            // 저녁 알림 테스트
            _buildTestButton(
              icon: Icons.nights_stay_outlined,
              label: AppStrings.settingsEveningReminder,
              color: AppColors.accentPurple,
              onTap: () {
                Navigator.pop(context);
                _sendTestNotification(isMorning: false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.btnCancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// 테스트 버튼 위젯
  Widget _buildTestButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppSizes.iconM),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyM.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.send_rounded, color: color, size: AppSizes.iconS),
          ],
        ),
      ),
    );
  }

  /// 테스트 알림 발송
  Future<void> _sendTestNotification({required bool isMorning}) async {
    try {
      // 권한 확인 및 요청
      final hasPermission = await _checkAndRequestPermission();
      if (!hasPermission) {
        AppLogger.w(
          'Permission denied, cannot send test notification',
          tag: _tag,
        );
        return;
      }

      final notificationService = NotificationService();

      final title = isMorning ? '☀️ Good Morning!' : '🌙 Good Evening!';
      final body = isMorning ? '오늘 하루를 어떻게 보낼지 계획해보세요' : '오늘 하루를 돌아보며 성찰해보세요';
      final color = isMorning ? AppColors.accentOrange : AppColors.accentPurple;

      // 시스템 알림 발송
      await notificationService.showTestNotification(title: title, body: body);

      // 인앱 알림 오버레이 표시
      if (mounted) {
        _showInAppNotification(title: title, body: body, color: color);
      }

      AppLogger.i(
        'Test notification sent: ${isMorning ? "morning" : "evening"}',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.e('Failed to send test notification', tag: _tag, error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.settingsTestNotificationFailed),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 인앱 알림 오버레이 표시
  void _showInAppNotification({
    required String title,
    required String body,
    required Color color,
  }) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () {
                if (overlayEntry.mounted) {
                  overlayEntry.remove();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  children: [
                    // 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          title.substring(0, 2),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 텍스트
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.substring(3),
                            style: AppTextStyles.labelL.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 닫기 버튼
                    Icon(Icons.close, size: 20, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // 4초 후 자동 제거
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 데이터 섹션
  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.settingsData, Icons.storage_outlined),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              // 데이터 내보내기
              _buildSettingRow(
                icon: Icons.upload_outlined,
                title: AppStrings.settingsExport,
                subtitle: AppStrings.settingsExportDescription,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.settingsComingSoon),
                      backgroundColor: AppColors.accentOrange,
                    ),
                  );
                },
              ),
              const Divider(height: AppSizes.spaceXL),

              // 데이터 초기화
              _buildSettingRow(
                icon: Icons.delete_outline,
                title: AppStrings.settingsReset,
                subtitle: AppStrings.settingsResetDescription,
                iconColor: AppColors.accentRed,
                onTap: _showResetConfirmDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 앱 정보 섹션
  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.settingsAbout, Icons.info_outline),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.info_outline,
                title: AppStrings.appName,
                subtitle: 'Version 1.0.0',
              ),
              const Divider(height: AppSizes.spaceXL),
              _buildSettingRow(
                icon: Icons.favorite_outline,
                title: AppStrings.settingsMadeWith,
                subtitle: 'Flutter & Riverpod',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 계정 섹션
  Widget _buildAccountSection() {
    final currentUser = ref.watch(currentUserProvider);
    final providerName = _getProviderDisplayName(currentUser?.provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.settingsAccount, Icons.account_circle_outlined),
        const SizedBox(height: AppSizes.spaceM),

        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              // 현재 로그인 정보
              if (currentUser != null) ...[
                _buildSettingRow(
                  icon: _getProviderIcon(currentUser.provider),
                  title: currentUser.email.isNotEmpty
                      ? currentUser.email
                      : currentUser.name,
                  subtitle: '$providerName ${AppStrings.settingsLoggedInWith}',
                  iconColor: _getProviderColor(currentUser.provider),
                ),
                const Divider(height: AppSizes.spaceXL),
              ],

              // 로그아웃 버튼
              _buildSettingRow(
                icon: Icons.logout,
                title: AppStrings.settingsLogout,
                subtitle: AppStrings.settingsLogoutDescription,
                iconColor: AppColors.accentRed,
                onTap: _showLogoutConfirmDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutConfirmDialog() {
    NeumorphicDialog.showConfirm(
      context: context,
      title: AppStrings.settingsLogoutConfirmTitle,
      message: AppStrings.settingsLogoutConfirmMessage,
      confirmText: AppStrings.settingsLogout,
      cancelText: AppStrings.btnCancel,
    ).then((confirmed) async {
      if (confirmed == true) {
        await _performLogout();
      }
    });
  }

  /// 로그아웃 실행
  Future<void> _performLogout() async {
    try {
      AppLogger.i('Starting logout...', tag: _tag);

      // 로딩 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSizes.spaceM),
                  Text(
                    AppStrings.settingsLoggingOut,
                    style: AppTextStyles.bodyM,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // AuthService 로그아웃 호출
      final authService = AuthService();
      await authService.signOut();

      // 상태 초기화
      ref.read(currentUserProvider.notifier).state = null;
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;

      AppLogger.i('Logout successful', tag: _tag);

      // 다이얼로그 닫기 및 로그인 화면으로 이동
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        // 로그인 화면으로 이동 (모든 스택 제거)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Logout failed', tag: _tag, error: e, stackTrace: stackTrace);

      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.settingsLogoutFailed),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  /// Provider 표시 이름 가져오기
  String _getProviderDisplayName(String? provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'kakao':
        return 'Kakao';
      case 'naver':
        return 'Naver';
      case 'email':
        return 'Email';
      default:
        return '';
    }
  }

  /// Provider 아이콘 가져오기
  IconData _getProviderIcon(String? provider) {
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'kakao':
        return Icons.chat_bubble;
      case 'naver':
        return Icons.language;
      case 'email':
        return Icons.email_outlined;
      default:
        return Icons.account_circle_outlined;
    }
  }

  /// Provider 색상 가져오기
  Color _getProviderColor(String? provider) {
    switch (provider) {
      case 'google':
        return const Color(0xFF4285F4);
      case 'apple':
        return Colors.black;
      case 'kakao':
        return const Color(0xFFFEE500);
      case 'naver':
        return const Color(0xFF03C75A);
      case 'email':
        return AppColors.accentBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconM, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 설정 행
  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.accentBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconM,
                color: iconColor ?? AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyM),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  /// 시간 포맷
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 이름 편집 다이얼로그
  void _showNameEditDialog() {
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(AppStrings.settingsEditName, style: AppTextStyles.heading4),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.settingsNameHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.btnCancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _userName = newName);
                _saveUserName(newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.settingsNameSaved),
                    backgroundColor: AppColors.accentGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              AppStrings.btnSave,
              style: TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 선택
  void _showTimePicker(bool isMorning) async {
    final currentTime = isMorning ? _morningReminderTime : _eveningReminderTime;
    final color = isMorning ? AppColors.accentOrange : AppColors.accentPurple;

    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
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
          _morningReminderTime = picked;
        } else {
          _eveningReminderTime = picked;
        }
      });

      // 시간 저장 및 알림 재스케줄링
      if (isMorning) {
        await _saveMorningReminderTime(picked);
      } else {
        await _saveEveningReminderTime(picked);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isMorning ? AppStrings.settingsMorningReminder : AppStrings.settingsEveningReminder} '
              '${AppStrings.settingsTimeChanged}: ${_formatTime(picked)}',
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      AppLogger.ui(
        '${isMorning ? "Morning" : "Evening"} time: ${_formatTime(picked)}',
        screen: _tag,
      );
    }
  }

  /// 초기화 확인 다이얼로그
  void _showResetConfirmDialog() {
    NeumorphicDialog.showConfirm(
      context: context,
      title: AppStrings.settingsResetConfirmTitle,
      message: AppStrings.settingsResetConfirmMessage,
      confirmText: AppStrings.settingsResetConfirm,
      cancelText: AppStrings.btnCancel,
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          // 데이터 초기화
          final storage = LocalStorageService();
          await storage.clearAllData();

          // 알림 취소
          final notificationService = NotificationService();
          await notificationService.cancelAllNotifications();

          // 설정 다시 로드
          await _loadSettings();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.settingsResetComplete),
                backgroundColor: AppColors.accentRed,
              ),
            );
          }

          AppLogger.i('Data reset completed', tag: _tag);
        } catch (e) {
          AppLogger.e('Failed to reset data', tag: _tag, error: e);
        }
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 알림 권한 관련
  // ─────────────────────────────────────────────────────────────────────────

  /// 알림 권한 확인 및 요청
  Future<bool> _checkAndRequestPermission() async {
    try {
      final notificationService = NotificationService();

      // 1. 현재 권한 상태 확인
      final isEnabled = await notificationService.checkPermissionStatus();

      if (isEnabled) {
        AppLogger.d('Notification permission already granted', tag: _tag);
        return true;
      }

      // 2. 권한 요청
      AppLogger.i('Requesting notification permission...', tag: _tag);
      final granted = await notificationService.requestPermission();

      if (granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.settingsNotificationPermissionGranted),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return true;
      } else {
        // 권한 거부 시 안내
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
    } catch (e) {
      AppLogger.e('Failed to check/request permission', tag: _tag, error: e);
      return false;
    }
  }

  /// 알림 권한 상태 확인 (버튼용)
  Future<void> _checkNotificationPermission() async {
    try {
      final notificationService = NotificationService();
      final isEnabled = await notificationService.checkPermissionStatus();

      if (mounted) {
        final statusText = isEnabled
            ? AppStrings.settingsNotificationPermissionEnabled
            : AppStrings.settingsNotificationPermissionDisabled;
        final color = isEnabled ? AppColors.accentGreen : AppColors.accentRed;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.settingsNotificationPermissionStatus}: $statusText',
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
            action: !isEnabled
                ? SnackBarAction(
                    label: AppStrings.settingsNotificationPermissionBtn,
                    textColor: Colors.white,
                    onPressed: _openAppSettings,
                  )
                : null,
          ),
        );
      }

      AppLogger.i('Notification permission status: $isEnabled', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to check permission status', tag: _tag, error: e);
    }
  }

  /// 권한 거부 다이얼로그
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: AppColors.accentRed,
              size: AppSizes.iconL,
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                AppStrings.settingsNotificationPermissionDenied,
                style: AppTextStyles.heading4,
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.settingsNotificationPermissionDeniedDesc,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.btnCancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAppSettings();
            },
            child: Text(
              AppStrings.settingsNotificationPermissionBtn,
              style: TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 앱 설정 열기
  Future<void> _openAppSettings() async {
    try {
      // permission_handler 패키지 사용 (추가 필요)
      // await openAppSettings();

      // 임시: 안내 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('설정 > 알림에서 Franklin Flow 알림을 허용해주세요'),
            backgroundColor: AppColors.accentOrange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      AppLogger.i('Open app settings requested', tag: _tag);
    } catch (e) {
      AppLogger.e('Failed to open app settings', tag: _tag, error: e);
    }
  }
}
