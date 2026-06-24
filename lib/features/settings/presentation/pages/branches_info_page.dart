import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class BranchesInfoPage extends StatelessWidget {
  const BranchesInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'فروع الجامعة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBranchCard(
              context,
              title: 'المقر الرئيسي - درنة',
              description: 'يضم إدارة الجامعة، كلية الهندسة، كلية تقنية المعلومات، كلية الطب البشري، وكلية العلوم.',
              location: 'طريق أُم المؤمنين، درنة',
              icon: Icons.account_balance_rounded,
            ),
            _buildBranchCard(
              context,
              title: 'فرع القبة',
              description: 'يضم كلية الآداب، وكلية التربية.',
              location: 'مدينة القبة',
              icon: Icons.account_balance_outlined,
            ),
            _buildBranchCard(
              context,
              title: 'فرع عين مارة',
              description: 'يضم كلية الزراعة.',
              location: 'منطقة عين مارة',
              icon: Icons.eco_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(
    BuildContext context, {
    required String title,
    required String description,
    required String location,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
