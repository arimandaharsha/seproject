import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seproject/features/app/pages/seller_product_details.dart';
import '../models/product.dart';
// import 'product_detail_page.dart';
import 'seller_edit_product_page.dart'; 

class SellerViewProducts extends StatefulWidget {
  @override
  _SellerViewProductsState createState() => _SellerViewProductsState();
}

class _SellerViewProductsState extends State<SellerViewProducts> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCategory = 'All';

  Future<bool?> _confirmAndDeleteProduct(String productId) async {
  // Show a confirmation dialog
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false); // Dismisses the dialog and returns false
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true); // Dismisses the dialog and returns true
            },
          ),
        ],
      );
    },
  ) ?? false; // If dialog is dismissed by tapping outside, treat it as "Cancel"

  // If user confirmed delete, then delete the product
  if (confirmDelete) {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    return true;
  }
  else {
    return false;
  }
}

Widget _buildCategoryChips() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').where('userId', isEqualTo: _auth.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container(); // Return an empty container if no categories
        final categories = snapshot.data!.docs.map((doc) => doc['category'] as String).toSet().toList();
        categories.insert(0, 'All'); // Add 'All' option to the list
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) => Padding(
              padding: const EdgeInsets.all(4.0), // Add padding around each chip
              child: ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
            )).toList(),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
      ),
      body: Column(
        children: [
          _buildCategoryChips(), // Display the category chips at the top
          Expanded(
            child: user == null
                ? Center(child: Text("Please log in to view your products."))
                : StreamBuilder<QuerySnapshot>(
                    stream: _selectedCategory == 'All'
                        ? FirebaseFirestore.instance.collection('products').where('userId', isEqualTo: user.uid).snapshots()
                        : FirebaseFirestore.instance.collection('products').where('userId', isEqualTo: user.uid).where('category', isEqualTo: _selectedCategory).snapshots(),
                    builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data?.docs.isEmpty ?? true) {
                  return Center(child: Text("You Have Not Uploaded Any Products Yet."));
                }
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var product = Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                    int numberOfLikes = (doc.data() as Map<String, dynamic>)['favoritedBy']?.length ?? 0; // Get the count of favoritedBy array elements
                    return Dismissible(
                      key: Key(product.id), // Unique key for the Dismissible widget
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Handle edit action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SellerEditProductPage(product: product)),
                          );
                          return false; // Do not dismiss the item
                        } else {
                          // Handle delete action
                          return _confirmAndDeleteProduct(product.id);
                        }
                      },
                      child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerProductDetails(product: product),
                          ),
                        );
                      },
                      child: Card(
                      // margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(width: 6), // Add some space (left padding
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                product.imageUrl,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    product.title.length > 20
                                        ? '${product.title.substring(0, 17)}...'
                                        : product.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // SizedBox(height: 10),
                                  Text(
                                    product.description.length > 33
                                        ? '${product.description.substring(0, 33)}...'
                                        : product.description,
                                  ), 
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.visibility, color: Colors.black, size: 15,), // Icon for views
                                          SizedBox(width: 4),
                                          Text('${product.views} Views', style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.favorite, color: Colors.red, size: 15,), // Icon for likes
                                          SizedBox(width: 4),
                                          Text('$numberOfLikes Likes', style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),),);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
