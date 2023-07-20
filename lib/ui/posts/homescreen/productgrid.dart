import 'package:ecommerce_app/ui/posts/homescreen/productcard.dart';
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> productsList;

  const ProductGrid({super.key, required this.productsList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: productsList.length,
      itemBuilder: (context, index) {
        final product = productsList[index];

        return ProductCard(
          userId: product['userId'],
          productName: product['productName'],
          minimumBidPrice: product['minimumBidPrice'.toString()],
          productPhotoUrl: product['productPhoto'],
          auctionEndDateTime: product['auctionEndDateTime'],
          productDescription: product['productDescription'],
        );
      },
    );
  }
}
