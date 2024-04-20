
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
// import 'package:seproject/features/app/pages/products_grid_view.dart';
import 'package:seproject/features/app/pages/seller_home_page.dart';
// import 'package:seproject/features/app/pages/seller_view_products.dart';


class ProductUploadPage extends StatefulWidget {
  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productDescription = '';
  String _productCategory = '';
  String _productColor = '';
  String _productDimensions = '';
  File? _imageFile;
  File? _modelFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _imageName;
String? _modelName;


  Widget _buildCategoryDropdown() {
    // Placeholder for category list. Consider fetching this list from Firestore if dynamic categories are needed
    List<String> categories = ['Sofa', 'Chair', 'Bed', 'Wardrobe', 'Table', 'Desk', 'Bookshelf', 'Cabinet', 'Dresser', 'Mirror', 'Other'];
    return DropdownButtonFormField<String>(
      value: _productCategory.isNotEmpty ? _productCategory : null,
      hint: Text('Select Category'),
      onChanged: (value) {
        if (value != null) {
          setState(() => _productCategory = value);
        }
      },
      validator: (value) => value == null ? 'Please select a category' : null,
      items: categories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _imageName = Path.basename(pickedFile.path);
      }
    });
  }

  Future<void> _pickModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _modelFile = File(result.files.single.path!);
        _modelName = Path.basename(result.files.single.path!);
      });
    }
  }

  Future<String> _uploadFile(File file, String folder) async {
    String fileName = Path.basename(file.path);
    Reference ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProduct(String imageUrl, String modelUrl) async {
    String userId = _auth.currentUser?.uid ?? ''; // Get the current user's UID
    await FirebaseFirestore.instance.collection('products').add({
      'title': _productName,
    'description': _productDescription,
    'category': _productCategory,
    'color': _productColor,
    'dimensions': _productDimensions,
    'imageUrl': imageUrl,
    'modelUrl': modelUrl,
    'userId': userId,
    'favoritedBy': [],
    'views': 0,
    });
  }

  Future<void> _uploadProduct() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  if (_imageFile == null || _modelFile == null) {
    Fluttertoast.showToast(
      msg: "Please select both an image and a 3D model file",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return; // Exit the function if files are not selected
  }

  setState(() => _isLoading = true);
  try {
    final imageUrl = await _uploadFile(_imageFile!, 'productImages');
    final modelUrl = await _uploadFile(_modelFile!, 'productModels');
    await _saveProduct(imageUrl, modelUrl);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SellerHomePage()),
    );
  } catch (e) {
    print("Error during file upload: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productName = value!;
                },
              ),
              SizedBox(height: 15,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Dimensions'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product dimensions';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productDimensions = value!;
                },
              ),
              SizedBox(height: 15,),
               TextFormField(
                decoration: InputDecoration(labelText: 'Product Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product color';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productColor = value!;
                },
              ),
              SizedBox(height: 15,),

              _buildCategoryDropdown(), //displays the dropdown for category selection
              SizedBox(height: 15,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null, // Set to null for growing vertically
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productDescription = value!;
                },
              ),
              SizedBox(height: 10,),
              // A button to trigger the image picker 
              ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(_imageFile == null ? 'Select Product Image' : 'Image Selected 👍', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _imageFile == null ? Colors.blue : Colors.green, // Change color to indicate selection
                  ),
                ),  // A button to trigger the file picker
                if (_imageName != null) Text("Selected Image: $_imageName"),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: _pickModel,
                    child: Text(_modelFile == null ? 'Select Product 3D Model' : 'Model Selected 👍', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _modelFile == null ? Colors.blue : Colors.green, // Change color to indicate selection
                  ),
                ),
                if (_modelName != null) Text("Selected Model: $_modelName"),
              SizedBox(height: 30,),
              // A button to trigger the upload process
             ElevatedButton(
              onPressed: _isLoading ? null : _uploadProduct,
              child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Upload Product', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
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
