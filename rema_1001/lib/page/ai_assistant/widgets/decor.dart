import 'package:flutter/material.dart';

class CornerBlob extends StatelessWidget {
  final double? top, left, right, bottom, size;
  final Color? color;
  const CornerBlob({
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF0D6EFD),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class LogoWordmark extends StatelessWidget {
  const LogoWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/images/rema-1000.png', height: 40),
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111217),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.3,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 12),
          Text('AI tenker…', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
