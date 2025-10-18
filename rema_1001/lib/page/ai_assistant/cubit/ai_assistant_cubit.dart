import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/llm_repository.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';

import 'ai_assistant_state.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  String? lastPrompt;
  final LlmRepository _llmRepository;
  final ShoppingListRepository _shoppingListRepository;

  AiAssistantCubit(this._llmRepository, this._shoppingListRepository)
    : super(const AiAssistantInitial());

  Future<void> requestList(String prompt) async {
    final p = prompt.trim();
    if (p.isEmpty && lastPrompt == null) {
      emit(const AiAssistantFailure('Skriv hva du vil lage først.'));
      return;
    }
    lastPrompt = p.isEmpty ? lastPrompt : p;

    emit(const AiAssistantLoading());
    try {
      final llmGroups = await _llmRepository.generateShoppingList(lastPrompt!);

      final groups = llmGroups.lists
          .map(
            (l) => RecipeGroup(
              l.title,
              l.items.map((i) => "${i.name}, ${i.quantity}${i.unit}").toList(),
              l.items,
            ),
          )
          .toList();

      emit(AiAssistantSuccess(groups));
    } catch (_) {
      emit(const AiAssistantFailure('Noe gikk galt. Prøv igjen.'));
    }
  }

  void toggleItemSelection(String productId) {
    final currentState = state;
    if (currentState is! AiAssistantSuccess) return;

    final selectedIds = Set<String>.from(currentState.selectedProductIds);
    if (selectedIds.contains(productId)) {
      selectedIds.remove(productId);
    } else {
      selectedIds.add(productId);
    }

    emit(currentState.copyWith(selectedProductIds: selectedIds));
  }

  Future<String?> createShoppingListFromSelected() async {
    final currentState = state;
    if (currentState is! AiAssistantSuccess) return null;

    if (currentState.selectedProductIds.isEmpty) return null;

    // Get all selected items and their lists
    final selectedItems = <String, List<String>>{};
    for (final group in currentState.groups) {
      final groupItems = group.itemsData
          .where(
            (item) => currentState.selectedProductIds.contains(item.productId),
          )
          .map((item) => item.productId)
          .toList();

      if (groupItems.isNotEmpty) {
        selectedItems[group.title] = groupItems;
      }
    }

    // Create list name by concatenating titles
    final listName = selectedItems.keys.join(' & ');

    // Create the shopping list
    final shoppingList = await _shoppingListRepository.createShoppingList(
      listName,
    );

    // Add all selected items to the list
    for (final productIds in selectedItems.values) {
      for (final productId in productIds) {
        try {
          await _shoppingListRepository.addItemToShoppingList(
            shoppingListId: shoppingList.id,
            productId: productId,
            checked: false,
          );
        } catch (_) {
          // already in shopping list
        }
      }
    }

    return shoppingList.id;
  }

  // --- Temporary mock instead of a repository call ---
  Future<List<RecipeGroup>> _mockGenerate(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = prompt.toLowerCase();

    if (lower.contains('ostekake')) {
      return const [
        RecipeGroup('Ostekake', [
          'Melk, lett, 1l',
          'Smør, 200g',
          'Kjeks',
          'Philadelphia',
          'Sitron',
        ]),
        RecipeGroup('Til servering', ['Jordbær, 1 kurv', 'Sitronmelisse']),
      ];
    }
    if (lower.contains('fisk') || lower.contains('middag')) {
      return const [
        RecipeGroup('Enkel fiskemiddag for 4', [
          'Fiskegrateng, findus, 1kg',
          'Gulrot, 4stk',
          'Hvitløksbaguette',
        ]),
        RecipeGroup('Drikke', ['Melk, lett, 1l']),
      ];
    }
    // default demo (matches your Figma)
    return const [
      RecipeGroup('Hjemmebakt grovbrød', []),
      RecipeGroup('Ostekake', ['Melk, lett, 1l', 'Smør, 200g', 'Ost']),
      RecipeGroup('Enkel fiskemiddag for 4', [
        'Fiskegrateng, findus, 1kg',
        'Gulrot, 4stk',
        'Hvitløksbaguette',
      ]),
    ];
  }
}
