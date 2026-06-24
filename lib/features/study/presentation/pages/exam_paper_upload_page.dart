// lib/features/study/presentation/pages/exam_paper_upload_page.dart
// ØµÙØ­Ø© Ø±ÙØ¹ Ø£ÙˆØ±Ø§Ù‚ Ø§Ù„Ø§Ù…ØªØ­Ø§Ù† Ù„Ù„Ø£Ø³Ø§ØªØ°Ø©

import 'dart:io'; // ðŸ‘ˆ ØªÙ… Ø¥Ø¶Ø§ÙØªÙ‡Ø§ Ù„Ù„ØªØ¹Ø§Ù…Ù„ Ù…Ø¹ Ø§Ù„Ù…Ù„ÙØ§Øª Ø¹Ù„Ù‰ Ø§Ù„Ù…ÙˆØ¨Ø§ÙŠÙ„
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExamPaperUploadPage extends StatefulWidget {
  const ExamPaperUploadPage({super.key});

  @override
  State<ExamPaperUploadPage> createState() => _ExamPaperUploadPageState();
}

class _ExamPaperUploadPageState extends State<ExamPaperUploadPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  String? _selectedCategory; // 'quiz', 'midterm', 'final'
  String? _selectedCourseId;
  String? _selectedCourseName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _yearCtrl.text = '2025-2026';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ø®Ø·Ø£ ÙÙŠ Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ù…Ù„Ù: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadExamPaper() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ù…Ù„Ù PDF',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final professorId = _auth.currentUser?.uid ?? '';
      final fileName =
          '${_selectedCourseId}_${_selectedCategory}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final storagePath = 'exam_papers/$fileName';
      final reference = _storage.ref(storagePath);

      String fileUrl = '';

      // ðŸ‘ˆ Ø¯Ø¹Ù… Ø§Ù„Ø±ÙØ¹ Ù„Ù„Ù…ÙˆØ¨Ø§ÙŠÙ„ ÙˆØ§Ù„ÙˆÙŠØ¨ Ù…Ø¹Ø§Ù‹ Ø¨Ø´ÙƒÙ„ Ø¢Ù…Ù†
      if (_selectedFile!.path != null) {
        // Ù„Ù„Ù…ÙˆØ¨Ø§ÙŠÙ„ (Android / iOS)
        await reference.putFile(File(_selectedFile!.path!));
      } else if (_selectedFile!.bytes != null) {
        // Ù„Ù„ÙˆÙŠØ¨ (Web)
        await reference.putData(_selectedFile!.bytes!);
      } else {
        throw 'ØªØ¹Ø°Ø± Ù‚Ø±Ø§Ø¡Ø© Ù…Ù„Ù Ø§Ù„Ù€ PDF';
      }

      fileUrl = await reference.getDownloadURL();

      // Ø­ÙØ¸ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª ÙÙŠ Firestore
      await _firestore.collection('exam_papers').add({
        'title': _titleCtrl.text.trim(),
        'course_id': _selectedCourseId,
        'course_name': _selectedCourseName,
        'department': '',
        'category': _selectedCategory,
        'year': _yearCtrl.text.trim(),
        'fileUrl': fileUrl,
        'storagePath': storagePath, // ðŸ‘ˆ Ø­ÙØ¸Ù†Ø§ Ø§Ù„Ù…Ø³Ø§Ø± Ù‡Ù†Ø§ Ù„Ù†ØªÙ…ÙƒÙ† Ù…Ù† Ø­Ø°ÙÙ‡ Ù„Ø§Ø­Ù‚Ø§Ù‹
        'uploadedBy': professorId,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ØªÙ… Ø±ÙØ¹ Ø§Ù„ÙˆØ±Ù‚Ø© Ø¨Ù†Ø¬Ø§Ø­',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ØªÙØ±ÙŠØº Ø§Ù„Ø­Ù‚ÙˆÙ„
      _formKey.currentState!.reset();
      _titleCtrl.clear();
      _yearCtrl.text = '2025-2026';
      setState(() {
        _selectedFile = null;
        _selectedCategory = null;
        _selectedCourseId = null;
        _selectedCourseName = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ø®Ø·Ø£: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ðŸ‘ˆ Ø¯Ø§Ù„Ø© Ø§Ù„Ø­Ø°Ù Ø§Ù„ÙƒØ§Ù…Ù„ Ù„Ù„Ù…Ø³ØªÙ†Ø¯ ÙˆØ§Ù„Ù…Ù„Ù Ù…Ù† Ø§Ù„Ù€ Storage
  Future<void> _deleteExamPaper(String docId, String? storagePath) async {
    try {
      // 1. Ø­Ø°Ù Ø§Ù„Ù…Ù„Ù Ù…Ù† Storage Ø£ÙˆÙ„Ø§Ù‹ Ø¥Ø°Ø§ ÙƒØ§Ù† Ø§Ù„Ù…Ø³Ø§Ø± Ù…ÙˆØ¬ÙˆØ¯Ø§Ù‹
      if (storagePath != null && storagePath.isNotEmpty) {
        await _storage.ref(storagePath).delete();
      }
      // 2. Ø­Ø°Ù Ø§Ù„Ù…Ø³ØªÙ†Ø¯ Ù…Ù† Firestore
      await _firestore.collection('exam_papers').doc(docId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ØªÙ… Ø­Ø°Ù Ø§Ù„ÙˆØ±Ù‚Ø© ÙˆÙ…Ù„ÙÙ‡Ø§ Ø¨Ù†Ø¬Ø§Ø­',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ Ø§Ù„Ø­Ø°Ù: $e',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Ø±ÙØ¹ Ø£ÙˆØ±Ø§Ù‚ Ø§Ù„Ø§Ù…ØªØ­Ø§Ù†',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.7),
              tabs: const [
                Tab(text: 'Ø±ÙØ¹ ÙˆØ±Ù‚Ø© Ø¬Ø¯ÙŠØ¯Ø©'),
                Tab(text: 'Ø£ÙˆØ±Ø§Ù‚ÙŠ Ø§Ù„Ø³Ø§Ø¨Ù‚Ø©'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _UploadFormTab(
              formKey: _formKey,
              titleCtrl: _titleCtrl,
              yearCtrl: _yearCtrl,
              selectedCategory: _selectedCategory,
              selectedCourseId: _selectedCourseId,
              selectedFile: _selectedFile,
              isUploading: _isUploading,
              firestore: _firestore,
              auth: _auth,
              onCategoryChanged:
                  (value) => setState(() => _selectedCategory = value),
              onCourseChanged: (id, name) {
                setState(() {
                  _selectedCourseId = id;
                  _selectedCourseName = name;
                });
              },
              onFilePicked: _pickFile,
              onUpload: _uploadExamPaper,
            ),
            _MyExamPapersTab(
              firestore: _firestore,
              auth: _auth,
              onDeleteRequested:
                  _deleteExamPaper, // ðŸ‘ˆ Ù…Ø±Ø±Ù†Ø§ Ø¯Ø§Ù„Ø© Ø§Ù„Ø­Ø°Ù Ù„Ù„Ù€ Tab
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Upload Form Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UploadFormTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController yearCtrl;
  final String? selectedCategory;
  final String? selectedCourseId;
  final PlatformFile? selectedFile;
  final bool isUploading;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Function(String?) onCategoryChanged;
  final Function(String, String) onCourseChanged;
  final VoidCallback onFilePicked;
  final VoidCallback onUpload;

  const _UploadFormTab({
    required this.formKey,
    required this.titleCtrl,
    required this.yearCtrl,
    required this.selectedCategory,
    required this.selectedCourseId,
    required this.selectedFile,
    required this.isUploading,
    required this.firestore,
    required this.auth,
    required this.onCategoryChanged,
    required this.onCourseChanged,
    required this.onFilePicked,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Ù†ÙˆØ¹ Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø±'),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: _inputDecoration(
                context,
                'Ø§Ø®ØªØ± Ù†ÙˆØ¹ Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø±',
                Icons.category,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'quiz',
                  child: Text(
                    'Ø§Ø®ØªØ¨Ø§Ø± Ù‚ØµÙŠØ±',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'midterm',
                  child: Text(
                    'Ø§Ø®ØªØ¨Ø§Ø± Ù†ØµÙ Ø§Ù„ÙØµÙ„',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'final',
                  child: Text(
                    'Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø± Ø§Ù„Ù†Ù‡Ø§Ø¦ÙŠ',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
              onChanged: onCategoryChanged,
              validator: (v) => v == null ? 'Ø§Ø®ØªØ± Ù†ÙˆØ¹ Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø±' : null,
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('Ø§Ù„Ù…Ø§Ø¯Ø©'),
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('courses').snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> courseItems = [];

                if (snapshot.hasData) {
                  courseItems =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            data['name'] ?? 'Unknown',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList();
                }

                return DropdownButtonFormField<String>(
                  initialValue: selectedCourseId,
                  decoration: _inputDecoration(
                    context,
                    'Ø§Ø®ØªØ± Ø§Ù„Ù…Ø§Ø¯Ø©',
                    Icons.book,
                  ),
                  items: courseItems,
                  onChanged: (value) {
                    if (value != null && snapshot.hasData) {
                      final course = snapshot.data!.docs.firstWhere(
                        (doc) => doc.id == value,
                      );
                      final data = course.data() as Map<String, dynamic>;
                      onCourseChanged(value, data['name'] ?? 'Unknown');
                    }
                  },
                  validator: (v) => v == null ? 'Ø§Ø®ØªØ± Ø§Ù„Ù…Ø§Ø¯Ø©' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('Ø¹Ù†ÙˆØ§Ù† Ø§Ù„ÙˆØ±Ù‚Ø© (Ø§Ø®ØªÙŠØ§Ø±ÙŠ)'),
            TextFormField(
              controller: titleCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: _inputDecoration(
                context,
                'Ù…Ø«Ø§Ù„: Ø£Ø³Ø¦Ù„Ø© Ø§Ù„ÙˆØ­Ø¯Ø© Ø§Ù„Ø£ÙˆÙ„Ù‰',
                Icons.title,
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('Ø§Ù„Ø³Ù†Ø© Ø§Ù„Ø£ÙƒØ§Ø¯ÙŠÙ…ÙŠØ©'),
            TextFormField(
              controller: yearCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: _inputDecoration(
                context,
                '2025-2026',
                Icons.calendar_today,
              ),
              validator: (v) => v == null || v.isEmpty ? 'Ø£Ø¯Ø®Ù„ Ø§Ù„Ø³Ù†Ø©' : null,
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('Ù…Ù„Ù PDF'),
            GestureDetector(
              onTap: isUploading ? null : onFilePicked,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selectedFile != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color:
                      selectedFile != null
                          ? AppTheme.primaryColor.withValues(alpha: 0.05)
                          : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 40,
                      color:
                          selectedFile != null
                              ? AppTheme.primaryColor
                              : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    if (selectedFile == null)
                      const Text(
                        'Ø§Ø¶ØºØ· Ù„Ø§Ø®ØªÙŠØ§Ø± Ù…Ù„Ù PDF',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      )
                    else
                      Column(
                        children: [
                          Text(
                            selectedFile!.name,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : onUpload,
                icon:
                    isUploading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(
                  isUploading ? 'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ø±ÙØ¹...' : 'Ø±ÙØ¹ Ø§Ù„ÙˆØ±Ù‚Ø©',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Cairo',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}

// â”€â”€ My Exam Papers Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MyExamPapersTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Function(String docId, String? storagePath)
  onDeleteRequested; // ðŸ‘ˆ ØªÙ… Ø¥Ø¶Ø§ÙØªÙ‡Ø§ Ù‡Ù†Ø§

  const _MyExamPapersTab({
    required this.firestore,
    required this.auth,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    final professorId = auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream:
          firestore
              .collection('exam_papers')
              .where('uploadedBy', isEqualTo: professorId)
              .orderBy('uploadedAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ù„Ù… ØªØ±ÙØ¹ Ø£ÙŠ Ø£ÙˆØ±Ø§Ù‚ Ø¨Ø¹Ø¯',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 32,
                ),
                title: Text(
                  data['course_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${data['year'] ?? ''} - ${data['category'] ?? ''}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      // ðŸ‘ˆ Ø§Ø³ØªØ¯Ø¹Ø§Ø¡ Ø§Ù„Ø­Ø°Ù Ø§Ù„Ø´Ø§Ù…Ù„ (Ø§Ù„Ù…Ù„Ù + Ø§Ù„Ù…Ø³ØªÙ†Ø¯)
                      onDeleteRequested(doc.id, data['storagePath']);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Ø­Ø°Ù',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                ),
              ),
            ).animate().slideX(begin: 0.2).fadeIn();
          },
        );
      },
    );
  }
}
