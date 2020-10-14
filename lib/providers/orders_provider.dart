import "dart:convert";

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _oreders = [];
  final String authToken;

  Orders(this.authToken, this._oreders);

  List<OrderItem> get orders {
    return [..._oreders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shopapp-ec6a2.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      // no orders in firebase
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData["products"] as List<dynamic>)
              .map((item) => CartItem(
                    id: item["id"],
                    title: item["title"],
                    price: item["price"],
                    quantity: item["quantity"],
                  ))
              .toList(),
        ),
      );
    });

    _oreders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shopapp-ec6a2.firebaseio.com/orders.json?auth=$authToken';
    final timeStamp = DateTime.now();

    final cartProductsSpes = cartProducts
        .map((cartItem) => {
              "id": cartItem.title,
              "title": cartItem.title,
              "price": cartItem.price,
              "quantity": cartItem.quantity,
            })
        .toList();

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "amount": total,
          "dateTime": timeStamp.toIso8601String(),
          "products": cartProductsSpes,
        }),
      );

      final order = OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      );

      _oreders.insert(0, order);
      notifyListeners();
    } catch (error) {
      // note: no need to remove because if the post raised an error
      //  the order won't be added to orders list
      throw error;
    }
  }
}
