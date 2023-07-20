import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('products');
  String _productName = '';
  String _productDescription = '';
  File? _productPhoto;
  double _minimumBidPrice = 0.0;
  final DateTime _porductCreatedDateTime = DateTime.now();
  Future<void> _selectProductPhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _productPhoto = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final DatabaseReference newProductRef = _databaseReference.push();
        String newProductKey = newProductRef.key!;
        final User? user = _auth.currentUser;
        if (user != null && _productPhoto != null) {
          // Upload the product photo to Firebase Storage
          final String photoURL =
              await _uploadProductPhoto(user.uid, _productPhoto!);

          // Save the product details to Firebase Realtime Database
          newProductRef.set({
            'productName': _productName,
            'productDescription': _productDescription,
            'productPhoto': photoURL,
            'minimumBidPrice': _minimumBidPrice,
            'productCreationTime': _porductCreatedDateTime.toUtc().toString(),
            'auctionEndDateTime': _auctionEndDateTime.toUtc().toString(),
            'userId': user.uid,
            'productId': newProductKey,
          });

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  DateTime _auctionEndDateTime = DateTime.now();
  Future<void> _selectAuctionEndDateTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
          DateTime.now().year + 10), // Set a limit to 10 years in the future
    );

    if (selectedDate != null) {
      setState(() {
        _auctionEndDateTime = selectedDate;
      });
    }
  }

  Future<String> _uploadProductPhoto(String userId, File productPhoto) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_photos')
          .child('$userId-${DateTime.now()}.jpg');
      final uploadTask = storageRef.putFile(productPhoto);
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload product photo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Product Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product description';
                  }
                  return null;
                },
                onSaved: (value) => _productDescription = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Minimum Bid Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the minimum bid price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid minimum bid price';
                  }
                  return null;
                },
                onSaved: (value) => _minimumBidPrice = double.parse(value!),
              ),
              Text(
                'Auction End Date: ${_auctionEndDateTime.toString()}',
                style: TextStyle(fontSize: 16),
              ),

              // Button to select Auction End Date
              ElevatedButton(
                onPressed: _selectAuctionEndDateTime,
                child: const Text('Select Auction End Date'),
              ),
              ElevatedButton(
                onPressed: _selectProductPhoto,
                child: const Text('Select Product Photo'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
