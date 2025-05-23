import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signin_page.dart';
import 'register_page.dart';
import 'addItem.dart';
import 'carts.dart';
import 'orders.dart';
import 'update_item.dart';

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
  Widget _selectedPage = const HomeContent(
    addToCart: _dummyFunction,
    isLoggedIn: false,
    userRole: null,
  );
  List<Map<String, dynamic>> cart = [];
  int cartItemCount = 0;
  Map<String, dynamic>? currentUser;
  String? currentRole;
  bool? isLoggedIn;
  bool isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    setState(() {
      isLoadingSession = true;
    });
    try {
      final url = Uri.parse(
        'https://golden-bowl-server.vercel.app/sessions/active',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final sessionData = jsonDecode(response.body);
        setState(() {
          isLoggedIn = sessionData['loggedIn'] ?? false;
          currentUser = sessionData['user'];
          currentRole = sessionData['role'];
        });
      } else {
        setState(() {
          isLoggedIn = false;
          currentUser = null;
          currentRole = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoggedIn = false;
        currentUser = null;
        currentRole = null;
      });
    } finally {
      setState(() {
        isLoadingSession = false;
      });
    }
  }

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

  Future<void> _logout() async {
    try {
      final url = Uri.parse(
        'https://golden-bowl-server.vercel.app/sessions/active',
      );
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': currentUser,
          'role': currentRole,
          'loggedIn': false,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          cart.clear();
          cartItemCount = 0;
          isLoggedIn = false;
        });
        await _fetchSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to logout')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.transparent),
              ),
              child: const Text(
                'Golden Bowl',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: InkWell(
                      onTap:
                          () => _changePage(
                            const HomeContent(
                              addToCart: _dummyFunction,
                              isLoggedIn: false,
                              userRole: null,
                            ),
                          ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Home',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                    title: InkWell(
                      onTap:
                          isLoggedIn == true && currentRole == 'Customer'
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CartPage(
                                          cartItems: cart,
                                          currentUser: currentUser,
                                        ),
                                  ),
                                );
                              }
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Carts',
                          style: TextStyle(
                            color:
                                isLoggedIn == true && currentRole == 'Customer'
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.white),
                    title: InkWell(
                      onTap:
                          isLoggedIn == true && currentRole == 'Manager'
                              ? () => Navigator.pushNamed(context, '/addItem')
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Add Items',
                          style: TextStyle(
                            color:
                                isLoggedIn == true && currentRole == 'Manager'
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update, color: Colors.white),
                    title: InkWell(
                      onTap:
                          isLoggedIn == true && currentRole == 'Manager'
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const UpdateItemsPage(),
                                  ),
                                );
                              }
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Update Items',
                          style: TextStyle(
                            color:
                                isLoggedIn == true && currentRole == 'Manager'
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.white),
                    title: InkWell(
                      onTap:
                          isLoggedIn == true && currentRole == 'Chef'
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrdersPage(),
                                  ),
                                );
                              }
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Orders',
                          style: TextStyle(
                            color:
                                isLoggedIn == true && currentRole == 'Chef'
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
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
          if (isLoggedIn == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currentUser != null
                    ? currentUser!['username'] ?? 'User'
                    : 'User',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: _logout,
            ),
          ],
          if (isLoggedIn != true)
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
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
            onPressed:
                isLoggedIn == true && currentRole == 'Customer'
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CartPage(
                                cartItems: cart,
                                currentUser: currentUser,
                              ),
                        ),
                      );
                    }
                    : null,
          ),
        ],
      ),
      body: HomeContent(
        addToCart:
            isLoggedIn == true && currentRole == 'Customer'
                ? addToCart
                : _dummyFunction,
        isLoggedIn: isLoggedIn ?? false,
        userRole: currentRole,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(Map<String, dynamic>) addToCart;
  final bool isLoggedIn;
  final String? userRole;

  const HomeContent({
    super.key,
    required this.addToCart,
    required this.isLoggedIn,
    required this.userRole,
  });

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
                                            onPressed: () {
                                              if (widget.isLoggedIn &&
                                                  widget.userRole ==
                                                      'Customer') {
                                                widget.addToCart(items[index]);
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Only customers can place an order',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
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
