import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FaqEntry {
  const FaqEntry({
    required this.questionAr,
    required this.answerAr,
    required this.questionEn,
    required this.answerEn,
  });

  final String questionAr;
  final String answerAr;
  final String questionEn;
  final String answerEn;
}

/// FAQ — Batch 10 localized.
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const _entries = [
    FaqEntry(
      questionAr: 'كيف يتم القبول في الكلية؟',
      answerAr: 'يتم القبول وفق شروط التسجيل المتوفرة على موقع الكلية الرسمي.',
      questionEn: 'How do I get admitted to the college?',
      answerEn:
          'Admission follows the registration requirements published on the official college website.',
    ),
    FaqEntry(
      questionAr: 'ما هي شروط القبول؟',
      answerAr:
          'يجب أن يكون الطالب من خريجي القسم العلمي أو معهد تقني، وأن لا تقل درجته عن جيد.',
      questionEn: 'What are the admission requirements?',
      answerEn:
          'Students must graduate from the scientific stream or a technical institute with at least a Good grade.',
    ),
    FaqEntry(
      questionAr: 'كيف يمكنني التواصل مع الدعم الفني؟',
      answerAr: 'يمكنك التواصل عبر البريد الإلكتروني أو الهاتف المتاح في التطبيق.',
      questionEn: 'How can I contact technical support?',
      answerEn: 'Use the email or phone options in the Contact Us section of the app.',
    ),
  ];

  final _searchController = TextEditingController();
  String _query = '';
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List.filled(_entries.length, false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqEntry> get _filtered {
    if (_query.isEmpty) return _entries;
    final q = _query.toLowerCase();
    return _entries.where((e) {
      return e.questionAr.contains(_query) ||
          e.answerAr.contains(_query) ||
          e.questionEn.toLowerCase().contains(q) ||
          e.answerEn.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.faqTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.faqSearchHint,
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                filtered.isEmpty
                    ? Center(
                      child: Text(
                        l10n.noDataFound,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final faq = filtered[index];
                        final globalIndex = _entries.indexOf(faq);
                        final expanded =
                            globalIndex >= 0 && _expanded[globalIndex];
                        final question =
                            isAr ? faq.questionAr : faq.questionEn;
                        final answer = isAr ? faq.answerAr : faq.answerEn;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            title: Text(
                              question,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onExpansionChanged: (open) {
                              if (globalIndex < 0) return;
                              setState(() => _expanded[globalIndex] = open);
                            },
                            initiallyExpanded: expanded,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  answer,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
