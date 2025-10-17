import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/data/models/store.dart';

abstract class ShoppingTripState extends Equatable {
  const ShoppingTripState();

  @override
  List<Object?> get props => [];
}

class ShoppingTripInitial extends ShoppingTripState {}

class ShoppingTripLoading extends ShoppingTripState {
  const ShoppingTripLoading();
}

class ShoppingTripLoaded extends ShoppingTripState {
  final List<Store> stores;
  final List<ShoppingList> shoppingLists;

  const ShoppingTripLoaded({required this.stores, required this.shoppingLists});

  @override
  List<Object?> get props => [stores, shoppingLists];
}

class ShoppingTripError extends ShoppingTripState {
  final String message;

  const ShoppingTripError(this.message);

  @override
  List<Object?> get props => [message];
}
