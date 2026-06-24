// pending_status_page.dart — shown to students whose account is not yet approved
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/core/constants/app_roles.dart';

class PendingStatusPage extends ConsumerWidget {
  final String status;
  final String? rejectionReason;
  const PendingStatusPage({
    super.key,
    this.status = 'pending_final_approval',
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regStatus = RegistrationStatus.fromString(status);
    final isRejected = regStatus.isBlocked;

    final Color color =
        isRejected ? const Color(0xFFDC3545) : const Color(0xFFFFC107);
    final IconData icon =
        isRejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded;
    final String title = isRejected ? 'لم يتم قبول طلبك' : 'طلبك قيد المراجعة';
    final String body =
        isRejected
            ? (rejectionReason ??
                'تم رفض طلب التسجيل. يمكنك التواصل مع القبول والتسجيل لمزيد من المعلومات.')
            : 'شكراً لتسجيلك في جامعة درنة. طلبك ${regStatus.labelAr} وسيتم إعلامك بالقرار النهائي عبر البريد الإلكتروني خلال 3-5 أيام عمل.';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 52),
              ),
              const SizedBox(height: 28),
              // University logo
              Image.asset(
                'assets/images/university_logo.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      isRejected
                          ? const Color(0xFFDC3545)
                          : const Color(0xFF001835),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF43474E),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 12),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  regStatus.labelAr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Actions
              if (!isRejected) ...[
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'تحديث الحالة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/gateway');
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF74777F),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'للاستفسار: admissions@uod.edu.ly',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Color(0xFF74777F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
