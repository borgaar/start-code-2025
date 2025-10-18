import 'dart:developer' as developer;

import '../api/api_client.dart';
import '../models/llm_shopping_list_item.dart';
import 'llm_repository.dart';

class LlmRepositoryImpl implements LlmRepository {
  final ApiClient _apiClient;

  LlmRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<LlmShoppingListResponse> generateShoppingList(String query) async {
    try {
      if (query.trim().isEmpty) {
        throw ApiException('Query cannot be empty');
      }

      final response = await _apiClient.post(
        '/api/llm/shopping-list',
        body: {'query': query},
      );

      return LlmShoppingListResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate shopping list from query: $query',
        name: 'LlmRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to generate shopping list: $e');
    }
  }
}
