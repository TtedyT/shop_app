import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show Cart;
import '../widgets/cart_item.dart';
// import '../widgets/cart_item.dart' as ci;
// can be done to prevent name ambiguity ("CartItem") **
import '../providers/orders_provider.dart';

class CartScreen extends StatelessWidget {
  static const ROUTE_NAME = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cart.itemCount,
                // itemBuilder: (context, idx) => ci.CartItem(
                // ** note (next to imports)
                itemBuilder: (context, idx) {
                  final cartItemsList = cart.items.values.toList();
                  return CartItem(
                    id: cartItemsList[idx].id, // cart item id
                    productId: cart.items.keys.toList()[idx], // item id
                    //  // note here is key(not value)
                    title: cartItemsList[idx].title,
                    quantity: cartItemsList[idx].quantity,
                    price: cartItemsList[idx].price,
                  );
                }),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  bool _canOrder(double totalAmount) {
    return totalAmount != 0;
  }

  Widget _alertMsg(BuildContext ctx) {
    return AlertDialog(
      title: Text("An Error!"),
      content: Text("Something went wrong :("),
      actions: [
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text("ORDER NOW"),
      onPressed: (_canOrder(widget.cart.totalAmount) || _isLoading)
          ? () async {
              // todo: maby add onfrimation msg that oreder placed
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false)
                  .addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              )
                  .catchError((error) async {
                await showDialog<Null>(
                  context: context,
                  builder: (ctx) => _alertMsg(ctx),
                );
              });
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            }
          : null, // can't order (no items)
      textColor: Theme.of(context).primaryColor,
    );
  }
}
