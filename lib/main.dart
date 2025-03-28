import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signin_page.dart';
import 'register_page.dart';
import 'addItem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golden Bowl',
      theme: ThemeData.dark(),
      home: const HomePage(),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All Items';
  List items = [];

  final Map<String, String> apiUrls = {
    'All Items': 'https://golden-bowl-server.vercel.app/items',
    'Tea': 'http://localhost:3000/api/tea',
    'Snacks': 'http://localhost:3000/api/snacks',
    'Meals': 'http://localhost:3000/api/meals',
    'Drinks': 'http://localhost:3000/api/drinks',
  };

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final url = apiUrls[selectedCategory]!; // Make sure the URL is valid
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          items = decodedData.isNotEmpty ? decodedData : [];
        });
        debugPrint('Fetched items: ${items.length}');
      } else {
        setState(() {
          items = [];
        });
      }
    } catch (e) {
      setState(() {
        items = [];
      });
      debugPrint('Error fetching items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black87,
                border: Border(bottom: BorderSide(color: Colors.white54)),
              ),
              child: const Text(
                'Golden Bowl',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(title: const Text('Home'), onTap: () {}),
                  ListTile(title: const Text('Carts'), onTap: () {}),
                  ListTile(title: const Text('Add Items'), onTap: () {}),
                  ListTile(title: const Text('Orders'), onTap: () {}),
                  ListTile(title: const Text('Update Item'), onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Golden Bowl'),
        centerTitle: true,
        shape: const Border(bottom: BorderSide(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signin');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Register'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Category:', style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      apiUrls.keys.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                    fetchItems();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  items.isEmpty
                      ? const Center(child: Text('No items available.'))
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    items[index]['image'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 120,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        items[index]['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('Price: \$${items[index]['price']}'),
                                      Text(
                                        items[index]['stock'] > 0
                                            ? 'In Stock'
                                            : 'Out of Stock',
                                        style: TextStyle(
                                          color:
                                              items[index]['stock'] > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
