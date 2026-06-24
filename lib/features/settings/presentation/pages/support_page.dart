import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isNumberOnly = false,
    bool isMessageField = false,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      inputFormatters:
          isNumberOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: theme.textTheme.bodyMedium?.color,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
        labelStyle: const TextStyle(fontFamily: 'Cairo'),
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
                theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
                theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
                theme.colorScheme.primary,
            width: 2,
          ),
        ),
        alignLabelWithHint: isMessageField,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.supportTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.supportFormSubtitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: nameController,
                hint: l10n.supportName,
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.supportNameRequired;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: emailController,
                hint: l10n.email,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.supportEmailRequired;
                  if (!v.contains('@')) return l10n.supportEmailInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: subjectController,
                hint: l10n.supportSubjectField,
                icon: Icons.subject_outlined,
                validator: (_) => null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: messageController,
                hint: l10n.supportMessage,
                icon: Icons.message_outlined,
                maxLines: 5,
                isMessageField: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.supportMessageRequired;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.supportSent)),
                      );
                      nameController.clear();
                      emailController.clear();
                      subjectController.clear();
                      messageController.clear();
                    }
                  },
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
                  child: Text(l10n.supportTicketButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
