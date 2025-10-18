import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PromptField extends StatefulWidget {
  final bool enabled;
  final String hint;
  final ValueChanged<String> onSubmit;
  const PromptField({
    super.key,
    required this.enabled,
    required this.hint,
    required this.onSubmit,
  });

  @override
  State<PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends State<PromptField>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _glowController;
  late AnimationController _colorController;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Glow intensity animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Color cycling animation
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF0D6EFD), // Blue
          end: const Color(0xFFFF4444), // Red
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFFFF4444), // Red
          end: Colors.white,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.white,
          end: const Color(0xFF0D6EFD), // Blue
        ),
        weight: 1,
      ),
    ]).animate(_colorController);
    _colorController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _colorAnimation]),
      builder: (context, child) {
        final glowColor = _colorAnimation.value ?? const Color(0xFF0D6EFD);
        final lighterGlowColor = Color.lerp(glowColor, Colors.white, 0.3)!;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
              BoxShadow(
                color: lighterGlowColor.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 30 * _glowAnimation.value,
                spreadRadius: 1 * _glowAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        onSubmitted: widget.onSubmit,
        textInputAction: TextInputAction.send,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hint: Text(
            widget.hint,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
          ),
          filled: true,
          fillColor: const Color(0xFF0F1014),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 4),
            child: Icon(Icons.auto_awesome, color: Colors.white70),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          border: _round(),
          enabledBorder: _round(color: Colors.white10),
          focusedBorder: _round(color: Color(0xFF2B2F38)),
        ),
      ),
    );
  }

  OutlineInputBorder _round({Color color = Colors.transparent}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 1.2),
      );
}
