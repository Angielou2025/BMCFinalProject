import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para sa Form Fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Para sa image link

  bool _isLoading = false;

  // Firestore Instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Function para mag-upload ng produkto sa Firestore
  Future<void> _uploadProduct() async {
    // 1. I-validate ang form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ipakita ang loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = _imageUrlController.text.trim();

      // 3. Idagdag ang data sa 'products' collection
      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        // I-parse ang price text sa number
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      // 5. Clear fields
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();

    } catch (e) {
      // 6. Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload product: $e')),
      );
    } finally {
      // 7. Itago ang loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Product'),
      ),
      // Nagpapa-scroll para hindi matakpan ng keyboard
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Image URL text field
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    if (!value.startsWith('http')) {
                      return 'Please enter a valid URL (e.g., http://...)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Product Name text field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),

                // Description text field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 16),

                // Price text field
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Upload Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _uploadProduct, // Disabled kung loading
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Upload Product', style: TextStyle(fontSize: 18)),
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