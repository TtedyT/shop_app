import "dart:convert";

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'product_provider.dart';

class ProductsProvider with ChangeNotifier {
  // List<Product> _items = Dummy.prudocts;
  List<Product> _items = [];
  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  // todo: maby change to 'filterItems' and add more filters
  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shopapp-ec6a2.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      print("response statusCode: ");
      print(response.statusCode);
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        print("error occ");
      }
      print("response statusCode::: ");
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        // no products in firebase
        return;
      }

      final favUrl =
          'https://shopapp-ec6a2.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      print("response statusCode fav: ");
      print(response.statusCode);
      responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        print("error occ");
      }
      print("response statusCode fav::: ");
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];

      extractedData.forEach((productId, productValuesMap) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productValuesMap["title"],
            price: productValuesMap["price"],
            description: productValuesMap["description"],
            imageUrl: productValuesMap["imageUrl"],
            isFavorite: (favoriteData == null
                ? false
                : favoriteData[productId] ?? false),
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Map _mapProductValues(Product product) {
    return {
      "title": product.title,
      "description": product.description,
      "imageUrl": product.imageUrl,
      "price": product.price,
      "creatorId": userId,
    };
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopapp-ec6a2.firebaseio.com/products.json?auth=$authToken';
    try {
      // the response is the cryptic key (will be used as product id)
      final response = await http.post(
        url,
        body: json.encode(
          _mapProductValues(
            product,
          ),
        ),
      );

      print("response statusCode add: ");
      print(response.statusCode);
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        print("error occ");
      }
      print("response statusCode add::: ");

      final newProduct = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  bool _errorOccored(http.Response response) {
    return response.statusCode >= 400;
  }

  void updateProduct(String id, Product updatedProduct) async {
    // max first found the idx and then ovveriden the Product that's there
    final idx = _items.indexWhere((product) => product.id == id);
    if (idx >= 0) {
      final url =
          'https://shopapp-ec6a2.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(
        url,
        body: json.encode({
          // _mapProductValues(updatedProduct), doesn't work :(
          "title": updatedProduct.title,
          "description": updatedProduct.description,
          "imageUrl": updatedProduct.imageUrl,
          "price": updatedProduct.price,
        }),
      );
      _items[idx] = updatedProduct;
      notifyListeners();
    } else {
      print("bla bla...");
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url =
        'https://shopapp-ec6a2.firebaseio.com/products/$productId.json?auth=$authToken';
    final existingProductIdx =
        _items.indexWhere((product) => product.id == productId);
    var existingProduct = _items[existingProductIdx];
    // optimistic delete
    _items.removeAt(existingProductIdx);
    notifyListeners();

    final response = await http.delete(url);
    if (_errorOccored(response)) {
      // roll back
      _items.insert(existingProductIdx, existingProduct);
      notifyListeners();
      throw HttpExeption("Could not delete product");
    }
    // else: delete succeded
    existingProduct = null;
  }
}
