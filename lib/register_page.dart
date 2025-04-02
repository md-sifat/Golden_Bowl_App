import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedRole;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;

  // Email Regex: standard email format
  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password Regex: at least 8 characters, 1 uppercase, 1 lowercase, 1 number
  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
  );

  bool _isFormValid() {
    return _emailError == null &&
        _passwordError == null &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        selectedRole != null;
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_emailRegex.hasMatch(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (!_passwordRegex.hasMatch(value)) {
        _passwordError =
            'Password must be 8+ characters with uppercase, lowercase, and number';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _registerUser() async {
    if (!_isFormValid()) return;

    final url = Uri.parse('https://golden-bowl-server.vercel.app/users');
    final body = jsonEncode({
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'role': selectedRole,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username'),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Email'),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorText: _emailError,
              ),
              onChanged: _validateEmail,
            ),
            const SizedBox(height: 16),
            const Text('Password'),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Toggle visibility
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorText: _passwordError,
                suffixIcon: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _isPasswordVisible = true; // Show password on hold
                    });
                  },
                  onLongPressUp: () {
                    setState(() {
                      _isPasswordVisible = false; // Hide when released
                    });
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
              onChanged: _validatePassword,
            ),
            const SizedBox(height: 16),
            const Text('Select Role:'),
            DropdownButton<String>(
              value: selectedRole,
              items:
                  ['Chef', 'Customer', 'Manager'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedRole = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _isFormValid() ? _registerUser : null, // Call API if valid
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
