import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/cubit/store_selection_state.dart';

class StoreSelectionCubit extends Cubit<StoreSelectionState> {
  final StoreRepository _storeRepository;

  StoreSelectionCubit(this._storeRepository) : super(StoreSelectionInitial());

  Future<void> loadStores() async {
    emit(const StoreSelectionLoading());

    try {
      final stores = await _storeRepository.getStores();
      emit(StoreSelectionLoaded(stores));
    } catch (e) {
      emit(StoreSelectionError('Failed to load stores: $e'));
    }
  }

  Future<void> refresh() async {
    await loadStores();
  }
}
