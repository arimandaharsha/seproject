import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? userDetails;
  bool userFetchAttempted = false; // Indicates if an attempt to fetch user details has been made
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isFavorited = false;


  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _checkIfFavorited();
    incrementProductView(widget.product.id);
  }
  
  void incrementProductView(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'views': FieldValue.increment(1),
    }).catchError((error) {
      print("Failed to increment view count: $error");
    });
  }

  Future<void> _fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.product.userId).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          userDetails = doc.data();
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

  void _checkIfFavorited() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      if (productDoc.exists) {
        Map<String, dynamic> data = productDoc.data() as Map<String, dynamic>;
        List<dynamic> favoritedBy = data['favoritedBy'] ?? [];
        setState(() {
          _isFavorited = favoritedBy.contains(currentUser.uid);
        });
      }
    } catch (e) {
      print("Error fetching product data: $e");
    }
  }





  void _toggleFavorite() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Optionally, prompt login or handle the case of no user.
      print("No user logged in.");
      return;
    }

    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(widget.product.id);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot productSnapshot = await transaction.get(productRef);

      if (productSnapshot.exists) {
        List<dynamic> favoritedBy = productSnapshot['favoritedBy'] ?? [];
        if (favoritedBy.contains(currentUser.uid)) {
          // User has already favorited the product; unfavorite it
          transaction.update(productRef, {
            'favoritedBy': FieldValue.arrayRemove([currentUser.uid])
          });
        } else {
          // User has not favorited the product; favorite it
          transaction.update(productRef, {
            'favoritedBy': FieldValue.arrayUnion([currentUser.uid])
          });
        }
      }
    }).then((_) {
      setState(() {
        _isFavorited = !_isFavorited; // Update the UI to reflect the change
      });
    }).catchError((error) {
      print("Failed to update favorite status: $error");
    });
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              child: ModelViewer(
                src: widget.product.modelUrl,
                alt: "A 3D model of ${widget.product.title}",
                ar: true,
                autoRotate: true,
                cameraControls: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
            ),
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Color: ${widget.product.color}", // Assuming 'color' is a String
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Dimensions: ${widget.product.dimensions}", // Assuming 'dimensions' is a String
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Category: ${widget.product.category}",
              style: TextStyle(fontSize: 16),
            ),
          ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Description: ${widget.product.description}",
                style: TextStyle(fontSize: 16),
              ),
            ),
            

            // Check if the fetch attempt was made
            userFetchAttempted
                ? userDetails == null
                    // If userDetails is null, display "Seller information not available"
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Seller information not available", style: TextStyle(fontSize: 16)),
                      )
                    // If userDetails is not null, display available information or "Not Available"
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sold by: ${userDetails?['name'] ?? 'Not Available'}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Seller Contact: ${userDetails?['contactNo'] ?? 'Not Available'}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Seller Address: ${userDetails?['address'] ?? 'Not Available'}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                : CircularProgressIndicator(), // Show a loading indicator while fetch is in progress
          ],
        ),
      ),
    );
  }
}


// class _ProductDetailPageState extends State<ProductDetailPage> {
//   Map<String, dynamic>? userDetails;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     final doc = await FirebaseFirestore.instance.collection('users').doc(widget.product.userId).get();
//     if (doc.exists) {
//       setState(() {
//         userDetails = doc.data();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.product.title),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               height: 300,
//               child: ModelViewer(
//                 src: widget.product.modelUrl,
//                 alt: "A 3D model of ${widget.product.title}",
//                 ar: true,
//                 autoRotate: true,
//                 cameraControls: true,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.product.title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.product.description,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             userDetails == null
//                 ? CircularProgressIndicator() // Show a loading indicator while user details are being fetched
//                 : Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Seller Name: ${userDetails!['name']}",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           "Seller Contact: ${userDetails!['contactNo']}",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           "Seller Address: ${userDetails!['address']}",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
