import 'package:flutter/material.dart';
import 'package:flutter_project/features/student/presentation/pages/exam_paper_view_page.dart';

/// Thin gateway that delegates to [ExamPaperViewPage].
///
/// The route `/exam-papers` (used from the home feature-grid) previously
/// showed a non-functional static list. Now it forwards directly to the
/// full Firestore-backed implementation.
class ExamPapersPage extends StatelessWidget {
  const ExamPapersPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const ExamPaperViewPage(paperData: {});
}