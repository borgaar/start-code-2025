import '../models/llm_shopping_list_item.dart';

abstract class LlmRepository {
  /// Generate shopping list recommendations based on a recipe query
  ///
  /// Takes a [query] string describing a recipe or meal idea and returns
  /// a list of recommended products with quantities.
  ///
  /// Example:
  /// ```dart
  /// final response = await llmRepository.generateShoppingList('pasta carbonara');
  /// ```
  Future<LlmShoppingListResponse> generateShoppingList(String query);
}
