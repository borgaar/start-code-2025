import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/shopping_list.dart';

abstract class ShoppingListsState extends Equatable {
  const ShoppingListsState();

  @override
  List<Object?> get props => [];
}

class ShoppingListsInitial extends ShoppingListsState {}

abstract class ShoppingListsInProgress extends ShoppingListsState {
  List<ShoppingList> get shoppingLists;

  const ShoppingListsInProgress();
}

class ShoppingListsLoading extends ShoppingListsInProgress {
  const ShoppingListsLoading();

  @override
  List<ShoppingList> get shoppingLists =>
      List.generate(5, (index) => ShoppingList.mock(id: index));

  @override
  List<Object?> get props => [];
}

class ShoppingListsLoaded extends ShoppingListsInProgress {
  @override
  final List<ShoppingList> shoppingLists;

  const ShoppingListsLoaded(this.shoppingLists);

  @override
  List<Object?> get props => [shoppingLists];
}

class ShoppingListsError extends ShoppingListsState {
  final String message;

  const ShoppingListsError(this.message);

  @override
  List<Object?> get props => [message];
}
