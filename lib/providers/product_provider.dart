import "dart:convert";

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  bool _errorOccored(http.Response response) {
    return response.statusCode >= 400;
  }

  void _setFavoriteValue(bool value) {
    isFavorite = value;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    final url =
        'https://shopapp-ec6a2.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    _setFavoriteValue(!isFavorite);
    // isFavorite = !isFavorite;
    // notifyListeners();

    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (_errorOccored(response)) {
        _setFavoriteValue(oldStatus);
      }
    } catch (error) {
      // print("err");
      // undo:
      _setFavoriteValue(oldStatus);
    }
  }
}
