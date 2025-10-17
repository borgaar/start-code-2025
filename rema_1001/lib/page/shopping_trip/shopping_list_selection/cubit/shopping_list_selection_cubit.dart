import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/page/shopping_trip/shopping_list_selection/cubit/shopping_list_selection_state.dart';

class ShoppingListSelectionCubit extends Cubit<ShoppingListSelectionState> {
  final ShoppingListRepository _shoppingListRepository;
  final String storeSlug;

  ShoppingListSelectionCubit(this._shoppingListRepository, this.storeSlug)
    : super(ShoppingListSelectionInitial());

  Future<void> loadShoppingLists() async {
    emit(ShoppingListSelectionLoading(storeSlug));

    try {
      final shoppingLists = await _shoppingListRepository.getShoppingLists();
      emit(ShoppingListSelectionLoaded(shoppingLists, storeSlug));
    } catch (e) {
      emit(ShoppingListSelectionError('Failed to load shopping lists: $e'));
    }
  }

  Future<void> refresh() async {
    await loadShoppingLists();
  }
}
