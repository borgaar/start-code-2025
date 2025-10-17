import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/product.dart';

abstract class AddItemState extends Equatable {
  const AddItemState();

  @override
  List<Object?> get props => [];
}

class AddItemInitial extends AddItemState {}

abstract class AddItemInProgress extends AddItemState {
  List<Product> get products;
  List<Product> get filteredProducts;
  String get searchQuery;

  const AddItemInProgress();
}

class AddItemLoading extends AddItemInProgress {
  const AddItemLoading();

  @override
  List<Product> get products =>
      List.generate(20, (index) => Product.mock(id: index));

  @override
  List<Product> get filteredProducts => products;

  @override
  String get searchQuery => '';

  @override
  List<Object?> get props => [];
}

class AddItemLoaded extends AddItemInProgress {
  @override
  final List<Product> products;
  @override
  final List<Product> filteredProducts;
  @override
  final String searchQuery;

  const AddItemLoaded({
    required this.products,
    required this.filteredProducts,
    this.searchQuery = '',
  });

  AddItemLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    String? searchQuery,
  }) {
    return AddItemLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts, searchQuery];
}

class AddItemError extends AddItemState {
  final String message;

  const AddItemError(this.message);

  @override
  List<Object?> get props => [message];
}
