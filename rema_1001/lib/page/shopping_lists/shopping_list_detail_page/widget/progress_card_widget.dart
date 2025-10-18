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
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateAnimation(0, _calculateProgress());
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checkedItems != widget.checkedItems ||
        oldWidget.totalItems != widget.totalItems) {
      final oldProgress = oldWidget.totalItems == 0
          ? 0.0
          : oldWidget.checkedItems / oldWidget.totalItems;
      _updateAnimation(oldProgress, _calculateProgress());
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation(double begin, double end) {
    _progressAnimation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  double _calculateProgress() {
    return widget.totalItems == 0
        ? 0.0
        : widget.checkedItems / widget.totalItems;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).listTileTheme.tileColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Fremgang', style: Theme.of(context).textTheme.titleMedium),
        _buildCounter(context),
      ],
    );
  }

  Widget _buildCounter(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Text(
        '${widget.checkedItems}/${widget.totalItems}',
        key: ValueKey<int>(widget.checkedItems),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _progressAnimation.value,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        );
      },
    );
  }
}
