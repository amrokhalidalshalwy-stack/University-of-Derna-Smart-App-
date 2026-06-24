// lib/features/fees/presentation/pages/enrollment_renewal_page.dart
// نموذج تجديد القيد عبر الخدمات المصرفية
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnrollmentRenewalPage extends StatefulWidget {
  const EnrollmentRenewalPage({super.key});

  @override
  State<EnrollmentRenewalPage> createState() => _EnrollmentRenewalPageState();
}

class _EnrollmentRenewalPageState extends State<EnrollmentRenewalPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _paymentConfirmed = false;
  String? _selectedPaymentMethod;

  // Preset amounts for quick selection
  static const _presetAmounts = ['250', '500', '750', '1000'];
  
  // Payment methods
  static const _paymentMethods = [
    'المصرف الليبي',
    'بنك الاستثمار الليبي',
    'بنك البراقة',
    'بنك الجمهورية',
  ];

  Widget _buildStatusTracker() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('renewal_requests')
          .where('student_id', isEqualTo: _auth.currentUser?.uid)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حالة طلبك الأخير',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      status == 'pending'
                          ? Icons.hourglass_empty
                          : status == 'approved'
                              ? Icons.check_circle
                              : Icons.cancel,
                      color: status == 'pending'
                          ? Colors.orange
                          : status == 'approved'
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'pending'
                                ? 'قيد الانتظار'
                                : status == 'approved'
                                    ? 'تم قبول الطلب'
                                    : 'تم رفض الطلب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: status == 'pending'
                                  ? Colors.orange
                                  : status == 'approved'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          if (status == 'rejected' && data['rejectionReason'] != null)
                            Text(
                              'السبب: ${data['rejectionReason']}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.first;
  }

  Future<void> _submitRenewal() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_paymentConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تأكيد الدفع أولاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار طريقة الدفع',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Save enrollment request to Firestore
      await _firestore.collection('renewal_requests').add({
        'student_id': user.uid,
        'studentName': userData['name'] ?? 'Unknown',
        'studentEmail': user.email,
        'department': userData['department'] ?? '',
        'accountNumber': _accountCtrl.text,
        'amount': int.parse(_amountCtrl.text),
        'paymentMethod': _selectedPaymentMethod,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00A8A8),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تم تجديد القيد بنجاح!',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'رقم الحساب: ${_accountCtrl.text}\n'
                    'المبلغ المدفوع: ${_amountCtrl.text} د.ل',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariantColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سيتم تفعيل القيد خلال 24 ساعة عمل.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'تجديد القيد الجامعي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status tracking widget
                _buildStatusTracker(),
                
                const SizedBox(height: 24),

                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF00A8A8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'جامعة درنة',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'تجديد القيد للفصل الدراسي القادم\nيمكنك دفع رسوم القيد عبر الخدمات المصرفية الإلكترونية',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Payment method
                _buildSectionLabel('طريقة الدفع'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  hint: const Text(
                    'اختر طريقة الدفع',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  items: _paymentMethods
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              method,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPaymentMethod = value);
                  },
                  decoration: _inputDecoration(
                    'اختر البنك',
                    Icons.account_balance_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'يرجى اختيار طريقة الدفع';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Bank account number
                _buildSectionLabel('رقم الحساب المصرفي'),
                TextFormField(
                  controller: _accountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontFamily: 'Cairo', letterSpacing: 2),
                  decoration: _inputDecoration(
                    'أدخل رقم حسابك المصرفي',
                    Icons.credit_card_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'رقم الحساب مطلوب';
                    if (v.length < 10) return 'رقم الحساب يجب أن يكون 10 أرقام على الأقل';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Amount
                _buildSectionLabel('المبلغ المطلوب (د.ل)'),
                // Quick select chips
                Wrap(
                  spacing: 8,
                  children:
                      _presetAmounts.map((amount) {
                        final isSelected = _amountCtrl.text == amount;
                        return FilterChip(
                          label: Text(
                            '$amount د.ل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: isSelected ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryColor,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _amountCtrl.text = selected ? amount : '';
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontFamily: 'Cairo'),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    'أو أدخل المبلغ يدويًا',
                    Icons.attach_money_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'المبلغ مطلوب';
                    final amount = int.tryParse(v);
                    if (amount == null || amount <= 0) return 'أدخل مبلغًا صحيحًا';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm amount
                _buildSectionLabel('تأكيد المبلغ'),
                TextFormField(
                  controller: _confirmCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: _inputDecoration(
                    'أعد إدخال المبلغ للتأكيد',
                    Icons.check_circle_outline_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'تأكيد المبلغ مطلوب';
                    if (v != _amountCtrl.text) return 'المبلغ غير متطابق';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Payment confirmation checkbox
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _paymentConfirmed
                          ? const Color(0xFF00A8A8)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _paymentConfirmed,
                        activeColor: const Color(0xFF00A8A8),
                        onChanged: (v) =>
                            setState(() => _paymentConfirmed = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'أؤكد أن المعلومات المدخلة صحيحة وأوافق على إتمام عملية الدفع وفقاً للسياسة الجامعية.',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRenewal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : const Text(
                              'إتمام عملية الدفع وتجديد القيد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'للاستفسار: registrar@uod.edu.ly | 0913-000-000',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
