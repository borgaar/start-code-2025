import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_assistant_state.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  String? lastPrompt;

  AiAssistantCubit() : super(const AiAssistantInitial());

  Future<void> requestList(String prompt) async {
    final p = prompt.trim();
    if (p.isEmpty && lastPrompt == null) {
      emit(const AiAssistantFailure('Skriv hva du vil lage først.'));
      return;
    }
    lastPrompt = p.isEmpty ? lastPrompt : p;

    emit(const AiAssistantLoading());
    try {
      final groups = await _mockGenerate(lastPrompt!);
      emit(AiAssistantSuccess(groups));
    } catch (_) {
      emit(const AiAssistantFailure('Noe gikk galt. Prøv igjen.'));
    }
  }

  // --- Temporary mock instead of a repository call ---
  Future<List<RecipeGroup>> _mockGenerate(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = prompt.toLowerCase();

    if (lower.contains('ostekake')) {
      return const [
        RecipeGroup('Ostekake', [
          'Melk, lett, 1l',
          'Smør, 200g',
          'Kjeks',
          'Philadelphia',
          'Sitron',
        ]),
        RecipeGroup('Til servering', ['Jordbær, 1 kurv', 'Sitronmelisse']),
      ];
    }
    if (lower.contains('fisk') || lower.contains('middag')) {
      return const [
        RecipeGroup('Enkel fiskemiddag for 4', [
          'Fiskegrateng, findus, 1kg',
          'Gulrot, 4stk',
          'Hvitløksbaguette',
        ]),
        RecipeGroup('Drikke', ['Melk, lett, 1l']),
      ];
    }
    // default demo (matches your Figma)
    return const [
      RecipeGroup('Hjemmebakt grovbrød', []),
      RecipeGroup('Ostekake', ['Melk, lett, 1l', 'Smør, 200g', 'Ost']),
      RecipeGroup('Enkel fiskemiddag for 4', [
        'Fiskegrateng, findus, 1kg',
        'Gulrot, 4stk',
        'Hvitløksbaguette',
      ]),
    ];
  }
}
