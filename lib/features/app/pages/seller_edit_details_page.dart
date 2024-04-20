import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerEditDetailsPage extends StatefulWidget {
  @override
  _SellerEditDetailsPageState createState() => _SellerEditDetailsPageState();
}

class _SellerEditDetailsPageState extends State<SellerEditDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveDetails() async {
  setState(() => _isLoading = true);
  String uid = _auth.currentUser?.uid ?? '';

  if (uid.isNotEmpty) {
    Map<String, String> updateData = {};

    // Include field values in the update only if they are not empty
    if (_nameController.text.isNotEmpty) {
      updateData['name'] = _nameController.text;
    }
    if (_contactController.text.isNotEmpty) {
      updateData['contactNo'] = _contactController.text;
    }
    if (_addressController.text.isNotEmpty) {
      updateData['address'] = _addressController.text;
    }

    // Proceed with update only if there's something to update
    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(uid).set(updateData, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Details saved successfully!')));
      // Navigate back to the profile page after a successful update
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No changes to save.')));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please login again.')));
  }

  setState(() => _isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Your Details'),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact No'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDetails,
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}
