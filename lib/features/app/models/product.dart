import 'dart:ffi';

class Product {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String modelUrl;
  final String category;
  final String userId;
  final String color;
  final String dimensions;
  List<String> favoritedBy;
  final int views;
  final int likes;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.modelUrl,
    required this.category,
    required this.userId,
    required this.favoritedBy,
    required this.views,
    required this.likes,
    required this.color,
    required this.dimensions,
  });

  factory Product.fromFirestore(Map<String, dynamic> firestoreDoc, String id) {
    return Product(
      id: id,
      title: firestoreDoc['title'] ?? '',
      description: firestoreDoc['description'] ?? '',
      imageUrl: firestoreDoc['imageUrl'] ?? '',
      modelUrl: firestoreDoc['modelUrl'] ?? '',
      category: firestoreDoc['category'] ?? '',
      userId: firestoreDoc['userId'] ?? '',
      favoritedBy: List<String>.from(firestoreDoc['favoritedBy'] ?? []),
      color: firestoreDoc['color'] ?? '',
      dimensions: firestoreDoc['dimensions'] ?? '',
      views: firestoreDoc['views'] ?? 0,
      likes: firestoreDoc['likes'] ?? 0,
    );
  }
}
