import 'package:flutter/material.dart';

class ProgressCard extends StatefulWidget {
  final int totalItems;
  final int checkedItems;

  const ProgressCard({
    super.key,
    required this.totalItems,
    required this.checkedItems,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _displayedCheckedItems = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _displayedCheckedItems = widget.checkedItems;
    _progressAnimation =
        Tween<double>(
          begin: 0,
          end: widget.totalItems == 0
              ? 0
              : widget.checkedItems / widget.totalItems,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checkedItems != widget.checkedItems ||
        oldWidget.totalItems != widget.totalItems) {
      final double begin = oldWidget.totalItems == 0
          ? 0
          : oldWidget.checkedItems / oldWidget.totalItems;
      final double end = widget.totalItems == 0
          ? 0
          : widget.checkedItems / widget.totalItems;

      _progressAnimation = Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.forward(from: 0);

      // Animate the counter
      setState(() {
        _displayedCheckedItems = widget.checkedItems;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '$_displayedCheckedItems/${widget.totalItems}',
                    key: ValueKey<int>(_displayedCheckedItems),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
