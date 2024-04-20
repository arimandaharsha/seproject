import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/product.dart'; // Ensure you have this model

class SellerEditProductPage extends StatefulWidget {
  final Product product;

  SellerEditProductPage({required this.product});

  @override
  _SellerEditProductPageState createState() => _SellerEditProductPageState();
}

class _SellerEditProductPageState extends State<SellerEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;
  late String _color;
  late String _dimensions;
  String? _imageName, _modelName;
  File? _newImageFile;
  File? _newModelFile;
  final ImagePicker _imagePicker = ImagePicker();

  List<String> categories = ['Sofa', 'Chair', 'Bed', 'Wardrobe', 'Table', 'Desk', 'Bookshelf', 'Cabinet', 'Dresser', 'Mirror', 'Other'];

  @override
  void initState() {
    super.initState();
    _title = widget.product.title;
    _description = widget.product.description;
    _category = widget.product.category;
    _color = widget.product.color; 
    _dimensions = widget.product.dimensions;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _newImageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      }
    });
  }

  Future<void> _pickModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _newModelFile = File(result.files.single.path!);
        _modelName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadFile(File file, String folder) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.path.split('/').last;
    Reference ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(labelText: 'Category'),
      onChanged: (value) => setState(() => _category = value!),
      items: categories.map<DropdownMenuItem<String>>((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    String? imageUrl = widget.product.imageUrl;
    String? modelUrl = widget.product.modelUrl;

    if (_newImageFile != null) {
      imageUrl = await _uploadFile(_newImageFile!, 'productImages');
    }
    if (_newModelFile != null) {
      modelUrl = await _uploadFile(_newModelFile!, 'productModels');
    }

    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
      'title': _title,
      'description': _description,
      'category': _category,
      'imageUrl': imageUrl,
      'modelUrl': modelUrl,
    });

    Navigator.pop(context); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(labelText: 'Title'),
                  onSaved: (value) => _title = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _color,
                  decoration: InputDecoration(labelText: 'Color'),
                  onSaved: (value) => _color = value ?? '',
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _dimensions,
                  decoration: InputDecoration(labelText: 'Dimensions'),
                  onSaved: (value) => _dimensions = value ?? '',
                ),
                SizedBox(height: 20),
                _buildCategoryDropdown(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(_newImageFile == null ? 'Select New Image' : 'New Image Selected 👍', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _newImageFile == null ? Colors.blueAccent : Colors.green, // Change color to indicate selection
                  ),
                ),
                if (_imageName != null) Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected Image: $_imageName'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickModel,
                  child: Text(_newModelFile == null ? 'Select New 3D Model' : 'New Model Selected👍', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _newImageFile == null ? Colors.blueAccent : Colors.green, // Change color to indicate selection
                  ),
                ),
                if (_modelName != null) Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected Image: $_modelName'),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed:  _updateProduct,
                  child: Text('Update Product', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Curved edges
                    ),
                    minimumSize: Size(double.infinity, 50), // Full width and fixed height
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
