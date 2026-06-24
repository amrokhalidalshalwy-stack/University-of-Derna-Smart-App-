import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_project/core/widgets/section_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _notifKey = 'settings_notifications_enabled';
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotif());
  }

  Future<void> _loadNotif() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final v = prefs.getBool(_notifKey) ?? true;
    if (mounted) setState(() => _notifEnabled = v);
  }

  Future<void> _toggleNotif() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = !_notifEnabled;
    await prefs.setBool(_notifKey, next);
    if (mounted) setState(() => _notifEnabled = next);
  }

  Future<void> _contactSupport(AppLocalizations l10n) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@uod.edu.ly',
      queryParameters: {'subject': l10n.supportSubject},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _showComingSoon() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.twoFactor),
            content: Text(l10n.comingSoonBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.ok),
              ),
            ],
          ),
    );
  }

  Future<void> _pickTheme() async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.themeSystem),
                leading: const Icon(Icons.brightness_auto),
                onTap: () => Navigator.pop(ctx, ThemeMode.system),
              ),
              ListTile(
                title: Text(l10n.themeLight),
                leading: const Icon(Icons.light_mode),
                onTap: () => Navigator.pop(ctx, ThemeMode.light),
              ),
              ListTile(
                title: Text(l10n.themeDark),
                leading: const Icon(Icons.dark_mode),
                onTap: () => Navigator.pop(ctx, ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
    if (chosen != null && mounted) {
      await ref.read(themeModeNotifierProvider.notifier).setThemeMode(chosen);
    }
  }

  Future<void> _pickLocale() async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.languageAuto),
                leading: const Icon(Icons.language),
                onTap: () => Navigator.pop(ctx, 'system'),
              ),
              ListTile(
                title: Text(l10n.languageAr),
                onTap: () => Navigator.pop(ctx, 'ar'),
              ),
              ListTile(
                title: Text(l10n.languageEn),
                onTap: () => Navigator.pop(ctx, 'en'),
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

  String _themeSubtitle(ThemeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };
  }

  String _languageSubtitle(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.languageAuto;
    return locale.languageCode == 'ar' ? l10n.languageAr : l10n.languageEn;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.pleaseLogin));
          }

          final userData = ref.watch(userDataProvider(user.uid));

          return userData.when(
            data: (data) {
              if (data == null) {
                return Center(child: Text(l10n.dataUnavailable));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileHeader(context, data, l10n, isAr),
                  const SizedBox(height: 32),
                  SectionHeader(
                    title: l10n.appPreferences,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  _buildSettingItem(
                    Icons.language,
                    l10n.language,
                    _languageSubtitle(locale, l10n),
                    isAr,
                    onTap: _pickLocale,
                  ),
                  _buildSettingItem(
                    Icons.dark_mode_outlined,
                    l10n.theme,
                    _themeSubtitle(themeMode, l10n),
                    isAr,
                    onTap: _pickTheme,
                  ),
                  _buildSettingItem(
                    Icons.notifications_active_outlined,
                    l10n.notifications,
                    _notifEnabled
                        ? l10n.notificationsEnabled
                        : l10n.notificationsDisabled,
                    isAr,
                    onTap: _toggleNotif,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                    ),
                    title: Text(
                      l10n.showNotificationCenter,
                      textAlign: TextAlign.start,
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: l10n.accountAndSecurity,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  _buildSettingItem(
                    Icons.lock_outline,
                    l10n.changePassword,
                    '',
                    isAr,
                    onTap: () => context.push('/change-password'),
                  ),
                  _buildSettingItem(
                    Icons.security_outlined,
                    l10n.twoFactor,
                    l10n.notificationsDisabled,
                    isAr,
                    onTap: _showComingSoon,
                  ),
                  _buildSettingItem(
                    Icons.privacy_tip_outlined,
                    l10n.privacy,
                    '',
                    isAr,
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: l10n.aboutUniversity,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  _buildSettingItem(
                    Icons.info_outline,
                    l10n.aboutApp,
                    'v1.0.0',
                    isAr,
                    onTap: () => context.push('/about'),
                  ),
                  _buildSettingItem(
                    Icons.support_agent,
                    l10n.technicalSupport,
                    '',
                    isAr,
                    onTap: () => _contactSupport(l10n),
                  ),
                  _buildSettingItem(
                    Icons.help_outline,
                    l10n.faqs,
                    '',
                    isAr,
                    onTap: () => context.push('/faq'),
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (!context.mounted) return;
                      context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 0.5,
                      ),
                    ),
                    child: Text(l10n.signOut),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
            loading: () => const UodScreenLoading(),
            error: (e, st) => Center(child: Text('${l10n.loadingError}: $e')),
          );
        },
        loading: () => const UodScreenLoading(),
        error: (e, st) => Center(child: Text(l10n.loadingError)),
      ),
    );
  }
Widget _buildProfileHeader(
    BuildContext context,
    Map<String, dynamic> data,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final name = data['fullName'] ?? l10n.defaultStudentName;
    final email = data['email'] ?? l10n.defaultStudentEmail;
    
    // ⬇️ التعديل هنا: فحص جميع المفاتيح المحتملة لرابط الصورة لضمان مطابقة شاشة الملف الشخصي
    final profilePhotoUrl = (data['profileImage'] as String? ?? 
                             data['profilePhotoUrl'] as String? ?? 
                             data['avatarUrl'] as String? ?? 
                             data['imageUrl'] as String?)?.trim();
                             
    final hasProfilePhoto =
        profilePhotoUrl != null && profilePhotoUrl.startsWith('http');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.primaryColor.withValues(alpha: 0.85),
                  AppTheme.primaryColor.withValues(alpha: 0.5),
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // الحاوية الدائرية للصورة الشخصية
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              // استخدام DecorationImage يضمن ملء الدائرة بالصورة دون مشاكل الـ Clip
              image: hasProfilePhoto
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(profilePhotoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // إذا لم تكن هناك صورة، يتم عرض الأيقونة الافتراضية في المنتصف
            child: !hasProfilePhoto
                ? const Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              tooltip: l10n.editProfileTooltip,
              onPressed: () => context.push('/profile'),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildSettingItem(
    IconData icon,
    String title,
    String value,
    bool isAr, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle:
            value.isNotEmpty
                ? Text(
                  value,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                )
                : null,
        trailing: Icon(
          Icons.chevron_right,
          color: theme.iconTheme.color?.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}
