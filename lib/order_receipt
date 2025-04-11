import 'package:flutter/material.dart';

class ReceiptGenerator {
  final List<OrderItem> items;
  final double taxRate;
  final double discount;

  ReceiptGenerator({
    required this.items,
    this.taxRate = 0.0,
    this.discount = 0.0,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get tax {
    return subtotal * taxRate;
  }

  double get total {
    return subtotal + tax - discount;
  }

  String generateReceipt() {
    final buffer = StringBuffer();
    buffer.writeln('--- Golden Bowl Receipt ---');
    for (var item in items) {
      buffer.writeln(
        '${item.name} x${item.quantity} - \$${(item.price * item.quantity).toStringAsFixed(2)}',
      );
    }
    buffer.writeln('---------------------------');
    buffer.writeln('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    buffer.writeln('Tax: \$${tax.toStringAsFixed(2)}');
    buffer.writeln('Discount: \$${discount.toStringAsFixed(2)}');
    buffer.writeln('Total: \$${total.toStringAsFixed(2)}');
    buffer.writeln('---------------------------');
    buffer.writeln('Thank you for dining with us!');
    return buffer.toString();
  }
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({required this.name, required this.price, required this.quantity});
}

// testing
void main() {
  final orders = [
    OrderItem(name: 'Fried Rice', price: 8.99, quantity: 2),
    OrderItem(name: 'Spring Rolls', price: 4.50, quantity: 3),
    OrderItem(name: 'Orange Chicken', price: 12.99, quantity: 1),
  ];

  final receiptGenerator = ReceiptGenerator(
    items: orders,
    taxRate: 0.07,
    discount: 5.0,
  );

  print(receiptGenerator.generateReceipt());
}
