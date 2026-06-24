import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';
import 'package:flutter_project/core/providers/service_providers.dart';

final _studentExcuseCoursesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, studentId) async {
      if (studentId.isEmpty) return const <String>[];

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get();
      final data = snapshot.data() ?? {};

      return _extractCourseNames(data['enrolledCourses'] ?? data['courses']);
    });

List<String> _extractCourseNames(dynamic value) {
  final names = <String>{};

  void addCourse(dynamic item) {
    if (item == null) return;

    if (item is String) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) names.add(trimmed);
      return;
    }

    if (item is Map) {
      for (final key in const [
        'course_name',
        'name',
        'title',
        'subjectName',
        'subject',
        'courseTitle',
      ]) {
        final raw = item[key];
        if (raw is String && raw.trim().isNotEmpty) {
          names.add(raw.trim());
          return;
        }
      }
    }
  }

  if (value is Iterable) {
    for (final item in value) {
      addCourse(item);
    }
  } else if (value is Map) {
    for (final item in value.values) {
      addCourse(item);
    }
  } else {
    addCourse(value);
  }

  return names.toList()..sort();
}

class AbsenceExcusePage extends ConsumerStatefulWidget {
  const AbsenceExcusePage({super.key});

  @override
  ConsumerState<AbsenceExcusePage> createState() => _AbsenceExcusePageState();
}

class _AbsenceExcusePageState extends ConsumerState<AbsenceExcusePage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSubject;
  DateTimeRange? _selectedDateRange;
  String? _selectedExcuseType;
  final _reasonController = TextEditingController();

  File? _attachment;
  bool _isUploading = false;

  List<String> _getExcuseTypes(AppLocalizations l10n) => [
    l10n.excuseTypeSick,
    l10n.excuseTypeEmergency,
    l10n.excuseTypeFamily,
    l10n.excuseTypeOther,
  ];

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 3)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _pickAttachment() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: Text(
                    AppLocalizations.of(context)!.takePhoto,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (picked != null) _processFile(File(picked.path));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(
                    AppLocalizations.of(context)!.chooseFromGallery,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (picked != null) _processFile(File(picked.path));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(
                    AppLocalizations.of(context)!.choosePdf,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      _processFile(File(result.files.single.path!));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _processFile(File file) {
    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.fileSizeError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }
    setState(() => _attachment = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.selectDateError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }
    if (_selectedExcuseType == l10n.excuseTypeSick && _attachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.medicalAttachmentRequired,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = ref.read(authStateChangesProvider).value;
      final l10n = AppLocalizations.of(context)!;
      if (user == null) throw Exception(l10n.userNotLoggedIn);

      // Get student data
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final userData = userDoc.data() ?? {};
      final studentName = userData['fullName'] ?? 'Ø·Ø§Ù„Ø¨';
      final studentNumber = userData['studentNumber'] ?? '';

      // Get professor ID for the course (simplified - would need course lookup)
      final professorId = 'default_professor';

      String? attachmentUrl;
      String? attachmentType;
      if (_attachment != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = p.extension(_attachment!.path);
        final ref = FirebaseStorage.instance.ref().child(
          'excuses/${user.uid}/$timestamp$ext',
        );
        await ref.putFile(_attachment!);
        attachmentUrl = await ref.getDownloadURL();
        attachmentType = ext.replaceFirst('.', '');
      }

      final service = ref.read(integrationServiceProvider);
      await service.submitAbsenceExcuse(
        studentId: user.uid,
        studentName: studentName,
        studentNumber: studentNumber,
        courseId: 'default_course',
        courseName: _selectedSubject ?? 'ØºÙŠØ± Ù…Ø­Ø¯Ø¯',
        professorId: professorId,
        absenceDate: _selectedDateRange!.start,
        reason: _reasonController.text.trim(),
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'âŒ ${l10n.submissionError(e.toString())}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            content: Text(
              AppLocalizations.of(context)!.excuseSubmittedSuccess,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
            actions: [
              Center(
                child: TapScale(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.backToHome,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final user = ref.watch(authStateChangesProvider).value;
    final coursesAsync = ref.watch(
      _studentExcuseCoursesProvider(user?.uid ?? ''),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.absenceExcuseTitle,
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
        body:
            _isUploading
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.uploadingRequest,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(AppLocalizations.of(context)!.subjectLabel),
                        coursesAsync.when(
                          data: (courses) {
                            final selectedSubject =
                                courses.contains(_selectedSubject)
                                    ? _selectedSubject
                                    : null;
                            return DropdownButtonFormField<String>(
                              initialValue: selectedSubject,
                              decoration: _inputDecoration(Icons.book_rounded),
                              hint: Text(
                                courses.isEmpty ? 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…ÙˆØ§Ø¯ Ù…Ø³Ø¬Ù„Ø©' : '',
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              items:
                                  courses
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            s,
                                            style: const TextStyle(
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  courses.isEmpty
                                      ? null
                                      : (val) => setState(
                                        () => _selectedSubject = val,
                                      ),
                              validator:
                                  (val) =>
                                      val == null
                                          ? AppLocalizations.of(
                                            context,
                                          )!.selectSubjectError
                                          : null,
                            );
                          },
                          loading:
                              () => DropdownButtonFormField<String>(
                                initialValue: null,
                                decoration: _inputDecoration(
                                  Icons.book_rounded,
                                ),
                                items: const <DropdownMenuItem<String>>[],
                                onChanged: null,
                                hint: const Text(
                                  'Ø¬Ø§Ø±ÙŠ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…ÙˆØ§Ø¯...',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                          error:
                              (error, stack) => DropdownButtonFormField<String>(
                                initialValue: null,
                                decoration: _inputDecoration(
                                  Icons.book_rounded,
                                ),
                                items: const <DropdownMenuItem<String>>[],
                                onChanged: null,
                                hint: const Text(
                                  'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…ÙˆØ§Ø¯ Ù…Ø³Ø¬Ù„Ø©',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(
                          AppLocalizations.of(context)!.absencePeriodLabel,
                        ),
                        InkWell(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDateRange == null
                                        ? AppLocalizations.of(
                                          context,
                                        )!.selectDatesHint
                                        : '${_selectedDateRange!.start.toString().split(' ')[0]}  Ø¥Ù„Ù‰  ${_selectedDateRange!.end.toString().split(' ')[0]}',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color:
                                          _selectedDateRange == null
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(
                          AppLocalizations.of(context)!.excuseTypeLabel,
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedExcuseType,
                          decoration: _inputDecoration(Icons.category_rounded),
                          items:
                              _getExcuseTypes(AppLocalizations.of(context)!)
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) =>
                                  setState(() => _selectedExcuseType = val),
                          validator:
                              (val) =>
                                  val == null
                                      ? AppLocalizations.of(
                                        context,
                                      )!.selectExcuseTypeError
                                      : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(
                          AppLocalizations.of(context)!.descriptionLabel,
                        ),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.descriptionHint,
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? AppLocalizations.of(
                                        context,
                                      )!.writeReasonError
                                      : null,
                        ),
                        const SizedBox(height: 12),

                        _buildLabel(
                          AppLocalizations.of(context)!.attachmentsLabel,
                        ),
                        InkWell(
                          onTap: _pickAttachment,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                if (_attachment == null) ...[
                                  Icon(
                                    Icons.cloud_upload_rounded,
                                    size: 48,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.tapToAttach,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.maxFileSize,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 48,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.basename(_attachment!.path),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () =>
                                            setState(() => _attachment = null),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.removeAttachment,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        TapScale(
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.submitRequest,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8.0, start: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
    );
  }
}
