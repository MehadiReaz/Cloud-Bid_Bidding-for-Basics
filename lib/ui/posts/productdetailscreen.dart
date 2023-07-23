import 'package:intl/intl.dart';
import 'dart:async';
import 'package:ecommerce_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'bid/bid.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final String productDescription;
  final String productPhoto;
  final int minimumBidPrice;
  final String auctionEndDateTime;
  final String prodId;
  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.productDescription,
    required this.productPhoto,
    required this.minimumBidPrice,
    required this.auctionEndDateTime,
    required this.prodId,
  });

  bool isAuctionOver() {
    DateTime now = DateTime.now();
    DateTime auctionEndTime = DateTime.parse(auctionEndDateTime);
    return now.isAfter(auctionEndTime);
  }

  Stream<List<Bid>> _fetchBids() {
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('product_bids');

    // Create a query to filter bids by productId
    Query query = reference.orderByChild('productId').equalTo(prodId);

    // Listen for all value events for the matching bids
    Stream<DatabaseEvent> eventStream = query.onValue;

    // Parse the stream and convert it to a List<Bid>
    return eventStream.asyncMap((event) async {
      List<Bid> bids = [];
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value == null) {
        return bids; // Return an empty list if there are no bids
      }

      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

      // Loop through all the bids and add them to the list
      values.forEach((key, value) {
        Bid bid = Bid.fromMap(value, key as String);
        bids.add(bid);
      });

      return bids;
    });
  }

// ... Rest of the code ...

  void showBidBottomSheet(BuildContext context, int minimumBidPrice) {
    String bidAmount = '';
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    StreamSubscription<DatabaseEvent>?
        subscription; // Initialize the subscription to null

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
                child: ListView(shrinkWrap: true, children: [
              Container(
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      onPressed: () async {
                        if (currentUser == null) {
                          // If the user is not logged in, redirect to the login screen or show a message.
                          return;
                        }

                        double amount = double.tryParse(bidAmount) ?? 0.0;

                        if (amount < minimumBidPrice) {
                          showLowBidAlertDialog(context, minimumBidPrice);
                        } else {
                          DatabaseReference bidsRef =
                              FirebaseDatabase.instance.ref().child(
                                    'product_bids',
                                  );

                          // Create a unique bid ID using the user's UID and product ID
                          String bidId = '${currentUser.uid}_$prodId';

                          // Listen for updates on the bid entry
                          subscription =
                              bidsRef.child(bidId).onValue.listen((event) {
                            DataSnapshot snapshot = event.snapshot;

                            if (snapshot.value != null) {
                              // If the user has already placed a bid, update the existing bid
                              bidsRef.child(bidId).update({
                                'bidAmount': amount,
                                'timestamp': ServerValue.timestamp,
                              });
                            } else {
                              // If the user has not placed a bid, create a new bid entry
                              DatabaseReference newBidRef =
                                  bidsRef.child(bidId);
                              newBidRef.set({
                                'bidderUid': currentUser.uid,
                                'bidderName': currentUser.email,
                                'bidAmount': amount,
                                'productId': prodId,
                                'timestamp': ServerValue.timestamp,
                              });
                            }

                            // Cancel the subscription to stop listening
                            subscription?.cancel();
                            Navigator.pop(context); // Close the bottom sheet
                          });
                        }
                      },
                      child: const Text(
                        'Submit Bid',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ])));
      },
    );
  }

  Widget buildBidList(List<Bid> bids, bool auctionOver) {
    if (bids.isEmpty && auctionOver) {
      // Auction is over and no one bid
      return const Text('Auction is over. The product is unsold.');
    } else if (bids.isEmpty && !auctionOver) {
      // Auction is still ongoing, but no one bid yet
      return const Text('No bids for this product yet.');
    }

    // Sort the bids by bidding amount in descending order
    bids.sort((a, b) => b.bidAmount.compareTo(a.bidAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Bids',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        DataTable(
          columns: const [
            DataColumn(label: Text('Bidder')),
            DataColumn(label: Text('Amount')),
          ],
          rows: bids.map((bid) {
            return DataRow(
              cells: [
                DataCell(Text(
                  bid.bidderName,
                  style: TextStyle(
                    color: auctionOver && bid == bids[0] ? Colors.green : null,
                  ),
                )),
                DataCell(Text(
                  '\$${bid.bidAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: auctionOver && bid == bids[0] ? Colors.green : null,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
        if (auctionOver && bids.isNotEmpty)
          // Display the winner name if auction is over and there are bids
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Winner: ${bids[0].bidderName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
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
                showBidBottomSheet(
                  context,
                  minimumBidPrice,
                ); // Show the bid bottom sheet again
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
    bool auctionOver = isAuctionOver();
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display minimum bid price
                  Text(
                    'Minimum Bid: \$${minimumBidPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  // Display auction end date and time
                  const Text(
                    'Auction End',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date: ${DateFormat('MM-dd-yyyy').format(DateTime.parse(auctionEndDateTime))}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Time: ${DateFormat('hh:mm a').format(DateTime.parse(auctionEndDateTime))}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  // Display product description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    productDescription,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    child: StreamBuilder<List<Bid>>(
                      stream: _fetchBids(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Bid> bids = snapshot.data ?? [];
                          if (bids.isEmpty) {
                            return const Text('No bids for this product yet.');
                          } else {
                            return buildBidList(
                              bids,
                              auctionOver,
                            ); // Display bids here
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RoundButton(
                      onTap: () {
                        if (!auctionOver) {
                          showBidBottomSheet(context, minimumBidPrice);
                        }
                      },
                      title: 'Place Bid',
                      isBidOver: auctionOver,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
