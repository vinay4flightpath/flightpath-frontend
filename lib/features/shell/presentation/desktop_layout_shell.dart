import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class DesktopLayoutShell extends StatefulWidget {
  final Widget child;

  const DesktopLayoutShell({super.key, required this.child});

  @override
  State<DesktopLayoutShell> createState() => _DesktopLayoutShellState();
}

class _DesktopLayoutShellState extends State<DesktopLayoutShell> {
  bool _isCollapsed = false;

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tenants')) return 1;
    if (location.startsWith('/people')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: Row(
        children: [
          // Collapsible Left Navigation Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isCollapsed ? 76 : 260,
            decoration: const BoxDecoration(
              color: AppTheme.primaryDark,
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header with Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      // Logo Image
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
                      if (!_isCollapsed) ...[
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
                                'Stage 1 Foundation',
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

                // Navigation Items
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/dashboard',
                  isSelected: selectedIndex == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.business_outlined,
                  selectedIcon: Icons.business,
                  title: 'Tenants',
                  route: '/tenants',
                  isSelected: selectedIndex == 1,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  title: 'People Directory',
                  route: '/people',
                  isSelected: selectedIndex == 2,
                ),

                const Spacer(),

                // Collapse / Expand Toggle
                const Divider(color: Color(0xFF1E293B)),
                ListTile(
                  dense: true,
                  leading: Icon(
                    _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white70,
                  ),
                  title: _isCollapsed
                      ? null
                      : const Text(
                          'Collapse Sidebar',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                  onTap: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Main Workspace Area
          Expanded(
            child: Column(
              children: [
                // Top Global Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Active Context Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              'Global Admin Mode',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // User Status Badge
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryNavy,
                            child: Text(
                              'SA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Super Administrator',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'vinay@flightpath-training.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Logout Action
                      IconButton(
                        tooltip: 'Logout',
                        icon: const Icon(Icons.logout, size: 20, color: AppTheme.textSecondary),
                        onPressed: () {
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),

                // Main Dynamic Canvas
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

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppTheme.accentCyan.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(route),
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
                if (!_isCollapsed) ...[
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.white70,
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
}
