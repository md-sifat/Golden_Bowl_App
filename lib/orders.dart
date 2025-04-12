import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_receipt.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('https://golden-bowl-server.vercel.app/orders');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch orders: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching orders: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final url = Uri.parse(
        'https://golden-bowl-server.vercel.app/orders/$orderId',
      );
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order $newStatus successfully')),
          );
          await fetchOrders(); // Refresh the list after update

          // Generate and show receipt if order is confirmed
          if (newStatus == 'completed') {
            final order = orders.firstWhere((o) => o['_id'] == orderId);
            final receipt = _generateReceipt(order);
            _showReceiptDialog(receipt);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update order: ${responseData['message']}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating order: $e')));
    }
  }

  String _generateReceipt(dynamic order) {
    final items =
        (order['items'] as List<dynamic>).map((item) {
          return OrderItem(
            name: item['name'],
            price: (item['price'] ?? 0.0).toDouble(),
            quantity: item['quantity'] ?? 1,
          );
        }).toList();

    final receiptGenerator = ReceiptGenerator(
      items: items,
      taxRate: 0.07, // Example tax rate (7%)
      discount: 0.0, // Example discount (adjust as needed)
    );

    return receiptGenerator.generateReceipt();
  }

  void _showReceiptDialog(String receipt) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Order Receipt'),
            content: SingleChildScrollView(
              child: Text(
                receipt,
                style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final items = order['items'] as List<dynamic>;
                  final totalPrice = order['totalPrice'];
                  final status = order['status'];
                  final orderId = order['_id'];
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
                            'Order ID: $orderId',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Items: ${items.map((item) => item['name']).join(', ')}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: $status',
                            style: TextStyle(
                              color:
                                  status == 'pending'
                                      ? Colors.orange
                                      : status == 'completed'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (status == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      () => updateOrderStatus(
                                        orderId,
                                        'completed',
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Confirm'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      () => updateOrderStatus(
                                        orderId,
                                        'canceled',
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
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
