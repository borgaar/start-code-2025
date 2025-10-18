import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
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
          return CarouselSlider(
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
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
