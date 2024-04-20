import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../user_auth/pages/login_page.dart';
import 'seller_edit_details_page.dart'; 

class SellerProfilePage extends StatefulWidget {
  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = 'Not Available';
  String email = ''; 
  String contactNo = 'Not Available';
  String address = 'Not Available';

  @override
  void initState() {
    super.initState();
    var currentUser = _auth.currentUser;
    if (currentUser != null) {
      email = currentUser.email ?? ''; 
    }
    _fetchSellerInfo();
  }

  Future<void> _fetchSellerInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          name = data?['name'] ?? 'Not Available';
          contactNo = data?['contactNo'] ?? 'Not Available';
          address = data?['address'] ?? 'Not Available';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSellerInfo,
        child: ListView(
          children: [
            ListTile(title: Text('Name'), subtitle: Text(name)),
            ListTile(title: Text('Email'), subtitle: Text(email)),
            ListTile(title: Text('Contact No'), subtitle: Text(contactNo)),
            ListTile(title: Text('Address'), subtitle: Text(address)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SellerEditDetailsPage())),
              child: Text('Edit Details'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Reset Password'),
            ),
            SizedBox(height: 120),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Curved edges
                ),
                minimumSize: Size(double.infinity, 50), // Full width and fixed height
              ),
              child: Text('Logout' , style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPassword() async {
    if (email.isNotEmpty) {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset link sent to your email.')));
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
