// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 설정 화면 (Settings Screen)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 앱 설정 및 사용자 프로필 관리
/// - 프로필 설정 (이름, 아바타)
/// - 테마 설정 (다크 모드)
/// - 알림 설정
/// - 데이터 관리
/// - 앱 정보
/// ═══════════════════════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // 임시 설정 상태 (나중에 Provider로 관리)
  String _userName = 'Won';
  bool _isDarkMode = false;
  bool _morningReminder = true;
  bool _eveningReminder = true;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningReminderTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  Widget build(BuildContext context) {
    AppLogger.d('SettingsScreen build', tag: 'SettingsScreen');

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
                    Text(_userName, style: AppTextStyles.heading3),
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
                    AppLogger.ui('Dark mode: $value', screen: 'SettingsScreen');
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
              // 아침 알림
              _buildSettingRow(
                icon: Icons.wb_sunny_outlined,
                title: AppStrings.settingsMorningReminder,
                subtitle: _formatTime(_morningReminderTime),
                trailing: Switch.adaptive(
                  value: _morningReminder,
                  onChanged: (value) {
                    setState(() => _morningReminder = value);
                    AppLogger.ui(
                      'Morning reminder: $value',
                      screen: 'SettingsScreen',
                    );
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
                  onChanged: (value) {
                    setState(() => _eveningReminder = value);
                    AppLogger.ui(
                      'Evening reminder: $value',
                      screen: 'SettingsScreen',
                    );
                  },
                  activeColor: AppColors.accentPurple,
                ),
                onTap: _eveningReminder ? () => _showTimePicker(false) : null,
              ),
            ],
          ),
        ),
      ],
    );
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

    // NeumorphicDialog.showCustom(
    //   context: context,
    //   title: AppStrings.settingsEditName,
    //   content: TextField(
    //     controller: controller,
    //     autofocus: true,
    //     decoration: InputDecoration(
    //       hintText: AppStrings.settingsNameHint,
    //       border: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(AppSizes.radiusM),
    //       ),
    //     ),
    //   ),
    //   confirmText: AppStrings.btnSave,
    //   cancelText: AppStrings.btnCancel,
    // ).then((confirmed) {time_of_day_mode
    //   if (confirmed == true && controller.text.trim().isNotEmpty) {
    //     setState(() {
    //       _userName = controller.text.trim();
    //     });
    //     AppLogger.ui('Name changed to: $_userName', screen: 'SettingsScreen');
    //   }
    // });
  }

  /// 시간 선택
  void _showTimePicker(bool isMorning) async {
    final currentTime = isMorning ? _morningReminderTime : _eveningReminderTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningReminderTime = picked;
        } else {
          _eveningReminderTime = picked;
        }
      });
      AppLogger.ui(
        '${isMorning ? "Morning" : "Evening"} time: ${_formatTime(picked)}',
        screen: 'SettingsScreen',
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
    ).then((confirmed) {
      if (confirmed == true) {
        // TODO: 실제 데이터 초기화 로직
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.settingsResetComplete),
            backgroundColor: AppColors.accentRed,
          ),
        );
        AppLogger.i('Data reset', tag: 'SettingsScreen');
      }
    });
  }
}
