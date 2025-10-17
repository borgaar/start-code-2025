import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/settings/allergies/bloc/allergies_cubit.dart';
import 'package:rema_1001/settings/allergies/bloc/allergies_state.dart';

class AllergiesPage extends StatelessWidget {
  const AllergiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergies'),
        actions: [
          BlocBuilder<AllergiesCubit, AllergiesState>(
            builder: (context, state) {
              if (state.selectedAllergies.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => _showClearConfirmation(context),
                child: const Text('Clear All'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AllergiesCubit, AllergiesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: AllergiesCubit.availableAllergies.length,
                  itemBuilder: (context, index) {
                    final allergy = AllergiesCubit.availableAllergies[index];
                    final isSelected = state.selectedAllergies.contains(
                      allergy,
                    );

                    return CheckboxListTile(
                      title: Text(allergy),
                      value: isSelected,
                      onChanged: (value) {
                        context.read<AllergiesCubit>().toggleAllergy(allergy);
                      },
                      secondary: Icon(
                        _getAllergyIcon(allergy),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    );
                  },
                ),
              ),
              if (state.selectedAllergies.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Allergies',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.selectedAllergies.map((allergy) {
                          return Chip(
                            label: Text(allergy),
                            onDeleted: () => context
                                .read<AllergiesCubit>()
                                .toggleAllergy(allergy),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Allergies'),
        content: const Text(
          'Are you sure you want to remove all selected allergies?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AllergiesCubit>().clearAllAllergies();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  IconData _getAllergyIcon(String allergy) {
    switch (allergy.toLowerCase()) {
      case 'peanuts':
      case 'tree nuts':
        return Icons.egg_alt;
      case 'milk':
      case 'lactose':
        return Icons.water_drop;
      case 'eggs':
        return Icons.egg;
      case 'wheat':
      case 'gluten':
        return Icons.grain;
      case 'fish':
        return Icons.set_meal;
      case 'shellfish':
      case 'molluscs':
        return Icons.dining;
      default:
        return Icons.warning_amber;
    }
  }
}
