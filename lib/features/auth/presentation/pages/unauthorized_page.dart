import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/providers/user_role_provider.dart';
import 'package:flutter_project/core/router/auth_navigation.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class UnauthorizedPage extends ConsumerStatefulWidget {
  final String attemptedPath;

  const UnauthorizedPage({super.key, required this.attemptedPath});

  @override
  ConsumerState<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends ConsumerState<UnauthorizedPage> {
  bool _loggedOnce = false;

  @override
  void initState() {
    super.initState();
    _logUnauthorizedAccess();
  }

  /// Log unauthorized access attempt to Firestore (once only)
  Future<void> _logUnauthorizedAccess() async {
    if (_loggedOnce) return;
    _loggedOnce = true;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userRole = ref.read(userRoleInfoProvider).value?.role;

      await FirebaseFirestore.instance.collection('activityLogs').add({
        'type': 'unauthorized_access_attempt',
        'uid': uid,
        'user_role': userRole?.toString(),
        'attempted_path': widget.attemptedPath,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ Failed to log unauthorized access');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userRole = ref.read(userRoleInfoProvider).value?.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Access Denied Icon ──────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFDC3545),
                  size: 52,
                ),
              ),
              const SizedBox(height: 28),

              // ── University Logo ─────────────────────────────────────────
              Image.asset(
                'assets/images/university_logo.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 20),

              // ── Title: Access Denied ────────────────────────────────────
              Text(
                l10n.unauthorizedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                ),
              ),
              const SizedBox(height: 16),

              // ── Message ─────────────────────────────────────────────────
              Text(
                l10n.unauthorizedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF43474E),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 12),

              // ── Attempted Path Badge ────────────────────────────────────
              if (widget.attemptedPath.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFDC3545).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    widget.attemptedPath,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Color(0xFFDC3545),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 40),

              // ── Return Button ───────────────────────────────────────────
              ElevatedButton(
                onPressed: () {
                  final role = userRole ?? UserRole.student;
                  context.go(homePathForRole(role));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6CBD),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.returnToPortal,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Support Contact ─────────────────────────────────────────
              const Text(
                'للاستفسار: support@uod.edu.ly',
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

