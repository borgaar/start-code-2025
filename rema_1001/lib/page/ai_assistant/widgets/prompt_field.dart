import 'package:flutter/material.dart';

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

class _PromptFieldState extends State<PromptField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmit,
      textInputAction: TextInputAction.send,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
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
    );
  }

  OutlineInputBorder _round({Color color = Colors.transparent}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 1.2),
      );
}
