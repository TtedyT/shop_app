import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    // else
    return null;
  }

  String get userId {
    // coul'd check if user authenticated but it's redundent
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String url) async {
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpExeption(responseData["error"]["message"]);
      }
      // no error => set token
      _token = responseData["idToken"];
      _userId = responseData["localId"];

      final numSecsToExpire = int.parse(responseData["expiresIn"]);
      _expiryDate = DateTime.now().add(Duration(seconds: numSecsToExpire));
      notifyListeners();
    } catch (error) {
      throw error;
    }

    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCga56-jU9aYKmCiweX1XXP22ovSdkdsUE';
    // we can pass only the segment in the url that is different

    return _authenticate(email, password, url);
  }

  Future<void> login(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCga56-jU9aYKmCiweX1XXP22ovSdkdsUE';
    // we can pass only the segment in the url that is different

    return _authenticate(email, password, url);
  }
}
