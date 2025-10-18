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

  void toggleGroupSelection(String groupTitle) {
    final currentState = state;
    if (currentState is! AiAssistantSuccess) return;

    final selectedTitles = Set<String>.from(currentState.selectedGroupTitles);
    if (selectedTitles.contains(groupTitle)) {
      selectedTitles.remove(groupTitle);
    } else {
      selectedTitles.add(groupTitle);
    }

    emit(currentState.copyWith(selectedGroupTitles: selectedTitles));
  }

  void reset() {
    lastPrompt = null;
    emit(const AiAssistantInitial());
  }

  Future<String?> createShoppingListFromSelected() async {
    final currentState = state;
    if (currentState is! AiAssistantSuccess) return null;

    if (currentState.selectedGroupTitles.isEmpty) return null;

    // Get all items from selected groups
    final selectedGroups = currentState.groups
        .where((group) => currentState.selectedGroupTitles.contains(group.title))
        .toList();

    // Create list name by concatenating titles
    final listName = selectedGroups.map((g) => g.title).join(' & ');

    // Create the shopping list
    final shoppingList = await _shoppingListRepository.createShoppingList(
      listName,
    );

    // Add all items from selected groups to the list
    for (final group in selectedGroups) {
      for (final item in group.itemsData) {
        try {
          await _shoppingListRepository.addItemToShoppingList(
            shoppingListId: shoppingList.id,
            productId: item.productId,
            checked: false,
          );
        } catch (_) {
          // already in shopping list
        }
      }
    }

    return shoppingList.id;
  }
}
