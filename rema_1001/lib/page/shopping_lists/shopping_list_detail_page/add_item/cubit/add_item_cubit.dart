import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/product_repository.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/cubit/add_item_state.dart';

class AddItemCubit extends Cubit<AddItemState> {
  final ProductRepository _productRepository;

  AddItemCubit(this._productRepository) : super(AddItemInitial());

  Future<void> loadProducts() async {
    emit(const AddItemLoading());

    try {
      final products = await _productRepository.getProducts();
      emit(AddItemLoaded(products: products, filteredProducts: products));
    } catch (e) {
      emit(AddItemError('Failed to load products: $e'));
    }
  }

  void filterProducts(String query) {
    final currentState = state;
    if (currentState is AddItemLoaded) {
      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredProducts: currentState.products,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
        emit(
          currentState.copyWith(filteredProducts: filtered, searchQuery: query),
        );
      }
    }
  }

  void clearSearch() {
    filterProducts('');
  }
}
