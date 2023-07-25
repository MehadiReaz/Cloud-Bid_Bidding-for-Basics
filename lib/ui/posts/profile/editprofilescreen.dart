import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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

  // Keep track of editing mode
  bool _isEditing = false;

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

  // Function to toggle editing mode
  void _toggleEditingMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // If not in editing mode, fetch user data again to reset changes
        _fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          IconButton(
            onPressed: _toggleEditingMode,
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
          ),
        ],
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
                    child: _isEditing
                        ? InkWell(
                            onTap: _pickProfilePicture,
                            child: _profilePicture != null
                                ? Image.file(_profilePicture!,
                                    width: 300, height: 300, fit: BoxFit.cover)
                                : Image.network(
                                    'https://www.inforwaves.com/media/2021/04/dummy-profile-pic-300x300-1.png',
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : _profilePicture != null
                            ? Image.file(_profilePicture!,
                                width: 300, height: 300, fit: BoxFit.cover)
                            : Image.network(
                                'https://www.inforwaves.com/media/2021/04/dummy-profile-pic-300x300-1.png',
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                  ),
                  if (_isEditing)
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
              title: _isEditing
                  ? TextField(
                      onChanged: (value) => _fName = value,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                      ),
                      controller: TextEditingController(text: _fName),
                    )
                  : Text('First Name: $_fName'),
            ),
            ListTile(
              title: _isEditing
                  ? TextField(
                      onChanged: (value) => _lName = value,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                      ),
                      controller: TextEditingController(text: _lName),
                    )
                  : Text('Last Name: $_lName'),
            ),
            ListTile(
              title: Text('Email: ${_auth.currentUser!.email}'),
            ),
            ListTile(
              title: _isEditing
                  ? TextField(
                      onChanged: (value) => _phoneNumber = value,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                      ),
                      controller: TextEditingController(text: _phoneNumber),
                    )
                  : Text('Phone: $_phoneNumber'),
            ),
            ListTile(
              title: _isEditing
                  ? DropdownButtonFormField<String>(
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
                    )
                  : Text('Gender: $_gender'),
            ),
            ListTile(
              title: _dob != null
                  ? Row(
                      children: [
                        Text('DOB: ${_dob!.day}-${_dob!.month}-${_dob!.year}'),
                        if (_isEditing)
                          IconButton(
                            onPressed: _pickDate,
                            icon: Icon(Icons.calendar_today),
                          ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _isEditing ? _pickDate : null,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick Date'),
                    ),
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
            if (_isEditing)
              ElevatedButton(
                onPressed: () {
                  _updateUserData();

                  _toggleEditingMode();
                },
                child: const Text('Save Changes'),
              ),
          ],
        ),
      ),
    );
  }
}
