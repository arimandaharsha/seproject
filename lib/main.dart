import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seproject/features/app/pages/products_grid_view.dart';
import 'package:seproject/features/app/splash/splash_screen.dart';
import 'features/app/pages/product_upload_page.dart';
import 'features/user_auth/pages/login_page.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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


