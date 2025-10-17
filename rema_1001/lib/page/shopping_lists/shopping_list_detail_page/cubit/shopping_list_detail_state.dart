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
  ShoppingList get shoppingList {
    final now = DateTime.now().toIso8601String();
    return ShoppingList(
      id: "",
      name: "Shopping List",
      createdAt: now,
      updatedAt: now,
      items: List.generate(5, (index) => ShoppingListItem.mock(id: index)),
    );
  }
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
