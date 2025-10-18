import 'dart:ui' show lerpDouble;

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

  late AnimationController _grayPathAnimationController;
  late Animation<double> _grayPathAnimation;

  late AnimationController _whitePathAnimationController;
  late Animation<double> _whitePathAnimation;

  // Track the start and end ratios for white path animation
  double _previousWhitePathRatio = 0.0;
  double _targetWhitePathRatio = 1.0;

  // Track waypoint index during backward animation
  int? _animatingToWaypointIndex;

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

    _grayPathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _grayPathAnimationController.addListener(() {
      setState(() {});
      // When gray path completes, start white path animation
      if (_grayPathAnimationController.isCompleted) {
        _whitePathAnimationController.forward(from: 0);
      }
    });

    _grayPathAnimation = CurvedAnimation(
      parent: _grayPathAnimationController,
      curve: Curves.easeOut,
    );

    _whitePathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _whitePathAnimationController.addListener(() => setState(() {}));

    _whitePathAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _animatingToWaypointIndex != null) {
        // When backward animation completes, reset to show full path
        setState(() {
          _animatingToWaypointIndex = null;
          _previousWhitePathRatio = 1.0;
          _targetWhitePathRatio = 1.0;
        });
      }
    });

    _whitePathAnimation = CurvedAnimation(
      parent: _whitePathAnimationController,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _entranceAnimationController.dispose();
    _glowAnimationController.dispose();
    _grayPathAnimationController.dispose();
    _whitePathAnimationController.dispose();
    super.dispose();
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

  /// Calculate the actual length of a curved path
  /// Uses a fixed reference size since we only need the ratio
  double _calculatePathLength(
    List<dynamic> path,
    int endIndex,
    double dimension,
  ) {
    if (path.isEmpty || endIndex <= 0) return 0.0;

    // Use reference size of 1000x1000 for consistent calculations
    const referenceSize = 1000.0;
    final scaleX = referenceSize / dimension;
    final scaleY = referenceSize / dimension;

    // Create curved path (simplified version of MapPainter._createCurvedPath)
    final curvedPath = Path();
    final curveRatio = 0.2;

    // Start at the first point
    final startPoint = Offset(
      path[0].position.dx * scaleX,
      path[0].position.dy * scaleY,
    );
    curvedPath.moveTo(startPoint.dx, startPoint.dy);

    // Process each segment
    for (int i = 0; i < endIndex && i < path.length - 1; i++) {
      final current = Offset(
        path[i].position.dx * scaleX,
        path[i].position.dy * scaleY,
      );
      final next = Offset(
        path[i + 1].position.dx * scaleX,
        path[i + 1].position.dy * scaleY,
      );

      final segmentVector = next - current;

      if (segmentVector.distance < 10) {
        curvedPath.lineTo(next.dx, next.dy);
        continue;
      }

      final straightRatio = 1 - curveRatio;
      final beforeCurve = Offset(
        current.dx + segmentVector.dx * straightRatio,
        current.dy + segmentVector.dy * straightRatio,
      );

      curvedPath.lineTo(beforeCurve.dx, beforeCurve.dy);

      if (i + 1 < endIndex && i + 2 < path.length) {
        final afterNext = Offset(
          path[i + 2].position.dx * scaleX,
          path[i + 2].position.dy * scaleY,
        );

        final nextSegmentVector = afterNext - next;

        final afterCurve = Offset(
          next.dx + nextSegmentVector.dx * curveRatio,
          next.dy + nextSegmentVector.dy * curveRatio,
        );

        curvedPath.quadraticBezierTo(
          next.dx,
          next.dy,
          afterCurve.dx,
          afterCurve.dy,
        );
      } else {
        curvedPath.lineTo(next.dx, next.dy);
      }
    }

    // Calculate total path length
    double totalLength = 0.0;
    final pathMetrics = curvedPath.computeMetrics();
    for (final metric in pathMetrics) {
      totalLength += metric.length;
    }

    return totalLength;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (BuildContext context, MapState state) {
        if (state is MapLoaded && context.read<MapCubit>().last is MapInitial) {
          // Entrance animation
          _entranceAnimationController.forward(from: 0);
          _grayPathAnimationController.reset();
          _whitePathAnimationController.reset();
          _previousWhitePathRatio = 0.0;
          _targetWhitePathRatio = 1.0;
        } else if (state is MapLoaded &&
            context.read<MapCubit>().last is MapLoaded) {
          // State transition animation
          _transitionController.forward(from: 0);
        }

        final lastState = context.read<MapCubit>().last;

        // Initial path load - start gray path animation
        if (state is MapPathfindingLoaded &&
            lastState is! MapPathfindingLoaded) {
          _grayPathAnimationController.forward(from: 0);
          // White path will automatically start when gray completes
        }

        // Step change - re-animate white path
        if (state is MapPathfindingLoaded &&
            lastState is MapPathfindingLoaded) {
          if (state.currentStep != lastState.currentStep) {
            // Calculate path lengths to determine animation start position
            const dimension = 64.0; // Same as in map_painter.dart

            final previousLength = _calculatePathLength(
              state.path,
              lastState.currentWaypointIndex,
              dimension,
            );
            final currentLength = _calculatePathLength(
              state.path,
              state.currentWaypointIndex,
              dimension,
            );

            // Determine if we're going forward or backward
            final isMovingForward = state.currentStep > lastState.currentStep;

            if (isMovingForward) {
              // Moving forward: extend from previous to current
              _animatingToWaypointIndex = null; // Use current waypoint
              if (currentLength > 0) {
                _previousWhitePathRatio = previousLength / currentLength;
              } else {
                _previousWhitePathRatio = 0.0;
              }
              _targetWhitePathRatio = 1.0;
            } else {
              // Moving backward: retract from previous to current
              // Keep rendering to the OLD (longer) waypoint during animation
              _animatingToWaypointIndex = lastState.currentWaypointIndex;
              _previousWhitePathRatio = 1.0;
              if (previousLength > 0) {
                _targetWhitePathRatio = currentLength / previousLength;
              } else {
                _targetWhitePathRatio = 0.0;
              }
            }

            // Always animate from 0 to 1 to use full curve
            _whitePathAnimationController.forward(from: 0);
          }
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

        // Map the animation progress from 0-1 to the actual path range
        final mappedWhitePathProgress = lerpDouble(
          _previousWhitePathRatio,
          _targetWhitePathRatio,
          _whitePathAnimation.value,
        )!;

        // Use override waypoint during backward animation, otherwise use current
        final displayWaypointIndex =
            _animatingToWaypointIndex ??
            (state is MapPathfindingLoaded ? state.currentWaypointIndex : 0);

        return ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(30),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: MapPainter(
                currentPathStep: displayWaypointIndex,
                grayPathAnimationProgress: _grayPathAnimation.value,
                whitePathAnimationProgress: mappedWhitePathProgress,
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

                      // For blinking aisles, animate between grey and white
                      final Color aisleColor;
                      final Color shadowColor;
                      if (shouldHaveGlow) {
                        final greyColors = getColorSetForAisleStatus(
                          AisleStatus.grey,
                        );
                        final whiteColors = getColorSetForAisleStatus(
                          AisleStatus.white,
                        );
                        aisleColor = Color.lerp(
                          greyColors.aislePaint.color,
                          whiteColors.aislePaint.color,
                          _glowAnimation.value,
                        )!;
                        shadowColor = Color.lerp(
                          greyColors.hardShadowPaint.color,
                          whiteColors.hardShadowPaint.color,
                          _glowAnimation.value,
                        )!;
                      } else {
                        aisleColor = targetColors.aislePaint.color;
                        shadowColor = targetColors.hardShadowPaint.color;
                      }

                      return aisle.copyWith(
                        // Animate hard shadow height from 0 to 12
                        hardShadowHeight: 12.0 * staggeredProgress,

                        // Keep target colors for main paint and hard shadow
                        paint: aislePaint(
                          Color.lerp(
                            backgroundColor,
                            aisleColor,
                            staggeredProgress,
                          )!,
                        ),

                        hardShadowPaint: aisleShadowPaint(
                          Color.lerp(
                            backgroundColor,
                            shadowColor,
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

                      // Status changed - transition all colors
                      final beginColors = getColorSetForAisleStatus(
                        previousAisle.status,
                      );
                      final endColors = getColorSetForAisleStatus(aisle.status);
                      final shouldHaveGlow =
                          aisle.status == AisleStatus.blinking;

                      // For blinking aisles, animate between grey and white
                      Color currentAisleColor;
                      Color currentShadowColor;
                      if (shouldHaveGlow) {
                        final greyColors = getColorSetForAisleStatus(
                          AisleStatus.grey,
                        );
                        final whiteColors = getColorSetForAisleStatus(
                          AisleStatus.white,
                        );
                        currentAisleColor = Color.lerp(
                          greyColors.aislePaint.color,
                          whiteColors.aislePaint.color,
                          _glowAnimation.value,
                        )!;
                        currentShadowColor = Color.lerp(
                          greyColors.hardShadowPaint.color,
                          whiteColors.hardShadowPaint.color,
                          _glowAnimation.value,
                        )!;
                      } else {
                        currentAisleColor = ColorTween(
                          begin: beginColors.aislePaint.color,
                          end: endColors.aislePaint.color,
                        ).animate(_transitionAnimation).value!;
                        currentShadowColor = ColorTween(
                          begin: beginColors.hardShadowPaint.color,
                          end: endColors.hardShadowPaint.color,
                        ).animate(_transitionAnimation).value!;
                      }

                      return aisle.copyWith(
                        paint: aislePaint(currentAisleColor),
                        hardShadowPaint: aisleShadowPaint(currentShadowColor),
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
