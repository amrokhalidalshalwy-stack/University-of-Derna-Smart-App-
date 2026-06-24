import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/widgets/section_header.dart';

class FacultySettingsPage extends ConsumerStatefulWidget {
  const FacultySettingsPage({super.key});

  @override
  ConsumerState<FacultySettingsPage> createState() =>
      _FacultySettingsPageState();
}

class _FacultySettingsPageState extends ConsumerState<FacultySettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;

  Future<void> _pickLocale(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx)!;
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final chosen = await showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: isDark ? const Color(0xFF0D2420) : null,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.themeSystem),
                leading: const Icon(Icons.language),
                onTap: () => Navigator.pop(sheetCtx, 'system'),
              ),
              ListTile(
                title: Text(l10n.languageArabic),
                onTap: () => Navigator.pop(sheetCtx, 'ar'),
              ),
              ListTile(
                title: Text(l10n.languageEnglish),
                onTap: () => Navigator.pop(sheetCtx, 'en'),
              ),
            ],
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    if (chosen == 'system') {
      await ref.read(localeProvider.notifier).setSystemLocale();
    } else {
      await ref.read(localeProvider.notifier).setLocale(Locale(chosen));
    }
  }

  String _languageSubtitle(Locale locale) {
    return locale.languageCode == 'ar' ? 'العربية' : 'English';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final brandTeal =
        isDark
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.primary;
    final brandNavy =
        isDark
            ? const Color(0xFF0D2420)
            : const Color(0xFF00A694);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: userDataAsync.when(
        data: (profile) {
          final fullName =
              profile?['fullName'] as String? ?? l10n.excusesFacultyMember;
          final role = profile?['role'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Profile overview card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Image Container
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: brandTeal.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 36,
                            color: brandTeal,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Doctor info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: brandNavy,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role == 'faculty'
                                ? l10n.settingsRoleFaculty
                                : l10n.settingsRoleStaff,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

              const SizedBox(height: 24),

              // 2. Account Settings Section
              SectionHeader(
                title: l10n.settingsAccount,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Edit Profile
                        _buildSettingsTile(
                          icon: Icons.person_outline_rounded,
                          title: l10n.settingsEditProfile,
                          onTap: () => context.push('/faculty/profile'),
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // Change Password
                        _buildSettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.settingsChangePassword,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.passwordResetNote,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            );
                          },
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // System Notifications Toggle Switch
                        _buildSwitchTile(
                          icon: Icons.notifications_none_rounded,
                          title: l10n.settingsNotifications,
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _notificationsEnabled = val;
                            });
                          },
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // Language Selection
                        _buildSettingsTile(
                          icon: Icons.language_rounded,
                          title: l10n.settingsLanguage,
                          subtitle: _languageSubtitle(locale),
                          onTap: () => _pickLocale(context),
                          brandTeal: brandTeal,
                          showDivider: false,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 50.ms)
                  .slideY(begin: 0.05),

              const SizedBox(height: 24),

              // 3. System Preferences Section
              SectionHeader(
                title: l10n.settingsSystem,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Dark Mode Switch
                        _buildSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.settingsDarkMode,
                          value: isDark,
                          onChanged: (val) {
                            ref
                                .read(themeModeNotifierProvider.notifier)
                                .setThemeMode(
                                  val ? ThemeMode.dark : ThemeMode.light,
                                );
                          },
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // Biometric Login Switch
                        _buildSwitchTile(
                          icon: Icons.fingerprint_rounded,
                          title: l10n.settingsBiometric,
                          value: _biometricEnabled,
                          onChanged: (val) {
                            setState(() {
                              _biometricEnabled = val;
                            });
                          },
                          brandTeal: brandTeal,
                          showDivider: false,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05),

              const SizedBox(height: 24),

              // 4. Support Section
              SectionHeader(
                title: l10n.settingsSupport,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Help Center
                        _buildSettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: l10n.settingsHelp,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.settingsHelpLoading,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            );
                          },
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // Privacy Policy
                        _buildSettingsTile(
                          icon: Icons.security_rounded,
                          title: l10n.settingsPrivacy,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.settingsPrivacyPolicy(DateTime.now().year),
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            );
                          },
                          brandTeal: brandTeal,
                          showDivider: true,
                        ),
                        // About
                        // _buildSettingsTile(
                        //   icon: Icons.info_outline_rounded,
                        //   title: l10n.settingsAbout,
                        //   onTap: () {
                        //     showAboutDialog(
                        //       context: context,
                        //       applicationName: 'تطبيق جامعة درنة',
                        //       applicationVersion: '2.0.1',
                        //       applicationIcon: Icon(
                        //         Icons.school_rounded,
                        //         color: brandTeal,
                        //         size: 40,
                        //       ),
                        //       children: const [
                        //         Text(
                        //           'البوابة الإلكترونية الذكية لجامعة درنة - كلية الهندسة وتقنية المعلومات. نسخة 2026.',
                        //           style: TextStyle(
                        //             fontFamily: 'Cairo',
                        //             fontSize: 13,
                        //           ),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        //   brandTeal: brandTeal,
                        //   showDivider: false,
                        // ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideY(begin: 0.05),

              const SizedBox(height: 32),

              // 5. Sign Out Button
              ElevatedButton(
                    onPressed: () => _confirmSignOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade600,
                      elevation: 0,
                      side: BorderSide(color: Colors.red.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          l10n.profileLogout,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 200.ms)
                  .slideY(begin: 0.05),
            ],
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF005A51)),
            ),
        error:
            (err, st) => Center(
              child: Text(
                '${l10n.errorPrefix}$err',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color brandTeal,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: brandTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandTeal, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          subtitle:
              subtitle != null
                  ? Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  )
                  : null,
          trailing: const Icon(Icons.chevron_left_rounded, color: Colors.grey),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 72),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color brandTeal,
    required bool showDivider,
  }) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: brandTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandTeal, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          activeTrackColor: brandTeal.withValues(alpha: 0.5),
          activeThumbColor: brandTeal,
          value: value,
          onChanged: onChanged,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 72),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.logoutConfirmTitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            l10n.logoutConfirmBody,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ref.read(authServiceProvider).signOut();
                context.go('/gateway'); // Reroute to gateway select screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.profileLogout,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
