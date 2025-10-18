import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/product_list/aisle_card.dart';
import 'package:rema_1001/map/product_list/last_carousel_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        if (state is MapLoaded) {
          return Column(
            children: [
              CarouselSlider(
                items:
                    state.aisleGroups
                        .map<Widget>((aisle) => AisleCard(aisle))
                        .toList()
                      ..add(LastCarouselCard()),
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    final s = context.read<MapCubit>().state;

                    if (s is! MapLoaded) return;

                    if (index < s.currentStep) {
                      context.read<MapCubit>().previous();
                    } else if (index > s.currentStep) {
                      context.read<MapCubit>().next();
                    }
                  },
                ),
                carouselController: context
                    .read<MapCubit>()
                    .carouselSliderController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(state.aisleGroups.length + 1, (idx) {
                  return AnimatedContainer(
                    duration: 200.milliseconds,
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.currentStep == idx
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xff353535),
                    ),
                  );
                }),
              ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
