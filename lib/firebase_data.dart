class FirebaseData {
  static const firebaseUrl = "https://shopapp-ec6a2.firebaseio.com";

  String getUrl(String urlEnding) {
    return firebaseUrl + urlEnding;
  }
}
