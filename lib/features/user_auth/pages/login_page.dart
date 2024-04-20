import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seproject/features/app/home/home_page.dart';
import 'package:seproject/features/app/pages/customer_home_page.dart';
import 'package:seproject/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:seproject/features/user_auth/pages/signup_page.dart';
import 'package:seproject/features/user_auth/widgets/form_container_widget.dart';
import 'package:seproject/global/common/toast.dart';
import 'package:seproject/main.dart';

import '../../app/pages/seller_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  bool _isSigningInCustomer = false;
  bool _isSigningInSeller = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align the text to the right
                children: [
                  GestureDetector(
                    onTap: () {
                      _showForgotPasswordDialog();
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  if (!_isSigningInCustomer) { // Only trigger sign-in if not already in process
                    _signIn(role: "customer");
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigningInCustomer // Check if customer sign-in is in process
                        ? CircularProgressIndicator(color: Colors.white,)
                        : Text(
                          "Login as Customer",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  if (!_isSigningInSeller) { // Only trigger sign-in if not already in process
                    _signIn(role: "seller");
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigningInSeller // Check if seller sign-in is in process
                        ? CircularProgressIndicator(color: Colors.white,)
                        : Text(
                          "Login as Seller",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ),



              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                            (route) => false,
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

   void _signIn({required String role}) async {
    setState(() {
    if (role == "customer") {
      _isSigningInCustomer = true;
    } else if (role == "seller") {
      _isSigningInSeller = true;
    }
  });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        showToast(message: "Login successful");

        if (role == "customer") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomePage()),
            (route) => false,
          );
        } else if (role == "seller") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SellerHomePage()), 
            (route) => false,
          );
        }
      } else {
        showToast(message: "Some error occurred");
      }
    } catch (e) {
      showToast(message: "Login failed: ${e.toString()}");
    } finally {
    setState(() {
      if (role == "customer") {
        _isSigningInCustomer = false;
      } else if (role == "seller") {
        _isSigningInSeller = false;
      }
    });
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email to receive a password reset link.'),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send Link'),
              onPressed: () {
                _resetPassword(emailController.text.trim());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetPassword(String email) async {
  if (email.isEmpty) {
    showToast(message: "Email cannot be empty.");
    return;
  }
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    showToast(message: "Password reset link sent! Check your email.");
  } catch (e) {
    showToast(message: "An error occurred while sending the password reset link.");
    print(e); // Optionally, log the error
  }
}



}