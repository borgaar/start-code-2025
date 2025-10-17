import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'allergies_state.dart';

class AllergiesCubit extends Cubit<AllergiesState> {
  static const String _storageKey = 'user_allergies';

  AllergiesCubit() : super(const AllergiesState()) {
    _loadAllergies();
  }

  // Common allergies list
  static const List<String> availableAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Milk',
    'Eggs',
    'Wheat',
    'Soy',
    'Fish',
    'Shellfish',
    'Sesame',
    'Mustard',
    'Celery',
    'Lupin',
    'Sulphites',
    'Molluscs',
    'Gluten',
    'Lactose',
  ];

  Future<void> _loadAllergies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final allergiesList = prefs.getStringList(_storageKey) ?? [];
      emit(
        state.copyWith(
          selectedAllergies: Set<String>.from(allergiesList),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> toggleAllergy(String allergy) async {
    final newAllergies = Set<String>.from(state.selectedAllergies);
    if (newAllergies.contains(allergy)) {
      newAllergies.remove(allergy);
    } else {
      newAllergies.add(allergy);
    }

    emit(state.copyWith(selectedAllergies: newAllergies));
    await _saveAllergies(newAllergies);
  }

  Future<void> _saveAllergies(Set<String> allergies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, allergies.toList());
    } catch (e) {
      // Handle error silently or add error state if needed
    }
  }

  Future<void> clearAllAllergies() async {
    emit(state.copyWith(selectedAllergies: {}));
    await _saveAllergies({});
  }
}
