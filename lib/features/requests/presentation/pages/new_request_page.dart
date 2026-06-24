import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/requests/data/requests_providers.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class NewRequestPage extends ConsumerStatefulWidget {
  final RequestType requestType;

  const NewRequestPage({super.key, required this.requestType});

  @override
  ConsumerState<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends ConsumerState<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form fields
  String _notes = '';
  int _numberOfCopies = 1;
  String _language = 'arabic';
  String _semester = '';
  String _reason = '';
  String _newMajor = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _getRequestTypeTitle(widget.requestType, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildFormFields(context, l10n),
            const SizedBox(height: 24),
            _buildSubmitButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, AppLocalizations l10n) {
    switch (widget.requestType) {
      case RequestType.graduationCertificate:
        return _buildGraduationCertificateForm(context, l10n);
      case RequestType.officialTranscript:
        return _buildOfficialTranscriptForm(context, l10n);
      case RequestType.semesterDeferral:
        return _buildSemesterDeferralForm(context, l10n);
      case RequestType.majorChange:
        return _buildMajorChangeForm(context, l10n);
    }
  }

  Widget _buildGraduationCertificateForm(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: l10n.optionalNotes,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      maxLines: 3,
      onChanged: (value) => setState(() => _notes = value),
    );
  }

  Widget _buildOfficialTranscriptForm(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.numberOfCopies,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _numberOfCopies > 1
                          ? () => setState(() => _numberOfCopies--)
                          : null,
                ),
                Text(
                  '$_numberOfCopies',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _numberOfCopies++),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.language,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          initialValue: _language,
          items: [
            DropdownMenuItem(value: 'arabic', child: Text(l10n.languageArabic)),
            DropdownMenuItem(
              value: 'english',
              child: Text(l10n.languageEnglish),
            ),
          ],
          onChanged: (value) => setState(() => _language = value!),
        ),
      ],
    );
  }

  Widget _buildSemesterDeferralForm(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.semesterToDefer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          initialValue: _semester.isEmpty ? null : _semester,
          items: const [
            DropdownMenuItem(value: 'fall2024', child: Text('Fall 2024')),
            DropdownMenuItem(value: 'spring2025', child: Text('Spring 2025')),
            DropdownMenuItem(value: 'fall2025', child: Text('Fall 2025')),
          ],
          onChanged: (value) => setState(() => _semester = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectSemester;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.reasonForRequest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.reasonRequired;
            }
            return null;
          },
          onChanged: (value) => setState(() => _reason = value),
        ),
      ],
    );
  }

  Widget _buildMajorChangeForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.newMajor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          initialValue: _newMajor.isEmpty ? null : _newMajor,
          items: const [
            DropdownMenuItem(value: 'cs', child: Text('Computer Science')),
            DropdownMenuItem(value: 'se', child: Text('Software Engineering')),
            DropdownMenuItem(
              value: 'it',
              child: Text('Information Technology'),
            ),
          ],
          onChanged: (value) => setState(() => _newMajor = value!),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectMajor;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.reasonForRequest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.reasonRequired;
            }
            return null;
          },
          onChanged: (value) => setState(() => _reason = value),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          _isSubmitting
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(
                l10n.submitRequest,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authStateChangesProvider);
      final user = authState.value;
      if (user == null) return;

      final l10n = AppLocalizations.of(context)!;
      final repository = ref.read(requestsRepositoryProvider);

      final details = _buildRequestDetails();

      final request = StudentRequest(
        id: '',
        studentId: user.uid,
        type: widget.requestType,
        status: RequestStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        details: details,
      );

      await repository.submitRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.requestSubmitted),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.requestFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, dynamic> _buildRequestDetails() {
    switch (widget.requestType) {
      case RequestType.graduationCertificate:
        return {'notes': _notes};
      case RequestType.officialTranscript:
        return {'numberOfCopies': _numberOfCopies, 'language': _language};
      case RequestType.semesterDeferral:
        return {'semester': _semester, 'reason': _reason};
      case RequestType.majorChange:
        return {'newMajor': _newMajor, 'reason': _reason};
    }
  }

  String _getRequestTypeTitle(RequestType type, AppLocalizations l10n) {
    switch (type) {
      case RequestType.graduationCertificate:
        return l10n.requestTypeGraduationCertificate;
      case RequestType.officialTranscript:
        return l10n.requestTypeOfficialTranscript;
      case RequestType.semesterDeferral:
        return l10n.requestTypeSemesterDeferral;
      case RequestType.majorChange:
        return l10n.requestTypeMajorChange;
    }
  }
}
