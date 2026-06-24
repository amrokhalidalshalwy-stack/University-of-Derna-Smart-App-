import 'dart:io'; // دمج الدعم للتعامل مع ملفات الموبايل (File)
import 'package:flutter/foundation.dart'; // دمج التحقق مما إذا كان التطبيق يعمل على الويب kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_project/features/forum/data/forum_models.dart';
import 'package:flutter_project/features/forum/data/forum_service.dart';

class AddEditPostPage extends StatefulWidget {
  final ForumPost? post; // إذا كان للتعديل، نمرر المنشور هنا
  final Course course; // المادة التي ينتمي إليها المنشور

  const AddEditPostPage({super.key, this.post, required this.course});

  @override
  State<AddEditPostPage> createState() => _AddEditPostPageState();
}

class _AddEditPostPageState extends State<AddEditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ForumService _forumService = ForumService();

  List<Map<String, String>> _references = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // إذا كان هناك منشور للتعديل، نملأ الحقول بالبيانات الموجودة
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _references = List.from(widget.post!.references);
    }
  }

  // دالة لرفع الملفات إلى Firebase Storage
  Future<void> _pickAndUploadFile() async {
    // استخدام الاستدعاء عبر الـ instance القياسي للمكتبة
    // ✅ السطر الجديد البديل والآمن:
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;
        final filePath = result.files.first.path;

        // مسار التخزين: forum_attachments / [course_id] / [timestamp]_[filename]
        final ref = FirebaseStorage.instance.ref(
          'forum_attachments/${widget.course.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        );

        // رفع الملف مع فصل المنصات بشكل آمن لتفادي أخطاء التشغيل
        if (kIsWeb) {
          if (fileBytes != null) {
            await ref.putData(fileBytes);
          } else {
            throw 'فشل في قراءة بيانات الملف على الويب';
          }
        } else {
          // لمستخدمي الموبايل (Android / iOS)
          if (filePath != null) {
            await ref.putFile(File(filePath));
          } else if (fileBytes != null) {
            await ref.putData(fileBytes);
          } else {
            throw 'لم يتم العثور على مسار الملف الخاص بالهاتف';
          }
        }

        final fileUrl = await ref.getDownloadURL();

        setState(() {
          _references.add({'type': 'file', 'value': fileUrl, 'name': fileName});
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ في رفع الملف: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // دالة لإضافة رابط خارجي
  void _addLink() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة رابط مرجع'),
            content: TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (urlController.text.isNotEmpty) {
                    setState(() {
                      _references.add({
                        'type': 'url',
                        'value': urlController.text,
                        'name': 'رابط خارجي',
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
    );
  }

  // دالة حفظ المنشور
  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      final now = DateTime.now();

      if (widget.post == null) {
        // إنشاء منشور جديد
        final newPost = ForumPost(
          postId: '', // سيتم إنشاؤه في Firestore
          courseId: widget.course.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          authorUid: user.uid,
          authorName: user.displayName ?? 'طالب',
          authorPhotoUrl: user.photoURL,
          createdAt: now,
          updatedAt: now,
          references: _references,
          tags: [], // يمكن إضافة نظام وسوم لاحقاً
          status: 'approved', // أو 'pending_moderation' حسب رغبتك
        );
        await _forumService.createPost(newPost);
      } else {
        // تحديث منشور موجود
        await _forumService.updatePost(widget.post!.postId, {
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'references': _references,
          'updatedAt': now,
        });
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'إضافة منشور جديد' : 'تعديل المنشور'),
        actions: [
          if (!_isLoading)
            IconButton(onPressed: _savePost, icon: const Icon(Icons.check)),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المادة: ${widget.course.nameAr}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الموضوع',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'الرجاء إدخال عنوان'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'محتوى النقاش أو السؤال',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 10,
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'الرجاء إدخال المحتوى'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'المرفقات والمراجع:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._references.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var ref = entry.value;
                        return ListTile(
                          leading: Icon(
                            ref['type'] == 'url'
                                ? Icons.link
                                : Icons.attach_file,
                          ),
                          title: Text(
                            ref['name'] ?? 'مرجع',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => setState(() => _references.removeAt(idx)),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickAndUploadFile,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('رفع ملف'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _addLink,
                              icon: const Icon(Icons.link),
                              label: const Text('إضافة رابط'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
