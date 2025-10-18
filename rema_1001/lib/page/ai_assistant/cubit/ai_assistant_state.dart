import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/llm_shopping_list_item.dart';

class RecipeGroup extends Equatable {
  final String title;
  final List<String> items;
  final List<LlmShoppingListItem> itemsData;

  const RecipeGroup(this.title, this.items, [this.itemsData = const []]);

  @override
  List<Object?> get props => [title, items, itemsData];
}

abstract class AiAssistantState extends Equatable {
  const AiAssistantState();
  @override
  List<Object?> get props => [];
}

class AiAssistantInitial extends AiAssistantState {
  const AiAssistantInitial();
}

class AiAssistantLoading extends AiAssistantState {
  const AiAssistantLoading();
}

class AiAssistantSuccess extends AiAssistantState {
  final List<RecipeGroup> groups;
  final Set<String> selectedProductIds;

  const AiAssistantSuccess(this.groups, {this.selectedProductIds = const {}});

  AiAssistantSuccess copyWith({
    List<RecipeGroup>? groups,
    Set<String>? selectedProductIds,
  }) {
    return AiAssistantSuccess(
      groups ?? this.groups,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
    );
  }

  @override
  List<Object?> get props => [groups, selectedProductIds];
}

class AiAssistantFailure extends AiAssistantState {
  final String message;
  const AiAssistantFailure(this.message);
  @override
  List<Object?> get props => [message];
}
