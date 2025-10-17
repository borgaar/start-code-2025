import 'package:equatable/equatable.dart';

class AllergiesState extends Equatable {
  final Set<String> selectedAllergies;
  final bool isLoading;

  const AllergiesState({
    this.selectedAllergies = const {},
    this.isLoading = false,
  });

  AllergiesState copyWith({Set<String>? selectedAllergies, bool? isLoading}) {
    return AllergiesState(
      selectedAllergies: selectedAllergies ?? this.selectedAllergies,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedAllergies, isLoading];
}
