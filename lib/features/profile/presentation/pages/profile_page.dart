import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/settings/presentation/pages/edit_profile_image_page.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/widgets/section_header.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFields(Map<String, dynamic> data) {
    if (_initialized) return;
    _nameController.text = data['fullName'] as String? ?? '';
    _phoneController.text = data['phone'] as String? ?? '';
    _initialized = true;
  }

  Future<void> _saveProfile(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileUpdateSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.errorPrefix}$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // واجت مخصص بديل للتحميل لتجنب أخطاء الملفات المفقودة
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localImagePath = ref.watch(profileImagePathProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: auth.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.pleaseLogin));
          }

          final userProfileAsync = ref.watch(userDataProvider(user.uid));

          return userProfileAsync.when(
            data: (profile) {
              if (profile == null) {
                return Center(child: Text(l10n.userNotFoundMsg));
              }

              _initFields({
                'fullName': profile['full_name'] ?? profile['fullName'] ?? '',
                'phone': profile['phone'] ?? '',
              });

              final fullNameAr = (profile['full_name_ar'] as String?) ?? '';
              final fullNameEn = (profile['full_name_en'] as String?) ?? '';
              final id = (profile['university_id'] as String?) ?? '—';
              final email = (profile['email'] as String?) ?? '—';

              final nationalId = (profile['national_id'] as String?) ?? '';
              final dateOfBirth = profile['date_of_birth'];
              final gender = (profile['gender'] as String?) ?? '';

              final college = (profile['major'] as String?) ?? '—'; 
              final department = (profile['major'] as String?) ?? '—';
              final rawGpa = profile['gpa'] ?? '0.00';
              final gpa = (rawGpa == '0.00' || rawGpa == '0') ? '0.00' : '$rawGpa%';
              final hours = (profile['completed_hours'] ?? '0').toString();

              final netUrl = profile['profile_photo_url'] as String?;

              final localPath = localImagePath.value;
              final hasLocal =
                  localPath != null &&
                  localPath.isNotEmpty &&
                  File(localPath).existsSync();
              final hasNet = netUrl != null && netUrl.trim().startsWith('http');

              Widget avatarChild;
              if (hasLocal) {
                avatarChild = Image.file(
                  File(localPath),
                  fit: BoxFit.cover,
                  width: 96,
                  height: 96,
                );
              } else if (hasNet) {
                avatarChild = CachedNetworkImage(
                  imageUrl: netUrl.trim(),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, _) => UodShimmer(
                        width: 96,
                        height: 96,
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: ColoredBox(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                  errorWidget:
                      (_, _, _) => Icon(
                        Icons.person,
                        size: 48,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                );
              } else {
                avatarChild = Icon(
                  Icons.person,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                );
              }

              String formattedDob = '—';
              if (dateOfBirth != null) {
                try {
                  if (dateOfBirth is Timestamp) {
                    formattedDob = DateFormat('yyyy-MM-dd').format(dateOfBirth.toDate());
                  } else if (dateOfBirth is DateTime) {
                    formattedDob = DateFormat('yyyy-MM-dd').format(dateOfBirth);
                  } else {
                    formattedDob = dateOfBirth.toString();
                  }
                } catch (_) {
                  formattedDob = '—';
                }
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/edit-profile-image');
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: ClipOval(child: avatarChild),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.secondaryColor,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fullNameAr.isNotEmpty
                                  ? fullNameAr
                                  : (_nameController.text.isEmpty
                                      ? l10n.defaultStudentName
                                      : _nameController.text),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (fullNameEn.isNotEmpty)
                              Text(
                                fullNameEn,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            Text(
                              '${l10n.registrationNumberPrefix}$id',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.05),
                    const SizedBox(height: 12),
                    _sectionCard(
                      context,
                      title: l10n.fullNameLabel,
                      icon: Icons.person_outline,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.fullName,
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.errorRequired(l10n.fullName);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.authLabelPhone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.05),
                    const SizedBox(height: 12),
                    _sectionCard(
                      context,
                      title: l10n.contactInfo,
                      icon: Icons.contact_mail_outlined,
                      children: [
                        TextFormField(
                          initialValue: email,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.emailLabel,
                            prefixIcon: const Icon(Icons.email_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => context.push('/edit-email'),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.05),
                    const SizedBox(height: 12),

                    _sectionCard(
                      context,
                      title: 'المعلومات الرسمية',
                      icon: Icons.badge_outlined,
                      children: [
                        _readOnlyRow('الرقم الوطني', nationalId.isNotEmpty ? nationalId : '—'),
                        _readOnlyRow('الجنس', gender.isNotEmpty ? gender : '—'),
                        _readOnlyRow('تاريخ الميلاد', formattedDob),
                      ],
                    ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.05),
                    const SizedBox(height: 12),

                    _sectionCard(
                      context,
                      title: l10n.academicInfo,
                      icon: Icons.school_outlined,
                      children: [
                        _readOnlyRow(l10n.profileStudentId, id),
                        _readOnlyRow(l10n.collegesTitle, college),
                        _readOnlyRow(l10n.profileDepartment, department),
                        _readOnlyRow(l10n.cumulativeGpa, gpa),
                        _readOnlyRow(l10n.completedHours, hours),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Divider(height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              context.push('/academic-plan');
                            },
                            icon: const Icon(
                              Icons.assignment_outlined,
                              size: 18,
                            ),
                            label: Text(
                              l10n.viewAndTrackAcademicPlan,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.05),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed:
                          _isSaving ? null : () => _saveProfile(user.uid),
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save_outlined),
                      label: Text(l10n.profileSaveChanges),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.05),
                  ],
                ),
              );
            },
            loading: () => _buildLoadingWidget(),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          );
        },
        loading: () => _buildLoadingWidget(),
        error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, icon: icon, padding: EdgeInsets.zero),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}