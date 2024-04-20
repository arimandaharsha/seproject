import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product.dart'; 
import 'product_detail_page.dart'; 

class CustomerFavPage extends StatefulWidget {
  @override
  _CustomerFavPageState createState() => _CustomerFavPageState();
}

class _CustomerFavPageState extends State<CustomerFavPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Products'),
      ),
      body: currentUser == null
          ? Center(child: Text("Please log in to view favorites."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('favoritedBy', arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
                  return Center(child: Text("No favorites yet."));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Adjust the number of items per row
                    childAspectRatio: 3 / 4, // Adjust the aspect ratio of the items
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var doc = documents[index];
                    var product = Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

                    return GestureDetector(
                      onTap: () {
                        // Navigate to product detail page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                        );
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: Image.network(
                                product.imageUrl, // Assuming imageUrl is part of your Product model
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
