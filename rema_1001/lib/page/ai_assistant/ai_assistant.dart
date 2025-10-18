import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/ai_assistant_cubit.dart';
import 'cubit/ai_assistant_state.dart';
import 'widgets/cta_button.dart';
import 'widgets/decor.dart';
import 'widgets/prompt_field.dart';
import 'widgets/recipe_group_card.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiAssistantCubit(), // no repo needed
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
          const CornerBlob(top: -50, right: 240, size: 220),
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
          const CornerBlob(bottom: -40, left: 300, size: 240),
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
                          const SizedBox(height: 40),
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
                          const SizedBox(height: 40),
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
                                  Text(
                                    state.message,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
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
                                      if (state is AiAssistantSuccess) ...[
                                        ...state.groups.map(
                                          (g) => RecipeGroupCard(group: g),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                RemaCtaButton(
                                  label: 'Gå til butikkart',
                                  onPressed: () {
                                    // TODO: navigate to your store map
                                    // Navigator.of(context).pushNamed('/store-map');
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (!isResult)
                                  RemaSecondaryButton(
                                    label: 'Få handleliste fra AI',
                                    onPressed: () => context
                                        .read<AiAssistantCubit>()
                                        .requestList(
                                          context
                                                  .read<AiAssistantCubit>()
                                                  .lastPrompt ??
                                              'Ostekake',
                                        ),
                                  ),
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
