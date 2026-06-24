import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/widgets/section_header.dart';

class FacultyProfilePage extends ConsumerWidget {
  const FacultyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandTeal =
        isDark ? const Color(0xFF10B981) : const Color(0xFF00A694);
    final brandNavy =
        isDark ? const Color(0xFF0D2420) : const Color(0xFF00A694);
    final cardBackgroundColor = isDark ? const Color(0xFF0D2420) : Colors.white;

    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      body: userDataAsync.when(
        data: (profileData) {
          if (profileData == null) {
            return Center(
              child: Text(
                l10n.notFoundError,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            );
          }

          final fullName = profileData['fullName'] as String? ?? l10n.excusesFacultyMember;
          final email = profileData['email'] as String? ?? 'm.ali@uod.edu.ly';
          final phone = profileData['phone'] as String? ?? '092-1234567';
          final major = profileData['major'] as String? ?? l10n.majorSoftwareEngineering;
          final facultyName =
              profileData['faculty'] as String? ?? 'كلية تقنية المعلومات';
          final jobId = profileData['universityId'] as String? ?? '202105423';
          final experienceYears =
              profileData['experienceYears']?.toString() ?? '12';
          final researchCount = profileData['researchCount']?.toString() ?? '8';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: brandNavy,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [brandTeal, brandNavy],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -50,
                        left: -50,
                        child: Opacity(
                          opacity: 0.08,
                          child: const Icon(
                            Icons.school,
                            size: 250,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAHewZag3NThmir6306uS3Y-biuEehalBuohIoKKQFn-pvLycYe3LTXQ1mNhI1w9kZ0Pr57fNQTWig-9a6Fi49qoBA_PWP0GEg42er_xyUYwGf5iU90E_xdMVnkWDeP1fb4hL0YMW4ttZ4aR_RhEY3fkdEXLVbzVYizJTA5SE5ryNY2aFoydCOXozZ5N9moHgBr57LZi8Y4uatXaUgO9feKZYcMUQFJg6bE81eCIlFzgxk2WzYmEpt_rp_U67cYjgFeLutJBU3Z6m5A',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                ).animate().scale(
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: brandNavy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.profileFacultyMember,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  facultyName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Sliver
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Quick Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                                context: context,
                                icon: Icons.work_history_rounded,
                                label: l10n.profileExperienceYears,
                                value: experienceYears,
                                brandTeal: brandTeal,
                                isDark: isDark,
                                cardBg: cardBackgroundColor,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 100.ms)
                              .slideY(begin: 0.1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                                context: context,
                                icon: Icons.menu_book_rounded,
                                label: l10n.profilePublishedResearch,
                                value: researchCount,
                                brandTeal: brandTeal,
                                isDark: isDark,
                                cardBg: cardBackgroundColor,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideY(begin: 0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2. Personal Information Section
                    SectionHeader(
                      title: l10n.profilePersonalInfo,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            cardBackgroundColor, // تم الإصلاح هنا ليدعم الوضعين
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoItem(
                            icon: Icons.badge_outlined,
                            label: l10n.profileJobId,
                            value: jobId,
                            brandTeal: brandTeal,
                            isFirst: true,
                            isDark: isDark,
                          ),
                          _buildInfoItem(
                            icon: Icons.lan_outlined,
                            label: l10n.profileSpecialization,
                            value: major,
                            brandTeal: brandTeal,
                            isDark: isDark,
                          ),
                          _buildInfoItem(
                            icon: Icons.email_outlined,
                            label: l10n.profileEmail,
                            value: email,
                            brandTeal: brandTeal,
                            isDark: isDark,
                          ),
                          _buildInfoItem(
                            icon: Icons.phone_android_outlined,
                            label: l10n.profilePhone,
                            value: phone,
                            brandTeal: brandTeal,
                            isLast: true,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                    const SizedBox(height: 24),

                    // 3. Digital Documents Section
                    SectionHeader(
                      title: l10n.profileDigitalDocuments,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentCard(
                      icon: Icons.contact_mail_rounded,
                      label: l10n.profileDownloadCard,
                      brandTeal: brandTeal,
                      cardBg: cardBackgroundColor,
                      onDownload: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.profileDownloadingCard,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                    ).animate().fadeIn(duration: 450.ms, delay: 300.ms),
                    const SizedBox(height: 10),
                    _buildDocumentCard(
                      icon: Icons.assignment_turned_in_rounded,
                      label: l10n.profileDownloadDecree,
                      brandTeal: brandTeal,
                      cardBg: cardBackgroundColor,
                      onDownload: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.profileDownloadingDecree,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                    ).animate().fadeIn(duration: 450.ms, delay: 350.ms),

                    const SizedBox(height: 36),

                    // 4. Logout Section
                    OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, ref, l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                          color:
                              isDark
                                  ? Colors.redAccent.withValues(alpha: 0.3)
                                  : const Color(0xFFFEEBEE),
                          width: 2,
                        ),
                        backgroundColor: cardBackgroundColor, // تم الإصلاح هنا
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        l10n.profileLogout,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
        loading:
            () => Center(child: CircularProgressIndicator(color: brandTeal)),
        error:
            (e, st) => Center(
              child: Text(
                '${l10n.errorPrefix}$e',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
      ),
    );
  }

  // Quick statistics widgets
  Widget _buildQuickStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color brandTeal,
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : brandTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF10B981) : brandTeal,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF10B981) : brandTeal,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // Info item card row
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color brandTeal,
    bool isFirst = false,
    bool isLast = false,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color:
                        isDark
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : brandTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF10B981) : brandTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Document download cards matching visual specs
  Widget _buildDocumentCard({
    required IconData icon,
    required String label,
    required Color brandTeal,
    required Color cardBg,
    required VoidCallback onDownload,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : brandTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF10B981) : brandTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, color: Colors.grey),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  void _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.profileLogout,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              l10n.logoutConfirmBody,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authServiceProvider).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.profileLogout,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
