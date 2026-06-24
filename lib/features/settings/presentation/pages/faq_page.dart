import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = const [
    {
      'question': 'كيف يتم القبول في الكلية؟',
      'answer': 'يتم القبول وفق شروط التسجيل المتوفرة على موقع الكلية الرسمي.',
    },
    {
      'question': 'ما هي شروط القبول؟',
      'answer':
          'يجب أن يكون الطالب من خريجي القسم العلمي أو معهد تقني، وأن لا تقل درجته عن جيد.',
    },
    {
      'question': 'ما هي التخصصات المتاحة؟',
      'answer':
          ' تشمل الكلية تخصصات مثل: تقنية المعلومات, الهندسة الكهربائية، الهندسة المدنية، الهندسة المعمارية, الهندسة الميكانيكية، المحاسبة المالية، والعلوم الإدارية.',
    },
    {
      'question': 'كيف يمكنني التواصل مع الدعم الفني؟',
      'answer':
          'يمكنك التواصل عبر البريد الإلكتروني أو الهاتف المتاح في التطبيق.',
    },
    {
      'question': 'كيف يمكنني معرفة نتائج الاختبارات؟',
      'answer':
          'يمكنك معرفة نتائج الاختبارات عبر البوابة الإلكترونية الخاصة بالكلية ',
    },
    {
      'question': 'ما هي شروط الانتقال بين التخصصات؟',
      'answer':
          'يتم التحويل وفقًا للشروط المعلنة من قبل إدارة الكلية ويعتمد على المعدل الأكاديمي.',
    },
    {
      'question': 'ما هي الأنشطة المتاحة؟',
      'answer':
          'تشمل الأنشطة الطلابية الأندية الأكاديمية، والفعاليات الثقافية، والمشاركات في المؤتمرات العلمية.',
    },
    {
      'question': 'كيف يمكنني الحصول على بطاقة الطالب الجامعية؟',
      'answer':
          'يتم إصدار بطاقة الطالب الجامعية بعد استكمال إجراءات التسجيل ويمكن استلامها من مكتب شؤون الطلاب.',
    },
    {
      'question': 'ما هي سياسة الحضور والغياب؟',
      'answer':
          'يجب على الطلاب الالتزام بنسبة حضور لا تقل عن 75% لضمان استمرارية التسجيل في المقررات.',
    },
  ];

  late List<bool> _expandedStatus;

  @override
  void initState() {
    super.initState();
    _expandedStatus = List.filled(faqs.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأسئلة الشائعة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        // هنا AppBar عادي بدون RTL
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl, // محتوى الصفحة RTL
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            final isExpanded = _expandedStatus[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    faq['question']!,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  trailing: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedStatus[index] = expanded;
                    });
                  },
                  children: [
                    Text(
                      faq['answer']!,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Cairo',
                        color:
                            theme.textTheme.bodyMedium?.color ?? Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
