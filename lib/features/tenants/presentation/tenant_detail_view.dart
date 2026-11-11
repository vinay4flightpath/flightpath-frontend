import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../state/tenants_provider.dart';
import '../../people/state/people_provider.dart';
import '../../../core/models/tenant_model.dart';
import '../../../core/models/person_model.dart';

class TenantDetailView extends ConsumerStatefulWidget {
  final String tenantId;

  const TenantDetailView({super.key, required this.tenantId});

  @override
  ConsumerState<TenantDetailView> createState() => _TenantDetailViewState();
}

class _TenantDetailViewState extends ConsumerState<TenantDetailView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tenantsProvider.notifier).fetchTenantMembers(widget.tenantId);
      ref.read(tenantsProvider.notifier).fetchTenants();
    });
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AddMemberDualDialog(tenantId: widget.tenantId);
      },
    );
  }

  void _showEditRolesDialog(TenantMember member) {
    final selectedRoles = List<String>.from(member.roles);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Edit Roles: ${member.fullName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flightpath ID: ${member.flightpathId}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Assigned Roles:'),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Admin (Can manage tenant)'),
                    value: selectedRoles.contains('ADMIN'),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          selectedRoles.add('ADMIN');
                        } else {
                          selectedRoles.remove('ADMIN');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Instructor'),
                    value: selectedRoles.contains('INSTRUCTOR'),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          selectedRoles.add('INSTRUCTOR');
                        } else {
                          selectedRoles.remove('INSTRUCTOR');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Student'),
                    value: selectedRoles.contains('STUDENT'),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          selectedRoles.add('STUDENT');
                        } else {
                          selectedRoles.remove('STUDENT');
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedRoles.isEmpty
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(dialogContext);

                          final success = await ref
                              .read(tenantsProvider.notifier)
                              .updateMemberRoles(
                                tenantId: widget.tenantId,
                                memberId: member.membershipId,
                                roles: selectedRoles,
                              );
                          if (success) {
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Roles updated successfully.')),
                            );
                          }
                        },
                  child: const Text('Save Roles'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantsProvider);
    final tenant = state.tenants.firstWhere(
      (t) => t.id == widget.tenantId,
      orElse: () => Tenant(
        id: widget.tenantId,
        name: 'Tenant Workspace',
        code: '',
        status: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
    );

    final members = state.members.where((m) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) return true;
      return m.fullName.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query) ||
          m.flightpathId.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Navigation
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back to Tenants'),
                onPressed: () => context.go('/admin/tenants'),
              ),
              const SizedBox(width: 8),
              const Text('/', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              Text(
                tenant.name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tenant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          tenant.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tenant workspace members, instructors, students, and role assignments',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Member'),
                onPressed: _showAddMemberDialog,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Search Bar
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search members by name, email, or Flightpath ID...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 20),

          // Members Table
          if (state.isMembersLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (members.isEmpty)
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    const Text(
                      'No Members in this Tenant',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search existing persons or add someone on-the-fly to assign roles in this tenant.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Member'),
                      onPressed: _showAddMemberDialog,
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  horizontalMargin: 24,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Flightpath ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tenant Roles', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: members.map((member) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            member.flightpathId,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accentCyan),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                child: Text(
                                  member.firstName.isNotEmpty ? member.firstName[0] : 'U',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        DataCell(Text(member.email)),
                        DataCell(
                          Wrap(
                            spacing: 6,
                            children: member.roles.map((r) => _buildRoleChip(r)).toList(),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${member.joinedAt.day}/${member.joinedAt.month}/${member.joinedAt.year}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.accentCyan),
                                tooltip: 'Edit Roles',
                                onPressed: () => _showEditRolesDialog(member),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                                tooltip: 'Remove from Tenant',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Removal'),
                                      content: Text(
                                        'Remove ${member.fullName} from this tenant? Their global Person profile in Flightpath will remain preserved.',
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref.read(tenantsProvider.notifier).removeMember(
                                          tenantId: widget.tenantId,
                                          memberId: member.membershipId,
                                        );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color bg = AppTheme.primaryNavy.withValues(alpha: 0.08);
    Color fg = AppTheme.primaryNavy;

    if (role == 'ADMIN') {
      bg = AppTheme.accentCyan.withValues(alpha: 0.15);
      fg = AppTheme.accentCyan;
    } else if (role == 'INSTRUCTOR') {
      bg = AppTheme.warning.withValues(alpha: 0.15);
      fg = AppTheme.warning;
    } else if (role == 'STUDENT') {
      bg = AppTheme.success.withValues(alpha: 0.15);
      fg = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Dual-Mode Add Member Dialog:
/// Tab 1: Search Existing Person
/// Tab 2: Create On-The-Fly
class _AddMemberDualDialog extends ConsumerStatefulWidget {
  final String tenantId;

  const _AddMemberDualDialog({required this.tenantId});

  @override
  ConsumerState<_AddMemberDualDialog> createState() => _AddMemberDualDialogState();
}

class _AddMemberDualDialogState extends ConsumerState<_AddMemberDualDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search existing state
  final _searchExistingController = TextEditingController();
  List<Person> _searchResults = [];
  Person? _selectedPerson;
  final Set<String> _existingSelectedRoles = {'STUDENT'};
  bool _isSearching = false;

  // Quick create state
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final Set<String> _quickCreateRoles = {'INSTRUCTOR'};
  bool _isSubmitting = false;

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

  void _onSearchExisting(String val) async {
    if (val.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await ref.read(peopleProvider.notifier).searchPersonsDirect(val);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Member to Tenant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Search for an existing person in the platform or create someone on-the-fly.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 18),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryNavy,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accentCyan,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.person_search, size: 20), text: 'Search Existing Person'),
                Tab(icon: Icon(Icons.person_add, size: 20), text: 'Create On-the-Fly'),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Views
            SizedBox(
              height: 340,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSearchExistingTab(),
                  _buildQuickCreateTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchExistingTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchExistingController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or Flightpath ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: _onSearchExisting,
          ),
          const SizedBox(height: 12),

          // Search results or selected person
          if (_selectedPerson != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.accentCyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPerson!.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${_selectedPerson!.email} • ID: ${_selectedPerson!.flightpathId}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedPerson = null),
                    child: const Text('Change'),
                  ),
                ],
              ),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = _searchResults[index];
                  return ListTile(
                    dense: true,
                    title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.email} • ${p.flightpathId}'),
                    trailing: const Icon(Icons.add_circle_outline, color: AppTheme.accentCyan),
                    onTap: () {
                      setState(() {
                        _selectedPerson = p;
                        _searchResults = [];
                      });
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
          const Text('Select Roles for this Tenant:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['ADMIN', 'INSTRUCTOR', 'STUDENT'].map((role) {
              final isSelected = _existingSelectedRoles.contains(role);
              return FilterChip(
                label: Text(role),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _existingSelectedRoles.add(role);
                    } else {
                      _existingSelectedRoles.remove(role);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: (_selectedPerson == null || _existingSelectedRoles.isEmpty || _isSubmitting)
                ? null
                : () async {
                    setState(() => _isSubmitting = true);
                    final success = await ref.read(tenantsProvider.notifier).addExistingMember(
                          tenantId: widget.tenantId,
                          personId: _selectedPerson!.id,
                          roles: _existingSelectedRoles.toList(),
                        );
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Member added to tenant successfully.')),
                        );
                      }
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Add Existing Person to Tenant'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCreateTab() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address *'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (optional)'),
            ),
            const SizedBox(height: 14),

            const Text('Assign Tenant Roles:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ['ADMIN', 'INSTRUCTOR', 'STUDENT'].map((role) {
                final isSelected = _quickCreateRoles.contains(role);
                return FilterChip(
                  label: Text(role),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _quickCreateRoles.add(role);
                      } else {
                        _quickCreateRoles.remove(role);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: (_quickCreateRoles.isEmpty || _isSubmitting)
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => _isSubmitting = true);
                        final success = await ref.read(tenantsProvider.notifier).quickCreateMember(
                              tenantId: widget.tenantId,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                              roles: _quickCreateRoles.toList(),
                            );
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          if (success) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Person added to tenant on-the-fly successfully.'),
                              ),
                            );
                          }
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create & Add Member On-the-Fly'),
            ),
          ],
        ),
      ),
    );
  }
}
