import 'package:flutter/material.dart';

import '../../user_auth/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget.child!), (route) => false
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Your Virtual Design\nStudio Awaits.", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 30),),
      ),
    );
  }
}