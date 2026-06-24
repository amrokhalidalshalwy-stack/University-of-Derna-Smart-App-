import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/l10n/localized_content.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/study/presentation/pages/news_and_events_page.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

class DepartmentInfoPage extends ConsumerWidget {
  const DepartmentInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }

        final profileAsync = ref.watch(userDataProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.departmentInfoTitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: profileAsync.when(
            data: (data) => _buildBody(context, data ?? {}, l10n),
            loading: () => const UodScreenLoading(),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          ),
        );
      },
      loading: () => const UodScreenLoading(),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.authError))),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Map<String, dynamic> data,
    AppLocalizations l10n,
  ) {
    final major = localizedMajor(data['major'] as String?, l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroCard(context, major, l10n).animate().fadeIn().scale(),
          const SizedBox(height: 32),
          _buildSectionTitle(context, l10n.academicAdvisorTitle, l10n),
          const SizedBox(height: 12),
          _buildAdvisorCard(
            context,
            l10n,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
          const SizedBox(height: 32),
          _buildSectionTitle(context, l10n.departmentNewsTitle, l10n),
          const SizedBox(height: 12),
          _buildNewsList(context, l10n).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    AppLocalizations l10n,
  ) {
    final isNewsSection = title == l10n.departmentNewsTitle;

    return InkWell(
      onTap:
          isNewsSection
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewsAndEventsPage(),
                  ),
                );
              }
              : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isNewsSection
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Cairo',
              ),
            ),
            if (isNewsSection) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    String major,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            major,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.collegeItSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:
                  Colors.white70, // تغيير اللون ليكون أبيض شفاف لضمان التباين
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.person, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.advisorNameSample,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    l10n.advisorRoleSample,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final news = [
      (l10n.newsResearchTitle, l10n.newsResearchDate),
      (l10n.newsAiSeminarTitle, l10n.newsAiSeminarDate),
      (l10n.newsExamsTitle, l10n.newsExamsDate),
    ];

    return Column(
      children:
          news
              .map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsAndEventsPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ), // خلفية متفاعلة مع الثيم
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          n.$1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: colorScheme.onSurface, // لون نص واضح جداً
                          ),
                        ),
                        subtitle: Text(
                          n.$2,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
