import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/product.dart';
import 'seller_edit_product_page.dart'; 

class SellerProductDetails extends StatelessWidget {
  final Product product;

  SellerProductDetails({required this.product});

  void _confirmDeletion(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white),
            ),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmation) {
      // Delete the product from Firestore
      print("Product deleted");
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {

     int numberOfLikes = product.favoritedBy?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title), // Display product title
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             CarouselSlider(
              options: CarouselOptions(
                height: 350.0,
                enlargeCenterPage: true,
                autoPlay: false,
              ),
              items: [product.imageUrl, product.modelUrl].map((itemUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    // Check if the current item is the image or the 3D model
                    bool isImage = itemUrl == product.imageUrl;
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                      ),
                      child: isImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                itemUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : ModelViewer(
                              src: itemUrl, // URL to the 3D model file
                              alt: "A 3D model of the product",
                              ar: true,
                              autoRotate: true,
                              cameraControls: true,
                            ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 8),

            // Display product title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Icon(Icons.favorite, color: Colors.red),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('❤️ $numberOfLikes Customers liked this product', style: TextStyle(fontSize: 16,)),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue[200]), // Icon for views
                  SizedBox(width: 4),
                  Text('${product.views} Views', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
                  
            SizedBox(height: 8),
            // Display product category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Category: ${product.category}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Color: ${product.color ?? 'Not specified'}', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Dimensions: ${product.dimensions ?? 'Not specified'}', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 8),
            // Display product description
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description: ${product.description}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerEditProductPage(product: product))),
                child: Text('Edit Product', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size.fromHeight(50)),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => _confirmDeletion(context),
                child: Text('Delete Product', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size.fromHeight(50)),
              ),
            ),
            // Display product descriptio
          ],
        ),
      ),
    );
  }
}
