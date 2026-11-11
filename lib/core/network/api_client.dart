import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;
  String? _accessToken;
  String? _activeTenantId;

  ApiClient({String baseUrl = 'http://localhost:4000/api'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (_activeTenantId != null && _activeTenantId!.isNotEmpty) {
            options.headers['x-tenant-id'] = _activeTenantId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Centralized error handling
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _accessToken = token;
  }

  void setActiveTenantId(String? tenantId) {
    _activeTenantId = tenantId;
  }

  String? get activeTenantId => _activeTenantId;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
}
