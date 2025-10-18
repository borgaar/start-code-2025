import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

class LastCarouselCard extends StatelessWidget {
  const LastCarouselCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        // <-- protects from bottom inset (34px on iPhone)
        top: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.all(0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                // add your own padding; SafeArea handles the bottom inset
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // be flexible in short heights
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/jubler.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => context.goNamed(RouteNames.home),
                      icon: const Icon(Icons.home),
                      label: const Text("Gå til hjem"),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                        foregroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "REMA",
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
