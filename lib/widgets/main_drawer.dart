import 'package:flutter/material.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget get _buildDivider {
    return const Divider(thickness: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Hello!"),
            automaticallyImplyLeading: false,
          ),
          _buildDivider,
          ListTile(
            leading: Icon(Icons.shop),
            title: const Text("Shop"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          _buildDivider,
          ListTile(
            leading: Icon(Icons.payment),
            title: const Text("Orders"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.ROUTE_NAME);
            },
          ),
          _buildDivider,
          ListTile(
            leading: Icon(Icons.edit),
            title: const Text("Manage Products"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                UserProductsScreen.ROUTE_NAME,
                // arguments: null, by default
              );
            },
          ),
        ],
      ),
    );
  }
}
