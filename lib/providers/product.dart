import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String desc;
  final double price;
  final String imageUrl;
  bool isFav;

  Product({
    required this.id,
    required this.title,
    required this.desc,
    required this.price,
    required this.imageUrl,
    this.isFav = false,
  });

  void _setFavValue(bool newFav) {
    isFav = newFav;
    notifyListeners();
  }

  Future<void> toggleFavStatus(String token, String userID) async {
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/userFav/$userID/$id.json?auth=$token';
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(isFav),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (e) {
      _setFavValue(oldStatus);
    }
  }
}
