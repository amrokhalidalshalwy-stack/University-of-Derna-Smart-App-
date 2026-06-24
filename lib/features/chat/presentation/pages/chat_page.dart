import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart'; // تأكد من صحة هذا المسار بناءً على مشروعك

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(_messageController.text.trim());
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام نظام الـ Localization الموجود في مشروعك
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.chatTitle, // تأكد من وجود هذا المفتاح في ملفات .arb
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.messagesEmptyMessage, // تأكد من وجود هذا المفتاح
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        // تحديد الاتجاه تلقائياً بناءً على اللغة
                        final isRtl =
                            Directionality.of(context) == TextDirection.rtl;
                        return Align(
                          alignment:
                              isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isRtl ? 16 : 0),
                                bottomRight: Radius.circular(isRtl ? 0 : 16),
                              ),
                            ),
                            child: Text(
                              _messages[index],
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            l10n.messageSearchHint, // تأكد من وجود هذا المفتاح
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            isDark
                                ? colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3)
                                : colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
          // شريط العمليات المساعد باستخدام نصوص الـ l10n
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.reply_rounded, color: colorScheme.primary),
                    label: Text(
                      l10n.messageReplyButton,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.forward_rounded,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      l10n.messageForwardButton,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (_messages.isNotEmpty) {
                        setState(() => _messages.clear());
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: Text(
                      l10n.cancelButton,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
