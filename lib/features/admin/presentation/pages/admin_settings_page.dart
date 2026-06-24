import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  // Mock settings state
  bool _allowStudentRegistration = true;
  bool _allowFacultyRegistration = true;
  bool _maintenanceMode = false;

  String _languageSubtitle(Locale locale) {
    return locale.languageCode == 'ar' ? 'العربية' : 'English';
  }

  Future<void> _pickLocale() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('تلقائي (النظام)'),
                leading: const Icon(Icons.language),
                onTap: () => Navigator.pop(ctx, 'system'),
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () => Navigator.pop(ctx, 'ar'),
              ),
              ListTile(
                title: const Text('English'),
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


  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات إدارة النظام'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── إعدادات المظهر واللغة ──────────────────────────────────────────
          _buildSectionTitle(context, 'المظهر واللغة'),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('الوضع الليلي'),
                  subtitle: const Text('تفعيل أو تعطيل المظهر الداكن'),
                  secondary: const Icon(Icons.dark_mode),
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeNotifierProvider.notifier).setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('لغة التطبيق'),
                  subtitle: Text(_languageSubtitle(locale)),
                  leading: const Icon(Icons.language),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _pickLocale,
                ),
              ],
            ),
          ),

          // ── إدارة الصلاحيات العامة (Mock) ─────────────────────────────────
          _buildSectionTitle(context, 'إدارة الصلاحيات العامة'),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('السماح بتسجيل الطلاب'),
                  subtitle: const Text('فتح أو إغلاق التسجيل للطلاب الجدد'),
                  secondary: const Icon(Icons.person_add),
                  value: _allowStudentRegistration,
                  onChanged: (value) {
                    setState(() {
                      _allowStudentRegistration = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('السماح بتسجيل أعضاء هيئة التدريس'),
                  subtitle: const Text('فتح أو إغلاق التسجيل للأساتذة'),
                  secondary: const Icon(Icons.school),
                  value: _allowFacultyRegistration,
                  onChanged: (value) {
                    setState(() {
                      _allowFacultyRegistration = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('وضع الصيانة'),
                  subtitle: const Text('إيقاف النظام مؤقتاً للتحديثات'),
                  secondary: const Icon(Icons.build),
                  activeThumbColor: Colors.red,
                  value: _maintenanceMode,
                  onChanged: (value) {
                    setState(() {
                      _maintenanceMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // ── عن التطبيق ───────────────────────────────────────────────────
          const SizedBox(height: 16),
          Center(
            child: const Text(
              'جامعة درنة © 1994 — uod.edu.ly',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, right: 8.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
