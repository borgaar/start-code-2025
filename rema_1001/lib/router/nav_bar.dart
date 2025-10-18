import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

class Destination {
  const Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routeName,
    this.badge,
  });

  final String label;
  final Icon icon;
  final Icon selectedIcon;
  final String routeName;
  final String? badge;
}

List<Destination> _destinations = [
  const Destination(
    label: "Hjem",
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_outlined),
    routeName: RouteNames.home,
    badge: "12",
  ),
  const Destination(
    label: "Handleturer",
    icon: Icon(Icons.receipt_outlined),
    selectedIcon: Icon(Icons.receipt_outlined),
    routeName: RouteNames.trips,
  ),
  const Destination(
    label: "Dine lister",
    icon: Icon(Icons.list_alt_outlined),
    selectedIcon: Icon(Icons.list_alt_outlined),
    routeName: RouteNames.lists,
  ),
  const Destination(
    label: "Profil",
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person_outline),
    routeName: RouteNames.profile,
  ),
];

class RoutedNavBar extends StatelessWidget {
  const RoutedNavBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    try {
      final goRouter = GoRouterState.of(context);
      final index = _destinations.indexWhere(
        (d) => goRouter.matchedLocation.contains(
          goRouter.namedLocation(d.routeName),
        ),
      );

      if (index != -1) {
        return index;
      }
    } catch (_) {
      return 0;
    }
    return 0;
  }

  void _onSelect(int index, BuildContext context) {
    GoRouter.of(context).goNamed(_destinations[index].routeName);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Container(
      height: 102,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_destinations.length, (index) {
            final destination = _destinations[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: InkWell(
                onTap: () => _onSelect(index, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected
                              ? destination.selectedIcon.icon
                              : destination.icon.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                        if (destination.badge != null)
                          Positioned(
                            right: -8,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                destination.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
