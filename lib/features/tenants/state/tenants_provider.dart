import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/tenant_model.dart';
import '../../../core/network/api_client.dart';

class TenantsState {
  final bool isLoading;
  final String? error;
  final List<Tenant> tenants;
  final String? selectedTenantId;
  final List<TenantMember> members;
  final bool isMembersLoading;

  const TenantsState({
    this.isLoading = false,
    this.error,
    this.tenants = const [],
    this.selectedTenantId,
    this.members = const [],
    this.isMembersLoading = false,
  });

  TenantsState copyWith({
    bool? isLoading,
    String? error,
    List<Tenant>? tenants,
    String? selectedTenantId,
    List<TenantMember>? members,
    bool? isMembersLoading,
    bool clearError = false,
  }) {
    return TenantsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      tenants: tenants ?? this.tenants,
      selectedTenantId: selectedTenantId ?? this.selectedTenantId,
      members: members ?? this.members,
      isMembersLoading: isMembersLoading ?? this.isMembersLoading,
    );
  }
}

class TenantsNotifier extends StateNotifier<TenantsState> {
  final ApiClient _apiClient;

  TenantsNotifier(this._apiClient) : super(const TenantsState());

  Future<void> fetchTenants() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.dio.get('/tenants');
      final items = (response.data['data'] as List<dynamic>)
          .map((t) => Tenant.fromJson(t as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isLoading: false, tenants: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load tenants.');
    }
  }

  Future<Tenant?> createTenant({required String name, required String code}) async {
    try {
      final response = await _apiClient.dio.post('/tenants', data: {
        'name': name.trim(),
        'code': code.toUpperCase().trim(),
      });

      final newTenant = Tenant.fromJson(response.data['data'] as Map<String, dynamic>);
      state = state.copyWith(tenants: [newTenant, ...state.tenants]);
      return newTenant;
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchTenantMembers(String tenantId) async {
    state = state.copyWith(
      isMembersLoading: true,
      selectedTenantId: tenantId,
      clearError: true,
    );
    try {
      final response = await _apiClient.dio.get('/tenants/$tenantId/members');
      final membersList = (response.data['data'] as List<dynamic>)
          .map((m) => TenantMember.fromJson(m as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isMembersLoading: false, members: membersList);
    } catch (e) {
      state = state.copyWith(
        isMembersLoading: false,
        error: 'Failed to load tenant members.',
      );
    }
  }

  Future<bool> addExistingMember({
    required String tenantId,
    required String personId,
    required List<String> roles,
  }) async {
    try {
      await _apiClient.dio.post('/tenants/$tenantId/members', data: {
        'personId': personId,
        'roles': roles,
      });

      // Refresh members and tenant stats
      await fetchTenantMembers(tenantId);
      await fetchTenants();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> quickCreateMember({
    required String tenantId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required List<String> roles,
  }) async {
    try {
      await _apiClient.dio.post('/tenants/$tenantId/members/quick-create', data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'roles': roles,
        'sendInvite': true,
      });

      // Refresh members and tenant stats
      await fetchTenantMembers(tenantId);
      await fetchTenants();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMemberRoles({
    required String tenantId,
    required String memberId,
    required List<String> roles,
  }) async {
    try {
      await _apiClient.dio.put('/tenants/$tenantId/members/$memberId/roles', data: {
        'roles': roles,
      });

      await fetchTenantMembers(tenantId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMember({
    required String tenantId,
    required String memberId,
  }) async {
    try {
      await _apiClient.dio.delete('/tenants/$tenantId/members/$memberId');
      state = state.copyWith(
        members: state.members.where((m) => m.membershipId != memberId).toList(),
      );
      await fetchTenants();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final tenantsProvider = StateNotifierProvider<TenantsNotifier, TenantsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TenantsNotifier(apiClient);
});
