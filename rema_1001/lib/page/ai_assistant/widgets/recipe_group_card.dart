import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/ai_assistant_cubit.dart';
import '../cubit/ai_assistant_state.dart';

class RecipeGroupCard extends StatefulWidget {
  final RecipeGroup group;
  const RecipeGroupCard({super.key, required this.group});

  @override
  State<RecipeGroupCard> createState() => _RecipeGroupCardState();
}

class _RecipeGroupCardState extends State<RecipeGroupCard> {
  bool open = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 22, 22, 22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Color.fromARGB(255, 22, 22, 22),
          initiallyExpanded: open,
          onExpansionChanged: (v) => setState(() => open = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          collapsedIconColor: Colors.white70,
          iconColor: Colors.white70,
          expansionAnimationStyle: AnimationStyle(curve: Curves.easeOut),
          title: Text(
            widget.group.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: widget.group.items.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Ingen varer – forslag fra AI kommer her.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ]
              : widget.group.itemsData
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final displayText = widget.group.items[index];

                        return BlocBuilder<AiAssistantCubit, AiAssistantState>(
                          builder: (context, state) {
                            final isSelected = state is AiAssistantSuccess &&
                                state.selectedProductIds.contains(item.productId);

                            return InkWell(
                              onTap: () => context
                                  .read<AiAssistantCubit>()
                                  .toggleItemSelection(item.productId),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => context
                                          .read<AiAssistantCubit>()
                                          .toggleItemSelection(item.productId),
                                      fillColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return const Color.fromARGB(255, 94, 155, 245);
                                          }
                                          return Colors.white30;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        displayText,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                    .toList(),
        ),
      ),
    );
  }
}
