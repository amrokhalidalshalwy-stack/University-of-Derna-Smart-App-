// ═══════════════════════════════════════════════════════════════════════════
// password_strength_meter.dart
// Live 5-rule password strength checker widget.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  // ── Rule checkers ──────────────────────────────────────────────────────────
  bool get _hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\+\=\[\]\/\\]'));
  bool get _hasMinLength => password.length >= 8;

  int get _passedRules =>
      [
        _hasUppercase,
        _hasLowercase,
        _hasDigit,
        _hasSpecial,
        _hasMinLength,
      ].where((b) => b).length;

  Color get _strengthColor {
    if (_passedRules <= 1) return const Color(0xFFDC3545);
    if (_passedRules == 2) return const Color(0xFFE87722);
    if (_passedRules == 3) return const Color(0xFFFFC107);
    if (_passedRules == 4) return const Color(0xFF28A745);
    return const Color(0xFF00A694);
  }

  String get _strengthLabel {
    if (password.isEmpty) return '';
    if (_passedRules <= 1) return 'ضعيفة جداً';
    if (_passedRules == 2) return 'ضعيفة';
    if (_passedRules == 3) return 'متوسطة';
    if (_passedRules == 4) return 'قوية';
    return 'قوية جداً ✓';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),

        // Strength bar (5 segments)
        Row(
          children: List.generate(5, (i) {
            final filled = i < _passedRules;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? _strengthColor : const Color(0xFFC4C6CF),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),

        // Strength label
        if (_strengthLabel.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: _strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
              child: Text(_strengthLabel),
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Individual rule checkers
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _RuleChip(label: '8 أحرف', passed: _hasMinLength),
            _RuleChip(label: 'حرف كبير', passed: _hasUppercase),
            _RuleChip(label: 'حرف صغير', passed: _hasLowercase),
            _RuleChip(label: 'رقم', passed: _hasDigit),
            _RuleChip(label: 'رمز خاص', passed: _hasSpecial),
          ],
        ),
      ],
    );
  }
}

class _RuleChip extends StatelessWidget {
  final String label;
  final bool passed;

  const _RuleChip({required this.label, required this.passed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            passed
                ? const Color(0xFF28A745).withValues(alpha: 0.1)
                : const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color:
              passed
                  ? const Color(0xFF28A745).withValues(alpha: 0.4)
                  : const Color(0xFFC4C6CF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              key: ValueKey(passed),
              size: 14,
              color: passed ? const Color(0xFF28A745) : const Color(0xFFC4C6CF),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Cairo',
              color: passed ? const Color(0xFF28A745) : const Color(0xFF74777F),
              fontWeight: passed ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
