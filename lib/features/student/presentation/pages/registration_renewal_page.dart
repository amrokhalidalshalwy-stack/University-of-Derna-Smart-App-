import 'package:flutter/material.dart';
import 'package:flutter_project/features/student/presentation/pages/enrollment_renewal_page.dart';

/// Thin gateway that delegates to [EnrollmentRenewalPage].
///
/// The route `/registration-renewal` (used from the home feature-grid) and
/// `/student/enrollment-renewal` both resolve to the same Stepper flow.
/// Keeping a separate route avoids router changes while fixing the stub.
class RegistrationRenewalPage extends StatelessWidget {
  const RegistrationRenewalPage({super.key});

  @override
  Widget build(BuildContext context) => const EnrollmentRenewalPage();
}