import 'package:flutter/material.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class ExamPaperUploadPage extends ConsumerStatefulWidget {
  const ExamPaperUploadPage({super.key});

  @override
  ConsumerState<ExamPaperUploadPage> createState() => _ExamPaperUploadPageState();
}

class _ExamPaperUploadPageState extends ConsumerState<ExamPaperUploadPage> {
  String? _selectedSubject;
  String? _selectedExamType;
  File? _pdfFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) {
        return;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('faculty_id', isEqualTo: user.uid)
          .get();

      final Set<String> uniqueSubjects = {};
      for (var doc in snapshot.docs) {
        final courseId = doc.data()['course_id'] as String?;
        final courseTitle = doc.data()['courseTitle'] as String?;
        if (courseId != null && courseId.isNotEmpty) {
          uniqueSubjects.add(courseId);
        } else if (courseTitle != null && courseTitle.isNotEmpty) {
          uniqueSubjects.add(courseTitle);
        }
      }

      setState(() {
        _subjects = uniqueSubjects.toList();
      });
    } catch (e) {
      // Do nothing
    }
  }

  List<String> _getExamTypes(AppLocalizations l10n) {
    return [
      l10n.midtermExam,
      l10n.finalExam,
      l10n.examTypeCourseOption,
      l10n.other,
    ];
  }

  Future<void> _pickFile(AppLocalizations l10n) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInMb = file.lengthSync() / (1024 * 1024);
      if (sizeInMb > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileSizeLimitNote, style: const TextStyle(fontFamily: 'Cairo'))),
        );
        return;
      }
      setState(() {
        _pdfFile = file;
      });
    }
  }

  Future<void> _uploadExamPaper(AppLocalizations l10n) async {
    if (_selectedSubject == null || _selectedExamType == null || _pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationError, style: const TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) throw Exception(l10n.userNotLoggedIn);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${p.basename(_pdfFile!.path)}';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('exam_papers/$_selectedSubject/$_selectedExamType/$fileName');

      final uploadTask = storageRef.putFile(_pdfFile!);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('exam_papers').add({
        'facultyUid': user.uid,
        'subjectName': _selectedSubject,
        'examType': _selectedExamType,
        'pdfUrl': downloadUrl,
        'fileName': p.basename(_pdfFile!.path),
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedSubject = null;
          _selectedExamType = null;
          _pdfFile = null;
          _uploadProgress = 0.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadSuccess, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadFailedWithReason(e.toString()), style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.uploadPageTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(l10n.targetCourse),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: _inputDecoration(Icons.book_rounded),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                onChanged: _isUploading ? null : (val) => setState(() => _selectedSubject = val),
                hint: Text(l10n.selectCourse, style: const TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 24),

              _buildLabel(l10n.examType),
              DropdownButtonFormField<String>(
                initialValue: _selectedExamType,
                decoration: _inputDecoration(Icons.assignment_rounded),
                items: _getExamTypes(l10n).map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                onChanged: _isUploading ? null : (val) => setState(() => _selectedExamType = val),
                hint: Text(l10n.selectExamType, style: const TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 24),

              _buildLabel(l10n.examPaperPdf),
              InkWell(
                onTap: _isUploading ? null : () => _pickFile(l10n),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: _pdfFile != null ? primaryColor : Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (_pdfFile == null) ...[
                        Icon(Icons.picture_as_pdf_rounded, size: 64, color: primaryColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(l10n.pdfPlaceholder, style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Text(l10n.maxSizeLimit, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ] else ...[
                        const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(p.basename(_pdfFile!.path), style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isUploading ? null : () => setState(() => _pdfFile = null),
                          child: Text(l10n.removeFile, style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                        )
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              if (_isUploading) ...[
                LinearProgressIndicator(value: _uploadProgress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 12),
                Center(child: Text(l10n.examUploadProgress((_uploadProgress * 100).toStringAsFixed(1)), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: _isUploading ? null : () {
                  final l10n = AppLocalizations.of(context)!;
                  _uploadExamPaper(l10n);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isUploading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10n.uploadAndSave, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4),
      child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
