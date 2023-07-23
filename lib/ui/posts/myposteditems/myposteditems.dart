import 'package:ecommerce_app/ui/posts/add_product.dart';
import 'package:ecommerce_app/ui/posts/homescreen/productgrid.dart';
import 'package:ecommerce_app/ui/posts/searchscreen/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyPostedItems extends StatefulWidget {
  const MyPostedItems({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyPostedItemsState createState() => _MyPostedItemsState();
}

class _MyPostedItemsState extends State<MyPostedItems> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('products');

  List<Map<String, dynamic>> _productsList = [];
  List<Map<String, dynamic>> _mYproductsList = [];
  late String userId;

  @override
  void initState() {
    super.initState();

    getUserIdformFirebase();
    getUserId();
  }

  void getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  void getUserIdformFirebase() {
    _productsList = [];
    _mYproductsList = [];
    _productsRef.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic value = snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        String userIdFirebase = value['userId'];
        // ignore: unnecessary_null_comparison
        if (userIdFirebase != null) {
          setState(() {
            _productsList.add(Map<String, dynamic>.from(value));
            if (userIdFirebase == userId) {
              _mYproductsList.add(Map<String, dynamic>.from(value));
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('My Posted Items')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              getUserIdformFirebase();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: _mYproductsList.isEmpty
          ? const Center(
              child: Text('No products found.'),
            )
          : ProductGrid(productsList: _mYproductsList),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductForm()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
