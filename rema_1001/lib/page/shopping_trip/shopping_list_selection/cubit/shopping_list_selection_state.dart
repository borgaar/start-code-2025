import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/shopping_list.dart';

abstract class ShoppingListSelectionState extends Equatable {
  const ShoppingListSelectionState();

  @override
  List<Object?> get props => [];
}

class ShoppingListSelectionInitial extends ShoppingListSelectionState {}

abstract class ShoppingListSelectionInProgress
    extends ShoppingListSelectionState {
  List<ShoppingList> get shoppingLists;
  String get storeSlug;

  const ShoppingListSelectionInProgress();
}

class ShoppingListSelectionLoading extends ShoppingListSelectionInProgress {
  @override
  final String storeSlug;

  const ShoppingListSelectionLoading(this.storeSlug);

  @override
  List<ShoppingList> get shoppingLists =>
      List.generate(5, (index) => ShoppingList.mock(id: index));

  @override
  List<Object?> get props => [storeSlug];
}

class ShoppingListSelectionLoaded extends ShoppingListSelectionInProgress {
  @override
  final List<ShoppingList> shoppingLists;
  @override
  final String storeSlug;

  const ShoppingListSelectionLoaded(this.shoppingLists, this.storeSlug);

  @override
  List<Object?> get props => [shoppingLists, storeSlug];
}

class ShoppingListSelectionError extends ShoppingListSelectionState {
  final String message;

  const ShoppingListSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}
