import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/data/models/shopping_list_item.dart';

abstract class ShoppingListDetailState extends Equatable {
  const ShoppingListDetailState();

  @override
  List<Object?> get props => [];
}

class ShoppingListDetailInitial extends ShoppingListDetailState {}

abstract class ShoppingListDetailInProgress extends ShoppingListDetailState {
  ShoppingList get shoppingList;
}

class ShoppingListDetailLoading extends ShoppingListDetailInProgress {
  @override
  ShoppingList get shoppingList => ShoppingList(
    id: "",
    name: "Shopping List",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    items: List.generate(5, (index) => ShoppingListItem.mock(id: index)),
  );
}

class ShoppingListDetailLoaded extends ShoppingListDetailInProgress {
  @override
  final ShoppingList shoppingList;

  ShoppingListDetailLoaded(this.shoppingList);

  @override
  List<Object?> get props => [shoppingList];
}

class ShoppingListDetailError extends ShoppingListDetailState {
  final String message;

  const ShoppingListDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
