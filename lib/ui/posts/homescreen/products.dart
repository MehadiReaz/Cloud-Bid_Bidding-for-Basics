import 'package:ecommerce_app/ui/auth/login_screen.dart';
import 'package:ecommerce_app/ui/posts/add_product.dart';
import 'package:ecommerce_app/ui/posts/homescreen/productgrid.dart';
import 'package:ecommerce_app/ui/posts/searchscreen/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../myposteditems/myposteditems.dart';
import '../profile/editprofilescreen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('products');

  List<Map<String, dynamic>> _productsList = [];
  List<Map<String, dynamic>> productGallary = [];
  late String userId;

// ... Inside your widget or function where you want to get the user ID
  @override
  void initState() {
    super.initState();

    getUserIdformFirebase();
    getUserId();
  }

  void _fetchProducts() {
    _productsList = [];
    _productsRef.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic value = snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        setState(() {
          _productsList.add(Map<String, dynamic>.from(value));
        });
      }
    });
  }

  void getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  void getUserIdformFirebase() {
    productGallary = [];
    _productsRef.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic value = snapshot.value;
      if (value != null && value is Map<dynamic, dynamic>) {
        String userIdFirebase = value['userId'];
        setState(() {
          _productsList.add(Map<String, dynamic>.from(value));
          if (userIdFirebase != userId) {
            productGallary.add(Map<String, dynamic>.from(value));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('eBay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchProducts();
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
          PopupMenuButton<String>(
            onSelected: (selectedValue) {
              switch (selectedValue) {
                case 'Profile':
                  // Perform action for 'Profile' selection
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()));

                  break;
                case 'My_Products':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyPostedItems()));
                  // Perform action for 'My Products' selection
                  break;
                case 'Logout':
                  {
                    GoogleSignIn googleSignIn = GoogleSignIn();
                    googleSignIn.disconnect();
                    FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Profile', child: Text('Profile')),
              const PopupMenuItem(
                  value: 'My_Products', child: Text('My Products')),
              const PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: productGallary.isEmpty
          ? const Center(
              child: Text('No products found.'),
            )
          : ProductGrid(
              productsList: productGallary), // Use the ProductGrid widget.
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
