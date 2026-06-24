import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// Branch data model
class DeanInfo {
  final String name;
  final String title;
  final String? phone;
  final String? email;

  const DeanInfo({
    required this.name,
    required this.title,
    this.phone,
    this.email,
  });
}

class UniversityBranch {
  final String name;
  final String address;
  final String phone;
  final LatLng location;
  final String id;
  final DeanInfo? dean;

  UniversityBranch({
    required this.name,
    required this.address,
    required this.phone,
    required this.location,
    required this.id,
    this.dean,
  });
}

class CollegeInfoPage extends ConsumerWidget {
  const CollegeInfoPage({super.key});

  // تم تحويل المصفوفة الثابتة إلى دالة تستقبل الـ context لجلب النصوص المترجمة ديناميكياً
  static List<UniversityBranch> getBranches(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      UniversityBranch(
        id: 'main',
        name: l10n.branchMainName,
        address: l10n.branchMainAddress,
        phone: '+218 87 630 789',
        location: const LatLng(32.6889343, 22.6879628),
        dean: DeanInfo(
          name: l10n.deanMainName,
          title: l10n.deanMainTitle,
          phone: '+218 87 630 789',
          email: 'dean.engineering.fataih@uod.edu.ly',
        ),
      ),
      UniversityBranch(
        id: 'shiha',
        name: l10n.branchShihaName,
        address: l10n.branchShihaAddress,
        phone: '+218 87 630 792',
        location: const LatLng(32.7605583, 22.6236081),
        dean: DeanInfo(
          name: l10n.deanShihaName,
          title: l10n.deanShihaTitle,
          phone: '+218 87 630 792',
          email: 'dean.econlaw.shiha@uod.edu.ly',
        ),
      ),
      UniversityBranch(
        id: 'bab_tobruk',
        name: l10n.branchBabTobrukName,
        address: l10n.branchBabTobrukAddress,
        phone: '+218 92-7664368',
        location: const LatLng(32.7518758, 22.640865),
        dean: DeanInfo(
          name: l10n.deanBabTobrukName,
          title: l10n.deanBabTobrukTitle,
          phone: '+218 92-7664368',
          email: 'dean.medicine.babtobruk@uod.edu.ly',
        ),
      ),
      UniversityBranch(
        id: 'alquba',
        name: l10n.branchAlqubaName,
        address: l10n.branchAlqubaAddress,
        phone: '+218 87 630 790',
        location: const LatLng(32.730278, 21.950278),
        dean: DeanInfo(
          name: l10n.deanAlqubaName,
          title: l10n.deanAlqubaTitle,
          phone: '+218 87 630 790',
          email: 'dean.engineering.alquba@uod.edu.ly',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }
        final profileAsync = ref.watch(userDataProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.collegeAffairs,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: profileAsync.when(
            data: (data) => _buildBody(context, l10n),
            loading: () => const UodScreenLoading(),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          ),
        );
      },
      loading: () => const UodScreenLoading(),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.authError))),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    // جلب القائمة المترجمة ديناميكياً هنا بناءً على اللغة الحالية للتطبيق
    final branches = getBranches(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(context, l10n.collegeAnnouncementsTitle),
          const SizedBox(height: 12),
          _buildAnnouncements(
            context,
            l10n,
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 32),
          _buildSectionTitle(context, l10n.collegeLocationTitle),
          const SizedBox(height: 12),
          _BranchSelectionWidget(
            branches: branches, // تمرير القائمة المترجمة
            onBranchSelected: (index) {},
            child: (selectedBranchIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInteractiveMap(
                    context,
                    l10n,
                    branches, // تمرير القائمة المترجمة هنا
                    selectedBranchIndex,
                  ).animate().fadeIn(delay: 200.ms).scale(),
                  const SizedBox(height: 16),
                  _buildBranchInfoCard(context, branches[selectedBranchIndex]),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, l10n.deanOfficeTitle),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    l10n,
                    branches[selectedBranchIndex],
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildAnnouncements(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.graduationAlertTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.graduationAlertBody,
            textAlign: TextAlign.start,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.5, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap(
    BuildContext context,
    AppLocalizations l10n,
    List<UniversityBranch>
    branches, // تمت إضافة الباراميتر هنا لتجنب استدعاء المصفوفة القديمة
    int selectedIndex,
  ) {
    final theme = Theme.of(context);
    final selectedBranch = branches[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                _MapWithBranches(
                  selectedBranch: selectedBranch,
                  branches: branches,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => context.push('/college-location'),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.openInteractiveMap,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontFamily: 'Cairo',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _openExternalMap(context, selectedBranch),
          icon: const Icon(Icons.navigation_rounded),
          label: Text(
            l10n.openInteractiveMap,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchInfoCard(BuildContext context, UniversityBranch branch) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.address,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.phone,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1).fadeIn();
  }

  Future<void> _openExternalMap(
    BuildContext context,
    UniversityBranch branch,
  ) async {
    final uri = Uri.parse(
      'http://maps.google.com/?q=${branch.location.latitude},${branch.location.longitude}',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loadingError)),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorPrefix}$e'),
        ),
      );
    }
  }

  Widget _buildContactCard(
    BuildContext context,
    AppLocalizations l10n,
    UniversityBranch branch,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryContainer,
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(
                branch.dean?.name ?? l10n.deanNameSample,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              subtitle: Text(
                branch.dean?.title ?? l10n.deanTitleSample,
                textAlign: TextAlign.start,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (branch.dean?.phone != null)
                  _buildContactBtn(
                    context,
                    Icons.phone,
                    l10n.contactCall,
                    branch.dean!.phone!,
                  ),
                if (branch.dean?.email != null)
                  _buildContactBtn(
                    context,
                    Icons.email,
                    l10n.contactEmail,
                    branch.dean!.email!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchContact(String contactDetail, IconData icon) async {
    Uri uri;
    if (icon == Icons.phone) {
      uri = Uri(scheme: 'tel', path: contactDetail);
    } else if (icon == Icons.email) {
      uri = Uri(scheme: 'mailto', path: contactDetail);
    } else {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error: could not launch
    }
  }

  Widget _buildContactBtn(
    BuildContext context,
    IconData icon,
    String label,
    String contactDetail,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchContact(contactDetail, icon),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.primaryColor,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          contactDetail,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _BranchSelectionWidget extends StatefulWidget {
  final List<UniversityBranch> branches;
  final Function(int) onBranchSelected;
  final Widget Function(int) child;

  const _BranchSelectionWidget({
    required this.branches,
    required this.onBranchSelected,
    required this.child,
  });

  @override
  State<_BranchSelectionWidget> createState() => _BranchSelectionWidgetState();
}

class _BranchSelectionWidgetState extends State<_BranchSelectionWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              widget.branches.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    widget.branches[index].name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _selectedIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onBranchSelected(index);
                  },
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color:
                        _selectedIndex == index
                            ? Colors.white
                            : Colors.grey.shade700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        widget.child(_selectedIndex),
      ],
    );
  }
}

class _MapWithBranches extends StatefulWidget {
  final UniversityBranch selectedBranch;
  final List<UniversityBranch> branches;

  const _MapWithBranches({
    required this.selectedBranch,
    required this.branches,
  });

  @override
  State<_MapWithBranches> createState() => _MapWithBranchesState();
}

class _MapWithBranchesState extends State<_MapWithBranches>
    with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant _MapWithBranches oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBranch != widget.selectedBranch) {
      _animateCameraToLocation(widget.selectedBranch.location);
    }
  }

  void _animateCameraToLocation(LatLng location) {
    _mapController.move(location, 15);
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.selectedBranch.location,
        initialZoom: 15.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.uod.flutter_project',
        ),
        MarkerLayer(
          markers:
              widget.branches.asMap().entries.map((entry) {
                final isSelected =
                    entry.key == widget.branches.indexOf(widget.selectedBranch);
                return Marker(
                  point: entry.value.location,
                  width: 48,
                  height: 48,
                  child: ScaleTransition(
                    scale: _animationController.drive(
                      Tween<double>(begin: 0.8, end: 1.0),
                    ),
                    child: Tooltip(
                      message: entry.value.name,
                      child: Icon(
                        Icons.location_pin,
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : Colors.grey.shade500,
                        size: isSelected ? 50 : 40,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
