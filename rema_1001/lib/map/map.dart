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

  late AnimationController _glowAnimationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _transitionController.addListener(() => setState(() {}));

    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOutQuad,
    );

    _entranceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _entranceAnimationController.addListener(() => setState(() {}));

    _entranceAnimation = CurvedAnimation(
      parent: _entranceAnimationController,
      curve: Curves.easeOutQuad,
    );

    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _glowAnimationController.addListener(() => setState(() {}));

    _glowAnimation = CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  /// Calculate deterministic staggered delay for each aisle based on idx
  double _getStaggeredProgress(int idx, double animationProgress) {
    // Use a simple hash function based on idx to create deterministic randomness
    final delayFactor = ((idx * 7) % 13) / 13.0; // Creates values between 0-1
    final maxDelay = 0.3; // 30% of the animation can be delay
    final delay = delayFactor * maxDelay;

    // Adjust progress to account for staggered delay
    final adjustedProgress = ((animationProgress - delay) / (1.0 - delay))
        .clamp(0.0, 1.0);
    return adjustedProgress;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (BuildContext context, MapState state) {
        if (state is MapLoaded && context.read<MapCubit>().last is MapInitial) {
          // Entrance animation
          _entranceAnimationController.forward(from: 0);
        } else if (state is MapLoaded &&
            context.read<MapCubit>().last is MapLoaded) {
          // State transition animation
          _transitionController.forward(from: 0);
        }
      },
      builder: (context, state) {
        if (state is! MapLoaded) {
          return ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(30),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(color: backgroundColor),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(30),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: MapPainter(
                path: state is MapPathfindingLoaded ? state.path : null,
                map: MapModel(
                  aisles: state.map.aisles.mapIndexed((idx, aisle) {
                    final lastState = context.read<MapCubit>().last;

                    // ENTRANCE ANIMATION: Animate from MapInitial state
                    if (lastState is MapInitial ||
                        _entranceAnimationController.isAnimating) {
                      final staggeredProgress = _getStaggeredProgress(
                        idx,
                        _entranceAnimation.value,
                      );

                      final targetColors = getColorSetForAisleStatus(
                        aisle.status,
                      );
                      final shouldHaveGlow =
                          aisle.status == AisleStatus.blinking;

                      return aisle.copyWith(
                        // Animate hard shadow height from 0 to 12
                        hardShadowHeight: 12.0 * staggeredProgress,

                        // Keep target colors for main paint and hard shadow
                        paint: aislePaint(
                          Color.lerp(
                            backgroundColor,
                            targetColors.aislePaint.color,
                            staggeredProgress,
                          )!,
                        ),

                        hardShadowPaint: aisleShadowPaint(
                          Color.lerp(
                            backgroundColor,
                            targetColors.hardShadowPaint.color,
                            staggeredProgress,
                          )!,
                        ),

                        // Fade in soft shadow from transparent to full color
                        softShadowPaint: aisleSoftShadowPaint(
                          Color.lerp(
                            Colors.transparent,
                            targetColors.softShadowPaint.color,
                            staggeredProgress,
                          )!,
                        ),

                        // Apply glow animation only if target status is blinking
                        glowPaint: shouldHaveGlow
                            ? aisleGlowPaint(
                                targetColors.glowPaint.color.withValues(
                                  alpha: _glowAnimation.value,
                                ),
                              )
                            : aisle.glowPaint,
                      );
                    }

                    // NO PREVIOUS STATE: Return aisle as-is
                    if (lastState == null) {
                      return aisle;
                    }

                    // TRANSITION ANIMATION: Animate between status changes
                    if (lastState is MapLoaded) {
                      final previousAisle = lastState.map.aisles[idx];

                      // No status change, check if should apply glow animation
                      if (aisle.status == previousAisle.status) {
                        if (aisle.status == AisleStatus.blinking) {
                          final targetColors = getColorSetForAisleStatus(
                            aisle.status,
                          );
                          return aisle.copyWith(
                            glowPaint: aisleGlowPaint(
                              targetColors.glowPaint.color.withValues(
                                alpha: _glowAnimation.value,
                              ),
                            ),
                          );
                        }
                        return aisle;
                      }

                      // Status changed - transition all colors
                      final beginColors = getColorSetForAisleStatus(
                        previousAisle.status,
                      );
                      final endColors = getColorSetForAisleStatus(aisle.status);
                      final shouldHaveGlow =
                          aisle.status == AisleStatus.blinking;

                      return aisle.copyWith(
                        paint: aislePaint(
                          ColorTween(
                            begin: beginColors.aislePaint.color,
                            end: endColors.aislePaint.color,
                          ).animate(_transitionAnimation).value!,
                        ),
                        hardShadowPaint: aisleShadowPaint(
                          ColorTween(
                            begin: beginColors.hardShadowPaint.color,
                            end: endColors.hardShadowPaint.color,
                          ).animate(_transitionAnimation).value!,
                        ),
                        softShadowPaint: aisleSoftShadowPaint(
                          ColorTween(
                            begin: beginColors.softShadowPaint.color,
                            end: endColors.softShadowPaint.color,
                          ).animate(_transitionAnimation).value!,
                        ),
                        // Apply glow animation only if target status is blinking
                        glowPaint: shouldHaveGlow
                            ? aisleGlowPaint(
                                endColors.glowPaint.color.withValues(
                                  alpha: _glowAnimation.value,
                                ),
                              )
                            : aisleGlowPaint(
                                ColorTween(
                                  begin: beginColors.glowPaint.color,
                                  end: endColors.glowPaint.color,
                                ).animate(_transitionAnimation).value!,
                              ),
                      );
                    }

                    return aisle;
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
