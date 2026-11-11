import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../state/tenants_provider.dart';
import '../../../core/models/tenant_model.dart';

class TenantsListView extends ConsumerStatefulWidget {
  const TenantsListView({super.key});

  @override
  ConsumerState<TenantsListView> createState() => _TenantsListViewState();
}

class _TenantsListViewState extends ConsumerState<TenantsListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tenantsProvider.notifier).fetchTenants());
  }

  void _showCreateTenantDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Create New Tenant',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
          ),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tenant / Organisation Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., SkyWings Flight Academy',
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unique Identifier Code',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., SKYWINGS-01',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Code is required';
                      if (!RegExp(r'^[A-Z0-9_-]+$', caseSensitive: false).hasMatch(val.trim())) {
                        return 'Only alphanumeric characters, hyphens, and underscores';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);

                  final newTenant = await ref.read(tenantsProvider.notifier).createTenant(
                        name: nameController.text,
                        code: codeController.text,
                      );
                  if (newTenant != null) {
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('Tenant "${newTenant.name}" created successfully.')),
                    );
                  }
                }
              },
              child: const Text('Create Tenant'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantsProvider);
    final tenants = state.tenants.where((t) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) return true;
      return t.name.toLowerCase().contains(query) || t.code.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenants Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage all aviation training academies, airlines, and training organisations',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Tenant'),
                onPressed: _showCreateTenantDialog,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Search Bar & Filter
          Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tenants by name or code...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),

          // Loading & Content
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (tenants.isEmpty)
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.business_outlined, size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    const Text(
                      'No Tenants Found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first training academy or organisation tenant above.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create Tenant'),
                      onPressed: _showCreateTenantDialog,
                    ),
                  ],
                ),
              ),
            )
          else
            _buildTenantsGrid(tenants),
        ],
      ),
    );
  }

  Widget _buildTenantsGrid(List<Tenant> tenants) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1300 ? 3 : (screenWidth > 900 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tenants.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              context.go('/admin/tenants/${tenant.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business, color: AppTheme.primaryNavy, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                tenant.code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                  const Spacer(),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Role Counts Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCountBadge('Total', tenant.totalMembers, AppTheme.primaryNavy),
                      _buildCountBadge('Admins', tenant.adminCount, AppTheme.accentCyan),
                      _buildCountBadge('Instructors', tenant.instructorCount, AppTheme.warning),
                      _buildCountBadge('Students', tenant.studentCount, AppTheme.success),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
