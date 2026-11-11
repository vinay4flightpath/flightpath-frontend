import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../state/people_provider.dart';

class PeopleListView extends ConsumerStatefulWidget {
  const PeopleListView({super.key});

  @override
  ConsumerState<PeopleListView> createState() => _PeopleListViewState();
}

class _PeopleListViewState extends ConsumerState<PeopleListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(peopleProvider.notifier).fetchPeople());
  }

  void _showCreatePersonDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    bool sendInvite = true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Create Global Person Record',
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
                        'This creates a standalone individual profile in Flightpath. Tenant roles can be assigned subsequently.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(labelText: 'First Name *'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(labelText: 'Last Name *'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email Address *'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number (optional)'),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Send invitation link / token immediately', style: TextStyle(fontSize: 13)),
                        value: sendInvite,
                        onChanged: (val) {
                          setDialogState(() {
                            sendInvite = val ?? true;
                          });
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

                      final newPerson = await ref.read(peopleProvider.notifier).createPerson(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                            sendInvite: sendInvite,
                          );

                      if (newPerson != null) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Person created successfully with Flightpath ID: ${newPerson.flightpathId}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Create Person'),
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
    final state = ref.watch(peopleProvider);
    final people = state.people;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global People Directory',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Unified identities across all tenants (One Person, One Identity)',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('New Person'),
                onPressed: _showCreatePersonDialog,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Search Bar
          Row(
            children: [
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
                    hintText: 'Search people by name, email, or Flightpath ID...',
                    prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (query) {
                    ref.read(peopleProvider.notifier).fetchPeople(search: query);
                  },
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search'),
                onPressed: () {
                  ref.read(peopleProvider.notifier).fetchPeople(search: _searchController.text);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (people.isEmpty)
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
                      'No People Found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add people to your system without roles, or add members inside tenants.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Create Person'),
                      onPressed: _showCreatePersonDialog,
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
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tenant Affiliations', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: people.map((person) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            person.flightpathId,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentCyan),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                child: Text(
                                  person.firstName.isNotEmpty ? person.firstName[0] : 'U',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(person.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        DataCell(Text(person.email)),
                        DataCell(_buildStatusBadge(person.status)),
                        DataCell(
                          person.memberships.isEmpty
                              ? const Text('None (Unassigned)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))
                              : Wrap(
                                  spacing: 6,
                                  children: person.memberships
                                      .map(
                                        (m) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${m.tenantCode} (${m.roles.join(', ')})',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                        DataCell(
                          Text(
                            '${person.createdAt.day}/${person.createdAt.month}/${person.createdAt.year}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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

  Widget _buildStatusBadge(String status) {
    Color bg = AppTheme.success.withValues(alpha: 0.15);
    Color fg = AppTheme.success;

    if (status == 'INVITED') {
      bg = AppTheme.warning.withValues(alpha: 0.15);
      fg = AppTheme.warning;
    } else if (status == 'INACTIVE') {
      bg = AppTheme.danger.withValues(alpha: 0.15);
      fg = AppTheme.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
