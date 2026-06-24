// lib/features/admin/presentation/pages/manage_departments.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/admin_sidebar.dart';
import '../../screens/admin_app_bar.dart';

const _kNavy = Color(0xFF1A365D);
const _kGold = Color(0xFFD4AF37);

// Providers
final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  try {
    final cached = await FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .get(const GetOptions(source: Source.cache));
    if (cached.docs.isNotEmpty) {
      return cached.docs.map((doc) => Department.fromFirestore(doc)).toList();
    }
    final fresh = await FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .get(const GetOptions(source: Source.server));
    return fresh.docs.map((doc) => Department.fromFirestore(doc)).toList();
  } catch (_) {
    final fresh = await FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .get();
    return fresh.docs.map((doc) => Department.fromFirestore(doc)).toList();
  }
});

final collegesProvider = FutureProvider<List<College>>((ref) async {
  try {
    final cached = await FirebaseFirestore.instance
        .collection('colleges')
        .orderBy('name')
        .get(const GetOptions(source: Source.cache));
    if (cached.docs.isNotEmpty) {
      return cached.docs.map((doc) => College.fromFirestore(doc)).toList();
    }
    final fresh = await FirebaseFirestore.instance
        .collection('colleges')
        .orderBy('name')
        .get(const GetOptions(source: Source.server));
    return fresh.docs.map((doc) => College.fromFirestore(doc)).toList();
  } catch (_) {
    final fresh = await FirebaseFirestore.instance
        .collection('colleges')
        .orderBy('name')
        .get();
    return fresh.docs.map((doc) => College.fromFirestore(doc)).toList();
  }
});

// Models
class Department {
  final String id;
  final String name;
  final String code;
  final String collegeId;
  final String collegeName;
  final int studentCount;
  final int facultyCount;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.collegeId,
    required this.collegeName,
    required this.studentCount,
    required this.facultyCount,
  });

  factory Department.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      collegeId: data['college_id'] ?? data['collegeId'] ?? '',
      collegeName: data['college_name'] ?? data['collegeName'] ?? '',
      studentCount: data['student_count'] ?? data['studentCount'] ?? 0,
      facultyCount: data['faculty_count'] ?? data['facultyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'college_id': collegeId,
      'college_name': collegeName,
      'student_count': studentCount,
      'faculty_count': facultyCount,
    };
  }
}

class College {
  final String id;
  final String name;
  final String code;
  final String dean;

  College({
    required this.id,
    required this.name,
    required this.code,
    required this.dean,
  });

  factory College.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return College(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      dean: data['dean'] ?? '',
    );
  }
}

// Main Page
class ManageDepartmentsPage extends ConsumerStatefulWidget {
  const ManageDepartmentsPage({super.key});

  @override
  ConsumerState<ManageDepartmentsPage> createState() => _ManageDepartmentsPageState();
}

class _ManageDepartmentsPageState extends ConsumerState<ManageDepartmentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  String? _selectedCollegeFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminSidebar(),
      appBar: AdminAppBar(
        title: 'إدارة الأقسام والكليات',
        scaffoldKey: _scaffoldKey,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // TabBar
            Container(
              color: _kNavy,
              child: const TabBar(
                tabs: [
                  Tab(text: 'الأقسام', icon: Icon(Icons.account_balance)),
                  Tab(text: 'الكليات', icon: Icon(Icons.business)),
                ],
                indicatorColor: _kGold,
                labelColor: _kGold,
                unselectedLabelColor: Colors.white70,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // تبويب الأقسام
                  _buildDepartmentsTab(),
                  // تبويب الكليات
                  _buildCollegesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    final departmentsAsync = ref.watch(departmentsProvider);
    final collegesAsync = ref.watch(collegesProvider);
    
    return Column(
      children: [
        // شريط البحث والفلترة
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن قسم...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: collegesAsync.when(
                  data: (colleges) => DropdownButtonFormField<String?>(
                    initialValue: _selectedCollegeFilter,  // ✅ تم التصحيح
                    hint: const Text('كل الكليات'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('كل الكليات')),
                      ...colleges.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                    onChanged: (value) => setState(() => _selectedCollegeFilter = value),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('خطأ: $e'),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: () => _showAddDepartmentDialog(collegesAsync),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        // قائمة الأقسام
        Expanded(
          child: departmentsAsync.when(
            data: (departments) {
              var filteredDepartments = departments;
              if (_searchQuery.isNotEmpty) {
                filteredDepartments = filteredDepartments.where((d) =>
                    d.name.toLowerCase().contains(_searchQuery) ||
                    d.code.toLowerCase().contains(_searchQuery)).toList();
              }
              if (_selectedCollegeFilter != null) {
                filteredDepartments = filteredDepartments
                    .where((d) => d.collegeId == _selectedCollegeFilter)
                    .toList();
              }

              if (filteredDepartments.isEmpty) {
                return const Center(child: Text('لا توجد أقسام'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDepartments.length,
                itemBuilder: (context, index) {
                  final department = filteredDepartments[index];
                  return _buildDepartmentCard(department);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentCard(Department department) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_balance, color: _kGold),
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكود: ${department.code}'),
            Text('الكلية: ${department.collegeName}'),
            Text('الطلاب: ${department.studentCount} | أعضاء هيئة تدريس: ${department.facultyCount}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDepartmentDialog(department),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDepartmentConfirmation(department),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegesTab() {
    final collegesAsync = ref.watch(collegesProvider);
    return Column(
      children: [
        // شريط البحث وزر الإضافة
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن كلية...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: () => _showAddCollegeDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        // قائمة الكليات
        Expanded(
          child: collegesAsync.when(
            data: (colleges) {
              var filteredColleges = colleges;
              if (_searchQuery.isNotEmpty) {
                filteredColleges = filteredColleges.where((c) =>
                    c.name.toLowerCase().contains(_searchQuery) ||
                    c.code.toLowerCase().contains(_searchQuery)).toList();
              }

              if (filteredColleges.isEmpty) {
                return const Center(child: Text('لا توجد كليات'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredColleges.length,
                itemBuilder: (context, index) {
                  final college = filteredColleges[index];
                  return _buildCollegeCard(college);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildCollegeCard(College college) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.business, color: _kGold),
        ),
        title: Text(
          college.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكود: ${college.code}'),
            Text('عميد الكلية: ${college.dean}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCollegeDialog(college),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteCollegeConfirmation(college),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDepartmentDialog(AsyncValue<List<College>> collegesAsync) {
    final formKey = GlobalKey<FormState>();
    String? name, code, collegeId;

    collegesAsync.whenData((colleges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إضافة قسم جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'اسم القسم'),
                    onChanged: (v) => name = v,
                    validator: (v) => v == null || v.isEmpty ? 'أدخل اسم القسم' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'كود القسم'),
                    onChanged: (v) => code = v,
                    validator: (v) => v == null || v.isEmpty ? 'أدخل كود القسم' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'الكلية'),
                    items: colleges.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (v) => collegeId = v,
                    validator: (v) => v == null ? 'اختر الكلية' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final selectedCollege = colleges.firstWhere((c) => c.id == collegeId);
                  final newDepartment = {
                    'name': name,
                    'code': code,
                    'college_id': collegeId,
                    'college_name': selectedCollege.name,
                    'student_count': 0,
                    'faculty_count': 0,
                  };
                  await FirebaseFirestore.instance
                      .collection('departments')
                      .add(newDepartment);
                  ref.invalidate(departmentsProvider); // Refresh data
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة القسم بنجاح')),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      );
    });
  }

  void _showAddCollegeDialog() {
    final formKey = GlobalKey<FormState>();
    String? name, code, dean;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة كلية جديدة'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'اسم الكلية'),
                onChanged: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'أدخل اسم الكلية' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'كود الكلية'),
                onChanged: (v) => code = v,
                validator: (v) => v == null || v.isEmpty ? 'أدخل كود الكلية' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'اسم عميد الكلية'),
                onChanged: (v) => dean = v,
                validator: (v) => v == null || v.isEmpty ? 'أدخل اسم العميد' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newCollege = {
                  'name': name,
                  'code': code,
                  'dean': dean,
                };
                await FirebaseFirestore.instance.collection('colleges').add(newCollege);
                ref.invalidate(collegesProvider); // Refresh data
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة الكلية بنجاح')),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditDepartmentDialog(Department department) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('وظيفة التعديل قيد التطوير')),
    );
  }

  void _showEditCollegeDialog(College college) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('وظيفة التعديل قيد التطوير')),
    );
  }

  void _showDeleteDepartmentConfirmation(Department department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف القسم "${department.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('departments')
                  .doc(department.id)
                  .delete();
              ref.invalidate(departmentsProvider); // Refresh data
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف القسم بنجاح')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCollegeConfirmation(College college) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الكلية "${college.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('colleges')
                  .doc(college.id)
                  .delete();
              ref.invalidate(collegesProvider); // Refresh data
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الكلية بنجاح')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}