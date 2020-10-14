import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../widgets/main_drawer.dart';
import '../screens/cart_screen.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  /*
  @override
  void initState() {
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts(); // wont work
    //
    // one approach: will work
    // Future.delayed(Duration.zero).then((_){
    //   Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    // });
    //
    // secont approach: use didChangeDependecies
    super.initState();
  }
  */

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget appBarBuilder(
    String title,
  ) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              switch (selectedValue) {
                // todo: chenage '_showOnlyFavorites' to be more informative
                //       then boolean - to be able to do several filterings
                case FilterOptions.Favorites:
                  _showOnlyFavorites = true;
                  break;
                case FilterOptions.All:
                  _showOnlyFavorites = false;
                  break;
                //.
                //.
                // add more cases
              }
            });
          },
          itemBuilder: (_) => [
            // todo: replace texts with map or Enum or something
            PopupMenuItem(
              child: Text("Only Favorites"),
              value: FilterOptions.Favorites,
            ),
            PopupMenuItem(
              child: Text("Show All"),
              value: FilterOptions.All,
            ),
          ],
        ),
        Consumer<Cart>(
          builder: (_, cart, onsumerChild) => Badge(
            child: onsumerChild,
            value: cart.itemCount.toString(),
          ),
          child: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.ROUTE_NAME);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder("my shop"),
      drawer: MainDrawer(),
      //backgroundColor: Colors.amber[100],
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
