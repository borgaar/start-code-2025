import 'package:flutter/material.dart';

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
          initiallyExpanded: open,
          onExpansionChanged: (v) => setState(() => open = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          collapsedIconColor: Colors.white70,
          iconColor: Colors.white70,
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
              : widget.group.items
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          t,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}
