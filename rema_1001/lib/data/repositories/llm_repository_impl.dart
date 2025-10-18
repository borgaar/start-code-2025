import 'dart:convert' as dart_convert;
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

      // Check if response contains an error/failure reason
      if (response is Map<String, dynamic>) {
        if (response.containsKey('error')) {
          final reason = response['error'] ?? 'Unknown error';
          throw LlmFailureException(reason.toString());
        }

        return LlmShoppingListResponse.fromJson(response);
      }

      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate shopping list from query: $query',
        name: 'LlmRepository',
        error: e,
        stackTrace: stackTrace,
      );

      // Re-throw LlmFailureException as-is to preserve the failure reason
      if (e is LlmFailureException) {
        rethrow;
      }

      // Try to extract error message from ApiException
      if (e is ApiException) {
        // ApiException message format: "Request failed with status XXX: {json body}"
        final message = e.message;
        final jsonStart = message.indexOf('{');
        if (jsonStart != -1) {
          try {
            final jsonBody = message.substring(jsonStart);
            final Map<String, dynamic> errorBody =
                dart_convert.jsonDecode(jsonBody) as Map<String, dynamic>;
            if (errorBody.containsKey('error')) {
              throw LlmFailureException(errorBody['error'].toString());
            }
          } catch (_) {
            // If parsing fails, fall through to generic error
          }
        }
      }

      throw ApiException('Failed to generate shopping list: $e');
    }
  }
}

/// Exception thrown when LLM generation fails with a specific reason
class LlmFailureException implements Exception {
  final String reason;

  LlmFailureException(this.reason);

  @override
  String toString() => reason;
}
