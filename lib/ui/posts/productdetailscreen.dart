import 'package:ecommerce_app/widgets/round_button.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final String productDescription;
  final String productPhoto;
  final int minimumBidPrice;
  final String auctionEndDateTime;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.productDescription,
    required this.productPhoto,
    required this.minimumBidPrice,
    required this.auctionEndDateTime,
  });

  void showBidBottomSheet(BuildContext context, int minimumBidPrice) {
    String bidAmount = '';
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Bid Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  bidAmount = value;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  double amount = double.tryParse(bidAmount) ?? 0.0;
                  if (amount < minimumBidPrice) {
                    showLowBidAlertDialog(context, minimumBidPrice);
                  } else {
                    Navigator.pop(context);
                    // Perform your bid submission here
                    // For example, you could call a function to submit the bid to Firebase
                  }
                },
                child: const Text('Submit Bid'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLowBidAlertDialog(BuildContext context, int minimumBidPrice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your Bid Amount is Low'),
          content: const Text('Do you want to increase your bid amount?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                showBidBottomSheet(context,
                    minimumBidPrice); // Show the bid bottom sheet again
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the product photo
            Image.network(
              productPhoto,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display product name
                  Text(
                    productName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Display minimum bid price
                  Text(
                    'Minimum Bid Price: \$${minimumBidPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  // Display auction end date and time
                  Text(
                    'Auction End Date: $auctionEndDateTime',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  // Display product description
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    productDescription,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 100),
                  Center(
                    child: RoundButton(
                      onTap: () {
                        showBidBottomSheet(context, minimumBidPrice);
                      },
                      title: 'Place Bid',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
