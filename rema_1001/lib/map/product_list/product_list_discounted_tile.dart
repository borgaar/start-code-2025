import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';

class ProductListDiscountedTile extends StatelessWidget {
  const ProductListDiscountedTile(
    this.item,
    this.aisleGroup, {
    super.key,
    required this.index,
  });

  final int index;
  final DiscountedAisleItem item;
  final ShoppingListAisleGroup aisleGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatTitle(item), style: TextStyle(fontSize: 14)),
              Text(
                "${item.price} kr",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD71E2C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Transform.rotate(
                  angle: 0.2,
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '-${(item.discountPercentage * 100).round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate(onComplete: (controller) => controller.repeat())
              .shake(
                delay: Duration(milliseconds: index * 1000 + 3000),
                hz: 4,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}

String _formatTitle(DiscountedAisleItem item) {
  final regex = RegExp(r'^(.*?)(\s*\d.*)?$');
  final match = regex.firstMatch(item.productName);
  String result = "";
  if (match != null) {
    result = match.group(1)!.trim();
  } else {
    result = item.productName;
  }
  return result;
}
