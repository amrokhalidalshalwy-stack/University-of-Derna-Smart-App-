// ═══════════════════════════════════════════════════════════════════════════
// guest_portal_page.dart — public university explorer (no auth required)
// Two view modes: Card Grid and Accordion List + sticky search
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

enum _ViewMode { grid, accordion }

class GuestPortalPage extends StatefulWidget {
  const GuestPortalPage({super.key});
  @override
  State<GuestPortalPage> createState() => _GuestPortalPageState();
}

class _GuestPortalPageState extends State<GuestPortalPage> {
  _ViewMode _mode = _ViewMode.grid;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuestEntryDialog());
  }

  Future<void> _showGuestEntryDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              l10n.guestPortalTitle,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            content: Text(
              l10n.guestWarningMessage,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancelButton,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.proceedButton,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
    );
    if (proceed != true && mounted) {
      context.go('/gateway');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FacultyData> get _filtered {
    if (_search.isEmpty) return UniversityData.faculties;
    final q = _search.toLowerCase();
    return UniversityData.faculties
        .where(
          (f) =>
              f.nameAr.contains(q) ||
              f.nameEn.toLowerCase().contains(q) ||
              f.departments.any((d) => d.contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF001835),
          ),
          onPressed: () => context.go('/gateway'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/university_logo.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.universityName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF001835),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // View mode toggle
          IconButton(
            icon: Icon(
              _mode == _ViewMode.grid
                  ? Icons.format_list_bulleted_rounded
                  : Icons.grid_view_rounded,
              color: const Color(0xFF001835),
            ),
            onPressed:
                () => setState(
                  () =>
                      _mode =
                          _mode == _ViewMode.grid
                              ? _ViewMode.accordion
                              : _ViewMode.grid,
                ),
            tooltip: _mode == _ViewMode.grid ? l10n.guestViewList : l10n.guestViewGrid,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sticky search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: l10n.searchCollegesHint,
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF74777F),
                ),
                suffixIcon:
                    _search.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                        : null,
                filled: true,
                fillColor: const Color(0xFFF7F9FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Text(
                  l10n.guestCollegesCount(_filtered.length),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Color(0xFF74777F),
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.collegesTitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Color(0xFF74777F),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child:
                _filtered.isEmpty
                    ? _buildEmpty()
                    : _mode == _ViewMode.grid
                    ? _buildGrid()
                    : _buildAccordion(),
          ),
          // Footer CTA
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _FacultyCard(faculty: _filtered[i]),
    );
  }

  Widget _buildAccordion() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _FacultyAccordion(faculty: _filtered[i]),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: const Color(0xFF74777F).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            _search.isEmpty
                ? l10n.noCollegesFoundMessage
                : l10n.guestNoResultsFor(_search),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF74777F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF001835),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => context.go('/signup'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.guestSignUpCTA,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Faculty Card (grid mode) ──────────────────────────────────────────────────
class _FacultyCard extends StatelessWidget {
  final FacultyData faculty;
  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Semantics(
        button: true,
        label: l10n.viewDetailsButton,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: faculty.color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: faculty.color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gradient header
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [faculty.color, faculty.color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Text(
                  faculty.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? faculty.nameAr : faculty.nameEn,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF001835),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.departmentsCount(faculty.departments.length),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: faculty.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FacultyDetailSheet(faculty: faculty),
    );
  }
}

// ── Faculty Accordion (list mode) ─────────────────────────────────────────────
class _FacultyAccordion extends StatelessWidget {
  final FacultyData faculty;
  const _FacultyAccordion({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: faculty.bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(faculty.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          isAr ? faculty.nameAr : faculty.nameEn,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF001835),
          ),
        ),
        subtitle: Text(
          isAr ? faculty.nameEn : faculty.nameAr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: faculty.color,
          ),
        ),
        iconColor: faculty.color,
        collapsedIconColor: const Color(0xFF74777F),
        children:
            faculty.departments
                .map(
                  (dept) => ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 8, color: faculty.color),
                    title: Text(
                      _localizedDept(dept, isAr),
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

// ── Faculty Detail Bottom Sheet ───────────────────────────────────────────────
class _FacultyDetailSheet extends StatelessWidget {
  final FacultyData faculty;
  const _FacultyDetailSheet({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder:
          (_, ctrl) => SingleChildScrollView(
            controller: ctrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4C6CF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        faculty.color,
                        faculty.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(faculty.emoji, style: const TextStyle(fontSize: 42)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? faculty.nameAr : faculty.nameEn,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isAr ? faculty.nameEn : faculty.nameAr,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Departments
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.guestAcademicDepartments,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: faculty.color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...faculty.departments.map(
                  (dept) => ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.school_rounded,
                      color: faculty.color,
                      size: 20,
                    ),
                    title: Text(
                      _localizedDept(dept, isAr),
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: faculty.color,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/signup');
                    },
                    icon: const Icon(
                      Icons.how_to_reg_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      l10n.guestRegisterInCollege,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }
}

String _localizedDept(String dept, bool isAr) {
  if (isAr) return dept;
  final map = {
    'الطب العام': 'General Medicine',
    'الجراحة': 'Surgery',
    'طب الأطفال': 'Pediatrics',
    'الطب الباطني': 'Internal Medicine',
    'أمراض النساء والتوليد': 'Obstetrics & Gynecology',
    'علم الأمراض': 'Pathology',
    'الصيدلة': 'Pharmacy',
    'الهندسة المدنية': 'Civil Engineering',
    'الهندسة الكهربائية': 'Electrical Engineering',
    'الهندسة الميكانيكية': 'Mechanical Engineering',
    'الهندسة الكيميائية': 'Chemical Engineering',
    'العمارة': 'Architecture',
    'القانون الدستوري والإداري': 'Constitutional & Administrative Law',
    'القانون الجنائي': 'Criminal Law',
    'القانون المدني': 'Civil Law',
    'القانون التجاري والبحري': 'Commercial & Maritime Law',
    'القانون الدولي': 'International Law',
    'اللغة العربية وآدابها': 'Arabic Language & Literature',
    'اللغة الإنجليزية وآدابها': 'English Language & Literature',
    'التاريخ': 'History',
    'الفلسفة': 'Philosophy',
    'علم الاجتماع': 'Sociology',
    'إدارة الأعمال': 'Business Administration',
    'المحاسبة': 'Accounting',
    'الاقتصاد': 'Economics',
    'المالية': 'Finance',
    'التسويق': 'Marketing',
    'الفيزياء': 'Physics',
    'الكيمياء': 'Chemistry',
    'الأحياء': 'Biology',
    'الرياضيات': 'Mathematics',
    'الجيولوجيا': 'Geology',
    'العلوم الصيدلانية': 'Pharmaceutical Sciences',
    'الكيمياء الصيدلانية': 'Pharmaceutical Chemistry',
    'الصيدلة الإكلينيكية': 'Clinical Pharmacy',
    'العلوم البيئية': 'Environmental Sciences',
    'الجيولوجيا والهندسة الجيوتقنية': 'Geology & Geotechnical Engineering',
    'الزراعة وعلم التربة': 'Agriculture & Soil Science',
    'إدارة الموارد الطبيعية': 'Natural Resources Management',
  };
  return map[dept.trim()] ?? dept;
}
