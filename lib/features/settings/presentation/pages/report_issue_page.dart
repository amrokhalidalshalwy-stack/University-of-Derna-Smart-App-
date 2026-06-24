import 'package:flutter/material.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _submitIssue() {
    if (_formKey.currentState!.validate()) {
      final issueText = _issueController.text.trim();

      debugPrint('تم إرسال المشكلة: $issueText');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الإبلاغ بنجاح')));

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإبلاغ عن مشكلة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'وصف المشكلة:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 10),

                // الحقل مع تصميم مشابه للكود السابق
                TextFormField(
                  controller: _issueController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'اكتب هنا تفاصيل المشكلة التي تواجهها...',
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: theme.hintColor,
                    ),
                    filled: true,
                    fillColor:
                        theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color:
                            theme
                                .inputDecorationTheme
                                .enabledBorder
                                ?.borderSide
                                .color ??
                            theme.dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color:
                            theme
                                .inputDecorationTheme
                                .focusedBorder
                                ?.borderSide
                                .color ??
                            theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال وصف للمشكلة';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: _submitIssue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    child: const Text('إرسال الإبلاغ'),
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
