import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/tenant_selection_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/tenants/presentation/tenants_list_view.dart';
import '../../features/tenants/presentation/tenant_detail_view.dart';
import '../../features/people/presentation/people_list_view.dart';
import '../../features/tenant_workspace/presentation/tenant_admin_dashboard.dart';
import '../../features/shell/presentation/adaptive_layout_shell.dart';
import '../state/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == '/login';

      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        if (authState.isSuperAdmin) {
          return '/admin/dashboard';
        } else if (authState.tenants.length > 1) {
          return '/tenant-selection';
        } else if (authState.tenants.length == 1) {
          return '/tenant/${authState.tenants.first.tenantId}/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/tenant-selection',
        name: 'tenant-selection',
        builder: (context, state) => const TenantSelectionScreen(),
      ),

      // Adaptive Nested Shell for SuperAdmin & Tenant Admin Workspaces
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdaptiveLayoutShell(child: child);
        },
        routes: [
          // SuperAdmin Routes
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/tenants',
            name: 'admin-tenants',
            builder: (context, state) => const TenantsListView(),
            routes: [
              GoRoute(
                path: ':tenantId',
                name: 'admin-tenant-detail',
                builder: (context, state) {
                  final tenantId = state.pathParameters['tenantId'] ?? '';
                  return TenantDetailView(tenantId: tenantId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/people',
            name: 'admin-people',
            builder: (context, state) => const PeopleListView(),
          ),

          // Tenant-Scoped Routes
          GoRoute(
            path: '/tenant/:tenantId/dashboard',
            name: 'tenant-dashboard',
            builder: (context, state) {
              final tenantId = state.pathParameters['tenantId'] ?? '';
              return TenantAdminDashboard(tenantId: tenantId);
            },
          ),
          GoRoute(
            path: '/tenant/:tenantId/members',
            name: 'tenant-members',
            builder: (context, state) {
              final tenantId = state.pathParameters['tenantId'] ?? '';
              return TenantDetailView(tenantId: tenantId);
            },
          ),
        ],
      ),
    ],
  );
});
