import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  String? _fName;
  String? _lName;
  DateTime? _dob;
  File? _profilePicture;
  String? _gender;
  String? _phoneNumber;
  String? _address;

  // Controller for handling the password change
  TextEditingController _newPasswordController = TextEditingController();

  // Function to update the user's password
  void _updatePassword() async {
    try {
      await _auth.currentUser?.updatePassword(_newPasswordController.text);
      Fluttertoast.showToast(msg: 'Password updated successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update password. ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch additional user data from Firestore
  void _fetchUserData() async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _fName = userData['firstName'];
          _lName = userData['lastName'];
          _dob = userData['dob']?.toDate(); // Convert the Timestamp to DateTime
          _gender = userData['gender'];
          _phoneNumber = userData['phoneNumber'];
          _address = userData['address'];
        });
      }
    } catch (e) {
      print('Error fetching user data: ${e.toString()}');
    }
  }

  // Function to update the user information in Firestore
  void _updateUserData() async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'firstName': _fName,
        'lastName': _lName,
        'dob': _dob != null
            ? Timestamp.fromDate(_dob!)
            : null, // Convert DateTime to Timestamp
        'gender': _gender,
        'phoneNumber': _phoneNumber,
        'address': _address,
      }, SetOptions(merge: true));

      Fluttertoast.showToast(msg: 'User information updated successfully!');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Failed to update user information. ${e.toString()}');
      print(e.toString());
    }
  }

  // Function to pick a date using the DateTime picker
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _dob) {
      setState(() {
        _dob = pickedDate;
      });
    }
  }

  // Function to handle tapping the profile picture
  void _pickProfilePicture() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: _profilePicture != null
                        ? Image.file(_profilePicture!,
                            width: 300, height: 300, fit: BoxFit.cover)
                        : Image.network(
                            'https://www.inforwaves.com/media/2021/04/dummy-profile-pic-300x300-1.png',
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton(
                      onPressed: _pickProfilePicture,
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: _fName != null
                  ? Text('First Name: $_fName')
                  : TextField(
                      onChanged: (value) => _fName = value,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                      ),
                    ),
            ),
            ListTile(
              title: _lName != null
                  ? Text('Last Name: $_lName')
                  : TextField(
                      onChanged: (value) => _lName = value,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
            ),
            ListTile(
              title: Text('Email: ${_auth.currentUser!.email}'),
            ),
            ListTile(
              title: _phoneNumber != null
                  ? Text('Phone: $_phoneNumber')
                  : TextField(
                      onChanged: (value) => _phoneNumber = value,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                      ),
                    ),
            ),
            ListTile(
              title: _gender != null
                  ? Text('Gender: $_gender')
                  : DropdownButtonFormField<String>(
                      value: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Gender',
                      ),
                    ),
            ),
            ListTile(
              title: _dob != null
                  ? Row(
                      children: [
                        Text('DOB: ${_dob!.day}-${_dob!.month}-${_dob!.year}'),
                        IconButton(
                          onPressed: _pickDate,
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick Date'),
                    ),
            ),
            ListTile(
              title: _address != null
                  ? Text('Address: $_address')
                  : TextField(
                      onChanged: (value) => _address = value,
                      decoration: InputDecoration(
                        labelText: 'Address',
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserData();
                _updatePassword();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
