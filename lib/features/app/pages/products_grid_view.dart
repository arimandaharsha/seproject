import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_detail_page.dart'; 

class ProductsGridView extends StatefulWidget {
  @override
  _ProductsGridViewState createState() => _ProductsGridViewState();
}

class _ProductsGridViewState extends State<ProductsGridView> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container(); // Return an empty container if no categories
              final categories = snapshot.data!.docs.map((doc) => doc['category'] as String).toSet().toList();
              categories.insert(0, 'All'); // Add 'All' option to the list
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0), // Add horizontal padding around each chip
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
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == 'All'
                  ? FirebaseFirestore.instance.collection('products').snapshots()
                  : FirebaseFirestore.instance
                      .collection('products')
                      .where('category', isEqualTo: _selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No products found"));
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var product = Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                          ),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10), // Adjust the radius to get the desired curve
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(product.title),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
