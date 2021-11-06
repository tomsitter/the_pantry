import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_pantry/models/grocery_cart.dart';
import 'package:the_pantry/screens/welcome_screen.dart';
import 'package:the_pantry/widgets/grocery_list.dart';

import '../constants.dart';
import '../widgets/add_item_modal.dart';

User? user;

class GroceryScreen extends StatefulWidget {
  static String id = 'grocery_screen';

  const GroceryScreen({Key? key}) : super(key: key);

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final _auth = FirebaseAuth.instance;
  // CollectionReference messages =
  //     FirebaseFirestore.instance.collection('messages');

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      _auth.authStateChanges().listen(
            (event) => setState(() => user = event),
          );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.blue,
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => AddItemModal(),
        ),
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          // const DrawerHeader(
          //   decoration: BoxDecoration(
          //     color: AppTheme.redBrown,
          //   ),
          //   child: Text('Drawer Header'),
          // ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
          ),
          ListTile(
            title: const Text('Save List'),
            onTap: () async {
              // await FirebaseAuth.instance.signOut();
              // Navigator.pushNamed(context, WelcomeScreen.id);
            },
          ),
        ]),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My grocery list',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${Provider.of<GroceryCart>(context).count} Items',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {},
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(10.0),
                  color: Colors.white,
                  child: const Icon(Icons.shopping_basket,
                      color: AppTheme.blue, size: 40.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 8.0, right: 8.0, bottom: 88.0),
                  child: GroceryList(),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.blue,
    );
  }
}
