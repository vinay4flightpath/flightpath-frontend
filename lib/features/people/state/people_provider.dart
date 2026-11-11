import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/person_model.dart';
import '../../../core/network/api_client.dart';

class PeopleState {
  final bool isLoading;
  final String? error;
  final List<Person> people;
  final int total;
  final int page;
  final String searchQuery;

  const PeopleState({
    this.isLoading = false,
    this.error,
    this.people = const [],
    this.total = 0,
    this.page = 1,
    this.searchQuery = '',
  });

  PeopleState copyWith({
    bool? isLoading,
    String? error,
    List<Person>? people,
    int? total,
    int? page,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PeopleState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      people: people ?? this.people,
      total: total ?? this.total,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PeopleNotifier extends StateNotifier<PeopleState> {
  final ApiClient _apiClient;

  PeopleNotifier(this._apiClient) : super(const PeopleState());

  Future<void> fetchPeople({String? search, int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': 50,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.dio.get('/people', queryParameters: queryParams);
      final body = response.data['data'] as Map<String, dynamic>;
      final items = (body['data'] as List<dynamic>)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
      final meta = body['meta'] as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        people: items,
        total: meta['total'] as int? ?? items.length,
        page: page,
        searchQuery: search ?? '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load people directory.');
    }
  }

  Future<Person?> createPerson({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    bool sendInvite = true,
  }) async {
    try {
      final response = await _apiClient.dio.post('/people', data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'sendInvite': sendInvite,
      });

      final personData = response.data['data'] as Map<String, dynamic>;
      final newPerson = Person.fromJson(personData);

      // Prepend to current list
      state = state.copyWith(
        people: [newPerson, ...state.people],
        total: state.total + 1,
      );
      return newPerson;
    } catch (e) {
      return null;
    }
  }

  Future<List<Person>> searchPersonsDirect(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _apiClient.dio.get('/people', queryParameters: {
        'search': query.trim(),
        'limit': 10,
      });
      final body = response.data['data'] as Map<String, dynamic>;
      return (body['data'] as List<dynamic>)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

final peopleProvider = StateNotifierProvider<PeopleNotifier, PeopleState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PeopleNotifier(apiClient);
});
