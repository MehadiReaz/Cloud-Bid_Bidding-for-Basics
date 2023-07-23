import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../productdetailscreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('products');
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProductsList = [];
  final List<Map<String, dynamic>> _allProductsList =
      []; // Keep a copy of all products here

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _filteredProductsList = _allProductsList;
  }

  void _fetchProducts() {
    _productsRef.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic value = snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        setState(() {
          _allProductsList.add(Map<String, dynamic>.from(value));
        });
      }
    });
  }

  // Function to perform the search
  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProductsList =
            _allProductsList; // If the search query is empty, show all products
      } else {
        // Use the 'query' to filter the products based on your search criteria
        _filteredProductsList = _allProductsList
            .where((product) => product['productName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _performSearch(value),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredProductsList.isEmpty
                ? const Center(
                    child: Text('No products found.'),
                  )
                : ListView.builder(
                    itemCount: _filteredProductsList.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProductsList[index];
                      final productName = product['productName'];
                      final minimumBidPrice = product['minimumBidPrice'];
                      final productDescription = product['productDescription'];
                      final productPhoto = product['productPhoto'];
                      final auctionEndDateTime = product['auctionEndDateTime'];
                      final prodId = product['productId'];
                      final userId = product['userId'];

                      return ListTile(
                        title: Text(productName),
                        subtitle: Text(
                            'Minimum Bid Price: \$${minimumBidPrice.toStringAsFixed(2)}'),
                        // Add any other additional information you want to show in the list.
                        onTap: () {
                          // Implement the action when the user taps on the product.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productName: productName,
                                productDescription: productDescription,
                                productPhoto: productPhoto,
                                minimumBidPrice: minimumBidPrice,
                                auctionEndDateTime: auctionEndDateTime,
                                prodId: prodId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
