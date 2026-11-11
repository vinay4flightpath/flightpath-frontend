import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? accessToken;
  final AuthenticatedUser? user;
  final List<UserTenantMembership> tenants;
  final UserTenantMembership? activeTenant;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.accessToken,
    this.user,
    this.tenants = const [],
    this.activeTenant,
  });

  bool get isAuthenticated => accessToken != null && user != null;
  bool get isSuperAdmin => user?.isSuperAdmin ?? false;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? accessToken,
    AuthenticatedUser? user,
    List<UserTenantMembership>? tenants,
    UserTenantMembership? activeTenant,
    bool clearActiveTenant = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      tenants: tenants ?? this.tenants,
      activeTenant: clearActiveTenant ? null : (activeTenant ?? this.activeTenant),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      final body = response.data;
      final data = body['data'] as Map<String, dynamic>;

      final token = data['accessToken'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = AuthenticatedUser.fromJson(userData);

      final tenantsData = (data['tenants'] as List<dynamic>?)
              ?.map((t) => UserTenantMembership.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [];

      // Configure ApiClient headers
      _apiClient.setAuthToken(token);

      UserTenantMembership? defaultActiveTenant;
      if (!user.isSuperAdmin && tenantsData.isNotEmpty) {
        defaultActiveTenant = tenantsData.first;
        _apiClient.setActiveTenantId(defaultActiveTenant.tenantId);
      }

      state = state.copyWith(
        isLoading: false,
        accessToken: token,
        user: user,
        tenants: tenantsData,
        activeTenant: defaultActiveTenant,
      );
      return true;
    } on DioException catch (e) {
      String errorMessage = 'Login failed. Please check your credentials.';
      final resData = e.response?.data;
      if (resData is Map<String, dynamic>) {
        final err = resData['error'];
        if (err is List && err.isNotEmpty) {
          errorMessage = err.first.toString();
        } else if (err != null) {
          errorMessage = err.toString();
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to connect to Flightpath backend. Please try again.',
      );
      return false;
    }
  }

  void selectTenant(String tenantId) {
    final selected = state.tenants.firstWhere(
      (t) => t.tenantId == tenantId,
      orElse: () => state.tenants.first,
    );
    _apiClient.setActiveTenantId(selected.tenantId);
    state = state.copyWith(activeTenant: selected);
  }

  void logout() {
    _apiClient.setAuthToken(null);
    _apiClient.setActiveTenantId(null);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});
