import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
}
