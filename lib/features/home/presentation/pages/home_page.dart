import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/widgets/section_header.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/core/providers/app_providers.dart';
import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;

    return authState.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }
        final userData = ref.watch(userDataProvider(user.uid));
        return userData.when(
          data:
              (data) =>
                  data == null
                      ? Scaffold(
                        body: Center(child: Text(l10n.dataUnavailable)),
                      )
                      : _HomeContent(uid: user.uid, userData: data),
          loading: () => Scaffold(body: UodScreenLoading()),
          error:
              (e, _) => Scaffold(
                body: Center(child: Text('${l10n.loadingError}: $e')),
              ),
        );
      },
      loading: () => Scaffold(body: UodScreenLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.loadingError))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HomeContent extends ConsumerWidget {
  final String uid;
  final Map<String, dynamic> userData;

  const _HomeContent({required this.uid, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildGreetingHeader(context, l10n, isAr),
                  const SizedBox(height: 16),
                  _buildStatsRow(context, ref, l10n, theme),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: l10n.academicServices,
                    icon: Icons.grid_view_rounded,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureGrid(context, l10n),
                  const SizedBox(height: 24),
                  _buildNotificationsSection(context, ref, l10n, theme),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// ── App Bar ───────────────────────────────────────────────────────────────
  // ✅ تم تعديل هنا: إضافة اللون الأبيض للنص وإخفاء أيقونة الشات/النقاش
  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
        centerTitle: true,
        title: Text(
          // 1. تم حذف const من هنا
          AppLocalizations.of(
            context,
          )!.appTitle, // 2. تم إضافة الفاصلة المفقودة هنا
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
            color: Colors.white, // ✅ اللون الأبيض للوضع الفاتح
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryContainer],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          tooltip: 'الملف الشخصي',
          onPressed: () => context.push('/profile'),
        ),
        // 🗑️ تم حذف أيقونة ساحة النقاش (Icons.forum) من هنا بشكل كامل لإخفائها قبل التسليم
      ],
    );
  }
  // ── Greeting Header ───────────────────────────────────────────────────────
  Widget _buildGreetingHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    final String timeEmoji;
    if (hour < 12) {
      timeGreeting = l10n.goodMorning; // ✅ تم التعديل هنا بدلاً من 'صباح الخير'
      timeEmoji = '🌅';
    } else if (hour < 17) {
      timeGreeting = l10n.goodEvening; // ✅ تم التعديل هنا بدلاً من 'مساء الخير'
      timeEmoji = '☀️';
    } else {
      timeGreeting =
          l10n.goodEveningReply; // ✅ تم التعديل هنا بدلاً من 'مساء النور'
      timeEmoji = '🌙';
    }

    final name = (userData['fullName'] as String? ?? '').split(' ').first;
    final major = userData['major'] as String? ?? l10n.unspecifiedMajor;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(timeEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$timeGreeting، $name!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? theme.colorScheme.onSurface
                          : AppTheme.primaryColor,
                  fontFamily: 'Cairo',
                  height: 1.3,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
        const SizedBox(height: 6),
        Text(
          major,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppTheme.onSurfaceVariantColor,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 150.ms),
      ],
    );
  }
  // ── Stats Row ─────────────────────────────────────────────────────────────
Widget _buildStatsRow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // 1. جلب الـ AsyncValue بالكامل بدلاً من .value مباشرة لمنع السقوط لـ null أثناء التحميل
    final gpaAsync = ref.watch(computedGpaProviderDirect(uid));
    final hoursAsync = ref.watch(computedCompletedHoursProviderDirect(uid));

    // 2. التحقق الذكي: إذا كان الـ Provider يمتلك قيمة نأخذها، وإذا كان يحمل (Loading) نتمسك بالقيمة السابقة، وإلا نعود للـ userData
    final gpa = gpaAsync.hasValue 
        ? gpaAsync.value 
        : (userData['gpa'] ?? '0.00');

    final hours = hoursAsync.hasValue 
        ? hoursAsync.value 
        : (userData['completedHours'] ?? '0');

    final displayGpa = (gpa == '0.00' || gpa == '0') ? '0.00' : '$gpa%';
    final displayHours = (hours == '0' || hours == '0.00') ? '0' : hours;

    debugPrint(
      '📱 HomePage: gpa from provider = "$gpa", displayGpa = "$displayGpa"',
    );
    debugPrint(
      '📱 HomePage: hours from provider = "$hours", displayHours = "$displayHours"',
    );

    return Row(
      children: [
        _StatCard(
          title: l10n.cumulativeGpa,
          value: displayGpa,
          icon: Icons.star_rounded,
          accentColor: const Color(0xFFFF9800),
          subtitle: _gpaLabel(
            double.tryParse(gpa.toString()) ?? 0,
            l10n,
          ), 
        ),
        const SizedBox(width: 14),
        _StatCard(
          title: l10n.completedHours,
          value: displayHours.toString(),
          icon: Icons.school_rounded,
          accentColor: AppTheme.tertiaryColor,
          subtitle: l10n.earnedHours, 
        ),
      ],
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
  }
  
  String _gpaLabel(double gpa, AppLocalizations l10n) {
    // ✅ تم إضافة AppLocalizations l10n هنا كمتغير
    if (gpa >= 85) return l10n.excellent; // ✅ تم التعديل هنا بدلاً من 'ممتاز'
    if (gpa >= 75) {
      return l10n.veryGood; // ✅ تم التعديل هنا بدلاً من 'جيد جداً'
    }
    if (gpa >= 65) return l10n.good; // ✅ تم التعديل هنا بدلاً من 'جيد'
    if (gpa >= 50) return l10n.pass; // ✅ تم التعديل هنا بدلاً من 'مقبول'
    return '—';
  }

  // ── Feature Grid ──────────────────────────────────────────────────────────

  Widget _buildFeatureGrid(BuildContext context, AppLocalizations l10n) {
    final features = [
      _FeatureData(
        title: l10n.grades,
        icon: Icons.assignment_rounded,
        path: '/grades',
        color: const Color(0xFF4CAF50),
      ),
      _FeatureData(
        title: l10n.attendance,
        icon: Icons.fact_check_rounded,
        path: '/attendance',
        color: const Color(0xFF9C27B0),
      ),
      _FeatureData(
        title: l10n.schedule,
        icon: Icons.calendar_month_rounded,
        path: '/schedule',
        color: const Color(0xFF2196F3),
      ),
      _FeatureData(
        title: l10n.absenceExcuse, // ✅ تم التعديل هنا بدلاً من 'عذر الغياب'
        icon: Icons.edit_note_rounded,
        path: '/absence-excuse',
        color: const Color(0xFFFF9800),
      ),
      _FeatureData(
        title: l10n.examPapers, // ✅ تم التعديل هنا بدلاً من 'أوراق الامتحانات'
        icon: Icons.description_rounded,
        path: '/exam-papers',
        color: const Color(0xFF009688),
      ),
      _FeatureData(
        title:
            l10n.registrationRenewal, // ✅ تم التعديل هنا بدلاً من 'تجديد القيد'
        icon: Icons.autorenew_rounded,
        path: '/registration-renewal',
        color: const Color(0xFF3F51B5),
      ),
      _FeatureData(
        title: l10n.eRequests,
        icon: Icons.inbox_rounded,
        path: '/e-requests',
        color: const Color(0xFFE91E63),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;
        double mainAxisSpacing;
        double crossAxisSpacing;

        if (screenWidth > 1200) {
          // Desktop: 4 columns
          crossAxisCount = 4;
          childAspectRatio = 1.0;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else if (screenWidth > 768) {
          // Tablet: 3 columns
          crossAxisCount = 3;
          childAspectRatio = 0.95;
          mainAxisSpacing = 14;
          crossAxisSpacing = 14;
        } else {
          // Mobile: 2 columns
          crossAxisCount = 2;
          childAspectRatio = 0.9;
          mainAxisSpacing = 12;
          crossAxisSpacing = 12;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return _FeatureItem(data: f, onTap: () => context.push(f.path))
                .animate()
                .fadeIn(delay: (300 + index * 60).ms)
                .scale(begin: const Offset(0.88, 0.88));
          },
        );
      },
    );
  } // ── Notifications Section ─────────────────────────────────────────────────
  // ✅ يعرض العنوان + "عرض الكل" فقط إذا كانت هناك إشعارات فعلية

  Widget _buildNotificationsSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final notifs = ref.watch(notificationListProvider(uid));

    return notifs.when(
      data: (list) {
        // ✅ لا mock data — إذا فارغة لا نعرض القسم كاملاً
        if (list.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: l10n.latestNotifications,
              icon: Icons.notifications_rounded,
              onSeeAll: () => context.push('/notifications'),
              seeAllText: 'عرض الكل',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 14),
            ...list
                .take(3)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => _NotificationTile(n: e.value)
                      .animate()
                      .fadeIn(delay: (500 + e.key * 80).ms)
                      .slideX(begin: 0.04),
                ),
          ],
        );
      },
      loading:
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: l10n.latestNotifications,
                icon: Icons.notifications_rounded,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ],
          ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [theme.cardColor, theme.cardColor.withValues(alpha: 0.8)]
                    : [Colors.white, Colors.white.withValues(alpha: 0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border(top: BorderSide(color: accentColor, width: 3)),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? theme.colorScheme.onSurface
                              : AppTheme.primaryColor,
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isDark
                              ? theme.colorScheme.onSurfaceVariant
                              : AppTheme.onSurfaceVariantColor,
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: accentColor,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final IconData icon;
  final String path;
  final Color color;

  const _FeatureData({
    required this.title,
    required this.icon,
    required this.path,
    required this.color,
  });
}

class _FeatureItem extends StatelessWidget {
  final _FeatureData data;
  final VoidCallback onTap;

  const _FeatureItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color:
          isDark
              ? theme.cardColor.withValues(alpha: 0.6)
              : data.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: data.color.withValues(alpha: 0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        theme.cardColor,
                        theme.cardColor.withValues(alpha: 0.5),
                      ]
                      : [
                        data.color.withValues(alpha: 0.05),
                        data.color.withValues(alpha: 0.1),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: isDark ? 0.25 : 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: data.color, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? theme.colorScheme.onSurface : data.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  const _NotificationTile({required this.n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (iconData, tileColor) = _categoryStyle(n.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [theme.cardColor, theme.cardColor.withValues(alpha: 0.7)]
                  : [Colors.white, Colors.white.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              n.isRead
                  ? theme.dividerColor.withValues(alpha: 0.3)
                  : tileColor.withValues(alpha: 0.4),
          width: n.isRead ? 0.8 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tileColor.withValues(alpha: isDark ? 0.3 : 0.15),
                tileColor.withValues(alpha: isDark ? 0.2 : 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, size: 20, color: tileColor),
        ),
        title: Text(
          n.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color:
                isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          n.body,
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppTheme.onSurfaceVariantColor,
            fontFamily: 'Cairo',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            !n.isRead
                ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: tileColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tileColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                )
                : null,
      ),
    );
  }

  (IconData, Color) _categoryStyle(String? category) {
    final c = (category ?? '').toLowerCase();
    if (c.contains('grade') || c.contains('درجة')) {
      return (Icons.grade_rounded, const Color(0xFF4CAF50));
    }
    if (c.contains('تنبيه') || c.contains('alert') || c.contains('غياب')) {
      return (Icons.warning_amber_rounded, const Color(0xFFFF9800));
    }
    if (c.contains('إعلان') || c.contains('announcement')) {
      return (Icons.campaign_rounded, AppTheme.tertiaryColor);
    }
    return (Icons.notifications_rounded, AppTheme.primaryColor);
  }
}
