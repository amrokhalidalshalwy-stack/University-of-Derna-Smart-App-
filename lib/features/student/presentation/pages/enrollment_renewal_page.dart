import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/student/data/academic_year_provider.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';

enum EnrollmentStatus {
  pending,
  adminApproved,
  adminRejected;

  static EnrollmentStatus fromString(String? s) {
    return values.firstWhere((e) => e.name == s, orElse: () => pending);
  }
}

enum PaymentMethod {
  bank,
  libyaBank,
  online;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case bank:
        return l10n.paymentMethodBank;
      case libyaBank:
        return l10n.paymentMethodLibyaBank;
      case online:
        return l10n.paymentMethodOnline;
    }
  }
}

final enrollmentStatusProvider = FutureProvider.autoDispose
    .family<DocumentSnapshot?, String>((ref, uid) async {
      if (uid.isEmpty) return null;
      final academicYear = ref.read(academicYearProvider);
      final snapshot =
          await FirebaseFirestore.instance
              .collection('renewal_requests')
              .where('uid', isEqualTo: uid)
              .where(
                'academicYear',
                isEqualTo: academicYear,
              )
              .limit(1)
              .get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    });

class EnrollmentRenewalPage extends ConsumerStatefulWidget {
  const EnrollmentRenewalPage({super.key});


  @override
  ConsumerState<EnrollmentRenewalPage> createState() =>
      _EnrollmentRenewalPageState();
}

class _EnrollmentRenewalPageState extends ConsumerState<EnrollmentRenewalPage> {
  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  bool _isUploading = false;
  String _referenceNumber = '';

  @override
  void initState() {
    super.initState();
    _referenceNumber =
        'RNW-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.selectPaymentMethodError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submitRenewal() async {
    setState(() => _isUploading = true);
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    try {
      final academicYear = ref.read(academicYearProvider);
      final feesAmount = ref.read(feesAmountProvider);
      await FirebaseFirestore.instance.collection('renewal_requests').add({
        'uid': user.uid,
        'referenceNumber': _referenceNumber,
        'status': EnrollmentStatus.pending.name,
        'paymentMethod': _selectedPaymentMethod?.name,
        'submittedAt': FieldValue.serverTimestamp(),
        'academicYear': academicYear,
        'feesAmount': feesAmount,
      });
      ref.invalidate(enrollmentStatusProvider);
      if (mounted) {
        setState(() {
          _isUploading = false;
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.submissionError(e.toString()),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.enrollmentRenewalTitle ??
                'ØªØ¬Ø¯ÙŠØ¯ Ø§Ù„Ù‚ÙŠØ¯',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userDataAsync = ref.watch(userDataProvider(user.uid));
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.enrollmentRenewalTitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ref
            .watch(enrollmentStatusProvider(user.uid))
            .when(
              data: (existingDoc) {
                if (existingDoc != null) {
                  final data = existingDoc.data() as Map<String, dynamic>;
                  _referenceNumber =
                      data['referenceNumber'] ?? _referenceNumber;
                  final status = EnrollmentStatus.fromString(
                    data['status'] as String?,
                  );
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildConfirmationCard(context, primaryColor, status),
                        const SizedBox(height: 16),
                        TapScale(
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.backToHome,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return userDataAsync.when(
                  data: (profile) {
                    final fullName = profile?['fullName'] as String? ?? 'Ø·Ø§Ù„Ø¨';
                    final studentId = profile?['student_id'] as String? ?? 'N/A';
                    final college =
                        profile?['college'] as String? ?? 'ÙƒÙ„ÙŠØ© Ø§Ù„Ù‡Ù†Ø¯Ø³Ø©';

                    return Stepper(
                      currentStep: _currentStep,
                      onStepContinue:
                          _currentStep == 0
                              ? _nextStep
                              : _currentStep == 1
                              ? _submitRenewal
                              : () => context.pop(),
                      onStepCancel: _currentStep == 0 ? null : _previousStep,
                      controlsBuilder: (context, details) {
                        if (_currentStep == 2) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TapScale(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Ø§Ù„Ø¹ÙˆØ¯Ø© Ù„Ù„Ø±Ø¦ÙŠØ³ÙŠØ©',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TapScale(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isUploading
                                            ? null
                                            : details.onStepContinue,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        _isUploading
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              _currentStep == 0
                                                  ? AppLocalizations.of(
                                                    context,
                                                  )!.startRenewalProcess
                                                  : AppLocalizations.of(
                                                    context,
                                                  )!.confirmPayment,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              if (_currentStep > 0 && !_isUploading) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TapScale(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: Text(
                            AppLocalizations.of(context)!.reviewDataStep,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: _buildReviewStep(
                            fullName,
                            studentId,
                            college,
                          ),
                          isActive: _currentStep >= 0,
                          state:
                              _currentStep > 0
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                        Step(
                          title: Text(
                            AppLocalizations.of(context)!.paymentMethodStep,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: _buildPaymentStep(primaryColor),
                          isActive: _currentStep >= 1,
                          state:
                              _currentStep > 1
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                        Step(
                          title: Text(
                            AppLocalizations.of(context)!.requestStatusStep,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: _buildConfirmationCard(
                            context,
                            primaryColor,
                            EnrollmentStatus.pending,
                          ),
                          isActive: _currentStep >= 2,
                          state:
                              _currentStep == 2
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, st) => Center(
                        child: Text(
                          'Ø®Ø·Ø£: $err',
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, st) => Center(
                    child: Text(
                      'Ø®Ø·Ø£: $err',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
            ),
      ),
    );
  }

  Widget _buildReviewStep(String name, String studentId, String college) {
    final academicYear = ref.watch(academicYearProvider);
    final deadline = ref.watch(deadlineProvider);
    final feesAmount = ref.watch(feesAmountProvider);
    
    return StaggeredFadeInSlideY(
      index: 0,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _detailRow(
                context,
                AppLocalizations.of(context)!.studentNameLabel,
                name,
              ),
              const Divider(),
              _detailRow(
                context,
                AppLocalizations.of(context)!.studentIdLabel,
                studentId,
              ),
              const Divider(),
              _detailRow(
                context,
                AppLocalizations.of(context)!.collegeLabel,
                college,
              ),
              const Divider(),
              _detailRow(
                context,
                AppLocalizations.of(context)!.academicYearLabel,
                academicYear,
              ),
              const Divider(),
              _detailRow(
                context,
                AppLocalizations.of(context)!.deadlineLabel,
                deadline,
                color: Theme.of(context).colorScheme.error,
              ),
              const Divider(),
              _detailRow(
                context,
                AppLocalizations.of(context)!.feesRequiredLabel,
                feesAmount.replaceAll('LYD', 'Ø¯.Ù„'),
                color: Theme.of(context).colorScheme.primary,
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(Color primaryColor) {
    return Column(
      children: [
        _paymentCard(
          method: PaymentMethod.bank,
          primaryColor: primaryColor,
          index: 1,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.republicBank,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.bankAccountNumber,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.beneficiary,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TapScale(
                child: ElevatedButton.icon(
                  onPressed:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.receiptAttached,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(
                    AppLocalizations.of(context)!.attachReceipt,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _paymentCard(
          method: PaymentMethod.libyaBank,
          primaryColor: primaryColor,
          index: 2,
          expandedContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.libyaCentralBank,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.cardPayment,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeInSlideY(
          index: 3,
          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            child: ListTile(
              leading: Radio<PaymentMethod>(
                value: PaymentMethod.online,
                // ignore: deprecated_member_use
                groupValue: _selectedPaymentMethod,
                // ignore: deprecated_member_use
                onChanged: null,
              ),
              title: Text(
                AppLocalizations.of(context)!.paymentMethodOnline,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.comingSoon,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentCard({
    required PaymentMethod method,
    required Color primaryColor,
    required Widget expandedContent,
    required int index,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return StaggeredFadeInSlideY(
      index: index,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isSelected
                    ? primaryColor
                    : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: RadioListTile<PaymentMethod>(
          controlAffinity:
              ListTileControlAffinity
                  .leading, // Ù„ØªÙˆØ­ÙŠØ¯ Ø¬Ù‡Ø© Ø¯Ø§Ø¦Ø±Ø© Ø§Ù„Ø§Ø®ØªÙŠØ§Ø± Ù„Ù„ÙŠÙ…ÙŠÙ†
          title: Text(
            method.getLabel(AppLocalizations.of(context)!),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle:
              isSelected
                  ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: expandedContent,
                  )
                  : null,
          value: method,
          // ignore: deprecated_member_use
          groupValue: _selectedPaymentMethod,
          // ignore: deprecated_member_use
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedPaymentMethod = val);
            }
          },
          activeColor: primaryColor,
        ),
      ),
    );
  }

  Widget _buildConfirmationCard(
    BuildContext context,
    Color primaryColor,
    EnrollmentStatus status,
  ) {
    final IconData icon;
    final Color iconColor;
    final Color bgColor;
    final String title;
    final String message;

    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case EnrollmentStatus.adminApproved:
        icon = Icons.check_circle_rounded;
        iconColor = Theme.of(context).colorScheme.primary;
        bgColor = Theme.of(context).colorScheme.primaryContainer;
        title = l10n.requestApproved;
        message = l10n.requestApprovedMessage;
      case EnrollmentStatus.adminRejected:
        icon = Icons.cancel_rounded;
        iconColor = Theme.of(context).colorScheme.error;
        bgColor = Theme.of(context).colorScheme.errorContainer;
        title = l10n.requestRejected;
        message = l10n.requestRejectedMessage;
      case EnrollmentStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        iconColor = Theme.of(context).colorScheme.tertiary;
        bgColor = Theme.of(context).colorScheme.tertiaryContainer;
        title = l10n.requestPending;
        message = l10n.requestPendingMessage;
    }

    return FadeInScale(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.referenceNumberLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _referenceNumber,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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
