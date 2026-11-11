import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tenants/state/tenants_provider.dart';
import '../../tenants/presentation/tenant_detail_view.dart';

class TenantAdminDashboard extends ConsumerStatefulWidget {
  final String tenantId;

  const TenantAdminDashboard({super.key, required this.tenantId});

  @override
  ConsumerState<TenantAdminDashboard> createState() => _TenantAdminDashboardState();
}

class _TenantAdminDashboardState extends ConsumerState<TenantAdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tenantsProvider.notifier).fetchTenantMembers(widget.tenantId);
      ref.read(tenantsProvider.notifier).fetchTenants();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reuse TenantDetailView for complete member administration within the active tenant!
    return TenantDetailView(tenantId: widget.tenantId);
  }
}
