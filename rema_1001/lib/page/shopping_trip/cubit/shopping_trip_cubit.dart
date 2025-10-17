import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/page/shopping_trip/cubit/shopping_trip_state.dart';

class ShoppingTripCubit extends Cubit<ShoppingTripState> {
  final StoreRepository _storeRepository;
  final ShoppingListRepository _shoppingListRepository;

  ShoppingTripCubit(this._storeRepository, this._shoppingListRepository)
    : super(ShoppingTripInitial());

  Future<void> loadData() async {
    emit(const ShoppingTripLoading());

    try {
      // Load both stores and shopping lists in parallel
      final stores = await _storeRepository.getStores();
      final shoppingLists = await _shoppingListRepository.getShoppingLists();

      emit(ShoppingTripLoaded(stores: stores, shoppingLists: shoppingLists));
    } catch (e) {
      emit(ShoppingTripError('Failed to load data: $e'));
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
