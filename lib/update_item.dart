import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateItemsPage extends StatefulWidget {
  const UpdateItemsPage({super.key});

  @override
  State<UpdateItemsPage> createState() => _UpdateItemsPageState();
}

class _UpdateItemsPageState extends State<UpdateItemsPage> {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('https://golden-bowl-server.vercel.app/items');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch items: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateItem(
    String itemId,
    Map<String, dynamic> updatedItem,
  ) async {
    try {
      final url = Uri.parse(
        'https://golden-bowl-server.vercel.app/items/$itemId',
      );
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedItem),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully')),
          );
          await fetchItems(); // Refresh the list after update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update item: ${responseData['message']}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
    }
  }

  void showUpdateDialog(BuildContext context, Map<String, dynamic> item) {
    TextEditingController nameController = TextEditingController(
      text: item['name'],
    );
    TextEditingController priceController = TextEditingController(
      text: item['price'].toString(),
    );
    TextEditingController categoryController = TextEditingController(
      text: item['category'],
    );
    TextEditingController imageController = TextEditingController(
      text: item['image'],
    );

Sifat, [4/11/2025 8:29 PM]
showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final updatedItem = {
                    'name': nameController.text,
                    'price':
                        double.tryParse(priceController.text) ?? item['price'],
                    'category': categoryController.text,
                    'image': imageController.text,
                  };
                  updateItem(item['_id'], updatedItem);
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Items'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text('Category: ${item['category']}'),
                          const SizedBox(height: 4),
                          Text('Image URL: ${item['image']}'),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => showUpdateDialog(context, item),
                              child: const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
