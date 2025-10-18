import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

import 'cubit/ai_assistant_cubit.dart';
import 'cubit/ai_assistant_state.dart';
import 'widgets/cta_button.dart';
import 'widgets/decor.dart';
import 'widgets/prompt_field.dart';
import 'widgets/recipe_group_card.dart';
import 'widgets/store_selection_dialog.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiAssistantCubit(context.read(), context.read()),
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatelessWidget {
  const _AiAssistantView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      body: Stack(
        children: [
          const CornerBlob(top: -50, left: -90, size: 220),
          const CornerBlob(
            top: -110,
            right: -150,
            size: 220,
            color: Color.fromARGB(255, 94, 155, 245),
          ),
          const CornerBlob(
            bottom: -200,
            left: -260,
            size: 340,
            color: Color.fromARGB(255, 94, 155, 245),
          ),
          const CornerBlob(bottom: -50, right: -150, size: 240),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: BlocBuilder<AiAssistantCubit, AiAssistantState>(
                  builder: (context, state) {
                    final isResult =
                        state is AiAssistantSuccess && state.groups.isNotEmpty;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const LogoWordmark(),
                          const SizedBox(height: 24),
                          Text(
                            isResult
                                ? 'Trenger du noe mer?'
                                : 'Hva trenger du på butikken i dag?',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 42),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                PromptField(
                                  enabled: state is! AiAssistantLoading,
                                  hint: 'Jeg vil lage ostekake…',
                                  onSubmit: (v) => context
                                      .read<AiAssistantCubit>()
                                      .requestList(v),
                                ),
                                const SizedBox(height: 16),
                                if (state is AiAssistantLoading)
                                  const LoadingCard(),
                                if (state is AiAssistantFailure) ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        60,
                                        20,
                                        20,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                state.message,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (state.detailedReason != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                40,
                                                15,
                                                15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              state.detailedReason!,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  255,
                                                  180,
                                                  180,
                                                ),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (state is AiAssistantSuccess)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        19,
                                        19,
                                        19,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                    child: Column(
                                      children: [
                                        ...[
                                          ...state.groups.map(
                                            (g) => RecipeGroupCard(group: g),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                if (state is AiAssistantSuccess &&
                                    state.selectedGroupTitles.isNotEmpty)
                                  RemaCtaButton(
                                    label: 'Gå til butikkart',
                                    onPressed: () async {
                                      // Create shopping list from selected groups
                                      final cubit = context
                                          .read<AiAssistantCubit>();
                                      final shoppingListId = await cubit
                                          .createShoppingListFromSelected();

                                      if (shoppingListId == null ||
                                          !context.mounted) {
                                        return;
                                      }

                                      // Show store selection dialog
                                      final storeSlug =
                                          await showDialog<String>(
                                            context: context,
                                            builder: (context) =>
                                                const StoreSelectionDialog(),
                                          );

                                      if (storeSlug == null ||
                                          !context.mounted) {
                                        return;
                                      }

                                      // Navigate to map page
                                      context.pushNamed(
                                        RouteNames.map,
                                        pathParameters: {
                                          'storeSlug': storeSlug,
                                          'shoppingListId': shoppingListId,
                                        },
                                      );

                                      // Reset the AI assistant page for next time
                                      if (context.mounted) {
                                        cubit.reset();
                                      }
                                    },
                                  ),
                                if (state is AiAssistantSuccess &&
                                    state.selectedGroupTitles.isNotEmpty)
                                  const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
