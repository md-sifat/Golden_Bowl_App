import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signin_page.dart';
import 'register_page.dart';
import 'addItem.dart';
import 'carts.dart';

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
        '/addItem': (context) => const AddItemPage(),
      },
    );
  }
}

void _dummyFunction(Map<String, dynamic> item) {
  // This is just a dummy function, replace with the actual implementation
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _selectedPage = const HomeContent(addToCart: _dummyFunction);
  List<Map<String, dynamic>> cart = [];
  int cartItemCount = 0;

  void _changePage(Widget page) {
    setState(() {
      _selectedPage = page;
    });
    Navigator.pop(context);
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cart.add(item);
      cartItemCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.white54),
              ),
              child: const Text(
                'Golden Bowl',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Home'),
                    onTap:
                        () => _changePage(
                          const HomeContent(addToCart: _dummyFunction),
                        ),
                  ),
                  ListTile(
                    title: const Text('Carts'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(cartItems: cart),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Add Items'),
                    onTap: () {
                      Navigator.pushNamed(context, '/addItem');
                    },
                  ),
                  ListTile(
                    title: const Text('Orders'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(cartItems: cart),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Golden Bowl'),
        centerTitle: true,
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: const [
                  Icon(Icons.login, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Log In",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Badge(
              badgeContent: Text(
                '$cartItemCount',
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cart),
                ),
              );
            },
          ),
        ],
      ),
      body: HomeContent(addToCart: addToCart),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(Map<String, dynamic>) addToCart;

  const HomeContent({super.key, required this.addToCart});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String selectedCategory = 'All Items';
  List items = [];
  bool isLoading = false;

  final Map<String, String> apiUrls = {
    'All Items': 'https://golden-bowl-server.vercel.app/items',
    'Tea': 'https://golden-bowl-server.vercel.app/items/Tea',
    'Snacks': 'https://golden-bowl-server.vercel.app/items/Snack',
    'Meals': 'https://golden-bowl-server.vercel.app/items/Meal',
    'Drinks': 'https://golden-bowl-server.vercel.app/items/Drink',
  };

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
      final url = apiUrls[selectedCategory]!;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          items = decodedData.isNotEmpty ? decodedData : [];
        });
      } else {
        setState(() {
          items = [];
        });
      }
    } catch (e) {
      setState(() {
        items = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const Center(
                      child: Text(
                        'No Items Found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.6,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double cardHeight = constraints.maxHeight;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: cardHeight * 0.6,
                                    width: double.infinity,
                                    child: Image.network(
                                      items[index]['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: cardHeight * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            items[index]['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 0),
                                          Text(
                                            'Price: \$${items[index]['price']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 0),
                                          const Text(
                                            'In Stock',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 0),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              side: const BorderSide(
                                                color: Colors.transparent,
                                                width: 0,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed:
                                                () => widget.addToCart(
                                                  items[index],
                                                ),
                                            child: const Text(
                                              'Add to Cart',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final Widget child;
  final Widget badgeContent;

  const Badge({super.key, required this.child, required this.badgeContent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.red,
            child: badgeContent,
          ),
        ),
      ],
    );
  }
}
