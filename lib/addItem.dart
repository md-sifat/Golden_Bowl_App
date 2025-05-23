import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _itemNameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String selectedCategory = 'Meal';
  bool _isLoading = false; // Loading state

  final List<String> categories = ['Meal', 'Drink', 'Snack', 'Tea'];
  final String defaultImageUrl = 'https://i.ibb.co.com/fmRrS07/default2.jpg';

  Future<void> addItem() async {
    if (_itemNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    final response = await http.post(
      Uri.parse('https://golden-bowl-server.vercel.app/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _itemNameController.text,
        'image':
            _imageUrlController.text.isNotEmpty
                ? _imageUrlController.text
                : defaultImageUrl, // Use default if empty
        'category': selectedCategory,
        'price': int.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
      }),
    );

    setState(() {
      _isLoading = false; // Hide loader after request completes
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added successfully')));
      _clearFields();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add item')));
    }
  }

  void _clearFields() {
    _itemNameController.clear();
    _imageUrlController.clear();
    _priceController.clear();
    _stockController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCategory,
              items:
                  categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : addItem,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
