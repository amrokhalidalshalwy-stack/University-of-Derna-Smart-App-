import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({super.key});

  @override
  State<SendMessagePage> createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourse;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  List<String> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('faculty_id', isEqualTo: uid)
          .get();

      final Set<String> uniqueCourses = {};
      for (var doc in snapshot.docs) {
        final courseId = doc.data()['course_id'] as String?;
        final courseTitle = doc.data()['courseTitle'] as String?;
        if (courseId != null && courseId.isNotEmpty) {
          uniqueCourses.add(courseId);
        } else if (courseTitle != null && courseTitle.isNotEmpty) {
          uniqueCourses.add(courseTitle);
        }
      }

      setState(() {
        _courses = uniqueCourses.toList();
      });
    } catch (e) {
      // Do nothing
    }
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    // Live API call
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('announcements').add({
        'course_id': _selectedCourse,
        'faculty_id': uid,
        'title': _titleController.text,
        'message': _messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error if needed
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
          content: Text(
            l10n.sendMessageSuccess,
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
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.back, style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          title: Text(l10n.sendMessageTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: AppColors.navyBlue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isSubmitting
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.navyBlue),
                    SizedBox(height: 16),
                    Text(l10n.sending, style: TextStyle(fontFamily: 'Cairo', color: AppColors.navyBlue)),
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
                      Text(l10n.courseSection, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyBlue)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCourse,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.group_rounded, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          fillColor: AppColors.cardWhite,
                          filled: true,
                        ),
                        items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                        onChanged: (val) => setState(() => _selectedCourse = val),
                        validator: (val) => val == null ? l10n.selectCourseError : null,
                        dropdownColor: AppColors.cardWhite,
                      ),
                      const SizedBox(height: 24),
                      
                      Text(l10n.announcementSubjectTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyBlue)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: l10n.announcementSubjectPlaceholder,
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          fillColor: AppColors.cardWhite,
                          filled: true,
                        ),
                        validator: (val) => val == null || val.isEmpty ? l10n.announcementSubjectError : null,
                      ),
                      const SizedBox(height: 24),

                      Text(l10n.announcementBodyTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyBlue)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: l10n.announcementBodyPlaceholder,
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          fillColor: AppColors.cardWhite,
                          filled: true,
                        ),
                        validator: (val) => val == null || val.isEmpty ? l10n.announcementBodyError : null,
                      ),
                      const SizedBox(height: 40),
                      
                      TapScale(
                        child: ElevatedButton(
                          onPressed: _submitMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(l10n.send, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
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
}
