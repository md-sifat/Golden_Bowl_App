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
  String selectedCategory = 'Food';
  String stockStatus = 'In Stock';

  final List<String> categories = ['Food', 'Drink', 'Dessert', 'Beverage'];
  final List<String> stockStatuses = ['In Stock', 'Out of Stock'];

  Future<void> addItem() async {
    final response = await http.post(
      Uri.parse('https://golden-bowl-server.vercel.app/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _itemNameController.text,
        'image': _imageUrlController.text,
        'category': selectedCategory,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': stockStatus == 'In Stock' ? 1 : 0,
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added successfully')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add item')));
    }
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
            DropdownButton<String>(
              value: stockStatus,
              items:
                  stockStatuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  stockStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: addItem, child: const Text('Add Item')),
          ],
        ),
      ),
    );
  }
}
