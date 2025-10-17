import 'package:equatable/equatable.dart';
import 'package:rema_1001/data/models/store.dart';

abstract class StoreSelectionState extends Equatable {
  const StoreSelectionState();

  @override
  List<Object?> get props => [];
}

class StoreSelectionInitial extends StoreSelectionState {}

abstract class StoreSelectionInProgress extends StoreSelectionState {
  List<Store> get stores;

  const StoreSelectionInProgress();
}

class StoreSelectionLoading extends StoreSelectionInProgress {
  const StoreSelectionLoading();

  @override
  List<Store> get stores => List.generate(5, (index) => Store.mock(id: index));

  @override
  List<Object?> get props => [];
}

class StoreSelectionLoaded extends StoreSelectionInProgress {
  @override
  final List<Store> stores;

  const StoreSelectionLoaded(this.stores);

  @override
  List<Object?> get props => [stores];
}

class StoreSelectionError extends StoreSelectionState {
  final String message;

  const StoreSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}
