import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final VoidCallback onTap;  // dagdag dito

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap,  // dagdag dito
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(  // wrap ang Card sa InkWell
      onTap: onTap,  // tawagin ang function pag na tap
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (existing widget tulad ng image, texts)
          ],
        ),
      ),
    );
  }
}
