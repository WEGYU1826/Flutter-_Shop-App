import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:state_management/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userID;

  Orders(this.authToken, this.userID, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrder = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderID, orderData) {
        loadedOrder.insert(
          0,
          OrderItem(
            id: orderID,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (items) => CartItem(
                    id: items['id'],
                    title: items['title'],
                    quantity: items['quantity'],
                    price: items['price'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      _orders = loadedOrder;
      notifyListeners();
    } catch (e) {
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://shop-app-fd8a1-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProduct
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity,
                  })
              .toList(),
        }),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProduct,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (e) {}
  }
}
