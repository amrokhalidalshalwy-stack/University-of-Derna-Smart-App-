// lib/features/admin/presentation/pages/manage_departments.dart
//
// صفحة إدارة الأقسام والكليات – تبويبان: الأقسام / الكليات
// RTL Arabic + Dark-blue/Gold theme + Firestore
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _kNavy     = Color(0xFF1A365D);
const _kNavyDark = Color(0xFF0F2340);
const _kGold     = Color(0xFFD4AF37);

// ══════════════════════════════════════════════════════════════════════════
//  MODELS
// ══════════════════════════════════════════════════════════════════════════

class CollegeModel {
  final String id;
  final String name;
  final String code;
  final String dean;

  CollegeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.dean,
  });

  factory CollegeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollegeModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      dean: data['dean'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'dean': dean,
    };
  }
}

class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final String collegeId;
  final String collegeName;
  final int studentCount;
  final int facultyCount;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.collegeId,
    required this.collegeName,
    required this.studentCount,
    required this.facultyCount,
  });

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      collegeId: data['collegeId'] ?? '',
      collegeName: data['collegeName'] ?? '',
      studentCount: data['studentCount'] ?? 0,
      facultyCount: data['facultyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'studentCount': studentCount,
      'facultyCount': facultyCount,
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: _kNavy,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.go('/admin/dashboard'),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kNavyDark, _kNavy],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Text(
            'إدارة الأقسام والكليات',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _kGold,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
            labelColor: _kGold,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.account_balance_rounded, size: 18), text: 'الأقسام'),
              Tab(icon: Icon(Icons.business_rounded, size: 18), text: 'الكليات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _DepartmentsTab(searchQuery: _searchQuery, onSearch: (q) => setState(() => _searchQuery = q)),
            _CollegesTab(searchQuery: _searchQuery, onSearch: (q) => setState(() => _searchQuery = q)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB 1 – DEPARTMENTS
// ══════════════════════════════════════════════════════════════════════════

class _DepartmentsTab extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearch;

  const _DepartmentsTab({required this.searchQuery, required this.onSearch});

  @override
  State<_DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<_DepartmentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCollegeFilter;
  bool _isLoading = false;

  // Stream للحصول على الأقسام من Firestore
  Stream<QuerySnapshot> get _departmentsStream {
    Query query = FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name');
    
    if (widget.searchQuery.isNotEmpty) {
      // بحث بسيط (يمكن تحسينه باستخدام array-contains)
      return query.snapshots();
    }
    return query.snapshots();
  }

  // Stream للحصول على الكليات للفلتر
  Stream<QuerySnapshot> get _collegesStream {
    return FirebaseFirestore.instance
        .collection('colleges')
        .orderBy('name')
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addDepartment() async {
    final formKey = GlobalKey<FormState>();
    String? name, code, collegeId, collegeName;
    List<CollegeModel> colleges = [];

    // جلب قائمة الكليات
    final snapshot = await FirebaseFirestore.instance.collection('colleges').get();
    colleges = snapshot.docs.map((doc) => CollegeModel.fromFirestore(doc)).toList();

    if (colleges.isEmpty) {
      _showSnackbar('يرجى إضافة كلية أولاً', isError: true);
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إضافة قسم جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: _fieldDecoration('اسم القسم', Icons.account_balance_rounded),
                    onChanged: (v) => name = v,
                    validator: (v) => v == null || v.isEmpty ? 'أدخل اسم القسم' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _fieldDecoration('كود القسم', Icons.code_rounded),
                    onChanged: (v) => code = v,
                    validator: (v) => v == null || v.isEmpty ? 'أدخل كود القسم' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: _fieldDecoration('الكلية', Icons.business_rounded),
                    items: colleges.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      collegeId = v;
                      collegeName = colleges.firstWhere((c) => c.id == v).name;
                    },
                    validator: (v) => v == null ? 'اختر الكلية' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await FirebaseFirestore.instance.collection('departments').add({
                    'name': name,
                    'code': code,
                    'collegeId': collegeId,
                    'collegeName': collegeName,
                    'studentCount': 0,
                    'facultyCount': 0,
                  });
                  setState(() => _isLoading = false);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSnackbar('تمت إضافة القسم بنجاح ✓');
                  }
                }
              },
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDepartment(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy)),
          content: Text('هل أنت متأكد من حذف القسم "$name"؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(context, true),
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('departments').doc(id).delete();
      if (context.mounted) _showSnackbar('تم حذف القسم بنجاح ✓');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط البحث والفلترة والإضافة
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن قسم...',
                    prefixIcon: const Icon(Icons.search, color: _kNavy),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // فلتر الكليات
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _collegesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      );
                    }
                    final colleges = snapshot.data!.docs;
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedCollegeFilter,
                      hint: Text('كل الكليات', style: GoogleFonts.cairo()),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('كل الكليات')),
                        ...colleges.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data['name'] ?? '', style: GoogleFonts.cairo()),
                          );
                        }),
                      ],
                      onChanged: (v) => setState(() => _selectedCollegeFilter = v),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: _addDepartment,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        // قائمة الأقسام
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _departmentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}', style: GoogleFonts.cairo()));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var departments = snapshot.data!.docs;
              
              // فلترة حسب البحث
              if (widget.searchQuery.isNotEmpty) {
                departments = departments.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  final code = data['code'] ?? '';
                  return name.contains(widget.searchQuery) || code.contains(widget.searchQuery);
                }).toList();
              }
              
              // فلترة حسب الكلية
              if (_selectedCollegeFilter != null) {
                departments = departments.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['collegeId'] == _selectedCollegeFilter;
                }).toList();
              }

              if (departments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('لا توجد أقسام', style: GoogleFonts.cairo(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final doc = departments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final department = DepartmentModel(
                    id: doc.id,
                    name: data['name'] ?? '',
                    code: data['code'] ?? '',
                    collegeId: data['collegeId'] ?? '',
                    collegeName: data['collegeName'] ?? '',
                    studentCount: data['studentCount'] ?? 0,
                    facultyCount: data['facultyCount'] ?? 0,
                  );
                  return _DepartmentCard(
                    department: department,
                    onDelete: () => _deleteDepartment(department.id, department.name),
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1B5E20),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ── بطاقة القسم ───────────────────────────────────────────────────────────
class _DepartmentCard extends StatelessWidget {
  final DepartmentModel department;
  final VoidCallback onDelete;

  const _DepartmentCard({required this.department, required this.onDelete});

  @override
Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGold.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _kNavy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_balance_rounded, color: _kNavy, size: 28),
        ),
        title: Text(
          department.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكود: ${department.code}', style: GoogleFonts.cairo(fontSize: 12)),
            Text('الكلية: ${department.collegeName}', style: GoogleFonts.cairo(fontSize: 12)),
            Text('الطلاب: ${department.studentCount} | أعضاء هيئة تدريس: ${department.facultyCount}',
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التعديل (قيد التطوير)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEditDialog(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('وظيفة التعديل قيد التطوير', style: GoogleFonts.cairo()),
    backgroundColor: _kNavy,
    behavior: SnackBarBehavior.floating,
  ));
}
}
// ══════════════════════════════════════════════════════════════════════════
//  TAB 2 – COLLEGES
// ══════════════════════════════════════════════════════════════════════════

class _CollegesTab extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearch;

  const _CollegesTab({required this.searchQuery, required this.onSearch});

  @override
  State<_CollegesTab> createState() => _CollegesTabState();
}

class _CollegesTabState extends State<_CollegesTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Stream<QuerySnapshot> get _collegesStream {
    return FirebaseFirestore.instance
        .collection('colleges')
        .orderBy('name')
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addCollege() async {
    final formKey = GlobalKey<FormState>();
    String? name, code, dean;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إضافة كلية جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: _fieldDecoration('اسم الكلية', Icons.business_rounded),
                  onChanged: (v) => name = v,
                  validator: (v) => v == null || v.isEmpty ? 'أدخل اسم الكلية' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: _fieldDecoration('كود الكلية', Icons.code_rounded),
                  onChanged: (v) => code = v,
                  validator: (v) => v == null || v.isEmpty ? 'أدخل كود الكلية' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: _fieldDecoration('اسم عميد الكلية', Icons.person_rounded),
                  onChanged: (v) => dean = v,
                  validator: (v) => v == null || v.isEmpty ? 'أدخل اسم العميد' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await FirebaseFirestore.instance.collection('colleges').add({
                    'name': name,
                    'code': code,
                    'dean': dean,
                  });
                  setState(() => _isLoading = false);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSnackbar('تمت إضافة الكلية بنجاح ✓');
                  }
                }
              },
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCollege(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy)),
          content: Text('هل أنت متأكد من حذف الكلية "$name"؟\n\nملاحظة: سيتم أيضاً حذف جميع الأقسام التابعة لها.', style: GoogleFonts.cairo()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(context, true),
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      // حذف الكلية
      await FirebaseFirestore.instance.collection('colleges').doc(id).delete();
      // حذف الأقسام التابعة لها
      final departments = await FirebaseFirestore.instance
          .collection('departments')
          .where('collegeId', isEqualTo: id)
          .get();
      for (var doc in departments.docs) {
        await doc.reference.delete();
      }
      if (context.mounted) _showSnackbar('تم حذف الكلية والأقسام التابعة لها ✓');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط البحث والإضافة
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث عن كلية...',
                    prefixIcon: const Icon(Icons.search, color: _kNavy),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: _addCollege,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        // قائمة الكليات
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _collegesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}', style: GoogleFonts.cairo()));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var colleges = snapshot.data!.docs;
              
              // فلترة حسب البحث
              if (widget.searchQuery.isNotEmpty) {
                colleges = colleges.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  final code = data['code'] ?? '';
                  return name.contains(widget.searchQuery) || code.contains(widget.searchQuery);
                }).toList();
              }

              if (colleges.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('لا توجد كليات', style: GoogleFonts.cairo(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: colleges.length,
                itemBuilder: (context, index) {
                  final doc = colleges[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final college = CollegeModel(
                    id: doc.id,
                    name: data['name'] ?? '',
                    code: data['code'] ?? '',
                    dean: data['dean'] ?? '',
                  );
                  return _CollegeCard(
                    college: college,
                    onDelete: () => _deleteCollege(college.id, college.name),
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1B5E20),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ── بطاقة الكلية ──────────────────────────────────────────────────────────
class _CollegeCard extends StatelessWidget {
  final CollegeModel college;
  final VoidCallback onDelete;

  const _CollegeCard({required this.college, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kGold.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.business_rounded, color: _kGold, size: 28),
          ),
          title: Text(
            college.name,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _kNavy),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الكود: ${college.code}', style: GoogleFonts.cairo(fontSize: 12)),
              Text('عميد الكلية: ${college.dean}', style: GoogleFonts.cairo(fontSize: 12)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => _showEditDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('وظيفة التعديل قيد التطوير', style: GoogleFonts.cairo()),
      backgroundColor: _kNavy,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════

InputDecoration _fieldDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.cairo(color: _kNavy),
    prefixIcon: Icon(icon, color: _kNavy),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kNavy, width: 1.5),
    ),
  );
}