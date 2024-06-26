import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seproject/features/app/splash/splash_screen.dart';
import 'features/user_auth/pages/login_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(child: LoginPage()),
      // home: ProductsGridView(),
      // home: ProductUploadPage(),
    );
  }
}


