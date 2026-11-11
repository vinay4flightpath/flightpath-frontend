import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/auth_provider.dart';

class AdaptiveLayoutShell extends ConsumerStatefulWidget {
  final Widget child;

  const AdaptiveLayoutShell({super.key, required this.child});

  @override
  ConsumerState<AdaptiveLayoutShell> createState() => _AdaptiveLayoutShellState();
}

class _AdaptiveLayoutShellState extends ConsumerState<AdaptiveLayoutShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final authState = ref.watch(authProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final isSuperAdminMode = location.startsWith('/admin');

    return Scaffold(
      key: _scaffoldKey,
      drawer: (!isDesktop) ? Drawer(child: _buildSidebarContent(context, location, isSuperAdminMode, false)) : null,
      body: Row(
        children: [
          // Sidebar on Desktop / Tablet (Expanded or Collapsed)
          if (isDesktop || (isTablet && !_isSidebarCollapsed))
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSidebarCollapsed ? 76 : 260,
              decoration: const BoxDecoration(
                color: AppTheme.primaryDark,
                border: Border(right: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: _buildSidebarContent(context, location, isSuperAdminMode, _isSidebarCollapsed),
            ),

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                // Top Global Header Bar
                _buildHeaderBar(context, ref, authState, !isDesktop),

                // Main Content View
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundLight,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    String location,
    bool isSuperAdminMode,
    bool isCollapsed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Header with Logo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.flight_takeoff, color: AppTheme.primaryNavy),
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLIGHTPATH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Training & Identity',
                        style: TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(color: Color(0xFF1E293B)),
        const SizedBox(height: 12),

        // Navigation Links depending on Mode
        if (isSuperAdminMode) ...[
          _buildNavItem(
            context,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            title: 'Global Dashboard',
            route: '/admin/dashboard',
            isSelected: location == '/admin/dashboard',
            isCollapsed: isCollapsed,
          ),
          _buildNavItem(
            context,
            icon: Icons.business_outlined,
            selectedIcon: Icons.business,
            title: 'Tenants Directory',
            route: '/admin/tenants',
            isSelected: location.startsWith('/admin/tenants'),
            isCollapsed: isCollapsed,
          ),
          _buildNavItem(
            context,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            title: 'People Directory',
            route: '/admin/people',
            isSelected: location.startsWith('/admin/people'),
            isCollapsed: isCollapsed,
          ),
        ] else ...[
          _buildNavItem(
            context,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            title: 'Tenant Dashboard',
            route: location.split('/members')[0], // active tenant dashboard
            isSelected: !location.contains('/members'),
            isCollapsed: isCollapsed,
          ),
          _buildNavItem(
            context,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            title: 'Members',
            route: '${location.split('/members')[0]}/members',
            isSelected: location.contains('/members'),
            isCollapsed: isCollapsed,
          ),
        ],

        const Spacer(),

        // Collapse / Expand Toggle
        const Divider(color: Color(0xFF1E293B)),
        ListTile(
          dense: true,
          leading: Icon(
            isCollapsed ? Icons.chevron_right : Icons.chevron_left,
            color: Colors.white70,
          ),
          title: isCollapsed
              ? null
              : const Text(
                  'Collapse Sidebar',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
          onTap: () {
            setState(() {
              _isSidebarCollapsed = !_isSidebarCollapsed;
            });
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String route,
    required bool isSelected,
    required bool isCollapsed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppTheme.accentCyan.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.of(context).pop(); // close drawer on mobile/tablet
            }
            context.go(route);
          },
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected ? AppTheme.accentTeal : Colors.white70,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    bool showDrawerButton,
  ) {
    final user = authState.user;
    final activeTenant = authState.activeTenant;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Row(
        children: [
          if (showDrawerButton)
            IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.primaryNavy),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          // Workspace Context Badge
          if (user?.isSuperAdmin ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppTheme.primaryNavy),
                  SizedBox(width: 6),
                  Text(
                    'SuperAdmin Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            )
          else if (activeTenant != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business, size: 14, color: AppTheme.accentCyan),
                  const SizedBox(width: 6),
                  Text(
                    activeTenant.tenantName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),

          // Multi-tenant switcher dropdown (if user has > 1 tenant)
          if ((authState.tenants.length > 1)) ...[
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              tooltip: 'Switch Tenant',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderLight),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Text('Switch Tenant', style: TextStyle(fontSize: 12)),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
              onSelected: (tenantId) {
                ref.read(authProvider.notifier).selectTenant(tenantId);
                context.go('/tenant/$tenantId/dashboard');
              },
              itemBuilder: (context) => authState.tenants
                  .map(
                    (t) => PopupMenuItem(
                      value: t.tenantId,
                      child: Text('${t.tenantName} (${t.roles.join(', ')})'),
                    ),
                  )
                  .toList(),
            ),
          ],

          const Spacer(),

          // User Profile Info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryNavy,
                child: Text(
                  user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Logout Action
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, size: 20, color: AppTheme.textSecondary),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
