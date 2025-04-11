// receipt_generator.dart
import 'package:flutter/material.dart';
import 'cart.dart'; // Import the cart.dart file

class ReceiptGenerator {
  final Cart cart; // Reference to the Cart
  final double taxRate;
  final double discount;

  ReceiptGenerator({
    required this.cart,
    this.taxRate = 0.0,
    this.discount = 0.0,
  });

  double get subtotal {
    return cart.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
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
    for (var item in cart.items) {
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
