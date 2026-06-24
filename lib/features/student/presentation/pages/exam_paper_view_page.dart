import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';

class ExamPaperViewPage extends ConsumerWidget {
  // 1️⃣ هنا تم إضافة استقبال المتغير القادم من الـ Router لمنع الخطأ
  final Map<String, dynamic> paperData;

  const ExamPaperViewPage({
    super.key, 
    required this.paperData, // جعل المتغير مطلوباً ومتوافقاً مع GoRouter
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.examPapersTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategoryCard(context, AppLocalizations.of(context)!.quizzesCategory, 'quiz', Icons.quiz_rounded, Theme.of(context).colorScheme.tertiary),
            const SizedBox(height: 16),
            _buildCategoryCard(context, AppLocalizations.of(context)!.midtermCategory, 'midterm', Icons.assignment_rounded, Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            _buildCategoryCard(context, AppLocalizations.of(context)!.finalCategory, 'final', Icons.school_rounded, Theme.of(context).colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String type, IconData icon, Color color) {
    return TapScale(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => _ExamListScreen(categoryTitle: title, examType: type),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamListScreen extends StatelessWidget {
  final String categoryTitle;
  final String examType;

  const _ExamListScreen({required this.categoryTitle, required this.examType});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('exam_papers')
              .where('exam_type', isEqualTo: examType)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(AppLocalizations.of(context)!.loadingPapersError(snapshot.error.toString()), style: const TextStyle(fontFamily: 'Cairo')));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.noPapersInSection, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              );
            }

            // ترتيب محلي حسب التاريخ
            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final t1 = aData['uploadedAt'] as Timestamp?;
              final t2 = bData['uploadedAt'] as Timestamp?;
              if (t1 == null || t2 == null) return 0;
              return t2.compareTo(t1);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final subjectName = data['subjectName'] ?? AppLocalizations.of(context)!.unknownSubject;
                final pdfUrl = data['pdfUrl'];
                final uploadedAt = data['uploadedAt'] as Timestamp?;
                
                String dateStr = AppLocalizations.of(context)!.unknownDate;
                if (uploadedAt != null) {
                  final date = uploadedAt.toDate();
                  dateStr = AppLocalizations.of(context)!.uploadDateLabel('${date.year}/${date.month}/${date.day}');
                }

                return StaggeredFadeInSlideY(
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.picture_as_pdf_rounded, color: Theme.of(context).colorScheme.error, size: 28),
                      ),
                      title: Text(subjectName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(dateStr, style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                      trailing: TapScale(
                        child: ElevatedButton(
                          onPressed: () {
                            if (pdfUrl != null) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => _PdfViewerScreen(
                                  pdfUrl: pdfUrl,
                                  title: '$subjectName - $categoryTitle',
                                ),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.fileLinkUnavailable, style: const TextStyle(fontFamily: 'Cairo'))),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(AppLocalizations.of(context)!.viewPaper, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const _PdfViewerScreen({required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: SfPdfViewer.network(
          pdfUrl,
          canShowScrollHead: false,
          canShowScrollStatus: false,
        ),
      ),
    );
  }
}