import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../tenants/state/tenants_provider.dart';
import '../../people/state/people_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tenantsProvider.notifier).fetchTenants();
      ref.read(peopleProvider.notifier).fetchPeople();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenantsState = ref.watch(tenantsProvider);
    final peopleState = ref.watch(peopleProvider);

    final totalTenants = tenantsState.tenants.length;
    final totalPeople = peopleState.total > 0 ? peopleState.total : peopleState.people.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SuperAdmin Global Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Flightpath Stage 1 Foundation System Overview',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Person'),
                    onPressed: () => context.go('/admin/people'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_business, size: 18),
                    label: const Text('New Tenant'),
                    onPressed: () => context.go('/admin/tenants'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Metric Cards Row
          Row(
            children: [
              _buildMetricCard(
                title: 'Active Tenants',
                value: totalTenants.toString(),
                subtitle: 'Configured training operators',
                icon: Icons.business,
                color: AppTheme.primaryNavy,
              ),
              const SizedBox(width: 20),
              _buildMetricCard(
                title: 'Total People',
                value: totalPeople.toString(),
                subtitle: 'Unified identities in platform',
                icon: Icons.people_outline,
                color: AppTheme.accentCyan,
              ),
              const SizedBox(width: 20),
              _buildMetricCard(
                title: 'System Status',
                value: 'Operational',
                subtitle: 'PostgreSQL + NestJS + Flutter Web',
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick Workflow Cards (7-Step Flow Guidance)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Initial System Onboarding Workflow (Phase 1)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Follow these 7 steps to configure your organisations, people, and contextual roles:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStepItem(
                    stepNumber: '1',
                    title: 'SuperAdmin Login',
                    description: 'Global administrator logged in with full system management permissions.',
                    isDone: true,
                  ),
                  _buildStepItem(
                    stepNumber: '2',
                    title: 'Create Persons',
                    description: 'Add global person records with unique Flightpath IDs without initial roles in People Directory.',
                    isDone: totalPeople > 1,
                  ),
                  _buildStepItem(
                    stepNumber: '3',
                    title: 'Create Tenants',
                    description: 'Provision training academies, flight schools, or airlines in Tenants Directory.',
                    isDone: totalTenants > 0,
                  ),
                  _buildStepItem(
                    stepNumber: '4',
                    title: 'Add Tenant Members (Search or On-the-Fly)',
                    description: 'Enter a tenant and assign existing persons or create new persons on-the-fly with Admin, Instructor, or Student roles.',
                    isDone: false,
                  ),
                  _buildStepItem(
                    stepNumber: '5',
                    title: 'Person Login & Multi-Tenant Switcher',
                    description: 'When users log in, they see their accessible tenants or are redirected to their active workspace.',
                    isDone: false,
                  ),
                  _buildStepItem(
                    stepNumber: '6 & 7',
                    title: 'Tenant Admin Workspace',
                    description: 'Tenant Admins manage instructors and students strictly within their tenant boundaries.',
                    isDone: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
    required bool isDone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone ? AppTheme.success : AppTheme.primaryNavy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      stepNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
