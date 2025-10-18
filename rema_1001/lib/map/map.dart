import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/map/colors.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/map_painter.dart';
import 'package:rema_1001/map/model.dart';
import 'package:collection/collection.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _transitionAnimation;

  late AnimationController _entranceAnimationController;
  late Animation<double> _entranceAnimation;

  late AnimationController _blinkingAnimationController;
  late Animation<double> _blinkingAnimation;

  @override
  void initState() {
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _transitionController.addListener(
      () => setState(() {
        print(_transitionController.value);
      }),
    );

    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOutQuad,
    );

    _entranceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceAnimationController,
      curve: Curves.easeOutQuad,
    );

    _blinkingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _blinkingAnimation = CurvedAnimation(
      parent: _blinkingAnimationController,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (BuildContext context, MapState state) {
        if (state is MapLoaded && context.read<MapCubit>().last is MapInitial) {
          _entranceAnimationController
              .forward(from: 0)
              .then((_) => _transitionController.forward(from: 0));
        } else if (state is MapLoaded &&
            context.read<MapCubit>().last is MapLoaded) {
          _transitionController
              .forward(from: 0)
              .then((_) => _blinkingAnimationController.forward(from: 0));
        }
      },
      builder: (context, state) {
        if (state is! MapLoaded) {
          return AspectRatio(
            aspectRatio: 1,
            child: Container(color: backgroundColor),
          );
        }

        return AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: MapPainter(
              path: state is MapPathfindingLoaded ? state.path : null,
              map: MapModel(
                aisles: state.map.aisles.mapIndexed((idx, aisle) {
                  final lastState = context.read<MapCubit>().last;
                  if (lastState == null || lastState is MapInitial) {
                    return aisle;
                  }

                  final previousAisle =
                      (lastState as MapLoaded).map.aisles[idx];

                  if (aisle.status == previousAisle.status) {
                    return aisle;
                  }

                  final beginColors = getColorSetForAisleStatus(
                    previousAisle.status,
                  );
                  final endColors = getColorSetForAisleStatus(aisle.status);
                  // Transition from previous to next
                  return aisle.copyWith(
                    glowPaint: aisleGlowPaint(
                      ColorTween(
                        begin: beginColors.glowPaint.color,
                        end: endColors.glowPaint.color,
                      ).animate(_transitionAnimation).value!,
                    ),
                    hardShadowPaint: aisleShadowPaint(
                      ColorTween(
                        begin: beginColors.hardShadowPaint.color,
                        end: endColors.hardShadowPaint.color,
                      ).animate(_transitionAnimation).value!,
                    ),
                    paint: aislePaint(
                      ColorTween(
                        begin: beginColors.aislePaint.color,
                        end: endColors.aislePaint.color,
                      ).animate(_transitionAnimation).value!,
                    ),
                    softShadowPaint: aisleSoftShadowPaint(
                      ColorTween(
                        begin: beginColors.softShadowPaint.color,
                        end: endColors.softShadowPaint.color,
                      ).animate(_transitionAnimation).value!,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
