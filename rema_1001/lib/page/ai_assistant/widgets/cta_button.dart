import 'package:flutter/material.dart';

class RemaCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const RemaCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // red outline
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFDC3545),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        // white outline
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        // blue pill
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_right_alt, size: 22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RemaSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const RemaSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
  }
}
