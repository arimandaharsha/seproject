import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../user_auth/pages/login_page.dart';

class CustomerProfilePage extends StatefulWidget {
  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? userDetails;
  bool userFetchAttempted = false;  
  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        userDetails = doc.data() as Map<String, dynamic>;
        userFetchAttempted = true;
      });
    } else {
      setState(() {
        userFetchAttempted = true; // Fetch attempted, but user document does not exist
      });
    }
  } catch (e) {
    print("Error fetching user details: $e");
    setState(() {
      userFetchAttempted = true; // Fetch attempted, but there was an error
    });
  }
}
  void _resetPassword() async {
    try {
      // Send a password reset email
      await _auth.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to your email.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset link.')),
      );
    }
  }

  void _logout() async {
    await _auth.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${userDetails?['name'] ?? 'Not Available'}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'Not Available'}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Reset Password'),
            ),
            
            Expanded(
              child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: _logout,
                child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white,),
                    SizedBox(width: 5,),
                    Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ],
                  ),
                ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
