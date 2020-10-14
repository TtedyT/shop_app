import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_sreen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());
//

class MyApp extends StatelessWidget {
  // static const HOME_ROUTE = "/";
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          // ChangeNotifierProxyProvider:
          // lets us define a provider depends on another provider,
          // the provider that depends need to be lower in the providers list
          update: (ctx, auth, previousProducts) => ProductsProvider(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          // create: null, // if have an error 'missimg create'
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'DeliMeals',
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.deepOrange,
            primarySwatch: Colors.blue,
            fontFamily: "Lato",
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            //"/": (ctx) => ProductsOverviewScreen(),
            AuthScreen.ROUTE_NAME: (ctx) => AuthScreen(),
            ProductDetailScreen.ROUTE_NAME: (ctx) => ProductDetailScreen(),
            CartScreen.ROUTE_NAME: (ctx) => CartScreen(),
            OrdersScreen.ROUTE_NAME: (ctx) => OrdersScreen(),
            UserProductsScreen.ROUTE_NAME: (ctx) => UserProductsScreen(),
            EditProductScreen.ROUTE_NAME: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
